import Foundation
import Observation

@Observable
final class AuthManager {
    var currentUser: User?
    var token: String?

    var isAuthenticated: Bool { token != nil }

    init() {
        // Restore persisted session on launch
        if let saved = KeychainManager.shared.getToken(), !saved.isEmpty {
            self.token = saved
        }
    }

    func saveSession(user: User, token: String) {
        self.currentUser = user
        self.token = token
        KeychainManager.shared.saveToken(token)
    }

    func logout() {
        currentUser = nil
        token = nil
        KeychainManager.shared.deleteToken()
    }
}
