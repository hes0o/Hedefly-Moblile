import Foundation

final class AuthService {
    static let shared = AuthService()
    private init() {}

    func login(email: String, password: String) async throws -> AuthResponse {
        try await APIService.shared.request(
            endpoint: Constants.Endpoints.login,
            method: "POST",
            body: ["email": email, "password": password],
            requiresAuth: false
        )
    }

    func register(name: String, email: String, password: String) async throws -> AuthResponse {
        try await APIService.shared.request(
            endpoint: Constants.Endpoints.register,
            method: "POST",
            body: ["name": name, "email": email, "password": password],
            requiresAuth: false
        )
    }
}
