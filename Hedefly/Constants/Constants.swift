import Foundation

enum Constants {
    static let baseURL = "http://localhost:5000/api"

    enum Endpoints {
        // Auth
        static let login     = "/auth/login"
        static let register  = "/auth/register"

        // Tasks
        static let tasks = "/tasks"
        static func task(id: String)  -> String { "/tasks/\(id)" }

        // Goals
        static let goals = "/goals"
        static func goal(id: String)           -> String { "/goals/\(id)" }
        static func goalProgress(id: String)   -> String { "/goals/\(id)/progress" }

        // Pages
        static let pages = "/pages"
        static func page(id: String)           -> String { "/pages/\(id)" }

        // Blocks
        static func blocks(pageId: String)          -> String { "/pages/\(pageId)/blocks" }
        static func reorderBlocks(pageId: String)   -> String { "/pages/\(pageId)/blocks/reorder" }
        static func block(id: String)               -> String { "/blocks/\(id)" }
    }
}
