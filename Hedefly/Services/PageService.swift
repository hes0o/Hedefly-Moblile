import Foundation

final class PageService {
    static let shared = PageService()
    private init() {}

    func getPages() async throws -> [Page] {
        let res: PagesResponse = try await APIService.shared.request(endpoint: Constants.Endpoints.pages)
        return res.pages
    }

    func createPage(title: String) async throws -> Page {
        let res: PageResponse = try await APIService.shared.request(
            endpoint: Constants.Endpoints.pages, method: "POST",
            body: ["title": title]
        )
        return res.page
    }

    func getPage(id: String) async throws -> Page {
        let res: PageResponse = try await APIService.shared.request(endpoint: Constants.Endpoints.page(id: id))
        return res.page
    }

    func updatePage(id: String, title: String) async throws -> Page {
        let res: PageResponse = try await APIService.shared.request(
            endpoint: Constants.Endpoints.page(id: id), method: "PUT",
            body: ["title": title]
        )
        return res.page
    }

    func deletePage(id: String) async throws {
        try await APIService.shared.requestVoid(
            endpoint: Constants.Endpoints.page(id: id), method: "DELETE"
        )
    }
}
