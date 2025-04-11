import Foundation
import Combine

class SyncService {
    static let shared = SyncService()
    private let networkService = NetworkService.shared
    private var syncTimer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    private init() {
        setupBackgroundSync()
    }
    
    func setupBackgroundSync() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
    }
    
    @objc private func applicationDidEnterBackground() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        
        syncTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task {
                await self?.syncData()
            }
        }
    }
    
    @objc private func applicationWillEnterForeground() {
        syncTimer?.invalidate()
        syncTimer = nil
        endBackgroundTask()
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    func syncData() async {
        await syncRoutes()
        await syncTrafficReports()
        await syncPreferences()
    }
    
    private func syncRoutes() async {
        do {
            let localRoutes = try await LocalStorage.shared.getSavedRoutes()
            let serverRoutes = try await networkService.getProfile().savedRoutes
            
            // Find routes to upload
            let routesToUpload = localRoutes.filter { localRoute in
                !serverRoutes.contains { $0.id == localRoute.id }
            }
            
            // Upload new routes
            for route in routesToUpload {
                try await networkService.saveRoute(route)
            }
            
            // Update local storage with server routes
            try await LocalStorage.shared.updateSavedRoutes(serverRoutes)
        } catch {
            print("Error syncing routes:", error)
        }
    }
    
    private func syncTrafficReports() async {
        do {
            let location = await LocationService.shared.getCurrentLocation()
            guard let location = location else { return }
            
            let nearbyTraffic = try await networkService.getNearbyTraffic(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                radius: 5000
            )
            
            // Update local traffic cache
            try await LocalStorage.shared.updateTrafficReports(nearbyTraffic)
        } catch {
            print("Error syncing traffic:", error)
        }
    }
    
    private func syncPreferences() async {
        do {
            let localPreferences = try await LocalStorage.shared.getUserPreferences()
            try await networkService.updatePreferences(localPreferences)
        } catch {
            print("Error syncing preferences:", error)
        }
    }
    
    func reportTraffic(at location: CLLocationCoordinate2D, level: String, description: String?) async {
        do {
            let report = try await networkService.reportTraffic(
                latitude: location.latitude,
                longitude: location.longitude,
                congestionLevel: level,
                description: description
            )
            try await LocalStorage.shared.addTrafficReport(report)
        } catch {
            print("Error reporting traffic:", error)
        }
    }
}
