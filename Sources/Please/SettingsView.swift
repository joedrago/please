import KeyboardShortcuts
import ServiceManagement
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var calculatorEnabled = Preferences.calculatorEnabled
    @State private var fuzzySearch = Preferences.fuzzySearch
    @State private var maxResults = Preferences.maxResults
    @State private var fontSize = Int(Preferences.fontSize)
    @State private var showResetConfirmation = false

    var body: some View {
        Form {
            Section("General") {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        do {
                            if newValue {
                                try SMAppService.mainApp.register()
                            } else {
                                try SMAppService.mainApp.unregister()
                            }
                        } catch {
                            NSLog("Failed to update login item: \(error)")
                            launchAtLogin = SMAppService.mainApp.status == .enabled
                        }
                    }

                Toggle("Fuzzy search", isOn: $fuzzySearch)
                    .onChange(of: fuzzySearch) { newValue in
                        Preferences.fuzzySearch = newValue
                    }

                Toggle("Built-in calculator", isOn: $calculatorEnabled)
                    .onChange(of: calculatorEnabled) { newValue in
                        Preferences.calculatorEnabled = newValue
                    }
            }

            Section("Hotkey") {
                HStack {
                    Text("Global shortcut")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .toggleSearch)
                }
            }

            Section("Appearance") {
                Picker("Max visible results", selection: $maxResults) {
                    ForEach(3 ... 20, id: \.self) { n in
                        Text("\(n)").tag(n)
                    }
                }
                .onChange(of: maxResults) { newValue in
                    Preferences.maxResults = newValue
                }

                Picker("Font size", selection: $fontSize) {
                    ForEach(10 ... 24, id: \.self) { n in
                        Text("\(n)pt").tag(n)
                    }
                }
                .onChange(of: fontSize) { newValue in
                    Preferences.fontSize = CGFloat(newValue)
                }
            }
            Section("Data") {
                Text(
                    "Export saves all settings to a JSON file. Import merges — aliases and priority lists are added to existing values; other settings are overwritten. Reset to Defaults erases all customizations."
                )
                .font(.caption)
                .foregroundColor(.secondary)

                HStack {
                    Button("Reset to Defaults") { showResetConfirmation = true }
                    Button("Import\u{2026}") { importSettings() }
                    Button("Export\u{2026}") { exportSettings() }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 360, height: 580)
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
        .alert("Reset to Defaults?", isPresented: $showResetConfirmation) {
            Button("Reset", role: .destructive) {
                Preferences.resetAll()
                try? SMAppService.mainApp.unregister()
                refreshState()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All settings will be restored to their default values. Consider exporting your settings first.")
        }
    }

    private func exportSettings() {
        let isLoginEnabled = SMAppService.mainApp.status == .enabled
        guard let data = Preferences.exportAll(launchAtLogin: isLoginEnabled) else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "please_settings.json"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        try? data.write(to: url)
    }

    private func importSettings() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        if let wantsLogin = try? Preferences.importFrom(data) {
            do {
                if wantsLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                NSLog("Failed to update login item: \(error)")
            }
        }
        refreshState()
    }

    private func refreshState() {
        launchAtLogin = SMAppService.mainApp.status == .enabled
        calculatorEnabled = Preferences.calculatorEnabled
        fuzzySearch = Preferences.fuzzySearch
        maxResults = Preferences.maxResults
        fontSize = Int(Preferences.fontSize)
    }
}
