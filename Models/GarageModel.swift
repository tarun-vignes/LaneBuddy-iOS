import Foundation
import CoreLocation

// Represents a parking spot
struct ParkingSpot: Identifiable, Codable {
    let id: String
    let level: Int
    let coordinates: GarageCoordinate
    let type: SpotType
    var isOccupied: Bool
    
    enum SpotType: String, Codable {
        case standard
        case handicap
        case electric
        case compact
    }
}

// Coordinate system within garage
struct GarageCoordinate: Codable {
    let x: Double // Distance from left wall in meters
    let y: Double // Distance from entrance in meters
}

// Represents a level in the parking garage
struct GarageLevel: Identifiable, Codable {
    let id: Int // Floor number (e.g., 1, 2, -1 for basement)
    let name: String // Display name (e.g., "Level 1", "B1")
    let spots: [ParkingSpot]
    let layout: GarageLayout
    
    var availableSpots: Int {
        spots.filter { !$0.isOccupied }.count
    }
}

// Represents the garage layout
struct GarageLayout: Codable {
    let width: Double // Width in meters
    let length: Double // Length in meters
    let driveLanes: [DriveLane]
    let walls: [Wall]
    let entrances: [Entrance]
}

// Represents a drive lane in the garage
struct DriveLane: Codable {
    let start: GarageCoordinate
    let end: GarageCoordinate
    let width: Double
    let direction: DriveDirection
    
    enum DriveDirection: String, Codable {
        case oneWay
        case twoWay
    }
}

// Represents a wall or barrier
struct Wall: Codable {
    let start: GarageCoordinate
    let end: GarageCoordinate
    let type: WallType
    
    enum WallType: String, Codable {
        case solid
        case partial
        case pillar
    }
}

// Represents an entrance/exit
struct Entrance: Codable {
    let location: GarageCoordinate
    let type: EntranceType
    
    enum EntranceType: String, Codable {
        case vehicleEntry
        case vehicleExit
        case pedestrian
    }
}

// Main garage model
class GarageModel: ObservableObject {
    @Published var levels: [GarageLevel]
    @Published var currentLevel: Int
    let location: CLLocation
    let name: String
    
    init(name: String, location: CLLocation) {
        self.name = name
        self.location = location
        self.levels = []
        self.currentLevel = 1
        
        // Load garage data
        loadGarageData()
    }
    
    private func loadGarageData() {
        // In a real app, this would load from a server or local database
        // For now, we'll create sample data
        
        // Create sample layout
        let layout = GarageLayout(
            width: 50,
            length: 100,
            driveLanes: [
                DriveLane(start: GarageCoordinate(x: 20, y: 0),
                         end: GarageCoordinate(x: 20, y: 100),
                         width: 6,
                         direction: .twoWay)
            ],
            walls: [
                Wall(start: GarageCoordinate(x: 0, y: 0),
                     end: GarageCoordinate(x: 50, y: 0),
                     type: .solid)
            ],
            entrances: [
                Entrance(location: GarageCoordinate(x: 20, y: 0),
                        type: .vehicleEntry)
            ]
        )
        
        // Create sample levels
        levels = [
            GarageLevel(id: -1, name: "B1", spots: createSpots(count: 50), layout: layout),
            GarageLevel(id: 1, name: "L1", spots: createSpots(count: 60), layout: layout),
            GarageLevel(id: 2, name: "L2", spots: createSpots(count: 55), layout: layout)
        ]
    }
    
    private func createSpots(count: Int) -> [ParkingSpot] {
        var spots: [ParkingSpot] = []
        for i in 0..<count {
            let x = Double(i % 10) * 3 + 2 // 3m wide spots, 2m from wall
            let y = Double(i / 10) * 5 + 5 // 5m deep spots, 5m from entrance
            
            spots.append(ParkingSpot(
                id: UUID().uuidString,
                level: currentLevel,
                coordinates: GarageCoordinate(x: x, y: y),
                type: i % 20 == 0 ? .electric : .standard,
                isOccupied: Bool.random()
            ))
        }
        return spots
    }
    
    // Update spot occupancy
    func updateSpot(id: String, isOccupied: Bool) {
        for (levelIndex, level) in levels.enumerated() {
            if let spotIndex = level.spots.firstIndex(where: { $0.id == id }) {
                levels[levelIndex].spots[spotIndex].isOccupied = isOccupied
            }
        }
    }
    
    // Change current level
    func changeLevel(to level: Int) {
        guard levels.contains(where: { $0.id == level }) else { return }
        currentLevel = level
    }
}
