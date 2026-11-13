# AI Buddy contributor and coding-agent rules

- Never commit directly to master. Use feature branches and pull requests.
- Security, accessibility and automated tests are mandatory release gates.
- Mac App Store compliance is a mandatory release gate. Do not call a change release-ready until a signed, sandboxed archive has been validated against the current App Review Guidelines.
- Default to local-only processing, App Sandbox, least privilege and user-authorised read-only file access.
- Never read, store or log Codex credentials, prompts or conversation contents.
- Do not bypass sandbox restrictions or introduce hidden network activity.
- Prefer Swift/SwiftUI and supported Apple frameworks; avoid experimental or unmaintained dependencies.
- Keep dependencies minimal, supported and current. CI must scan dependency changes and source for known security issues, and automated upgrade pull requests must remain enabled.
- Use only public Apple APIs. Keep the app self-contained: do not require a separately installed CLI, helper or runtime, and never download or execute code that changes app functionality.
- Keep App Sandbox and Hardened Runtime enabled. Every entitlement must be necessary, documented and covered by a signed-build test.
- Store OAuth credentials only in Keychain, validate OAuth state, PKCE and signed ID tokens, and provide clear sign-in, sign-out and revocation behavior.
- Keep the App Store build free while it uses OpenAI's open-source ChatGPT-plan authorization route. Reassess OpenAI approval before adding payment, remote hosting or proprietary distribution.
- Maintain an in-app privacy-policy link, App Store privacy disclosures, third-party licence notices and complete App Review notes. Account features must include a reviewable login path or approved demo mode.
- Distribute App Store updates only through the App Store. Do not add private update systems, license keys, privilege escalation or unconsented login items/background processes.
- Include unit and integration tests for parser changes and UI/accessibility tests for interaction changes.
- Handle unavailable, stale or incomplete usage data explicitly. Never invent credit balances.
- Document design decisions, permissions, threat considerations and test evidence.
