import Foundation

struct User: Codable {
    let id: String
    let email: String
    var preferences: UserPreferences
    var savedRoutes: [SavedRoute]
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case preferences
        case savedRoutes
        case createdAt
    }
}

struct UserPreferences: Codable {
    var defaultNavigation: NavigationPreferences
    var notifications: NotificationPreferences
    
    var dictionary: [String: Any] {
        [
            "defaultNavigation": defaultNavigation.dictionary,
            "notifications": notifications.dictionary
        ]
    }
}

struct NavigationPreferences: Codable {
    var avoidHighways: Bool
    var avoidTolls: Bool
    var preferredLanePosition: LanePosition
    
    var dictionary: [String: Any] {
        [
            "avoidHighways": avoidHighways,
            "avoidTolls": avoidTolls,
            "preferredLanePosition": preferredLanePosition.rawValue
        ]
    }
}

struct NotificationPreferences: Codable {
    var voice: Bool
    var vibration: Bool
    
    var dictionary: [String: Any] {
        [
            "voice": voice,
            "vibration": vibration
        ]
    }
}

enum LanePosition: String, Codable {
    case left
    case middle
    case right
}

struct SavedRoute: Codable {
    let id: String?
    var startLocation: Location
    var endLocation: Location
    var frequentlyUsed: Bool
    var lastUsed: Date?
    
    var dictionary: [String: Any] {
        [
            "startLocation": startLocation.dictionary,
            "endLocation": endLocation.dictionary,
            "frequentlyUsed": frequentlyUsed,
            "lastUsed": lastUsed?.timeIntervalSince1970 ?? 0
        ]
    }
}

struct Location: Codable {
    var latitude: Double
    var longitude: Double
    var name: String?
    
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude
        ]
        if let name = name {
            dict["name"] = name
        }
        return dict
    }
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}
