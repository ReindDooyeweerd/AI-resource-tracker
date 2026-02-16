import SwiftUI

struct PopoverView: View {
    @ObservedObject var viewModel: UsageViewModel
    @ObservedObject var authManager: AuthManager
    var body: some View {
        VStack(spacing: 0) {
            if !authManager.isAuthenticated {
                notAuthenticatedView
            } else if viewModel.usages.isEmpty {
                emptyState
            } else {
                ForEach(Array(viewModel.usages.enumerated()), id: \.offset) { _, usage in
                    ProviderCard(usage: usage)

                    if usage.providerName != viewModel.usages.last?.providerName {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }

            Divider()
                .padding(.top, 4)

            HStack {
                Text("AI Resource Tracker")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()

                SettingsLink {
                    Image(systemName: "gear")
                }
                .buttonStyle(.plain)
                .font(.caption2)
                .foregroundStyle(.secondary)

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(width: 300)
    }

    private var notAuthenticatedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "terminal")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)

            Text("Claude Code CLI Required")
                .font(.headline)

            Text("Install and sign in with the Claude Code CLI to view your usage.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Divider()
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 8) {
                Label {
                    Text("Install Claude Code CLI")
                        .font(.caption)
                } icon: {
                    Text("1.")
                        .font(.caption.bold())
                }

                HStack {
                    Text("npm install -g @anthropic-ai/claude-code")
                        .font(.system(.caption2, design: .monospaced))
                        .padding(6)
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(4)

                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString("npm install -g @anthropic-ai/claude-code", forType: .string)
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .buttonStyle(.plain)
                    .font(.caption2)
                    .help("Copy to clipboard")
                }

                Label {
                    Text("Run `claude` and sign in")
                        .font(.caption)
                } icon: {
                    Text("2.")
                        .font(.caption.bold())
                }

                Label {
                    Text("Restart this app")
                        .font(.caption)
                } icon: {
                    Text("3.")
                        .font(.caption.bold())
                }
            }

            Button("Retry") {
                authManager.checkAuthentication()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .padding(.top, 4)
        }
        .padding(24)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No providers configured")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
}

struct ProviderCard: View {
    let usage: UsageData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(usage.providerName)
                    .font(.system(.headline, design: .rounded))
                Spacer()
                remainingBadge
            }

            UsageBar(used: usage.used)

            if let resetDate = usage.resetDate {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("Resets in ")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(resetDate, style: .relative)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }

            if !usage.details.isEmpty {
                VStack(spacing: 6) {
                    ForEach(Array(usage.details.enumerated()), id: \.offset) { _, detail in
                        HStack {
                            Text(detail.label)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(detail.value)
                                .font(.system(.caption, design: .monospaced))
                        }
                    }
                }
                .padding(10)
                .background(.quaternary.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(16)
    }

    private var remainingBadge: some View {
        let used = Int(usage.used * 100)
        let color: Color = used < 50 ? .green : used < 80 ? .orange : .red

        return Text("\(used)% used")
            .font(.system(.caption, design: .rounded, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

struct UsageBar: View {
    let used: Double

    private var color: Color {
        let remaining = 1.0 - used
        if remaining > 0.5 { return .green }
        if remaining > 0.2 { return .orange }
        return .red
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(.quaternary)

                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: geo.size.width * min(used, 1.0))
            }
        }
        .frame(height: 6)
    }
}
