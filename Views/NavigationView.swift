import SwiftUI
import MapKit
import MapLibre
import MapLibreNavigation

struct NavigationView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var navigationService = NavigationService()
    @StateObject private var lanePreferenceService = LanePreferenceService()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3361, longitude: -122.0090),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @State private var showDirections = false
    @State private var showGarageView = false
    @State private var selectedDestination: MKMapItem?
    @State private var searchQuery = ""
    
    var body: some View {
        ZStack {
            // Main navigation map
            MapLibreMapView(styleURL: URL(string: "https://demotiles.maplibre.org/style.json")!)
                .edgesIgnoringSafeArea(.all)
                .overlay(LaneOverlayView(viewModel: LaneGuidanceViewModel()))
                .sheet(isPresented: $showDirections) {
                    SearchSheet(query: $searchQuery,
                               selected: $selectedDestination,
                               userLocation: locationManager.location)
                }
                .sheet(isPresented: $showGarageView) {
                    if let location = locationManager.location {
                        GarageMapView(name: "Local Garage",
                                     location: location)
                    }
                }
            
            // Vehicle indicators when navigating
            if navigationService.isNavigating {
                VehicleIndicatorsView()
            }
            
            // Navigation info panel
            if navigationService.isNavigating {
                VStack {
                    NavigationInfoPanel(step: navigationService.currentStep,
                                      distance: navigationService.distanceToNextStep)
                    Spacer()
                }
                .padding(.top)
            }
            
            // Controls
            VStack {
                Spacer()
                NavigationControlsView(region: $region,
                                     userLocation: locationManager.location,
                                     showDirections: $showDirections,
                                     showGarageView: $showGarageView,
                                     navigationService: navigationService)
                    .padding()
            }
        }
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
        }
        .onChange(of: selectedDestination) { destination in
            if let destination = destination,
               let location = locationManager.location {
                // Calculate route
                Task {
                    do {
                        let route = try await navigationService.calculateRoute(
                            from: location.coordinate,
                            to: destination.placemark.coordinate)
                        navigationService.startNavigation(route: route)
                    } catch {
                        print("Error calculating route: \(error)")
                    }
                }
            }
        }
        .onChange(of: locationManager.location) { location in
            if let location = location {
                // Update navigation
                navigationService.updateNavigation(at: location)
                
                // Check for garage entry
                checkForGarageEntry(at: location)
                
                // Update lane preferences
                if let segment = lanePreferenceService.findNearbySegment(at: location.coordinate) {
                    if let preferredLane = lanePreferenceService.getPreferredLane(for: segment) {
                        // Update lane guidance
                        // This would update the LaneGuidanceViewModel
                    }
                }
            }
        }
    }
    
    private func checkForGarageEntry(at location: CLLocation) {
        // In a real app, this would check against known garage locations
        // For demo, we'll just use a fixed coordinate
        let garageLocation = CLLocation(latitude: 37.3361, longitude: -122.0090)
        if location.distance(from: garageLocation) < 50 { // Within 50 meters
            showGarageView = true
        }
    }
}

// Location Manager to handle user location updates
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5 // Update location every 5 meters
    }
    
    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
}

struct LaneOverlayView: View {
    @StateObject private var viewModel = LaneGuidanceViewModel()
    @State private var currentLane = 1 // Start in middle lane
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Lane visualization
                Canvas { context, size in
                    drawLanes(context: context, size: size)
                }
                .allowsHitTesting(false)
                
                // Lane change recommendation arrow if needed
                if let changeDirection = viewModel.shouldChangeLane(currentLane: currentLane) {
                    LaneChangeArrow(direction: changeDirection)
                        .transition(.opacity)
                }
            }
        }
    }
    
    private func drawLanes(context: GraphicsContext, size: CGSize) {
        guard let segment = viewModel.currentRoadSegment else { return }
        
        let laneCount = segment.lanes.count
        let laneWidth = size.width / CGFloat(laneCount)
        let laneLength = size.height * 0.4 // Show lanes for 40% of screen height
        
        // Draw from bottom of screen
        let startY = size.height
        let endY = size.height - laneLength
        
        for (index, lane) in segment.lanes.enumerated() {
            let startX = CGFloat(index) * laneWidth
            
            // Create lane path
            var path = Path()
            path.move(to: CGPoint(x: startX, y: startY))
            path.addLine(to: CGPoint(x: startX + laneWidth, y: startY))
            path.addLine(to: CGPoint(x: startX + laneWidth, y: endY))
            path.addLine(to: CGPoint(x: startX, y: endY))
            path.closeSubpath()
            
            // Determine lane color
            let color: Color
            if lane.isActive {
                color = viewModel.activeLaneColor
            } else if lane.isPreferred {
                color = viewModel.preferredLaneColor
            } else {
                color = viewModel.regularLaneColor
            }
            
            // Draw lane
            context.fill(path, with: .color(color))
            
            // Draw lane markings
            for marking in lane.markings {
                drawLaneMarking(context: context, marking: marking,
                              x: startX, startY: startY, endY: endY)
            }
        }
    }
    
    private func drawLaneMarking(context: GraphicsContext, marking: LaneMarking,
                                x: CGFloat, startY: CGFloat, endY: CGFloat) {
        let path = Path { path in
            path.move(to: CGPoint(x: x, y: startY))
            path.addLine(to: CGPoint(x: x, y: endY))
        }
        
        switch marking {
        case .solid:
            context.stroke(path, with: .color(.white), lineWidth: 2)
        case .dashed:
            context.stroke(path, with: .color(.white), lineWidth: 2,
                          dash: [10, 10]) // 10pt line, 10pt gap
        case .double:
            context.stroke(path, with: .color(.white), lineWidth: 4)
            let offsetPath = path.offsetBy(dx: 2, dy: 0)
            context.stroke(offsetPath, with: .color(.black), lineWidth: 2)
        case .none:
            break
        }
    }
}

struct LaneChangeArrow: View {
    let direction: Direction
    
    var body: some View {
        Image(systemName: direction == .left ? "arrow.left.circle.fill" : "arrow.right.circle.fill")
            .resizable()
            .frame(width: 44, height: 44)
            .foregroundColor(.green)
            .background(Circle().fill(Color.white))
            .shadow(radius: 3)
    }
}

struct VehicleIndicatorsView: View {
    var body: some View {
        // Placeholder for nearby vehicle indicators
        EmptyView()
    }
}

struct NavigationControlsView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var showDirections: Bool
    @Binding var showGarageView: Bool
    var userLocation: CLLocation?
    var navigationService: NavigationService
    
    var body: some View {
        HStack(spacing: 20) {
            // Recenter button
            Button(action: recenterToUserLocation) {
                Image(systemName: "location.fill")
                    .padding()
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 3)
            }
            
            // Search/Navigation button
            Button(action: { showDirections = true }) {
                Image(systemName: navigationService.isNavigating ? 
                      "xmark.circle.fill" : "magnifyingglass.circle.fill")
                    .padding()
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 3)
            }
            
            // Garage view button
            Button(action: { showGarageView = true }) {
                Image(systemName: "parkingsign.circle.fill")
                    .padding()
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 3)
            }
            
            if navigationService.isNavigating {
                // Stop navigation button
                Button(action: navigationService.stopNavigation) {
                    Image(systemName: "stop.circle.fill")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
            }
        }
    }
    
    private func recenterToUserLocation() {
        guard let location = userLocation else { return }
        withAnimation {
            region.center = location.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        }
    }
}
}
