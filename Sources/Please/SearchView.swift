import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var selectedIndex = 0
    @Published var allApps: [AppInfo] = []

    var filteredApps: [FuzzyMatcher.Match] {
        let matches = FuzzyMatcher.filter(apps: allApps, query: query)
        return Array(matches.prefix(Preferences.maxResults))
    }

    var selectedApp: AppInfo? {
        let matches = filteredApps
        guard selectedIndex >= 0, selectedIndex < matches.count else { return nil }
        return matches[selectedIndex].app
    }

    func reset() {
        query = ""
        selectedIndex = 0
        allApps = AppFinder.findApplications()
    }

    func moveUp() {
        if selectedIndex > 0 {
            selectedIndex -= 1
        }
    }

    func moveDown() {
        let count = filteredApps.count
        if selectedIndex < count - 1 {
            selectedIndex += 1
        }
    }

    func launchSelected() -> Bool {
        guard let app = selectedApp else { return false }
        AppLauncher.launch(app)
        return true
    }
}

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            PleaseSentenceView(appName: viewModel.selectedApp?.name)
                .padding(.top, 20)
                .padding(.horizontal, 24)

            SearchField(
                text: $viewModel.query,
                onMoveUp: { viewModel.moveUp() },
                onMoveDown: { viewModel.moveDown() },
                onSubmit: {
                    if viewModel.launchSelected() {
                        onDismiss()
                    }
                },
                onEscape: {
                    onDismiss()
                }
            )
            .padding(.horizontal, 24)
            .padding(.top, 12)

            Divider()
                .padding(.horizontal, 16)
                .padding(.top, 12)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.filteredApps.enumerated()), id: \.element.app.id) { index, match in
                            SearchResultRow(
                                app: match.app,
                                isSelected: index == viewModel.selectedIndex,
                                fontSize: Preferences.fontSize
                            )
                            .id(index)
                            .onTapGesture {
                                viewModel.selectedIndex = index
                                if viewModel.launchSelected() {
                                    onDismiss()
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onChange(of: viewModel.selectedIndex) { newIndex in
                    withAnimation {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }
        }
        .frame(width: 680, height: 400)
        .onChange(of: viewModel.query) { _ in
            viewModel.selectedIndex = 0
        }
    }
}
