import Foundation

// MARK: - User
struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
}

// MARK: - Task
struct HTask: Codable, Identifiable {
    let id: String
    var title: String
    var completed: Bool
    var priority: String          // "high" | "medium" | "low"
    var dueDate: String?
    var linkedBlockId: String?
}

// MARK: - Goal
struct Goal: Codable, Identifiable {
    let id: String
    var title: String
    var frequency: String         // "daily" | "weekly"
    var streak: Int
    var progress: Double
}

// MARK: - Page
struct Page: Codable, Identifiable {
    let id: String
    var title: String
    var blocks: [Block]?
    let createdAt: String
    let updatedAt: String?
}

// MARK: - Block
struct Block: Codable, Identifiable {
    let id: String
    let pageId: String?
    var type: String              // "text" | "heading" | "task"
    var content: String
    var order: Int
}

// MARK: - Response wrappers
struct AuthResponse: Codable {
    let message: String
    let token: String
    let user: User
}

struct TasksResponse: Codable  { let tasks: [HTask] }
struct TaskResponse: Codable   { let task: HTask }

struct GoalsResponse: Codable  { let goals: [Goal] }
struct GoalResponse: Codable   { let goal: Goal }

struct PagesResponse: Codable  { let pages: [Page] }
struct PageResponse: Codable   { let page: Page }

struct BlockResponse: Codable  { let block: Block }

struct MessageResponse: Codable { let message: String }
