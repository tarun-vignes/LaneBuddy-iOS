import Foundation
import CoreLocation
import MapKit
import SwiftUI

class LaneGuidanceViewModel: ObservableObject {
    @Published var currentRoadSegment: RoadSegment?
    @Published var nextManeuver: MKRoute.Step?
    @Published var distanceToNextManeuver: CLLocationDistance?
    @Published var showLaneChangeRecommendation = false
    
    // Lane colors
    let regularLaneColor = Color.gray.opacity(0.3)
    let activeLaneColor = Color.blue.opacity(0.4)
    let preferredLaneColor = Color.green.opacity(0.4)
    let warningLaneColor = Color.red.opacity(0.4)
    
    // Initialize with default 3-lane road
    init() {
        currentRoadSegment = RoadSegment(laneCount: 3, direction: 0)
    }
    
    // Update road segment based on current location
    func updateRoadSegment(at location: CLLocationCoordinate2D) {
        // In a real app, this would use MapKit or another service to get actual road data
        // For now, we'll simulate lane data
        let heading = calculateRoadHeading(at: location)
        currentRoadSegment = RoadSegment(laneCount: 3, direction: heading)
    }
    
    // Calculate road heading based on user movement
    private func calculateRoadHeading(at location: CLLocationCoordinate2D) -> CLLocationDirection {
        // In real app, this would use recent location history to determine heading
        // For now, return a simulated value
        return 0
    }
    
    // Determine if lane change is recommended
    func shouldChangeLane(currentLane: Int) -> Direction? {
        guard let segment = currentRoadSegment else { return nil }
        
        // Find preferred lane
        if let preferredLane = segment.lanes.firstIndex(where: { $lane in
            $lane.isPreferred
        }) {
            if preferredLane < currentLane {
                return .left
            } else if preferredLane > currentLane {
                return .right
            }
        }
        return nil
    }
    
    // Update next maneuver from navigation
    func updateNextManeuver(_ step: MKRoute.Step?, distance: CLLocationDistance?) {
        nextManeuver = step
        distanceToNextManeuver = distance
        
        // Update lane recommendations based on upcoming maneuver
        if let step = step {
            updateLaneRecommendations(for: step)
        }
    }
    
    private func updateLaneRecommendations(for step: MKRoute.Step) {
        guard let segment = currentRoadSegment else { return }
        
        // In a real app, this would use more sophisticated logic based on:
        // - Upcoming turn direction
        // - Distance to maneuver
        // - Traffic conditions
        // - Historical preferred lanes
        
        // For now, simple logic: prefer right lane for right turns, left lane for left turns
        switch step.instructions {
        case let str where str.contains("right"):
            segment.setPreferredLane(segment.lanes.count - 1) // Rightmost lane
        case let str where str.contains("left"):
            segment.setPreferredLane(0) // Leftmost lane
        default:
            segment.setPreferredLane(1) // Middle lane for going straight
        }
    }
}
