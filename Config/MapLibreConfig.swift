import Foundation
import MapLibre

struct MapLibreConfig {
    // Default style URL (using OSM data)
    static let defaultStyleURL = URL(string: "https://demotiles.maplibre.org/style.json")!
    
    // Custom style with traffic data
    static let trafficStyleURL = URL(string: "https://tiles.stadiamaps.com/styles/osm_bright.json")!
    
    // Offline storage configuration
    static let offlineStorageConfig = MLNOfflineStorageConfiguration(
        cachePath: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("maplibre-cache").path,
        maximalDatabaseSize: 50 * 1024 * 1024  // 50MB cache limit
    )
    
    // Navigation configuration
    static let navigationConfig = MLNNavigationConfiguration(
        // Use metric units by default
        distanceUnit: .kilometer,
        // Enable voice guidance
        voiceEnabled: true,
        // Enable traffic avoidance
        trafficEnabled: true
    )
    
    // Map configuration
    static let mapConfig = MLNMapConfiguration(
        // Enable location tracking
        locationTrackingEnabled: true,
        // Enable compass
        compassEnabled: true,
        // Enable zoom controls
        zoomControlsEnabled: true,
        // Enable rotation gestures
        rotationEnabled: true,
        // Enable traffic display
        trafficEnabled: true
    )
    
    // Initialize MapLibre with these configurations
    static func initialize() {
        MLNSettings.shared.offlineStorage = offlineStorageConfig
        MLNSettings.shared.navigation = navigationConfig
        MLNSettings.shared.map = mapConfig
    }
}
