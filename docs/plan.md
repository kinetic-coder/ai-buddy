# AI Buddy macOS implementation plan

Status: Milestone 0 prototype source and initial smoke tests committed. Build, tests and signed sandbox validation still pending on macOS.

## Milestone 0: App Sandbox feasibility (first blocker)

Initial source: `Sources/AIBuddy/`; entitlement example: `Config/AIBuddy.entitlements`; build notes: `docs/build.md`. This is not yet a validated sandboxed app.
1. Create a minimal SwiftUI macOS application with App Sandbox and only the outgoing network entitlement required by the Codex app-server process.
2. Provide first-run Connect Codex / Skip options; use NSOpenPanel to let the user select their Codex data directory.
3. Persist a security-scoped bookmark in the app container. Resolve and use it only during authorised reads.
4. Test protocol decoding, missing or unavailable usage, Codex executable discovery, refresh, and signed sandbox behavior.
5. Verify with a signed sandboxed macOS build. Document App Store distribution risks. Never bypass sandbox restrictions.

**Exit criteria:** permission is optional; authorised read-only access works across relaunch; failures are explained and recoverable; disconnect stops reads and removes bookmark; no Codex files are modified; tests pass on macOS.

## Milestone 1: local Codex reader
- Inspect actual Codex file formats using sanitised sample fixtures.
- Parse token counts and rate-limit snapshots without retaining conversation content.
- Handle malformed JSONL, partial writes, duplicates, missing data and stale timestamps.
- Introduce provider-independent usage models and data-source interface.

## Milestone 2: persistence and refresh
- Save minimal snapshots and support retention/deletion.
- Refresh on launch and initially every 60 seconds while running; catch up after sleep/restart.
- Mark snapshots stale when appropriate and minimise battery/IO usage.

## Milestone 3: accessible menu-bar app
- Build dashboard, first-run flow, settings, notifications, optional launch at login and explicit Quit.
- Add automated unit/integration/UI/accessibility tests, CI, dependency and secret scanning.
- Review privacy, signing, entitlements and Mac App Store submission requirements.

## Open risks
- Codex data layout may change without notice.
- Rate-limit snapshots can be stale and may not expose all allowance types.
- Security-scoped bookmark behaviour must be validated for future files and across launches.
- Apple review approval cannot be guaranteed.

## Branch and delivery
Develop on feature/macos-codex-sandbox-poc from master. Do not commit directly to master. Open a PR for review and required checks.

## Future milestone: iPhone and iPad companion experience
- Reuse shared Swift usage models and provider interfaces across macOS, iOS and iPadOS.
- Deliver an iPhone companion dashboard for use beside a developer's Mac, with configurable threshold and reset alerts and a Home Screen/Lock Screen widget where supported.
- Explore optional Live Activity for active sessions, subject to platform rules.
- Support iPad dashboard layouts and accessibility.
- Investigate official account-level usage sources and secure sync so mobile works when the Mac is off; do not assume all subscription allowances are exposed.
- Respect iOS background execution and WidgetKit refresh limits; show freshness timestamps and never promise continuous background polling.
- Obtain explicit permission for notifications and any sync; keep the macOS v1 offline-first.
- Test notification thresholds, duplicate suppression, stale data, widget timelines, permission denial and reconnect flows.
