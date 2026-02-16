import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsTab()
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            ProvidersSettingsTab()
                .tabItem {
                    Label("Providers", systemImage: "square.stack.3d.up")
                }
        }
        .frame(width: 450, height: 300)
    }
}

struct GeneralSettingsTab: View {
    @AppStorage("refreshInterval") private var refreshInterval = 30.0

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    Button("Launch at Login") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") {
                        NSWorkspace.shared.open(url)
                    }
                }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
            } footer: {
                Text("To launch at login, enable AI Resource Tracker in System Settings > General > Login Items.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Picker("Refresh interval", selection: $refreshInterval) {
                Text("15 seconds").tag(15.0)
                Text("30 seconds").tag(30.0)
                Text("1 minute").tag(60.0)
                Text("5 minutes").tag(300.0)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct ProvidersSettingsTab: View {
    var body: some View {
        Form {
            Section("Active") {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Claude Code")
                    Spacer()
                    Text("Via CLI token")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Coming Soon") {
                HStack {
                    Image(systemName: "circle.dashed")
                        .foregroundStyle(.secondary)
                    Text("Anthropic API")
                    Spacer()
                    Text("API Key")
                        .font(.callout)
                        .foregroundStyle(.tertiary)
                }

                HStack {
                    Image(systemName: "circle.dashed")
                        .foregroundStyle(.secondary)
                    Text("OpenAI")
                    Spacer()
                    Text("API Key")
                        .font(.callout)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
