import SwiftUI

struct SettingsView: View {
    @State private var isCarPlayPreviewEnabled = false
    @State private var voiceGuidanceEnabled = true
    @State private var preferredLaneEnabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Navigation")) {
                    Toggle("Voice Guidance", isOn: $voiceGuidanceEnabled)
                    Toggle("Preferred Lane Suggestions", isOn: $preferredLaneEnabled)
                }
                
                Section(header: Text("CarPlay")) {
                    Toggle("CarPlay Preview Mode", isOn: $isCarPlayPreviewEnabled)
                }
                
                Section(header: Text("About")) {
                    Text("LaneBuddy v1.0")
                    Text("© 2025 LaneBuddy")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
