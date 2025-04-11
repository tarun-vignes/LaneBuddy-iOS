import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LaneBuddy")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Routes
    
    func saveRoute(startLocation: CLLocationCoordinate2D, startName: String?,
                  endLocation: CLLocationCoordinate2D, endName: String?) {
        let route = SavedRoute(context: context)
        route.id = UUID()
        route.startLatitude = startLocation.latitude
        route.startLongitude = startLocation.longitude
        route.startName = startName
        route.endLatitude = endLocation.latitude
        route.endLongitude = endLocation.longitude
        route.endName = endName
        route.lastUsed = Date()
        route.frequentlyUsed = false
        
        saveContext()
    }
    
    func getSavedRoutes() -> [SavedRoute] {
        let request: NSFetchRequest<SavedRoute> = SavedRoute.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SavedRoute.lastUsed, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching routes: \(error)")
            return []
        }
    }
    
    func deleteRoute(_ route: SavedRoute) {
        context.delete(route)
        saveContext()
    }
    
    // MARK: - Preferences
    
    func getPreferences() -> UserPreferences {
        let request: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()
        request.fetchLimit = 1
        
        do {
            if let preferences = try context.fetch(request).first {
                return preferences
            }
        } catch {
            print("Error fetching preferences: \(error)")
        }
        
        // Create default preferences if none exist
        let preferences = UserPreferences(context: context)
        preferences.id = UUID()
        preferences.preferredLanePosition = "middle"
        preferences.avoidHighways = false
        preferences.avoidTolls = false
        preferences.voiceEnabled = true
        preferences.vibrationEnabled = true
        saveContext()
        
        return preferences
    }
    
    func updatePreferences(avoidHighways: Bool? = nil,
                         avoidTolls: Bool? = nil,
                         preferredLanePosition: String? = nil,
                         voiceEnabled: Bool? = nil,
                         vibrationEnabled: Bool? = nil) {
        let preferences = getPreferences()
        
        if let avoidHighways = avoidHighways {
            preferences.avoidHighways = avoidHighways
        }
        if let avoidTolls = avoidTolls {
            preferences.avoidTolls = avoidTolls
        }
        if let preferredLanePosition = preferredLanePosition {
            preferences.preferredLanePosition = preferredLanePosition
        }
        if let voiceEnabled = voiceEnabled {
            preferences.voiceEnabled = voiceEnabled
        }
        if let vibrationEnabled = vibrationEnabled {
            preferences.vibrationEnabled = vibrationEnabled
        }
        
        saveContext()
    }
}
