# AI Buddy contributor and coding-agent rules

- Never commit directly to master. Use feature branches and pull requests.
- Security, accessibility and automated tests are mandatory release gates.
- Default to local-only processing, App Sandbox, least privilege and user-authorised read-only file access.
- Never read, store or log Codex credentials, prompts or conversation contents.
- Do not bypass sandbox restrictions or introduce hidden network activity.
- Prefer Swift/SwiftUI and supported Apple frameworks; avoid experimental or unmaintained dependencies.
- Include unit and integration tests for parser changes and UI/accessibility tests for interaction changes.
- Handle unavailable, stale or incomplete usage data explicitly. Never invent credit balances.
- Document design decisions, permissions, threat considerations and test evidence.
