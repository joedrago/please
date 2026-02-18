import AppKit
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var query = "" {
        didSet { updateResults() }
    }

    @Published var selectedIndex = 0
    @Published var results: [FuzzyMatcher.Match] = []
    @Published var calculatorResult: String?
    @Published var calculatorCopied = false
    @Published var lowPriorityApps: Set<String> = Preferences.lowPriorityApps
    @Published var highPriorityApps: Set<String> = Preferences.highPriorityApps
    @Published var appAliases: [String: String] = Preferences.appAliases
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
        calculatorCopied = false
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

    @discardableResult
    func copyCalculatorResult() -> Bool {
        guard let result = calculatorResult else { return false }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(result, forType: .string)
        calculatorCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.calculatorCopied = false
        }
        return true
    }

    func updateResults() {
        if query.isEmpty {
            results = []
            calculatorResult = nil
        } else {
            results = FuzzyMatcher.filter(
                apps: allApps,
                query: query,
                fuzzy: Preferences.fuzzySearch,
                lowPriorityIDs: lowPriorityApps,
                highPriorityIDs: highPriorityApps,
                aliases: appAliases
            )
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
                    } else {
                        viewModel.copyCalculatorResult()
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
                    Text(viewModel.calculatorCopied ? "= \(result)  — Copied!" : "= \(result)")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 6)
                .animation(.easeInOut(duration: 0.15), value: viewModel.calculatorCopied)
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
                                isLowPriority: viewModel.lowPriorityApps.contains(match.app.id),
                                isHighPriority: viewModel.highPriorityApps.contains(match.app.id),
                                alias: viewModel.appAliases[match.app.id],
                                fontSize: Preferences.fontSize
                            )
                            .id(match.app.id)
                            .onTapGesture {
                                viewModel.selectedIndex = index
                                if viewModel.launchSelected() {
                                    onDismiss()
                                }
                            }
                            .contextMenu {
                                Button("Set Alias...") {
                                    let appID = match.app.id
                                    let appName = match.app.name
                                    let current = viewModel.appAliases[appID]
                                    DispatchQueue.main.async {
                                        Self.showAliasAlert(appName: appName, current: current) { newAlias in
                                            Preferences.setAlias(newAlias, for: appID)
                                            viewModel.appAliases = Preferences.appAliases
                                            viewModel.updateResults()
                                        }
                                    }
                                }
                                Button(viewModel.highPriorityApps.contains(match.app.id)
                                    ? "Unmark High Priority"
                                    : "Mark as High Priority")
                                {
                                    Preferences.toggleHighPriority(match.app.id)
                                    viewModel.highPriorityApps = Preferences.highPriorityApps
                                    viewModel.lowPriorityApps = Preferences.lowPriorityApps
                                    viewModel.updateResults()
                                }
                                Button(viewModel.lowPriorityApps.contains(match.app.id)
                                    ? "Unmark Low Priority"
                                    : "Mark as Low Priority")
                                {
                                    Preferences.toggleLowPriority(match.app.id)
                                    viewModel.lowPriorityApps = Preferences.lowPriorityApps
                                    viewModel.highPriorityApps = Preferences.highPriorityApps
                                    viewModel.updateResults()
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

    private static func showAliasAlert(
        appName: String,
        current: String?,
        completion: @escaping (String?) -> Void
    ) {
        let alert = NSAlert()
        alert.messageText = "Set alias for \(appName)"
        alert.addButton(withTitle: "Set")
        alert.addButton(withTitle: "Cancel")
        if current != nil {
            alert.addButton(withTitle: "Clear")
        }

        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
        field.stringValue = current ?? ""
        field.placeholderString = "Alias"
        alert.accessoryView = field
        alert.window.initialFirstResponder = field

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let text = field.stringValue.trimmingCharacters(in: .whitespaces)
            completion(text.isEmpty ? nil : text)
        } else if response == .alertThirdButtonReturn {
            completion(nil)
        }
    }
}
