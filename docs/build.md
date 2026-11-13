# macOS sandbox proof of concept

This is a Swift Package executable proof of concept, **not yet a signed/sandbox-verified App Store application**. Swift Package Manager alone does not apply the included entitlements when running with `swift run`.

On a Mac with Xcode, open Package.swift, build and run the AIBuddy executable, and run `swift test`. To validate sandbox behaviour, create a macOS App target in Xcode, include the two Swift source files, enable App Sandbox with user-selected files **Read Only**, and apply `Config/AIBuddy.entitlements` to its signing configuration. Run the signed sandboxed app and test first-run selection, relaunch, new nested files, denied access and disconnect.

Do not claim App Store feasibility until this signed sandbox test is completed. The current implementation only lists top-level entries to prove authorised access; it does not parse or retain Codex usage, and no background polling has been added.
