import Foundation
import Observation

@Observable
final class GoalViewModel {
    var goals: [Goal] = []
    var isLoading = false
    var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do { goals = try await GoalService.shared.getGoals() }
        catch { errorMessage = error.localizedDescription }
    }

    func addGoal(title: String, frequency: String) async {
        do {
            let g = try await GoalService.shared.createGoal(title: title, frequency: frequency)
            goals.insert(g, at: 0)
        } catch { errorMessage = error.localizedDescription }
    }

    func markDone(_ goal: Goal) async {
        let newProgress = min(goal.progress + 10, 100)
        do {
            let updated = try await GoalService.shared.updateProgress(id: goal.id, progress: newProgress, completedToday: true)
            if let idx = goals.firstIndex(where: { $0.id == goal.id }) {
                goals[idx] = updated
            }
        } catch { errorMessage = error.localizedDescription }
    }

    func delete(id: String) async {
        do {
            try await GoalService.shared.deleteGoal(id: id)
            goals.removeAll { $0.id == id }
        } catch { errorMessage = error.localizedDescription }
    }
}
