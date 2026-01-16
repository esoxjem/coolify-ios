import Foundation
import os

#if DEBUG

final class NetworkLogger: Sendable {
    static let shared = NetworkLogger()

    private let logger: Logger
    private let maxBodySize = 1024  // 1KB limit

    private init() {
        logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "com.coolify.ios",
            category: "Network"
        )
    }

    // MARK: - Public API

    @discardableResult
    func logRequest(_ request: URLRequest, id: UUID = UUID()) -> UUID {
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "unknown"
        let headers = sanitizeHeaders(request.allHTTPHeaderFields ?? [:])

        logger.debug("[\(id.uuidString.prefix(8), privacy: .public)] --> \(method, privacy: .public) \(url, privacy: .public)")
        logger.debug("[\(id.uuidString.prefix(8), privacy: .public)] Headers: \(headers, privacy: .public)")

        if let body = request.httpBody {
            logger.debug("[\(id.uuidString.prefix(8), privacy: .public)] Body: \(self.formatBody(body), privacy: .private)")
        }

        return id
    }

    func logResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        duration: TimeInterval,
        id: UUID
    ) {
        let shortId = String(id.uuidString.prefix(8))
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        let durationMs = String(format: "%.0f", duration * 1000)

        if let error = error {
            logger.error("[\(shortId, privacy: .public)] <-- ERROR (\(durationMs, privacy: .public)ms): \(error.localizedDescription, privacy: .public)")
            return
        }

        let emoji = statusCode >= 400 ? "!" : "<--"

        if statusCode >= 400 {
            logger.error("[\(shortId, privacy: .public)] \(emoji, privacy: .public) \(statusCode) (\(durationMs, privacy: .public)ms)")
        } else {
            logger.info("[\(shortId, privacy: .public)] \(emoji, privacy: .public) \(statusCode) (\(durationMs, privacy: .public)ms)")
        }

        if let data = data {
            logger.debug("[\(shortId, privacy: .public)] Body: \(self.formatBody(data), privacy: .private)")
        }
    }

    // MARK: - Private Helpers

    private func sanitizeHeaders(_ headers: [String: String]) -> String {
        var sanitized = headers
        if let auth = sanitized["Authorization"], auth.hasPrefix("Bearer ") {
            let token = String(auth.dropFirst(7))
            sanitized["Authorization"] = "Bearer \(token.prefix(8))...[REDACTED]"
        }
        return sanitized.map { "\($0): \($1)" }.joined(separator: ", ")
    }

    private func formatBody(_ data: Data) -> String {
        guard let string = String(data: data, encoding: .utf8) else {
            return "<binary: \(data.count) bytes>"
        }

        if data.count > maxBodySize {
            return String(string.prefix(maxBodySize)) + "...[TRUNCATED \(data.count) bytes]"
        }

        // Pretty-print JSON if possible
        if let json = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let prettyString = String(data: pretty, encoding: .utf8) {
            if prettyString.count > maxBodySize {
                return String(prettyString.prefix(maxBodySize)) + "...[TRUNCATED]"
            }
            return prettyString
        }

        return string
    }
}

#endif
