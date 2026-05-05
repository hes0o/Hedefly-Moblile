import SwiftUI

@main
struct HedeflyApp: App {
    @State private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authManager)
                .preferredColorScheme(.dark)
        }
    }
}

struct RootView: View {
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        if authManager.isAuthenticated {
            ContentView()
        } else {
            LoginView()
        }
    }
}
