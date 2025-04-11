import SwiftUI

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var isRegistering = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textContentType(isRegistering ? .newPassword : .password)
                }
                
                Section {
                    Button(action: {
                        Task {
                            await viewModel.authenticate(isRegistering: isRegistering)
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text(isRegistering ? "Register" : "Log In")
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isLoading)
                    
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                
                Section {
                    Button(action: { isRegistering.toggle() }) {
                        HStack {
                            Spacer()
                            Text(isRegistering ? "Already have an account? Log In" : "Don't have an account? Register")
                                .foregroundColor(.blue)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(isRegistering ? "Register" : "Log In")
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    func authenticate(isRegistering: Bool) async {
        guard !email.isEmpty && !password.isEmpty else {
            showError(message: "Please fill in all fields")
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            let user: User
            if isRegistering {
                user = try await NetworkService.shared.register(email: email, password: password)
            } else {
                user = try await NetworkService.shared.login(email: email, password: password)
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
                // Handle successful authentication
                // Navigate to main app view
            }
        } catch {
            showError(message: error.localizedDescription)
        }
    }
    
    private func showError(message: String) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = message
            self.showError = true
        }
    }
}
