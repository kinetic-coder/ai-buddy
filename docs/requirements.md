# AI Buddy macOS requirements

## Product
Native macOS Swift/SwiftUI menu-bar app, offline-first, initially tracking local OpenAI Codex usage. Windows version and online providers are out of scope for v1.

## Functional
- Show available token usage, provider-reported allowance used/remaining percentages, reset timestamps, data source and last-observed time.
- Distinguish measured token counts, rate-limit percentages, and unknown or stale values. Never infer credit balance from token totals.
- Read local Codex session files only after the user selects a folder. Never collect conversation text or credentials.
- First-run onboarding offers Connect Codex and Skip. Settings supports connect, change folder, disconnect and separate deletion of saved history.
- Use security-scoped bookmarks; handle revoked, moved or inaccessible folders after relaunch.
- Store minimal deduplicated usage snapshots locally with configurable retention.
- Refresh on launch and initially every 60 seconds while running; optimise scanning and provide manual refresh.
- Continue monitoring in the menu bar when dashboard closes; explicit Quit stops it. Optional launch at login.
- Offline by default, no telemetry and no network entitlements without review.

## Engineering and release gates
- Least privilege, App Sandbox, read-only access, input validation, secure storage and no sensitive logging.
- Prefer native Apple frameworks and maintained, pinned dependencies; vulnerability and secret scanning.
- Automated unit, integration, UI and accessibility tests; CI must pass before merge.
- Native macOS UX: VoiceOver, keyboard navigation, focus visibility, text scaling, contrast, reduced motion and no colour-only meaning. Target WCAG 2.2 AA where applicable.
- Mac App Store compatibility is a requirement, subject to sandbox feasibility and Apple's review.
- Record decisions, test evidence and security implications in the repository.
