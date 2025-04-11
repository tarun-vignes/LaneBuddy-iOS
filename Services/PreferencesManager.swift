import Foundation
import CloudKit

class PreferencesManager {
    static let shared = PreferencesManager()
    private let defaults = UserDefaults.standard
    private let coreData = CoreDataManager.shared
    
    // Keys for UserDefaults
    private enum Keys {
        static let avoidHighways = "avoidHighways"
        static let avoidTolls = "avoidTolls"
        static let preferredLanePosition = "preferredLanePosition"
        static let voiceEnabled = "voiceEnabled"
        static let vibrationEnabled = "vibrationEnabled"
    }
    
    private init() {
        // Set default values if not already set
        if !defaults.bool(forKey: "preferencesInitialized") {
            defaults.set(false, forKey: Keys.avoidHighways)
            defaults.set(false, forKey: Keys.avoidTolls)
            defaults.set("middle", forKey: Keys.preferredLanePosition)
            defaults.set(true, forKey: Keys.voiceEnabled)
            defaults.set(true, forKey: Keys.vibrationEnabled)
            defaults.set(true, forKey: "preferencesInitialized")
        }
        
        // Sync with CoreData
        syncWithCoreData()
    }
    
    // MARK: - Preferences Access
    
    var avoidHighways: Bool {
        get { defaults.bool(forKey: Keys.avoidHighways) }
        set {
            defaults.set(newValue, forKey: Keys.avoidHighways)
            updateCoreData()
        }
    }
    
    var avoidTolls: Bool {
        get { defaults.bool(forKey: Keys.avoidTolls) }
        set {
            defaults.set(newValue, forKey: Keys.avoidTolls)
            updateCoreData()
        }
    }
    
    var preferredLanePosition: String {
        get { defaults.string(forKey: Keys.preferredLanePosition) ?? "middle" }
        set {
            defaults.set(newValue, forKey: Keys.preferredLanePosition)
            updateCoreData()
        }
    }
    
    var voiceEnabled: Bool {
        get { defaults.bool(forKey: Keys.voiceEnabled) }
        set {
            defaults.set(newValue, forKey: Keys.voiceEnabled)
            updateCoreData()
        }
    }
    
    var vibrationEnabled: Bool {
        get { defaults.bool(forKey: Keys.vibrationEnabled) }
        set {
            defaults.set(newValue, forKey: Keys.vibrationEnabled)
            updateCoreData()
        }
    }
    
    // MARK: - Sync
    
    private func syncWithCoreData() {
        let preferences = coreData.getPreferences()
        defaults.set(preferences.avoidHighways, forKey: Keys.avoidHighways)
        defaults.set(preferences.avoidTolls, forKey: Keys.avoidTolls)
        defaults.set(preferences.preferredLanePosition, forKey: Keys.preferredLanePosition)
        defaults.set(preferences.voiceEnabled, forKey: Keys.voiceEnabled)
        defaults.set(preferences.vibrationEnabled, forKey: Keys.vibrationEnabled)
    }
    
    private func updateCoreData() {
        coreData.updatePreferences(
            avoidHighways: avoidHighways,
            avoidTolls: avoidTolls,
            preferredLanePosition: preferredLanePosition,
            voiceEnabled: voiceEnabled,
            vibrationEnabled: vibrationEnabled
        )
    }
    
    // MARK: - iCloud Sync
    
    func syncWithiCloud() {
        let container = CKContainer.default()
        let database = container.privateCloudDatabase
        
        let record = CKRecord(recordType: "UserPreferences")
        record["avoidHighways"] = avoidHighways as CKRecordValue
        record["avoidTolls"] = avoidTolls as CKRecordValue
        record["preferredLanePosition"] = preferredLanePosition as CKRecordValue
        record["voiceEnabled"] = voiceEnabled as CKRecordValue
        record["vibrationEnabled"] = vibrationEnabled as CKRecordValue
        
        database.save(record) { record, error in
            if let error = error {
                print("Error saving to iCloud: \(error)")
            }
        }
    }
    
    func loadFromiCloud() {
        let container = CKContainer.default()
        let database = container.privateCloudDatabase
        
        let query = CKQuery(recordType: "UserPreferences", predicate: NSPredicate(value: true))
        
        database.perform(query, inZoneWith: nil) { [weak self] records, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading from iCloud: \(error)")
                return
            }
            
            if let record = records?.first {
                DispatchQueue.main.async {
                    self.avoidHighways = record["avoidHighways"] as? Bool ?? false
                    self.avoidTolls = record["avoidTolls"] as? Bool ?? false
                    self.preferredLanePosition = record["preferredLanePosition"] as? String ?? "middle"
                    self.voiceEnabled = record["voiceEnabled"] as? Bool ?? true
                    self.vibrationEnabled = record["vibrationEnabled"] as? Bool ?? true
                }
            }
        }
    }
}
