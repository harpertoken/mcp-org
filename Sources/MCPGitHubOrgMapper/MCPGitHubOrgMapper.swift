// SPDX-License-Identifier: MIT
// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@main
struct MCPGitHubOrgMapper {
    static func main() async {
        loadEnv()
        let args = CommandLine.arguments
        if args.count > 1 && args[1] == "server" {
            // Run as MCP server
            do {
                let url = URL(fileURLWithPath: "test-config.json")
                let data = try Data(contentsOf: url)
                let config: OrgConfig = try JSONDecoder().decode(OrgConfig.self, from: data)
                let server = MCPServer(config: config)
                await server.run()
            } catch {
                print("Failed to start server: \(error)")
            }
        } else {
            // Test mode
            print("Testing MCP GitHub Org Mapper...")
            do {
                let url = URL(fileURLWithPath: "test-config.json")
                let data = try Data(contentsOf: url)
                let config: OrgConfig = try JSONDecoder().decode(OrgConfig.self, from: data)
                print("Config loaded: Org \(config.org.name)")

                // Fetch public repos from GitHub
                let api = GitHubAPI()
                let repos = try await api.listPublicRepos(org: config.org.name)
                print("Fetched \(repos.count) public repos from \(config.org.name)")

                // Test repo authorization
                var allowedRepos: [String] = []
                for repo in repos {
                    if config.repos.isAllowed(repo) {
                        allowedRepos.append(repo)
                    }
                }
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
