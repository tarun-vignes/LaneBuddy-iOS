import Foundation
import CoreData

class LocalStorage {
    static let shared = LocalStorage()
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    private init() {
        container = NSPersistentContainer(name: "LaneBuddy")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        context = container.viewContext
    }
    
    // MARK: - Routes
    
    func getSavedRoutes() async throws -> [SavedRoute] {
        let request = NSFetchRequest<CDSavedRoute>(entityName: "CDSavedRoute")
        let cdRoutes = try context.fetch(request)
        return cdRoutes.map { $0.toModel() }
    }
    
    func updateSavedRoutes(_ routes: [SavedRoute]) async throws {
        // Clear existing routes
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDSavedRoute")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(deleteRequest)
        
        // Add new routes
        for route in routes {
            let cdRoute = CDSavedRoute(context: context)
            cdRoute.update(from: route)
        }
        
        try context.save()
    }
    
    // MARK: - Traffic Reports
    
    func getTrafficReports() async throws -> [TrafficReport] {
        let request = NSFetchRequest<CDTrafficReport>(entityName: "CDTrafficReport")
        let cdReports = try context.fetch(request)
        return cdReports.map { $0.toModel() }
    }
    
    func updateTrafficReports(_ reports: [TrafficReport]) async throws {
        // Remove expired reports
        let oldRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDTrafficReport")
        oldRequest.predicate = NSPredicate(
            format: "createdAt < %@",
            Date().addingTimeInterval(-1800) as NSDate
        )
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: oldRequest)
        try context.execute(deleteRequest)
        
        // Add new reports
        for report in reports {
            let cdReport = CDTrafficReport(context: context)
            cdReport.update(from: report)
        }
        
        try context.save()
    }
    
    func addTrafficReport(_ report: TrafficReport) async throws {
        let cdReport = CDTrafficReport(context: context)
        cdReport.update(from: report)
        try context.save()
    }
    
    // MARK: - User Preferences
    
    func getUserPreferences() async throws -> UserPreferences {
        let request = NSFetchRequest<CDUserPreferences>(entityName: "CDUserPreferences")
        request.fetchLimit = 1
        
        let preferences = try context.fetch(request).first ?? CDUserPreferences(context: context)
        return preferences.toModel()
    }
    
    func updateUserPreferences(_ preferences: UserPreferences) async throws {
        let request = NSFetchRequest<CDUserPreferences>(entityName: "CDUserPreferences")
        let existing = try context.fetch(request)
        
        let cdPreferences = existing.first ?? CDUserPreferences(context: context)
        cdPreferences.update(from: preferences)
        
        try context.save()
    }
    
    // MARK: - Save Context
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context:", error)
            }
        }
    }
}
