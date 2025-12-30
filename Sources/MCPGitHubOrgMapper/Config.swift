// SPDX-License-Identifier: MIT
import Foundation

public struct OrgConfig: Codable {
    let org: Org
    let repos: RepoScope
}

public struct Org: Codable {
    let name: String
    let installationID: String
    let appID: String
    let defaultVisibility: String
}

public struct RepoScope: Codable {
    let include: [String]
    let exclude: [String]
    let overrides: [String: RepoOverride]  // keyed by repo name
}

struct RepoOverride: Codable {
    let repo: String
    let indexing: IndexingConfig
    let tools: ToolPermissions
}

struct IndexingConfig: Codable {
    let maxDepth: Int
    let allowPrivate: Bool
    let includePaths: [String]
    let excludePaths: [String]
}

struct ToolPermissions: Codable {
    let allow: [String]
}

extension RepoScope {
    func isAllowed(_ repoName: String) -> Bool {
        // First, check exclude (negation patterns)
        for pattern in exclude {
            if matches(pattern, repoName) {
                return false
            }
        }

        // Then, check include
        for pattern in include {
            if matches(pattern, repoName) {
                return true
            }
        }

        // If no include matches, deny
        return false
    }

    private func matches(_ pattern: String, _ name: String) -> Bool {
        if pattern.hasPrefix("!") {
            let cleanPattern = String(pattern.dropFirst())
            return globMatch(cleanPattern, name)
        }
        return globMatch(pattern, name)
    }

    private func globMatch(_ pattern: String, _ name: String) -> Bool {
        // Simple glob: * matches any sequence, ? matches one char
        let regexPattern = pattern
            .replacingOccurrences(of: ".", with: "\\.")
            .replacingOccurrences(of: "*", with: ".*")
            .replacingOccurrences(of: "?", with: ".")
        let regex = try! NSRegularExpression(pattern: "^\(regexPattern)$", options: [])
        let range = NSRange(location: 0, length: name.utf16.count)
        return regex.firstMatch(in: name, options: [], range: range) != nil
    }
}

func loadOrgConfig(from path: String) throws -> OrgConfig {
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(OrgConfig.self, from: data)
}
