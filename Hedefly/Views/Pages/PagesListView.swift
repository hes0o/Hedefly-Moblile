import SwiftUI

struct PagesListView: View {
    @State private var vm = PageViewModel()
    @State private var showAdd = false
    @State private var newTitle = ""
    @State private var navigateTo: Page?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0D0D0D").ignoresSafeArea()

                Group {
                    if vm.isLoading && vm.pages.isEmpty {
                        ProgressView().tint(Color(hex: "A78BFA"))
                    } else if vm.pages.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 50))
                                .foregroundColor(Color(hex: "A78BFA").opacity(0.4))
                            Text("No pages yet").foregroundColor(.white.opacity(0.5))
                        }
                    } else {
                        List {
                            ForEach(vm.pages) { page in
                                NavigationLink(destination: PageEditorView(page: page)) {
                                    PageRowView(page: page)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                            .onDelete { idx in
                                idx.forEach { i in
                                    Task { await vm.delete(id: vm.pages[i].id) }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Pages")
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
            .alert("New Page", isPresented: $showAdd) {
                TextField("Page title", text: $newTitle)
                Button("Create") {
                    let t = newTitle
                    newTitle = ""
                    Task { await vm.addPage(title: t) }
                }
                Button("Cancel", role: .cancel) { newTitle = "" }
            }
        }
    }
}

private struct PageRowView: View {
    let page: Page
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "doc.fill")
                .foregroundColor(Color(hex: "818CF8"))
                .font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text(page.title)
                    .foregroundColor(.white)
                    .font(.headline)
                    .lineLimit(1)
                Text(String(page.updatedAt?.prefix(10) ?? page.createdAt.prefix(10)))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.2))
                .font(.caption)
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.vertical, 4)
    }
}
