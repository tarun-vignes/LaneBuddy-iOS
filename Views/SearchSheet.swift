import SwiftUI
import MapKit

struct SearchSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var query: String
    @Binding var selected: MKMapItem?
    let userLocation: CLLocation?
    
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search destination", text: $query)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: query) { _ in
                            searchPlaces()
                        }
                    
                    if !query.isEmpty {
                        Button(action: {
                            query = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                
                if isSearching {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    // Search results
                    List(searchResults, id: \.self) { item in
                        Button(action: {
                            selected = item
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            VStack(alignment: .leading) {
                                Text(item.name ?? "Unknown location")
                                    .font(.headline)
                                
                                if let address = item.placemark.addressDictionary?["FormattedAddressLines"] as? [String] {
                                    Text(address.joined(separator: ", "))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                if let userLocation = userLocation,
                                   let itemLocation = item.placemark.location {
                                    Text(formatDistance(from: userLocation, to: itemLocation))
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search Destination")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func searchPlaces() {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        if let location = userLocation {
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 50000, // 50km radius
                longitudinalMeters: 50000
            )
        }
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            isSearching = false
            
            if let error = error {
                print("Search error: \(error)")
                return
            }
            
            searchResults = response?.mapItems ?? []
        }
    }
    
    private func formatDistance(from: CLLocation, to: CLLocation) -> String {
        let distance = from.distance(from: to)
        
        if distance < 1000 {
            return String(format: "%.0f m away", distance)
        } else {
            return String(format: "%.1f km away", distance / 1000)
        }
    }
}
