import Foundation
import Observation

@Observable
final class DashboardViewModel {
    var tasks:  [HTask] = []
    var goals:  [Goal]  = []
    var isLoading = false
    var errorMessage: String?

    var pendingCount:   Int    { tasks.filter { !$0.completed }.count }
    var completedCount: Int    { tasks.filter {  $0.completed }.count }
    var activeGoals:    Int    { goals.count }
    var topStreak:      Int    { goals.map(\.streak).max() ?? 0 }
    var recentTasks:    [HTask] { Array(tasks.filter { !$0.completed }.prefix(8)) }
    var allTasksDoneToday: Bool { !tasks.isEmpty && tasks.allSatisfy { $0.completed } }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let t = TaskService.shared.getTasks()
            async let g = GoalService.shared.getGoals()
            (tasks, goals) = try await (t, g)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func suggestedTasks(for mood: String) -> [HTask] {
        let pending = tasks.filter { !$0.completed }
        switch mood {
        case "energetic": return Array(pending.filter { $0.priority == "high" }.prefix(3))
        case "tired":     return Array(pending.filter { $0.priority == "low" }.prefix(3))
        default:          return Array(pending.filter { $0.priority == "medium" }.prefix(3))
        }
    }
}
