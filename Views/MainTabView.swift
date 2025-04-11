import SwiftUI

struct MainTabView: View {
    @StateObject private var syncService = SyncService.shared
    
    var body: some View {
        TabView {
            NavigationView {
                MapView()
            }
            .tabItem {
                Label("Navigation", systemImage: "map")
            }
            
            NavigationView {
                SavedRoutesView()
            }
            .tabItem {
                Label("Routes", systemImage: "list.bullet")
            }
            
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
        }
        .onAppear {
            // Start initial sync
            Task {
                await SyncService.shared.syncData()
            }
        }
    }
}

struct SavedRoutesView: View {
    @StateObject private var viewModel = SavedRoutesViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.routes) { route in
                NavigationLink(destination: RouteDetailView(route: route)) {
                    SavedRouteRow(route: route)
                }
            }
            .onDelete(perform: viewModel.deleteRoute)
        }
        .navigationTitle("Saved Routes")
        .refreshable {
            await viewModel.loadRoutes()
        }
        .onAppear {
            Task {
                await viewModel.loadRoutes()
            }
        }
    }
}

class SavedRoutesViewModel: ObservableObject {
    @Published var routes: [SavedRoute] = []
    
    func loadRoutes() async {
        do {
            routes = try await LocalStorage.shared.getSavedRoutes()
        } catch {
            print("Error loading routes:", error)
        }
    }
    
    func deleteRoute(at offsets: IndexSet) {
        // Implementation for deleting routes
    }
}
