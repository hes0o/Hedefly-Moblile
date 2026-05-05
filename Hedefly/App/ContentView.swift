import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            TasksView()
                .tabItem {
                    Label("Tasks", systemImage: "checkmark.circle.fill")
                }
            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
            PagesListView()
                .tabItem {
                    Label("Pages", systemImage: "doc.fill")
                }
        }
        .tint(Color(hex: "A78BFA"))
    }
}
