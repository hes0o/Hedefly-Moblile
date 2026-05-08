import Foundation

// MARK: - Shared CodingKeys helper to map MongoDB _id → id
private enum MongoID: String, CodingKey {
    case id = "_id"
}

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
    var priority: String
    var dueDate: String?
    var timeSlot: String?       // "morning" | "afternoon" | "evening"
    var linkedBlockId: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id", title, completed, priority, dueDate, timeSlot, linkedBlockId
    }
}

// MARK: - Goal
struct Goal: Codable, Identifiable {
    let id: String
    var title: String
    var frequency: String
    var streak: Int
    var progress: Double

    enum CodingKeys: String, CodingKey {
        case id = "_id", title, frequency, streak, progress
    }
}

// MARK: - Page
struct Page: Codable, Identifiable {
    let id: String
    var title: String
    var blocks: [Block]?
    let createdAt: String
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id", title, blocks, createdAt, updatedAt
    }
}

// MARK: - Block
struct Block: Codable, Identifiable {
    let id: String
    let pageId: String?
    var type: String
    var content: String
    var order: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id", pageId, type, content, order
    }
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
