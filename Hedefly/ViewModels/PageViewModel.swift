import Foundation
import Observation

@Observable
final class PageViewModel {
    var pages: [Page] = []
    var isLoading = false
    var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do { pages = try await PageService.shared.getPages() }
        catch { errorMessage = error.localizedDescription }
    }

    func addPage(title: String) async -> Page? {
        do {
            let p = try await PageService.shared.createPage(title: title)
            pages.insert(p, at: 0)
            return p
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func delete(id: String) async {
        do {
            try await PageService.shared.deletePage(id: id)
            pages.removeAll { $0.id == id }
        } catch { errorMessage = error.localizedDescription }
    }
}

@Observable
final class BlockViewModel {
    var blocks: [Block] = []
    var isLoading = false
    var errorMessage: String?
    let pageId: String

    init(pageId: String) { self.pageId = pageId }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let page = try await PageService.shared.getPage(id: pageId)
            blocks = (page.blocks ?? []).sorted { $0.order < $1.order }
        } catch { errorMessage = error.localizedDescription }
    }

    func addBlock(type: String, content: String) async {
        let nextOrder = (blocks.map(\.order).max() ?? 0) + 1
        do {
            let b = try await BlockService.shared.addBlock(pageId: pageId, type: type, content: content, order: nextOrder)
            blocks.append(b)
        } catch { errorMessage = error.localizedDescription }
    }

    func updateBlock(id: String, content: String) async {
        do {
            let updated = try await BlockService.shared.updateBlock(id: id, fields: ["content": content])
            if let idx = blocks.firstIndex(where: { $0.id == id }) {
                blocks[idx] = updated
            }
        } catch { errorMessage = error.localizedDescription }
    }

    func delete(id: String) async {
        do {
            try await BlockService.shared.deleteBlock(id: id)
            blocks.removeAll { $0.id == id }
        } catch { errorMessage = error.localizedDescription }
    }

    func move(from source: IndexSet, to destination: Int) {
        blocks.move(fromOffsets: source, toOffset: destination)
        Task {
            let reordered = blocks.enumerated().map { (id: $0.element.id, order: $0.offset + 1) }
            try? await BlockService.shared.reorderBlocks(pageId: pageId, blocks: reordered)
        }
    }
}
