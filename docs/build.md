# Xcode app build

1. Install Xcode 15 or later and select it with `xcode-select`.
2. Open `AIBuddy.xcodeproj` and select the **AIBuddy** scheme.
3. In Signing & Capabilities, select the team's signing certificate and use a bundle identifier registered to that team.
4. Build and run, or use Product > Test.

The native macOS target supports macOS 14 and uses `Config/AIBuddy.entitlements`: App Sandbox, hardened runtime, and an outgoing network-client entitlement for a future user-authorised ChatGPT connection. It has no user-selected file entitlement.

## Validation evidence

On 2026-11-13, the shared scheme built successfully and its two XCTest cases passed with Xcode 27.1 using `CODE_SIGNING_ALLOWED=NO`. This verifies the project wiring and test target without requiring a developer certificate. It does not verify the sandbox at runtime; complete the signed manual checks below after selecting a development team.

## Sandbox proof of concept

This is a Swift Package executable proof of concept, **not yet a signed/sandbox-verified App Store application**. Swift Package Manager alone does not apply the included entitlements when running with `swift run`.

Open `AIBuddy.xcodeproj`, build and run the AIBuddy app, and run its test target. To validate sandbox behaviour, use a signed configuration and test first-run selection, relaunch, new nested files, denied access, and disconnect.

Do not claim App Store feasibility until this signed sandbox test is completed. The current implementation only lists top-level entries to prove authorised access; it does not parse or retain Codex usage, and no background polling has been added.
