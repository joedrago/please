import KeyboardShortcuts
import ServiceManagement
import SwiftUI

struct SettingsView: View {
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var maxResults = Preferences.maxResults
    @State private var fontSize = Int(Preferences.fontSize)

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
        }
        .formStyle(.grouped)
        .frame(width: 360, height: 340)
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}
