import Foundation

final class GoalService {
    static let shared = GoalService()
    private init() {}

    func getGoals() async throws -> [Goal] {
        let res: GoalsResponse = try await APIService.shared.request(endpoint: Constants.Endpoints.goals)
        return res.goals
    }

    func createGoal(title: String, frequency: String) async throws -> Goal {
        let res: GoalResponse = try await APIService.shared.request(
            endpoint: Constants.Endpoints.goals, method: "POST",
            body: ["title": title, "frequency": frequency]
        )
        return res.goal
    }

    func updateProgress(id: String, progress: Double, completedToday: Bool) async throws -> Goal {
        let res: GoalResponse = try await APIService.shared.request(
            endpoint: Constants.Endpoints.goalProgress(id: id), method: "PUT",
            body: ["progress": progress, "completedToday": completedToday]
        )
        return res.goal
    }

    func deleteGoal(id: String) async throws {
        try await APIService.shared.requestVoid(
            endpoint: Constants.Endpoints.goal(id: id), method: "DELETE"
        )
    }
}
