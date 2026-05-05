import SwiftUI

struct GoalsView: View {
    @State private var vm = GoalViewModel()
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0D0D0D").ignoresSafeArea()

                Group {
                    if vm.isLoading && vm.goals.isEmpty {
                        ProgressView().tint(Color(hex: "A78BFA"))
                    } else if vm.goals.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "target")
                                .font(.system(size: 50))
                                .foregroundColor(Color(hex: "A78BFA").opacity(0.4))
                            Text("No goals yet").foregroundColor(.white.opacity(0.5))
                        }
                    } else {
                        List {
                            ForEach(vm.goals) { goal in
                                GoalRowView(goal: goal) {
                                    Task { await vm.markDone(goal) }
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                            .onDelete { idx in
                                idx.forEach { i in
                                    Task { await vm.delete(id: vm.goals[i].id) }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(hex: "A78BFA"))
                            .font(.title3)
                    }
                }
            }
            .task { await vm.load() }
            .refreshable { await vm.load() }
            .sheet(isPresented: $showAdd) {
                AddGoalView { title, frequency in
                    Task { await vm.addGoal(title: title, frequency: frequency) }
                }
            }
        }
    }
}

private struct GoalRowView: View {
    let goal: Goal
    let onMarkDone: () -> Void

    private var progressColor: Color {
        goal.progress >= 80 ? Color(hex: "10B981") :
        goal.progress >= 40 ? Color(hex: "F59E0B") : Color(hex: "818CF8")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    HStack(spacing: 8) {
                        Label(goal.frequency.capitalized, systemImage: "calendar")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                        Label("\(goal.streak)🔥", systemImage: "flame")
                            .font(.caption2)
                            .foregroundColor(Color(hex: "F87171"))
                    }
                }
                Spacer()
                Button(action: onMarkDone) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: "10B981"))
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08)).frame(height: 6)
                    Capsule()
                        .fill(progressColor)
                        .frame(width: geo.size.width * CGFloat(goal.progress / 100), height: 6)
                        .animation(.spring(response: 0.5), value: goal.progress)
                }
            }
            .frame(height: 6)

            HStack {
                Spacer()
                Text("\(Int(goal.progress))%")
                    .font(.caption2)
                    .foregroundColor(progressColor)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.vertical, 4)
    }
}

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (String, String) -> Void

    @State private var title     = ""
    @State private var frequency = "daily"

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "12111A").ignoresSafeArea()
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Goal title").font(.caption).foregroundColor(.white.opacity(0.5))
                        TextField("e.g. Read 10 pages daily", text: $title)
                            .padding(14)
                            .background(Color.white.opacity(0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundColor(.white)
                            .tint(Color(hex: "A78BFA"))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Frequency").font(.caption).foregroundColor(.white.opacity(0.5))
                        Picker("", selection: $frequency) {
                            Text("Daily").tag("daily")
                            Text("Weekly").tag("weekly")
                        }
                        .pickerStyle(.segmented)
                    }

                    Button {
                        guard !title.isEmpty else { return }
                        onAdd(title, frequency)
                        dismiss()
                    } label: {
                        Text("Add Goal")
                            .font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(LinearGradient(colors: [Color(hex: "7C3AED"), Color(hex: "4F46E5")],
                                                       startPoint: .leading, endPoint: .trailing))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(title.isEmpty)
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(Color(hex: "A78BFA"))
                }
            }
        }
    }
}
