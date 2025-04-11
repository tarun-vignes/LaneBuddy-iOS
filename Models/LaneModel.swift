import Foundation
import CoreLocation
import MapLibre
import MapKit

// Represents a single lane on the road
struct Lane: Identifiable, Codable {
    let id: UUID
    let index: Int
    let type: LaneType
    let markings: LaneMarkings
    var isActive: Bool
    var isPreferred: Bool
    var maneuver: MLNManeuverType?
    
    init(index: Int, type: LaneType = .regular, markings: LaneMarkings = .dashed, maneuver: MLNManeuverType? = nil) {
        self.id = UUID()
        self.index = index
        self.type = type
        self.markings = markings
        self.isActive = false
        self.isPreferred = false
        self.maneuver = maneuver
    }
    
    init(from mlnLane: MLNLane, index: Int) {
        self.id = UUID()
        self.index = index
        self.type = .regular
        self.markings = mlnLane.separator == .solid ? .solid : .dashed
        self.isActive = mlnLane.isActive
        self.isPreferred = mlnLane.isPreferred
        self.maneuver = mlnLane.maneuverType
    }
}

// Types of lanes
enum LaneType {
    case regular           // Standard driving lane
    case hov              // High-occupancy vehicle lane
    case exit             // Exit/off-ramp lane
    case merge            // Merge lane
    case turn(Direction)  // Turn lane
}

// Turn directions
enum Direction {
    case left
    case right
    case straight
}

// Lane marking types
enum LaneMarkings {
    case solid
    case dashed
    case double
    case none
}

// Represents the current road segment with all lanes
struct RoadSegment: Identifiable {
    let id: UUID
    let lanes: [Lane]
    let coordinate: CLLocationCoordinate2D
    let heading: CLLocationDirection
    let intersectionIndex: Int?
    
    init(lanes: [Lane], coordinate: CLLocationCoordinate2D, heading: CLLocationDirection, intersectionIndex: Int? = nil) {
        self.id = UUID()
        self.lanes = lanes
        self.coordinate = coordinate
        self.heading = heading
        self.intersectionIndex = intersectionIndex
    }
    
    // Update lane states based on navigation
    func updateLanes(userPosition: CLLocationCoordinate2D, 
                    nextManeuver: MKRoute.Step?) {
        // Will implement lane state updates based on navigation
    }
    
    // Mark a lane as preferred
    func setPreferredLane(_ position: Int) {
        guard position >= 0 && position < lanes.count else { return }
        for i in 0..<lanes.count {
            lanes[i].isPreferred = (i == position)
        }
    }
}
