# AI Buddy

[![CodeQL](https://github.com/kinetic-coder/ai-buddy/actions/workflows/codeql.yml/badge.svg)](https://github.com/kinetic-coder/ai-buddy/actions/workflows/codeql.yml)

An open-source macOS menu-bar app for viewing structured Codex subscription-usage status. AI Buddy uses the supported ChatGPT authorization flow and does not inspect Codex credentials, prompts, or conversations.

Open [AIBuddy.xcodeproj](AIBuddy.xcodeproj) in Xcode 15 or later, select the **AIBuddy** scheme, and build, run, or test. Before distributing, set `DEVELOPMENT_TEAM` and replace the placeholder bundle identifier (`com.aibuddy.desktop`) with one registered to that team.

For a package-level test run, use `swift test`.

See [the Codex usage design](docs/codex-usage.md) for the protocol, permissions, and availability constraints.

AI Buddy is available under the [MIT License](LICENSE). The App Store build is intended to remain free and run entirely on the user's Mac.
