import Foundation

// MARK: - Error types
enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(String)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:             return "Invalid URL."
        case .noData:                 return "No data received."
        case .decodingError(let e):   return "Decode error: \(e.localizedDescription)"
        case .serverError(let msg):   return msg
        case .unauthorized:           return "Session expired. Please log in again."
        }
    }
}

// MARK: - APIService
final class APIService {
    static let shared = APIService()
    private init() {}

    private var token: String? { KeychainManager.shared.getToken() }

    // Generic async/await request
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: Constants.baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth, let token = token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let http = response as? HTTPURLResponse else { throw APIError.noData }

        if http.statusCode == 401 { throw APIError.unauthorized }

        if http.statusCode >= 400 {
            if let errBody = try? JSONDecoder().decode([String: String].self, from: data),
               let msg = errBody["message"] {
                throw APIError.serverError(msg)
            }
            throw APIError.serverError("HTTP \(http.statusCode)")
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // Void request (for DELETEs / REORDERs that don't need a return value)
    func requestVoid(
        endpoint: String,
        method: String,
        body: [String: Any]? = nil
    ) async throws {
        let _: MessageResponse = try await request(endpoint: endpoint, method: method, body: body)
    }
}
