import SwiftUI
import CoreLocation

struct GarageMapView: View {
    @StateObject private var garageModel: GarageModel
    @State private var scale: CGFloat = 1.0
    @State private var offset = CGSize.zero
    @State private var showLevelPicker = false
    
    init(name: String, location: CLLocation) {
        _garageModel = StateObject(wrappedValue: GarageModel(name: name, location: location))
    }
    
    var body: some View {
        ZStack {
            // Garage map
            GarageMapContent(model: garageModel)
                .scaleEffect(scale)
                .offset(x: offset.width, y: offset.height)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = value.magnitude
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = value.translation
                        }
                )
            
            // Controls overlay
            VStack {
                // Level selector
                HStack {
                    Text("Level \(garageModel.currentLevel)")
                        .font(.title2)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onTapGesture {
                            showLevelPicker = true
                        }
                    
                    Spacer()
                    
                    // Available spots counter
                    if let currentLevelData = garageModel.levels.first(where: { $0.id == garageModel.currentLevel }) {
                        Text("\(currentLevelData.availableSpots) spots available")
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding()
                
                Spacer()
                
                // Reset view button
                Button(action: resetView) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.title)
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .padding()
            }
        }
        .sheet(isPresented: $showLevelPicker) {
            LevelPickerView(garageModel: garageModel)
        }
    }
    
    private func resetView() {
        withAnimation {
            scale = 1.0
            offset = .zero
        }
    }
}

struct GarageMapContent: View {
    @ObservedObject var model: GarageModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw drive lanes
                ForEach(model.levels[model.currentLevel].layout.driveLanes, id: \.start.x) { lane in
                    DriveLanePath(lane: lane)
                        .stroke(Color.gray, lineWidth: 2)
                }
                
                // Draw parking spots
                ForEach(model.levels[model.currentLevel].spots) { spot in
                    ParkingSpotView(spot: spot)
                }
                
                // Draw walls
                ForEach(model.levels[model.currentLevel].layout.walls, id: \.start.x) { wall in
                    WallPath(wall: wall)
                        .stroke(Color.black, lineWidth: wall.type == .solid ? 3 : 1)
                }
                
                // Draw entrances
                ForEach(model.levels[model.currentLevel].layout.entrances, id: \.location.x) { entrance in
                    EntranceMarker(entrance: entrance)
                }
            }
        }
    }
}

struct DriveLanePath: Shape {
    let lane: DriveLane
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: lane.start.x, y: lane.start.y))
        path.addLine(to: CGPoint(x: lane.end.x, y: lane.end.y))
        return path
    }
}

struct WallPath: Shape {
    let wall: Wall
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: wall.start.x, y: wall.start.y))
        path.addLine(to: CGPoint(x: wall.end.x, y: wall.end.y))
        return path
    }
}

struct ParkingSpotView: View {
    let spot: ParkingSpot
    
    var body: some View {
        Rectangle()
            .fill(spotColor)
            .frame(width: 3, height: 5) // 3m wide, 5m deep
            .position(x: spot.coordinates.x, y: spot.coordinates.y)
    }
    
    private var spotColor: Color {
        if spot.isOccupied {
            return .red
        }
        switch spot.type {
        case .standard: return .blue
        case .handicap: return .purple
        case .electric: return .green
        case .compact: return .orange
        }
    }
}

struct EntranceMarker: View {
    let entrance: Entrance
    
    var body: some View {
        Image(systemName: entrance.type == .vehicleEntry ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
            .font(.title)
            .foregroundColor(.blue)
            .position(x: entrance.location.x, y: entrance.location.y)
    }
}

struct LevelPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var garageModel: GarageModel
    
    var body: some View {
        NavigationView {
            List(garageModel.levels) { level in
                Button(action: {
                    garageModel.changeLevel(to: level.id)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(level.name)
                        Spacer()
                        Text("\(level.availableSpots) available")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Select Level")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
