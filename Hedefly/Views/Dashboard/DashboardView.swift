import SwiftUI

struct DashboardView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var vm = DashboardViewModel()
    @State private var moodManager = MoodManager.shared
    @State private var showMoodPicker = false
    @State private var focusTask: HTask? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0D0D0D").ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // MARK: – Header
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

                        // MARK: – Mood badge (tappable to change)
                        if let mood = moodManager.selectedMood {
                            Button { showMoodPicker = true } label: {
                                HStack(spacing: 10) {
                                    Text(mood.emoji).font(.title3)
                                    Text("Feeling \(mood.label)")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("Change")
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "A78BFA"))
                                }
                                .padding(14)
                                .background(Color.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal, 20)
                        }

                        // MARK: – Stats Grid
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

                        // MARK: – Mood-Based Suggestions
                        if let mood = moodManager.selectedMood {
                            let suggested = vm.suggestedTasks(for: mood.rawValue)
                            if !suggested.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Suggested for You")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text(mood.emoji)
                                    }
                                    .padding(.horizontal, 20)

                                    ForEach(suggested) { task in
                                        Button {
                                            focusTask = task
                                        } label: {
                                            SuggestedTaskRow(task: task)
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }

                        // MARK: – Up Next (grouped by time slot)
                        if !vm.recentTasks.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Up Next")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)

                                ForEach(timeSlotOrder, id: \.self) { slot in
                                    let slotTasks = vm.recentTasks.filter { ($0.timeSlot ?? "anytime") == slot }
                                    if !slotTasks.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(slotLabel(slot))
                                                .font(.caption.weight(.semibold))
                                                .foregroundColor(Color(hex: "A78BFA"))
                                                .padding(.horizontal, 20)

                                            ForEach(slotTasks) { task in
                                                Button {
                                                    focusTask = task
                                                } label: {
                                                    DashboardTaskRow(task: task)
                                                }
                                                .padding(.horizontal, 20)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // MARK: – End-of-day summary
                        if vm.allTasksDoneToday {
                            VStack(spacing: 12) {
                                Text("🎉").font(.system(size: 44))
                                Text("All tasks completed!")
                                    .font(.headline).foregroundColor(.white)
                                Text("Great work today. Time to rest and recharge.")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(24)
                            .background(
                                LinearGradient(colors: [Color(hex: "7C3AED").opacity(0.15), Color(hex: "4F46E5").opacity(0.08)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "A78BFA").opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
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
            .onAppear {
                if !moodManager.hasPickedToday {
                    showMoodPicker = true
                }
            }
            .sheet(isPresented: $showMoodPicker) {
                MoodPickerView { mood in
                    moodManager.selectMood(mood)
                }
            }
            .sheet(item: $focusTask) { task in
                FocusTimerView(task: task) {
                    Task { await vm.load() }
                }
            }
        }
    }

    // MARK: – Helpers
    private let timeSlotOrder = ["morning", "afternoon", "evening", "anytime"]

    private func slotLabel(_ slot: String) -> String {
        switch slot {
        case "morning":   return "🌅  Morning"
        case "afternoon": return "☀️  Afternoon"
        case "evening":   return "🌙  Evening"
        default:          return "📋  Anytime"
        }
    }
}

// MARK: – Dashboard Task Row
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
            Image(systemName: "play.circle.fill")
                .foregroundColor(Color(hex: "A78BFA").opacity(0.5))
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

// MARK: – Suggested Task Row (mood-based)
private struct SuggestedTaskRow: View {
    let task: HTask
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .foregroundColor(Color(hex: "A78BFA"))
            Text(task.title)
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer()
            Image(systemName: "play.circle.fill")
                .foregroundColor(Color(hex: "A78BFA").opacity(0.5))
        }
        .padding(14)
        .background(
            LinearGradient(colors: [Color(hex: "7C3AED").opacity(0.1), Color(hex: "4F46E5").opacity(0.05)],
                           startPoint: .leading, endPoint: .trailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "A78BFA").opacity(0.15), lineWidth: 1)
        )
    }
}

// Make HTask identifiable for .sheet(item:)
extension HTask: @retroactive Hashable {
    static func == (lhs: HTask, rhs: HTask) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
