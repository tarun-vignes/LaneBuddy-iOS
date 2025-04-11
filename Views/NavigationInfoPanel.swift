import SwiftUI
import MapKit

struct NavigationInfoPanel: View {
    let step: MKRoute.Step?
    let distance: CLLocationDistance?
    
    var body: some View {
        VStack(spacing: 8) {
            // Next maneuver
            if let step = step {
                HStack {
                    // Maneuver icon
                    Image(systemName: iconForStep(step))
                        .font(.title)
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                    
                    VStack(alignment: .leading) {
                        // Distance to maneuver
                        if let distance = distance {
                            Text(formatDistance(distance))
                                .font(.headline)
                        }
                        
                        // Instructions
                        Text(step.instructions)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    private func iconForStep(_ step: MKRoute.Step) -> String {
        if step.instructions.contains("right") {
            return "arrow.turn.up.right"
        } else if step.instructions.contains("left") {
            return "arrow.turn.up.left"
        } else if step.instructions.contains("Continue") {
            return "arrow.up"
        } else if step.instructions.contains("destination") {
            return "mappin.circle.fill"
        } else {
            return "arrow.up"
        }
    }
    
    private func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
}
