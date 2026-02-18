import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var query = "" {
        didSet { updateResults() }
    }

    @Published var selectedIndex = 0
    @Published var results: [FuzzyMatcher.Match] = []
    @Published var calculatorResult: String?
    private var allApps: [AppInfo] = []

    var selectedApp: AppInfo? {
        guard selectedIndex >= 0, selectedIndex < results.count else { return nil }
        return results[selectedIndex].app
    }

    func reset() {
        allApps = AppFinder.findApplications()
        query = ""
        selectedIndex = 0
        calculatorResult = nil
        updateResults()
    }

    func moveUp() {
        guard !results.isEmpty else { return }
        if selectedIndex > 0 {
            selectedIndex -= 1
        } else {
            selectedIndex = results.count - 1
        }
    }

    func moveDown() {
        guard !results.isEmpty else { return }
        if selectedIndex < results.count - 1 {
            selectedIndex += 1
        } else {
            selectedIndex = 0
        }
    }

    func launchSelected() -> Bool {
        guard let app = selectedApp else { return false }
        AppLauncher.launch(app)
        return true
    }

    private func updateResults() {
        if query.isEmpty {
            results = []
            calculatorResult = nil
        } else {
            results = FuzzyMatcher.filter(apps: allApps, query: query)
            calculatorResult = Preferences.calculatorEnabled ? ExpressionEvaluator.evaluate(query) : nil
        }
        selectedIndex = 0
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
                    if viewModel.query.isEmpty {
                        onDismiss()
                    } else {
                        viewModel.query = ""
                    }
                }
            )
            .padding(.horizontal, 24)
            .padding(.top, 12)

            if let result = viewModel.calculatorResult {
                HStack {
                    Text("= \(result)")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 6)
            }

            Divider()
                .padding(.horizontal, 16)
                .padding(.top, 12)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.results.enumerated()), id: \.element.app.id) { index, match in
                            SearchResultRow(
                                app: match.app,
                                isSelected: index == viewModel.selectedIndex,
                                fontSize: Preferences.fontSize
                            )
                            .id(match.app.id)
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
                .onChange(of: viewModel.selectedIndex) { _ in
                    if let app = viewModel.selectedApp {
                        withAnimation {
                            proxy.scrollTo(app.id, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(width: 680)
    }
}
