import SwiftUI

@main
struct AIBuddyApp: App {
    @StateObject private var access = CodexFolderAccess()

    var body: some Scene {
        MenuBarExtra("AI Buddy", systemImage: "chart.bar.xaxis") {
            VStack(alignment: .leading, spacing: 12) {
                Text("AI Buddy").font(.headline)
                Text(access.status).accessibilityIdentifier("connectionStatus")
                if access.isConnected {
                    Button("Check folder access") { access.checkAccess() }
                    Button("Disconnect Codex") { access.disconnect() }
                } else {
                    Button("Connect Codex…") { access.connect() }
                    Button("Skip for now") { access.skip() }
                }
                Divider()
                Button("Quit AI Buddy") { NSApplication.shared.terminate(nil) }
            }
            .padding()
        }
        .menuBarExtraStyle(.window)
    }
}
