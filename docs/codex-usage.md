# Codex usage integration

## Decision

AI Buddy launches the installed OpenAI Codex CLI as a local stdio app-server and calls the documented `account/rateLimits/read` method. Codex owns ChatGPT authentication, token refresh, and backend routing.

AI Buddy never reads or writes Codex credentials, `auth.json`, prompts, conversations, session logs, or private ChatGPT endpoints. The AI Companion reference project was reviewed, but its direct credential-file and private-endpoint implementation was deliberately not copied.

## User experience

When the menu opens, AI Buddy locates the Codex executable in standard Homebrew locations and the process path. It requests current rate limits and displays only values returned by Codex: five-hour usage, weekly usage, reset times, plan type, credits, and available resets. Missing or stale data is reported as unavailable and never inferred.

If Codex is missing, signed out, incompatible, blocked by App Sandbox, or temporarily unavailable, the menu explains the failure and offers a refresh action.

## Permissions and threat considerations

- App Sandbox and outgoing network-client access remain enabled.
- The local protocol uses stdio and has an eight-second timeout.
- Standard error is discarded so credentials or diagnostics cannot enter AI Buddy logs.
- Only the structured rate-limit response is decoded; account identifiers and unrelated notifications are ignored.
- A signed sandbox verification is still required to confirm that the distributed app can launch the installed Codex executable. If macOS blocks it, the product must use an approved helper or a user-authorized alternative rather than weakening the sandbox.

## Test evidence

`CodexUsageTests` verifies the documented response shape, a successful published snapshot, and explicit unavailable state without invented usage. Its live integration test runs when Codex is installed and skips on hosts without Codex. Complete the signed sandbox verification before release.
