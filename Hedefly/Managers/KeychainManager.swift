import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()
    private init() {}

    private let tokenKey = "hedefly_jwt_token"

    // MARK: - Save
    @discardableResult
    func saveToken(_ token: String) -> Bool {
        guard let data = token.data(using: .utf8) else { return false }

        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: tokenKey,
            kSecValueData:   data
        ]
        // Delete existing first, then add
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    // MARK: - Read
    func getToken() -> String? {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: tokenKey,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Delete
    @discardableResult
    func deleteToken() -> Bool {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: tokenKey
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}
