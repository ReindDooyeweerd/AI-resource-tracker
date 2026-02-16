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
                
                Button("Open at Login...") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") {
                        NSWorkspace.shared.open(url)
                    }
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
        .onAppear {
            viewModel.configure(with: authManager)
        }
    }

    private var notAuthenticatedView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "terminal")
                    .font(.system(size: 32))
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Not Signed In")
                        .font(.headline)
                    Text("Sign in via Terminal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text("Run this command in Terminal:")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack {
                Text("claude")
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(6)
                
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString("claude", forType: .string)
                }) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.plain)
                .help("Copy to clipboard")
            }
            
            Text("This will open Claude Code and prompt you to sign in. After signing in, restart this app.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(32)
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
            // Header
            HStack {
                Text(usage.providerName)
                    .font(.system(.headline, design: .rounded))
                Spacer()
                remainingBadge
            }

            // Progress bar
            UsageBar(used: usage.used)

            // Reset timer
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

            // Details
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
//
//  Popoverview.swift
//  AI resource tracker
//
//  Created by Reind Dooyeweerd on 16/02/2026.
//

