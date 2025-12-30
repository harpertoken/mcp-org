// SPDX-License-Identifier: MIT
// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

func loadConfigFromEnv() -> OrgConfig {
    let orgName = ProcessInfo.processInfo.environment["ORG_NAME"] ?? "default-org"
    let appID = ProcessInfo.processInfo.environment["APP_ID"] ?? "0"
    let installationID = ProcessInfo.processInfo.environment["INSTALLATION_ID"] ?? "0"
    let defaultVisibility = ProcessInfo.processInfo.environment["DEFAULT_VISIBILITY"] ?? "public"
    let include = ProcessInfo.processInfo.environment["REPO_INCLUDE"]?.split(separator: ",").map(String.init) ?? ["*"]
    let exclude = ProcessInfo.processInfo.environment["REPO_EXCLUDE"]?.split(separator: ",").map(String.init) ?? []
    let org = Org(name: orgName, installationID: installationID, appID: appID, defaultVisibility: defaultVisibility)
    let repos = RepoScope(include: include, exclude: exclude, overrides: [:])
    return OrgConfig(org: org, repos: repos)
}

@main
struct MCPGitHubOrgMapper {
    static func main() async {
        loadEnv()
        let args = CommandLine.arguments
        let config = loadConfigFromEnv()
        if args.count > 1 && args[1] == "server" {
            // Run as MCP server
            let server = MCPServer(config: config)
            await server.run()
        } else {
            // Test mode
            print("Testing MCP GitHub Org Mapper...")
            do {
                print("Config loaded: Org \(config.org.name)")

                // Fetch public repos from GitHub
                let api = GitHubAPI()
                let repos = try await api.listPublicRepos(org: config.org.name)
                print("Fetched \(repos.count) public repos from \(config.org.name)")

                // Test repo authorization
                let allowedRepos = repos.filter { config.repos.isAllowed($0) }
                print("Authorized repos (\(allowedRepos.count)): \(allowedRepos.prefix(10).joined(separator: ", "))")

                // Test JWT generation with config key
                if let privateKey = ProcessInfo.processInfo.environment["GITHUB_PRIVATE_KEY"] {
                    let auth = GitHubAppAuth(appID: config.org.appID, privateKeyPEM: privateKey)
                    let jwt = try auth.generateJWT()
                    print("JWT generated successfully (first 50 chars): \(jwt.prefix(50))...")
                } else {
                    print("No GITHUB_PRIVATE_KEY in environment")
                }
            } catch {
                print("Test failed: \(error)")
            }
            print("Test complete.")
        }
    }
}
