import XCTest
@testable import AIBuddy

final class AccessSmokeTests: XCTestCase {
    func testInitialStateHasNoImplicitFolderPermission() async {
        await MainActor.run {
            let key = "codexFolderBookmark"
            let previous = UserDefaults.standard.data(forKey: key)
            defer { if let previous { UserDefaults.standard.set(previous, forKey: key) } }
            UserDefaults.standard.removeObject(forKey: key)
            let access = CodexFolderAccess()
            XCTAssertFalse(access.isConnected)
            XCTAssertEqual(access.status, "Codex not connected")
        }
    }

    func testDisconnectClearsBookmark() async {
        await MainActor.run {
            let access = CodexFolderAccess()
            access.disconnect()
            XCTAssertNil(UserDefaults.standard.data(forKey: "codexFolderBookmark"))
            XCTAssertFalse(access.isConnected)
        }
    }
}
