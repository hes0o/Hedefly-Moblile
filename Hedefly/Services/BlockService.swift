import Foundation

final class BlockService {
    static let shared = BlockService()
    private init() {}

    func addBlock(pageId: String, type: String, content: String, order: Int) async throws -> Block {
        let res: BlockResponse = try await APIService.shared.request(
            endpoint: Constants.Endpoints.blocks(pageId: pageId), method: "POST",
            body: ["type": type, "content": content, "order": order]
        )
        return res.block
    }

    func updateBlock(id: String, fields: [String: Any]) async throws -> Block {
        let res: BlockResponse = try await APIService.shared.request(
            endpoint: Constants.Endpoints.block(id: id), method: "PUT", body: fields
        )
        return res.block
    }

    func deleteBlock(id: String) async throws {
        try await APIService.shared.requestVoid(
            endpoint: Constants.Endpoints.block(id: id), method: "DELETE"
        )
    }

    func reorderBlocks(pageId: String, blocks: [(id: String, order: Int)]) async throws {
        let payload = blocks.map { ["id": $0.id, "order": "\($0.order)"] }
        try await APIService.shared.requestVoid(
            endpoint: Constants.Endpoints.reorderBlocks(pageId: pageId), method: "PUT",
            body: ["blocks": payload]
        )
    }
}
