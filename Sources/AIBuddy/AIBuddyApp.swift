import SwiftUI

@main
struct AIBuddyApp: App {
    @StateObject private var usage = CodexUsageStore()

    var body: some Scene {
        MenuBarExtra("AI Buddy", systemImage: "chart.bar.xaxis") {
            VStack(alignment: .leading, spacing: 12) {
                Text("AI Buddy").font(.headline)
                switch usage.state {
                case .idle, .loading:
                    ProgressView("Checking Codex usage…")
                        .accessibilityIdentifier("usageLoading")
                case .unavailable(let message):
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("usageUnavailable")
                case .loaded(let snapshot):
                    CodexUsageView(snapshot: snapshot)
                }

                Button("Refresh usage") { Task { await usage.refresh() } }
                    .disabled(usage.state == .loading)
                    .accessibilityIdentifier("refreshUsage")
                Divider()
                Button("Quit AI Buddy") { NSApplication.shared.terminate(nil) }
            }
            .padding()
            .frame(width: 320)
            .task {
                if usage.state == .idle { await usage.refresh() }
            }
        }
        .menuBarExtraStyle(.window)
    }
}

private struct CodexUsageView: View {
    let snapshot: CodexUsageSnapshot

    var body: some View {
        let limits = snapshot.codexLimits
        VStack(alignment: .leading, spacing: 10) {
            if let plan = limits.planType {
                Text("Codex · \(plan.capitalized)")
                    .font(.subheadline.weight(.semibold))
            }
            if let primary = limits.primary {
                usageRow("5-hour usage", window: primary, identifier: "primaryUsage")
            }
            if let secondary = limits.secondary {
                usageRow("Weekly usage", window: secondary, identifier: "secondaryUsage")
            }
            if let credits = limits.credits, credits.hasCredits {
                Text(credits.unlimited ? "Credits: unlimited" : "Credits: \(credits.balance ?? "available")")
                    .font(.caption)
                    .accessibilityIdentifier("creditsStatus")
            }
            if let resetCredits = snapshot.rateLimitResetCredits, resetCredits.availableCount > 0 {
                Text("Available resets: \(resetCredits.availableCount)")
                    .font(.caption)
            }
        }
    }

    private func usageRow(_ title: String, window: CodexRateLimitWindow, identifier: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text("\(window.usedPercent)% used")
            }
            .font(.caption)
            ProgressView(value: Double(window.usedPercent), total: 100)
            if let resetsAt = window.resetsAt {
                Text("Resets \(Date(timeIntervalSince1970: TimeInterval(resetsAt)).formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(identifier)
    }
}
