import XCTest
@testable import AIBuddy

final class CodexUsageTests: XCTestCase {
    func testDecodesDocumentedRateLimitResponse() throws {
        let data = Data(fixture.utf8)
        let envelope = try JSONDecoder().decode(TestEnvelope.self, from: data)
        let usage = envelope.result

        XCTAssertEqual(usage.codexLimits.primary?.usedPercent, 37)
        XCTAssertEqual(usage.codexLimits.secondary?.usedPercent, 18)
        XCTAssertEqual(usage.codexLimits.planType, "plus")
        XCTAssertEqual(usage.rateLimitResetCredits?.availableCount, 1)
    }

    @MainActor
    func testStoreExposesUnavailableDataWithoutInventingUsage() async {
        let store = CodexUsageStore(provider: FailingProvider())

        await store.refresh()

        XCTAssertEqual(store.state, .unavailable("Codex was not found. Install Codex and sign in with ChatGPT, then try again."))
    }

    @MainActor
    func testStorePublishesProviderSnapshot() async {
        let expected = try! JSONDecoder().decode(TestEnvelope.self, from: Data(fixture.utf8)).result
        let store = CodexUsageStore(provider: StubProvider(snapshot: expected))

        await store.refresh()

        XCTAssertEqual(store.state, .loaded(expected))
    }

    func testInstalledCodexAppServerReturnsStructuredUsage() async throws {
        guard let executableURL = CodexExecutableLocator.find() else {
            throw XCTSkip("Codex is not installed in a standard location.")
        }

        let usage = try await CodexAppServerClient(executableURL: executableURL).fetchUsage()

        XCTAssertNotNil(usage.codexLimits.primary ?? usage.codexLimits.secondary)
        if let usedPercent = usage.codexLimits.primary?.usedPercent {
            XCTAssertTrue((0...100).contains(usedPercent))
        }
    }
}

private struct TestEnvelope: Decodable {
    let result: CodexUsageSnapshot
}

private struct FailingProvider: CodexUsageProviding {
    func fetchUsage() async throws -> CodexUsageSnapshot {
        throw CodexUsageError.codexNotInstalled
    }
}

private struct StubProvider: CodexUsageProviding {
    let snapshot: CodexUsageSnapshot

    func fetchUsage() async throws -> CodexUsageSnapshot {
        snapshot
    }
}

private let fixture = #"""
{"id":2,"result":{"ordinaryUsageAllowed":true,"rateLimits":{"primary":{"usedPercent":37,"windowDurationMins":300,"resetsAt":1794609000},"secondary":{"usedPercent":18,"windowDurationMins":10080,"resetsAt":1795212000},"credits":{"hasCredits":true,"unlimited":false,"balance":"20"},"planType":"plus","rateLimitReachedType":null},"rateLimitsByLimitId":{"codex":{"primary":{"usedPercent":37,"windowDurationMins":300,"resetsAt":1794609000},"secondary":{"usedPercent":18,"windowDurationMins":10080,"resetsAt":1795212000},"credits":{"hasCredits":true,"unlimited":false,"balance":"20"},"planType":"plus","rateLimitReachedType":null}},"rateLimitResetCredits":{"availableCount":1}}}
"""#
