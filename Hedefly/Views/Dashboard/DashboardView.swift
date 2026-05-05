import SwiftUI

struct DashboardView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var vm = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0D0D0D").ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(vm.greeting) 👋")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                                Text(authManager.currentUser?.name ?? "Welcome")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Button { authManager.logout() } label: {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(Color(hex: "A78BFA"))
                                    .font(.title3)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        // Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            StatsCardView(title: "Pending", value: "\(vm.pendingCount)",
                                          icon: "clock.fill", color: Color(hex: "F59E0B"))
                            StatsCardView(title: "Completed", value: "\(vm.completedCount)",
                                          icon: "checkmark.circle.fill", color: Color(hex: "10B981"))
                            StatsCardView(title: "Goals", value: "\(vm.activeGoals)",
                                          icon: "target", color: Color(hex: "818CF8"))
                            StatsCardView(title: "Top Streak", value: "\(vm.topStreak)🔥",
                                          icon: "flame.fill", color: Color(hex: "F87171"))
                        }
                        .padding(.horizontal, 20)

                        // Upcoming Tasks
                        if !vm.recentTasks.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Up Next")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)

                                ForEach(vm.recentTasks) { task in
                                    DashboardTaskRow(task: task)
                                        .padding(.horizontal, 20)
                                }
                            }
                        }

                        if vm.isLoading {
                            HStack { Spacer(); ProgressView().tint(Color(hex: "A78BFA")); Spacer() }
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .task { await vm.load() }
            .refreshable { await vm.load() }
        }
    }
}

private struct DashboardTaskRow: View {
    let task: HTask
    private var priorityColor: Color {
        switch task.priority {
        case "high":   return Color(hex: "F87171")
        case "medium": return Color(hex: "F59E0B")
        default:       return Color(hex: "10B981")
        }
    }
    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(priorityColor).frame(width: 8, height: 8)
            Text(task.title)
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer()
            Text(task.priority.capitalized)
                .font(.caption)
                .foregroundColor(priorityColor)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(priorityColor.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
