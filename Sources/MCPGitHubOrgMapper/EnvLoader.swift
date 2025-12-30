// SPDX-License-Identifier: MIT
import Foundation

public func loadEnv() {
    let envPath = ".env"
    guard let contents = try? String(contentsOfFile: envPath, encoding: .utf8) else { return }
    for line in contents.split(separator: "\n") {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
        let parts = trimmed.split(separator: "=", maxSplits: 1)
        if parts.count == 2 {
            let key = String(parts[0])
            let value = String(parts[1]).replacingOccurrences(of: "\\n", with: "\n")
            setenv(key, value, 1)
        }
    }
}
