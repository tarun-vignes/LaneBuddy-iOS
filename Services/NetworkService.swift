import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case unauthorized
}

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://localhost:3000/api"
    private var authToken: String?
    
    private init() {}
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    func clearAuthToken() {
        self.authToken = nil
    }
    
    private func createRequest(_ endpoint: String, method: String, body: [String: Any]? = nil) -> URLRequest? {
        guard let url = URL(string: baseURL + endpoint) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        return request
    }
    
    func register(email: String, password: String) async throws -> User {
        guard let request = createRequest("/auth/register", method: "POST", body: [
            "email": email,
            "password": password
        ]) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        }
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw NetworkError.serverError("Server returned \(httpResponse.statusCode)")
        }
        
        let decoder = JSONDecoder()
        guard let authResponse = try? decoder.decode(AuthResponse.self, from: data) else {
            throw NetworkError.decodingError
        }
        
        setAuthToken(authResponse.token)
        return authResponse.user
    }
    
    func login(email: String, password: String) async throws -> User {
        guard let request = createRequest("/auth/login", method: "POST", body: [
            "email": email,
            "password": password
        ]) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        }
        
        let decoder = JSONDecoder()
        guard let authResponse = try? decoder.decode(AuthResponse.self, from: data) else {
            throw NetworkError.decodingError
        }
        
        setAuthToken(authResponse.token)
        return authResponse.user
    }
    
    func updatePreferences(_ preferences: UserPreferences) async throws -> UserPreferences {
        guard let request = createRequest("/auth/preferences", method: "PUT", body: [
            "preferences": preferences.dictionary
        ]) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(UserPreferences.self, from: data)
    }
    
    func getProfile() async throws -> User {
        guard let request = createRequest("/auth/profile", method: "GET") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(User.self, from: data)
    }
    
    func saveRoute(_ route: SavedRoute) async throws -> SavedRoute {
        guard let request = createRequest("/routes", method: "POST", body: route.dictionary) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(SavedRoute.self, from: data)
    }
}
