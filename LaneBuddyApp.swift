import SwiftUI
import MapboxNavigation
import MapboxMaps
import MapLibre

@main
struct LaneBuddyApp: App {
    init() {
        // Initialize MapLibre configurations
        MapLibreConfig.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView()
                .tabItem {
                    Label("Navigate", systemImage: "location.fill")
                }
            
            TripHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
