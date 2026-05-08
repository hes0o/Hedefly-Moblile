import SwiftUI

struct TasksView: View {
    @State private var vm = TaskViewModel()
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0D0D0D").ignoresSafeArea()

                Group {
                    if vm.isLoading && vm.tasks.isEmpty {
                        ProgressView().tint(Color(hex: "A78BFA"))
                    } else if vm.tasks.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 50))
                                .foregroundColor(Color(hex: "A78BFA").opacity(0.5))
                            Text("No tasks yet").foregroundColor(.white.opacity(0.5))
                        }
                    } else {
                        List {
                            ForEach(vm.tasks) { task in
                                TaskRowView(task: task) {
                                    Task { await vm.toggle(task) }
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                            .onDelete { idx in
                                idx.forEach { i in
                                    Task { await vm.delete(id: vm.tasks[i].id) }
                                }
                            }
                            .onMove { source, destination in
                                vm.move(from: source, to: destination)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                        .foregroundColor(Color(hex: "A78BFA"))
                }
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
                AddTaskView { title, priority, timeSlot in
                    Task { await vm.addTask(title: title, priority: priority, timeSlot: timeSlot) }
                }
            }
        }
    }
}

struct TaskRowView: View {
    let task: HTask
    let onToggle: () -> Void

    private var priorityColor: Color {
        switch task.priority {
        case "high":   return Color(hex: "F87171")
        case "medium": return Color(hex: "F59E0B")
        default:       return Color(hex: "10B981")
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggle) {
                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.completed ? Color(hex: "10B981") : .white.opacity(0.4))
                    .animation(.easeInOut(duration: 0.2), value: task.completed)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .foregroundColor(task.completed ? .white.opacity(0.4) : .white)
                    .strikethrough(task.completed)
                    .lineLimit(2)
                    .font(.body)

                HStack(spacing: 6) {
                    Circle().fill(priorityColor).frame(width: 6, height: 6)
                    Text(task.priority.capitalized)
                        .font(.caption2)
                        .foregroundColor(priorityColor)
                    if let slot = task.timeSlot {
                        Text("· \(slotEmoji(slot)) \(slot.capitalized)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.4))
                    }
                    if let due = task.dueDate {
                        Text("· Due \(String(due.prefix(10)))")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.vertical, 4)
    }

    private func slotEmoji(_ slot: String) -> String {
        switch slot {
        case "morning":   return "🌅"
        case "afternoon": return "☀️"
        case "evening":   return "🌙"
        default:          return ""
        }
    }
}

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (String, String, String?) -> Void

    @State private var title    = ""
    @State private var priority = "medium"
    @State private var timeSlot = "anytime"

    private let timeSlots = [
        ("anytime",   "📋", "Anytime"),
        ("morning",   "🌅", "Morning"),
        ("afternoon", "☀️", "Afternoon"),
        ("evening",   "🌙", "Evening"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "12111A").ignoresSafeArea()

                VStack(spacing: 24) {
                    // Title field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task title").font(.caption).foregroundColor(.white.opacity(0.5))
                        TextField("e.g. Study for midterms", text: $title)
                            .padding(14)
                            .background(Color.white.opacity(0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundColor(.white)
                            .tint(Color(hex: "A78BFA"))
                    }

                    // Priority picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Priority").font(.caption).foregroundColor(.white.opacity(0.5))
                        Picker("Priority", selection: $priority) {
                            Text("High").tag("high")
                            Text("Medium").tag("medium")
                            Text("Low").tag("low")
                        }
                        .pickerStyle(.segmented)
                        .tint(Color(hex: "A78BFA"))
                    }

                    // Time slot picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("When?").font(.caption).foregroundColor(.white.opacity(0.5))
                        HStack(spacing: 10) {
                            ForEach(timeSlots, id: \.0) { slot in
                                Button {
                                    timeSlot = slot.0
                                } label: {
                                    VStack(spacing: 6) {
                                        Text(slot.1).font(.title3)
                                        Text(slot.2).font(.caption2)
                                    }
                                    .foregroundColor(timeSlot == slot.0 ? .white : .white.opacity(0.4))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        timeSlot == slot.0
                                            ? Color(hex: "7C3AED").opacity(0.3)
                                            : Color.white.opacity(0.05)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                timeSlot == slot.0
                                                    ? Color(hex: "A78BFA").opacity(0.4)
                                                    : Color.clear,
                                                lineWidth: 1
                                            )
                                    )
                                }
                            }
                        }
                    }

                    // Add button
                    Button {
                        guard !title.isEmpty else { return }
                        onAdd(title, priority, timeSlot == "anytime" ? nil : timeSlot)
                        dismiss()
                    } label: {
                        Text("Add Task")
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
            .navigationTitle("New Task")
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
