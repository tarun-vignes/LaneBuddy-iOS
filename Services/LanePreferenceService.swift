import Foundation
import CoreLocation

// Represents a road segment for lane preference tracking
struct RoadSegmentIdentifier: Codable, Hashable {
    let startCoordinate: CLLocationCoordinate2D
    let endCoordinate: CLLocationCoordinate2D
    let laneCount: Int
    let name: String?
    
    // Implement Codable for CLLocationCoordinate2D
    enum CodingKeys: String, CodingKey {
        case startLat, startLon, endLat, endLon, laneCount, name
    }
    
    init(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, laneCount: Int, name: String? = nil) {
        self.startCoordinate = start
        self.endCoordinate = end
        self.laneCount = laneCount
        self.name = name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let startLat = try container.decode(Double.self, forKey: .startLat)
        let startLon = try container.decode(Double.self, forKey: .startLon)
        let endLat = try container.decode(Double.self, forKey: .endLat)
        let endLon = try container.decode(Double.self, forKey: .endLon)
        
        startCoordinate = CLLocationCoordinate2D(latitude: startLat, longitude: startLon)
        endCoordinate = CLLocationCoordinate2D(latitude: endLat, longitude: endLon)
        laneCount = try container.decode(Int.self, forKey: .laneCount)
        name = try container.decodeIfPresent(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startCoordinate.latitude, forKey: .startLat)
        try container.encode(startCoordinate.longitude, forKey: .startLon)
        try container.encode(endCoordinate.latitude, forKey: .endLat)
        try container.encode(endCoordinate.longitude, forKey: .endLon)
        try container.encode(laneCount, forKey: .laneCount)
        try container.encodeIfPresent(name, forKey: .name)
    }
}

// Records a single instance of lane usage
struct LaneUsageRecord: Codable {
    let timestamp: Date
    let lanePosition: Int
    let timeOfDay: Int // Hour of day (0-23)
    let dayOfWeek: Int // (1-7, Sunday = 1)
    let wasSuccessful: Bool // Did this lane choice work well?
}

// Manages lane preference learning and prediction
class LanePreferenceService: ObservableObject {
    private var preferences: [RoadSegmentIdentifier: [LaneUsageRecord]] = [:]
    private let storage = UserDefaults.standard
    private let storageKey = "lanePreferences"
    
    init() {
        loadPreferences()
    }
    
    // Record a lane usage
    func recordLaneUsage(segment: RoadSegmentIdentifier, lane: Int, successful: Bool = true) {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let dayOfWeek = calendar.component(.weekday, from: now)
        
        let record = LaneUsageRecord(
            timestamp: now,
            lanePosition: lane,
            timeOfDay: hour,
            dayOfWeek: dayOfWeek,
            wasSuccessful: successful
        )
        
        if preferences[segment] != nil {
            preferences[segment]?.append(record)
        } else {
            preferences[segment] = [record]
        }
        
        savePreferences()
    }
    
    // Get preferred lane for a segment
    func getPreferredLane(for segment: RoadSegmentIdentifier) -> Int? {
        guard let records = preferences[segment], !records.isEmpty else {
            return nil
        }
        
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        let currentDayOfWeek = calendar.component(.weekday, from: now)
        
        // Filter records to those that were successful and relevant to current time
        let relevantRecords = records.filter { record in
            record.wasSuccessful &&
            abs(record.timeOfDay - currentHour) <= 2 && // Within 2 hours of current time
            (record.dayOfWeek == currentDayOfWeek || // Same day of week
             record.timestamp.timeIntervalSinceNow > -7 * 24 * 3600) // Or within last week
        }
        
        if relevantRecords.isEmpty {
            return nil
        }
        
        // Count occurrences of each lane
        var laneCounts: [Int: Int] = [:]
        for record in relevantRecords {
            laneCounts[record.lanePosition, default: 0] += 1
        }
        
        // Return most frequently used lane
        return laneCounts.max(by: { $0.value < $1.value })?.key
    }
    
    // Find nearby learned segments
    func findNearbySegment(at location: CLLocationCoordinate2D, radius: CLLocationDistance = 50) -> RoadSegmentIdentifier? {
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        return preferences.keys.first { segment in
            let segmentStart = CLLocation(latitude: segment.startCoordinate.latitude,
                                        longitude: segment.startCoordinate.longitude)
            let segmentEnd = CLLocation(latitude: segment.endCoordinate.latitude,
                                      longitude: segment.endCoordinate.longitude)
            
            return userLocation.distance(from: segmentStart) < radius ||
                   userLocation.distance(from: segmentEnd) < radius
        }
    }
    
    // Save preferences to persistent storage
    private func savePreferences() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            storage.set(encoded, forKey: storageKey)
        }
    }
    
    // Load preferences from persistent storage
    private func loadPreferences() {
        if let data = storage.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([RoadSegmentIdentifier: [LaneUsageRecord]].self, from: data) {
            preferences = decoded
        }
    }
    
    // Clear all preferences (for testing)
    func clearPreferences() {
        preferences.removeAll()
        storage.removeObject(forKey: storageKey)
    }
}
