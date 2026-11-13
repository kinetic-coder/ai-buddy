import AppKit
import Foundation

/// Proof of concept: never modifies the selected Codex directory.
@MainActor
final class CodexFolderAccess: ObservableObject {
    @Published private(set) var status = "Codex not connected"
    @Published private(set) var isConnected = false

    private let bookmarkKey = "codexFolderBookmark"
    private var selectedURL: URL?

    init() { restore() }

    func connect() {
        let panel = NSOpenPanel()
        panel.title = "Select your Codex data folder"
        panel.message = "AI Buddy requests read-only access to usage data in your chosen folder."
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        if panel.runModal() == .OK, let url = panel.url {
            do {
                let bookmark = try url.bookmarkData(options: [.withSecurityScope],
                                                    includingResourceValuesForKeys: nil,
                                                    relativeTo: nil)
                UserDefaults.standard.set(bookmark, forKey: bookmarkKey)
                selectedURL = url
                checkAccess()
            } catch {
                status = "Could not save folder permission. Please try again."
            }
        }
    }

    func skip() { status = "Not connected. Connect from the menu when ready." }

    func restore() {
        guard let bookmark = UserDefaults.standard.data(forKey: bookmarkKey) else { return }
        do {
            var stale = false
            let url = try URL(resolvingBookmarkData: bookmark,
                              options: [.withSecurityScope],
                              relativeTo: nil,
                              bookmarkDataIsStale: &stale)
            guard !stale else {
                status = "Folder permission expired. Please reconnect."
                return
            }
            selectedURL = url
            checkAccess()
        } catch {
            status = "Folder permission unavailable. Please reconnect."
        }
    }

    func checkAccess() {
        guard let url = selectedURL else {
            isConnected = false
            status = "Codex not connected"
            return
        }
        guard url.startAccessingSecurityScopedResource() else {
            isConnected = false
            status = "Access denied. Please reconnect."
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        do {
            let files = try FileManager.default.contentsOfDirectory(at: url,
                includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            isConnected = true
            status = "Folder accessible (\\(files.count) top-level items). Usage parsing not yet enabled."
        } catch {
            isConnected = false
            status = "Unable to read selected folder. Please reconnect."
        }
    }

    func disconnect() {
        UserDefaults.standard.removeObject(forKey: bookmarkKey)
        selectedURL = nil
        isConnected = false
        status = "Codex disconnected"
    }
}
