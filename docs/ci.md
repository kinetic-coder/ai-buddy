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
- Run the AIBuddy Xcode scheme on a hosted macOS runner after Xcode is available locally. The project now has a sandboxed macOS app target, but a passing Swift Package build does not prove signed sandbox behaviour or Mac App Store compatibility.
- Add automated UI/accessibility tests for the menu-bar connection flow.
- Set master branch protection / ruleset requiring successful CI and review; repository administrator must verify permissions and enable these rules.
- CD later: signed/notarised TestFlight or App Store distribution using Apple signing credentials and manual release approvals. Do not place signing secrets in untrusted PR jobs.

## Security and dependency automation

- `macos-ci.yml` builds and tests both the Swift package and Xcode app, validates entitlements, and runs Gitleaks.
- `dependency-review.yml` rejects pull requests that introduce dependencies with moderate-or-higher known vulnerabilities.
- `codeql.yml` runs extended Swift security queries on pushes, pull requests, and weekly.
- Dependabot checks GitHub Actions and Swift packages weekly and opens grouped upgrade pull requests.
- Third-party actions are pinned to full commit SHAs. Dependabot updates those pins; review the upstream release before merging.

In GitHub repository settings, enable the dependency graph, Dependabot alerts and security updates, CodeQL default setup visibility, secret scanning and push protection. Protect `master` and require the macOS CI, dependency-review and CodeQL checks before merge. Security findings are reported in the repository Security tab; upgrades arrive as Dependabot pull requests and must pass the same release gates as other changes.
