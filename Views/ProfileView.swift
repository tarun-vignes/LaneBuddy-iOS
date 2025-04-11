import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    Text(viewModel.user?.email ?? "")
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Navigation Preferences")) {
                    Toggle("Avoid Highways", isOn: $viewModel.avoidHighways)
                    Toggle("Avoid Tolls", isOn: $viewModel.avoidTolls)
                    
                    Picker("Preferred Lane", selection: $viewModel.preferredLane) {
                        Text("Left").tag(LanePosition.left)
                        Text("Middle").tag(LanePosition.middle)
                        Text("Right").tag(LanePosition.right)
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Voice Guidance", isOn: $viewModel.voiceEnabled)
                    Toggle("Vibration", isOn: $viewModel.vibrationEnabled)
                }
                
                Section(header: Text("Saved Routes")) {
                    if viewModel.savedRoutes.isEmpty {
                        Text("No saved routes")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.savedRoutes, id: \.id) { route in
                            NavigationLink(destination: RouteDetailView(route: route)) {
                                SavedRouteRow(route: route)
                            }
                        }
                        .onDelete(perform: viewModel.deleteRoute)
                    }
                }
                
                Section {
                    Button(action: { showingLogoutAlert = true }) {
                        Text("Log Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    viewModel.logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
        .onAppear {
            viewModel.loadProfile()
        }
    }
}

struct SavedRouteRow: View {
    let route: SavedRoute
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(route.endLocation.name ?? "Unnamed Location")
                .font(.headline)
            Text("From: \(route.startLocation.name ?? "Current Location")")
                .font(.subheadline)
                .foregroundColor(.secondary)
            if route.frequentlyUsed {
                Text("Frequently Used")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }
}

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var savedRoutes: [SavedRoute] = []
    @Published var avoidHighways = false
    @Published var avoidTolls = false
    @Published var preferredLane = LanePosition.middle
    @Published var voiceEnabled = true
    @Published var vibrationEnabled = true
    
    func loadProfile() {
        Task {
            do {
                let user = try await NetworkService.shared.getProfile()
                DispatchQueue.main.async {
                    self.user = user
                    self.updatePreferencesFromUser(user)
                }
            } catch {
                print("Error loading profile:", error)
            }
        }
    }
    
    private func updatePreferencesFromUser(_ user: User) {
        self.avoidHighways = user.preferences.defaultNavigation.avoidHighways
        self.avoidTolls = user.preferences.defaultNavigation.avoidTolls
        self.preferredLane = user.preferences.defaultNavigation.preferredLanePosition
        self.voiceEnabled = user.preferences.notifications.voice
        self.vibrationEnabled = user.preferences.notifications.vibration
        self.savedRoutes = user.savedRoutes
    }
    
    func deleteRoute(at offsets: IndexSet) {
        // Implementation for deleting routes
    }
    
    func logout() {
        NetworkService.shared.clearAuthToken()
        // Handle navigation to login screen
    }
}
