import Foundation
import MapKit
import CoreLocation
import AVFoundation
import MapLibre
import MapLibreNavigation

class NavigationService: NSObject, ObservableObject {
    @Published var route: MLNRoute?
    @Published var currentStep: MLNRouteStep?
    @Published var nextStep: MLNRouteStep?
    @Published var distanceToNextStep: CLLocationDistance?
    @Published var isNavigating = false
    @Published var offlinePackages: [MLNOfflinePackage] = []
    
    private let navigationService: MLNNavigationService
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var lastAnnouncementTime: Date?
    private let minimumAnnouncementInterval: TimeInterval = 10
    
    override init() {
        self.navigationService = MLNNavigationService()
        super.init()
        self.navigationService.delegate = self
    }
    
    // Calculate route between points
    func calculateRoute(from start: CLLocationCoordinate2D, 
                      to destination: CLLocationCoordinate2D) async throws -> MLNRoute {
        let options = MLNNavigationRouteOptions(origin: start, destination: destination)
        options.includesAlternativeRoutes = true
        options.routeShapeResolution = .full
        
        return try await withCheckedThrowingContinuation { continuation in
            navigationService.calculateRoutes(options) { routes, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let route = routes?.first {
                    continuation.resume(returning: route)
                } else {
                    continuation.resume(throwing: NSError(domain: "NavigationService",
                                                       code: -1,
                                                       userInfo: [NSLocalizedDescriptionKey: "No route found"]))
                }
            }
        }
    }
    
    // Start navigation along route
    func startNavigation(route: MLNRoute) {
        self.route = route
        self.isNavigating = true
        navigationService.start(route: route)
        
        // Set initial steps
        if let legs = route.legs.first {
            self.currentStep = legs.steps.first
            self.nextStep = legs.steps.count > 1 ? legs.steps[1] : nil
            announceNextStep()
        }
    }
    
    // Stop navigation
    func stopNavigation() {
        navigationService.stop()
        self.isNavigating = false
        self.route = nil
        self.currentStep = nil
        self.nextStep = nil
        self.distanceToNextStep = nil
    }
    
    // Download offline maps for a region
    func downloadOfflineMaps(for region: MLNCoordinateBounds) async throws {
        let options = MLNOfflinePackageOptions(bounds: region, 
                                              minimumZoomLevel: 10,
                                              maximumZoomLevel: 15)
        
        return try await withCheckedThrowingContinuation { continuation in
            navigationService.downloadOfflinePackage(for: options) { package, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let package = package {
                    self.offlinePackages.append(package)
                    continuation.resume()
                } else {
                    continuation.resume(throwing: NSError(domain: "NavigationService",
                                                       code: -1,
                                                       userInfo: [NSLocalizedDescriptionKey: "Failed to download offline package"]))
                }
            }
        }
    }
    
    // Update navigation state based on user location
    func updateNavigation(at location: CLLocation) {
        guard isNavigating, let route = route else { return }
        
        // Find current step based on location
        if let (step, nextStep, distance) = findCurrentStep(at: location) {
            self.currentStep = step
            self.nextStep = nextStep
            self.distanceToNextStep = distance
            
            // Announce if needed
            if shouldAnnounceStep(distance: distance) {
                announceNextStep()
            }
        }
    }
    
    // Find the current step based on user location
    private func findCurrentStep(at location: CLLocation) -> (MKRoute.Step, MKRoute.Step?, CLLocationDistance)? {
        guard let route = route else { return nil }
        
        // Find closest step
        var closestStep = route.steps[0]
        var closestDistance = Double.infinity
        var stepIndex = 0
        
        for (index, step) in route.steps.enumerated() {
            if let stepLocation = step.polyline.coordinate() {
                let distance = location.distance(from: CLLocation(latitude: stepLocation.latitude,
                                                               longitude: stepLocation.longitude))
                if distance < closestDistance {
                    closestDistance = distance
                    closestStep = step
                    stepIndex = index
                }
            }
        }
        
        // Get next step if available
        let nextStep = stepIndex + 1 < route.steps.count ? route.steps[stepIndex + 1] : nil
        
        return (closestStep, nextStep, closestDistance)
    }
    
    // Determine if we should announce the next step
    private func shouldAnnounceStep(distance: CLLocationDistance) -> Bool {
        guard let lastAnnouncement = lastAnnouncementTime else { return true }
        
        // Announce based on distance and time since last announcement
        let timeSinceLastAnnouncement = Date().timeIntervalSince(lastAnnouncement)
        
        return timeSinceLastAnnouncement >= minimumAnnouncementInterval &&
            (distance <= 200 || // Announce when within 200m
             distance <= 500 && distance.truncatingRemainder(dividingBy: 100) < 10) // Announce every 100m when within 500m
    }
    
    // Announce next navigation step
    private func announceNextStep() {
        guard let nextStep = nextStep,
              let distance = distanceToNextStep else { return }
        
        var announcement = ""
        
        if distance > 1000 {
            announcement = "In \(Int(distance/100)/10) kilometers, \(nextStep.instructions)"
        } else {
            announcement = "In \(Int(distance)) meters, \(nextStep.instructions)"
        }
        
        // Add lane guidance if needed
        if nextStep.instructions.contains("right") {
            announcement += " Use the right lane."
        } else if nextStep.instructions.contains("left") {
            announcement += " Use the left lane."
        }
        
        speak(announcement)
        lastAnnouncementTime = Date()
    }
    
    // Speak the announcement
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        speechSynthesizer.speak(utterance)
    }
}
