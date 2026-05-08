import Foundation

final class TaskService {
    static let shared = TaskService()
    private init() {}

    func getTasks(completed: Bool? = nil, priority: String? = nil) async throws -> [HTask] {
        var endpoint = Constants.Endpoints.tasks
        var params: [String] = []
        if let completed { params.append("completed=\(completed)") }
        if let priority  { params.append("priority=\(priority)") }
        if !params.isEmpty { endpoint += "?" + params.joined(separator: "&") }

        let res: TasksResponse = try await APIService.shared.request(endpoint: endpoint)
        return res.tasks
    }

    func createTask(title: String, priority: String, timeSlot: String? = nil, dueDate: String? = nil) async throws -> HTask {
        var body: [String: Any] = ["title": title, "priority": priority]
        if let timeSlot { body["timeSlot"] = timeSlot }
        if let dueDate  { body["dueDate"]  = dueDate  }
        let res: TaskResponse = try await APIService.shared.request(
            endpoint: Constants.Endpoints.tasks, method: "POST", body: body
        )
        return res.task
    }

    func updateTask(id: String, fields: [String: Any]) async throws -> HTask {
        let res: TaskResponse = try await APIService.shared.request(
            endpoint: Constants.Endpoints.task(id: id), method: "PUT", body: fields
        )
        return res.task
    }

    func deleteTask(id: String) async throws {
        try await APIService.shared.requestVoid(
            endpoint: Constants.Endpoints.task(id: id), method: "DELETE"
        )
    }
}
