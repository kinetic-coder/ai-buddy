import Foundation
import Darwin

struct CodexRateLimitWindow: Codable, Equatable {
    let usedPercent: Int
    let windowDurationMins: Int?
    let resetsAt: Int?
}

struct CodexCreditsSnapshot: Codable, Equatable {
    let hasCredits: Bool
    let unlimited: Bool
    let balance: String?
}

struct CodexRateLimitSnapshot: Codable, Equatable {
    let primary: CodexRateLimitWindow?
    let secondary: CodexRateLimitWindow?
    let credits: CodexCreditsSnapshot?
    let planType: String?
    let rateLimitReachedType: String?
}

struct CodexResetCreditsSummary: Codable, Equatable {
    let availableCount: Int
}

struct CodexUsageSnapshot: Codable, Equatable {
    let ordinaryUsageAllowed: Bool?
    let rateLimits: CodexRateLimitSnapshot
    let rateLimitsByLimitId: [String: CodexRateLimitSnapshot]?
    let rateLimitResetCredits: CodexResetCreditsSummary?

    var codexLimits: CodexRateLimitSnapshot {
        rateLimitsByLimitId?["codex"] ?? rateLimits
    }
}

enum CodexUsageError: LocalizedError, Equatable {
    case codexNotInstalled
    case processLaunchFailed
    case timedOut
    case disconnected
    case invalidResponse
    case server(String)

    var errorDescription: String? {
        switch self {
        case .codexNotInstalled:
            return "Codex was not found. Install Codex and sign in with ChatGPT, then try again."
        case .processLaunchFailed:
            return "AI Buddy could not start Codex. Open Codex once, confirm you are signed in, and try again."
        case .timedOut:
            return "Codex did not respond in time. Usage is temporarily unavailable."
        case .disconnected:
            return "Codex closed before returning usage. Open Codex and try again."
        case .invalidResponse:
            return "Codex returned usage in an unsupported format. Update Codex and try again."
        case .server(let message):
            return message.isEmpty ? "Codex usage is unavailable." : message
        }
    }
}

protocol CodexUsageProviding {
    func fetchUsage() async throws -> CodexUsageSnapshot
}

/// Reads only the documented app-server response. Codex owns authentication and token refresh;
/// AI Buddy never reads auth.json, session logs, prompts, conversations, or OAuth tokens.
struct CodexAppServerClient: CodexUsageProviding {
    private let executableURL: URL?
    private let timeout: TimeInterval

    init(executableURL: URL? = CodexExecutableLocator.find(), timeout: TimeInterval = 8) {
        self.executableURL = executableURL
        self.timeout = timeout
    }

    func fetchUsage() async throws -> CodexUsageSnapshot {
        guard let executableURL else { throw CodexUsageError.codexNotInstalled }
        return try await Task.detached(priority: .userInitiated) {
            try fetchUsageSynchronously(executableURL: executableURL, timeout: timeout)
        }.value
    }
}

enum CodexExecutableLocator {
    static func find(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        fileManager: FileManager = .default
    ) -> URL? {
        var paths = [
            "/opt/homebrew/bin/codex",
            "/usr/local/bin/codex",
            "/Applications/ChatGPT.app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex"
        ]
        if let path = environment["PATH"] {
            paths.append(contentsOf: path.split(separator: ":").map { "\($0)/codex" })
        }

        var seen = Set<String>()
        for path in paths where seen.insert(path).inserted {
            if fileManager.isExecutableFile(atPath: path) {
                return URL(fileURLWithPath: path)
            }
        }
        return nil
    }
}

private struct RPCErrorPayload: Decodable {
    let message: String
}

private struct UsageRPCResponse: Decodable {
    let result: CodexUsageSnapshot?
    let error: RPCErrorPayload?
}

private final class TimeoutFlag: @unchecked Sendable {
    private let lock = NSLock()
    private var value = false

    func mark() {
        lock.lock()
        value = true
        lock.unlock()
    }

    var isMarked: Bool {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
}

private func fetchUsageSynchronously(executableURL: URL, timeout: TimeInterval) throws -> CodexUsageSnapshot {
    let process = Process()
    let input = Pipe()
    let output = Pipe()
    let timeoutFlag = TimeoutFlag()
    let timeoutWork = DispatchWorkItem {
        timeoutFlag.mark()
        if process.isRunning { process.terminate() }
    }

    process.executableURL = executableURL
    process.arguments = ["app-server", "--listen", "stdio://"]
    process.environment = codexProcessEnvironment(executableURL: executableURL)
    process.standardInput = input
    process.standardOutput = output
    process.standardError = FileHandle.nullDevice
    _ = fcntl(input.fileHandleForWriting.fileDescriptor, F_SETNOSIGPIPE, 1)

    do {
        try process.run()
    } catch {
        throw CodexUsageError.processLaunchFailed
    }

    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + timeout, execute: timeoutWork)
    defer {
        timeoutWork.cancel()
        try? input.fileHandleForWriting.close()
        try? output.fileHandleForReading.close()
        if process.isRunning { process.terminate() }
    }

    var lineReader = JSONLineReader(handle: output.fileHandleForReading)
    try writeJSON([
        "method": "initialize",
        "id": 1,
        "params": [
            "clientInfo": ["name": "ai_buddy", "title": "AI Buddy", "version": "0.1.0"],
            "capabilities": NSNull()
        ]
    ], to: input.fileHandleForWriting)
    _ = try readResponse(id: 1, reader: &lineReader, timeoutFlag: timeoutFlag)

    try writeJSON(["method": "initialized"], to: input.fileHandleForWriting)
    try writeJSON([
        "method": "account/rateLimits/read",
        "id": 2,
        "params": [:]
    ], to: input.fileHandleForWriting)

    let responseData = try readResponse(id: 2, reader: &lineReader, timeoutFlag: timeoutFlag)
    guard let response = try? JSONDecoder().decode(UsageRPCResponse.self, from: responseData) else {
        throw CodexUsageError.invalidResponse
    }
    if let error = response.error { throw CodexUsageError.server(error.message) }
    guard let result = response.result else { throw CodexUsageError.invalidResponse }
    return result
}

/// Xcode injects dynamic-loader and XCTest variables into its test host. Passing those on can
/// make an unrelated command-line executable load test libraries or terminate before speaking
/// JSON-RPC. Strip only test/debugger injection while retaining the user's normal Codex settings.
private func codexProcessEnvironment(executableURL: URL) -> [String: String] {
    let inherited = ProcessInfo.processInfo.environment
    let permittedKeys = [
        "HOME", "USER", "LOGNAME", "TMPDIR", "LANG", "LC_ALL", "LC_CTYPE",
        "PATH", "CODEX_HOME", "SSL_CERT_FILE", "SSL_CERT_DIR"
    ]
    var environment = permittedKeys.reduce(into: [String: String]()) { result, key in
        result[key] = inherited[key]
    }
    let executableDirectory = executableURL.deletingLastPathComponent().path
    let inheritedPath = environment["PATH"] ?? "/usr/bin:/bin"
    if !inheritedPath.split(separator: ":").contains(Substring(executableDirectory)) {
        environment["PATH"] = "\(executableDirectory):\(inheritedPath)"
    }
    return environment
}

private func writeJSON(_ value: [String: Any], to handle: FileHandle) throws {
    var data = try JSONSerialization.data(withJSONObject: value)
    data.append(0x0A)
    do {
        try handle.write(contentsOf: data)
    } catch {
        throw CodexUsageError.disconnected
    }
}

private func readResponse(id: Int, reader: inout JSONLineReader, timeoutFlag: TimeoutFlag) throws -> Data {
    for _ in 0..<100 {
        guard let line = try reader.nextLine() else {
            throw timeoutFlag.isMarked ? CodexUsageError.timedOut : CodexUsageError.disconnected
        }
        guard
            let object = try? JSONSerialization.jsonObject(with: line) as? [String: Any],
            let responseID = object["id"] as? Int
        else { continue }
        if responseID == id { return line }
    }
    throw CodexUsageError.invalidResponse
}

private struct JSONLineReader {
    let handle: FileHandle
    private var buffer = Data()

    init(handle: FileHandle) {
        self.handle = handle
    }

    mutating func nextLine() throws -> Data? {
        while true {
            if let newline = buffer.firstIndex(of: 0x0A) {
                let line = buffer[..<newline]
                buffer.removeSubrange(...newline)
                return Data(line)
            }
            let chunk = handle.availableData
            guard !chunk.isEmpty else {
                return buffer.isEmpty ? nil : buffer
            }
            buffer.append(chunk)
        }
    }
}

@MainActor
final class CodexUsageStore: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded(CodexUsageSnapshot)
        case unavailable(String)
    }

    @Published private(set) var state: State = .idle
    private let provider: CodexUsageProviding

    init(provider: CodexUsageProviding = CodexAppServerClient()) {
        self.provider = provider
    }

    func refresh() async {
        guard state != .loading else { return }
        state = .loading
        do {
            state = .loaded(try await provider.fetchUsage())
        } catch {
            state = .unavailable((error as? LocalizedError)?.errorDescription ?? "Codex usage is unavailable.")
        }
    }
}
