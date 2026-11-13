# CI/CD plan

GitHub Actions workflow: `.github/workflows/macos-ci.yml`.

## Implemented CI
- Trigger on pull requests targeting master, pushes to master and feature branches, and manual dispatch.
- Build Swift package and run XCTest suite on a hosted macOS runner.
- Lint sandbox entitlement plist.
- Scan Git history for leaked secrets.
- Use read-only GitHub token permissions, no persisted checkout credentials, bounded run time and cancellation of superseded runs.

## Verification needed
- Inspect the first workflow run and fix any Swift/compiler/test failures. A committed workflow is not evidence of a passing build.
- Check whether the secret-scanning action requires configuration or licensing in this private repository.
- Pin third-party GitHub Actions to reviewed immutable commit SHAs before production release.
- Add SwiftLint/static analysis and dependency audits with maintained pinned tools.
- Add a signed sandboxed macOS Xcode app target and automated UI/accessibility tests. Current Swift package build does not prove Mac App Store compatibility.
- Set master branch protection / ruleset requiring successful CI and review; repository administrator must verify permissions and enable these rules.
- CD later: signed/notarised TestFlight or App Store distribution using Apple signing credentials and manual release approvals. Do not place signing secrets in untrusted PR jobs.
