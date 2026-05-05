import Foundation
import Observation

@Observable
final class TaskViewModel {
    var tasks: [HTask] = []
    var isLoading = false
    var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do { tasks = try await TaskService.shared.getTasks() }
        catch { errorMessage = error.localizedDescription }
    }

    func addTask(title: String, priority: String, dueDate: String? = nil) async {
        do {
            let t = try await TaskService.shared.createTask(title: title, priority: priority, dueDate: dueDate)
            tasks.insert(t, at: 0)
        } catch { errorMessage = error.localizedDescription }
    }

    func toggle(_ task: HTask) async {
        do {
            let updated = try await TaskService.shared.updateTask(id: task.id, fields: ["completed": !task.completed])
            if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[idx] = updated
            }
        } catch { errorMessage = error.localizedDescription }
    }

    func delete(id: String) async {
        do {
            try await TaskService.shared.deleteTask(id: id)
            tasks.removeAll { $0.id == id }
        } catch { errorMessage = error.localizedDescription }
    }
}
