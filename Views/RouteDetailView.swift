import SwiftUI
import MapKit

struct RouteDetailView: View {
    let route: SavedRoute
    @StateObject private var viewModel: RouteDetailViewModel
    
    init(route: SavedRoute) {
        self.route = route
        _viewModel = StateObject(wrappedValue: RouteDetailViewModel(route: route))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Map preview
                Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.annotations) { item in
                    MapMarker(coordinate: item.coordinate, tint: item.color)
                }
                .frame(height: 200)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Route details
                VStack(alignment: .leading, spacing: 12) {
                    RouteInfoRow(title: "From", value: route.startLocation.name ?? "Current Location")
                    RouteInfoRow(title: "To", value: route.endLocation.name ?? "Destination")
                    
                    if let lastUsed = route.lastUsed {
                        RouteInfoRow(title: "Last Used", value: viewModel.formatDate(lastUsed))
                    }
                    
                    if route.frequentlyUsed {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Frequently Used Route")
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                
                // Actions
                VStack(spacing: 12) {
                    Button(action: { viewModel.startNavigation() }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Start Navigation")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: { viewModel.toggleFavorite() }) {
                        HStack {
                            Image(systemName: route.frequentlyUsed ? "star.fill" : "star")
                            Text(route.frequentlyUsed ? "Remove from Favorites" : "Add to Favorites")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(route.endLocation.name ?? "Route Details")
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct RouteInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

class RouteDetailViewModel: ObservableObject {
    let route: SavedRoute
    @Published var region: MKCoordinateRegion
    @Published var annotations: [RouteAnnotation]
    @Published var showError = false
    @Published var errorMessage = ""
    
    init(route: SavedRoute) {
        self.route = route
        
        // Calculate region to show both start and end locations
        let center = CLLocationCoordinate2D(
            latitude: (route.startLocation.latitude + route.endLocation.latitude) / 2,
            longitude: (route.startLocation.longitude + route.endLocation.longitude) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: abs(route.startLocation.latitude - route.endLocation.latitude) * 1.5,
            longitudeDelta: abs(route.startLocation.longitude - route.endLocation.longitude) * 1.5
        )
        
        self.region = MKCoordinateRegion(center: center, span: span)
        
        self.annotations = [
            RouteAnnotation(coordinate: CLLocationCoordinate2D(
                latitude: route.startLocation.latitude,
                longitude: route.startLocation.longitude
            ), color: .green),
            RouteAnnotation(coordinate: CLLocationCoordinate2D(
                latitude: route.endLocation.latitude,
                longitude: route.endLocation.longitude
            ), color: .red)
        ]
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func startNavigation() {
        // Implementation for starting navigation
    }
    
    func toggleFavorite() {
        Task {
            do {
                var updatedRoute = route
                updatedRoute.frequentlyUsed.toggle()
                _ = try await NetworkService.shared.updateRoute(updatedRoute)
            } catch {
                showError(message: error.localizedDescription)
            }
        }
    }
    
    private func showError(message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showError = true
        }
    }
}

struct RouteAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let color: Color
}
