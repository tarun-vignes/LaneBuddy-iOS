import SwiftUI

struct TripHistoryView: View {
    var body: some View {
        NavigationView {
            List {
                // Placeholder for trip history items
                Text("Recent trips will appear here")
                    .foregroundColor(.gray)
            }
            .navigationTitle("Trip History")
        }
    }
}
