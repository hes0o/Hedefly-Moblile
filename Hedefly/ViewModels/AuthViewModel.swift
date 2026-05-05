import Foundation
import Observation

@Observable
final class AuthViewModel {
    var isLoading = false
    var errorMessage: String?

    func login(email: String, password: String, authManager: AuthManager) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let res = try await AuthService.shared.login(email: email, password: password)
            authManager.saveSession(user: res.user, token: res.token)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func register(name: String, email: String, password: String, authManager: AuthManager) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let res = try await AuthService.shared.register(name: name, email: email, password: password)
            authManager.saveSession(user: res.user, token: res.token)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
