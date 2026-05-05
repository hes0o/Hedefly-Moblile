import SwiftUI

struct PageEditorView: View {
    let page: Page
    @State private var vm: BlockViewModel
    @State private var showAddBlock = false
    @State private var editingBlock: Block?
    @State private var editContent  = ""

    init(page: Page) {
        self.page = page
        _vm = State(initialValue: BlockViewModel(pageId: page.id))
    }

    var body: some View {
        ZStack {
            Color(hex: "0D0D0D").ignoresSafeArea()

            if vm.isLoading && vm.blocks.isEmpty {
                ProgressView().tint(Color(hex: "A78BFA"))
            } else if vm.blocks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "818CF8").opacity(0.4))
                    Text("Empty page — add your first block")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                }
            } else {
                List {
                    ForEach(vm.blocks) { block in
                        BlockRowView(block: block) {
                            editingBlock = block
                            editContent = block.content
                        } onDelete: {
                            Task { await vm.delete(id: block.id) }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .onMove { vm.move(from: $0, to: $1) }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.editMode, .constant(.active))
            }
        }
        .navigationTitle(page.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAddBlock = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: "A78BFA"))
                }
            }
        }
        .task { await vm.load() }
        .sheet(isPresented: $showAddBlock) {
            AddBlockView { type, content in
                Task { await vm.addBlock(type: type, content: content) }
            }
        }
        .sheet(item: $editingBlock) { block in
            EditBlockView(block: block, content: $editContent) {
                Task { await vm.updateBlock(id: block.id, content: editContent) }
            }
        }
    }
}

// MARK: - Block Row
private struct BlockRowView: View {
    let block: Block
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Type indicator
            blockTypeIcon
                .frame(width: 28)
                .padding(.top, 2)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                switch block.type {
                case "heading":
                    Text(block.content)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                case "task":
                    HStack(spacing: 8) {
                        Image(systemName: "square")
                            .foregroundColor(Color(hex: "A78BFA"))
                        Text(block.content)
                            .foregroundColor(.white)
                    }
                default:
                    Text(block.content)
                        .foregroundColor(.white.opacity(0.85))
                        .font(.body)
                }
            }
            Spacer()

            // Actions
            HStack(spacing: 14) {
                Button(action: onEdit) {
                    Image(systemName: "pencil").foregroundColor(Color(hex: "818CF8"))
                }
                Button(action: onDelete) {
                    Image(systemName: "trash").foregroundColor(Color(hex: "F87171"))
                }
            }
            .font(.caption)
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.vertical, 4)
    }

    @ViewBuilder private var blockTypeIcon: some View {
        switch block.type {
        case "heading":
            Image(systemName: "h.square.fill")
                .foregroundColor(Color(hex: "FBBF24"))
        case "task":
            Image(systemName: "checklist")
                .foregroundColor(Color(hex: "34D399"))
        default:
            Image(systemName: "text.alignleft")
                .foregroundColor(Color(hex: "818CF8"))
        }
    }
}

// MARK: - Add Block Sheet
struct AddBlockView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (String, String) -> Void

    @State private var type    = "text"
    @State private var content = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "12111A").ignoresSafeArea()
                VStack(spacing: 24) {
                    // Type picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Block type").font(.caption).foregroundColor(.white.opacity(0.5))
                        HStack(spacing: 10) {
                            ForEach(["text", "heading", "task"], id: \.self) { t in
                                Button {
                                    type = t
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: iconFor(t))
                                        Text(t.capitalized)
                                    }
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(type == t ? .white : .white.opacity(0.5))
                                    .padding(.horizontal, 12).padding(.vertical, 8)
                                    .background(type == t ? Color(hex: "4F46E5") : Color.white.opacity(0.07))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content").font(.caption).foregroundColor(.white.opacity(0.5))
                        TextField(placeholderFor(type), text: $content, axis: .vertical)
                            .lineLimit(3...8)
                            .padding(14)
                            .background(Color.white.opacity(0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundColor(.white)
                            .tint(Color(hex: "A78BFA"))
                    }

                    Button {
                        guard !content.isEmpty else { return }
                        onAdd(type, content)
                        dismiss()
                    } label: {
                        Text("Add Block")
                            .font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(LinearGradient(colors: [Color(hex: "7C3AED"), Color(hex: "4F46E5")],
                                                       startPoint: .leading, endPoint: .trailing))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(content.isEmpty)
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("New Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(Color(hex: "A78BFA"))
                }
            }
        }
    }

    private func iconFor(_ t: String) -> String {
        switch t { case "heading": return "h.square"; case "task": return "checklist"; default: return "text.alignleft" }
    }
    private func placeholderFor(_ t: String) -> String {
        switch t { case "heading": return "Section heading..."; case "task": return "Task description..."; default: return "Write something..." }
    }
}

// MARK: - Edit Block Sheet
struct EditBlockView: View {
    let block: Block
    @Binding var content: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "12111A").ignoresSafeArea()
                VStack(spacing: 20) {
                    TextField("Content", text: $content, axis: .vertical)
                        .lineLimit(3...10)
                        .padding(14)
                        .background(Color.white.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundColor(.white)
                        .tint(Color(hex: "A78BFA"))

                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Text("Save Changes")
                            .font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(LinearGradient(colors: [Color(hex: "7C3AED"), Color(hex: "4F46E5")],
                                                       startPoint: .leading, endPoint: .trailing))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Edit Block")
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
