// SPDX-License-Identifier: MIT
import Foundation

public final class MCPServer {
    private let config: OrgConfig
    private let api: GitHubAPI

    public init(config: OrgConfig) {
        self.config = config
        self.api = GitHubAPI()
    }

    public func run() async {
        let stdin = FileHandle.standardInput
        let stdout = FileHandle.standardOutput

        while true {
            do {
                let data = stdin.availableData
                if data.isEmpty { continue }

                let request = try JSONDecoder().decode(MCPRequest.self, from: data)
                let response = try await handle(request: request)

                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let responseData = try encoder.encode(response)
                stdout.write(responseData)
                stdout.write(Data("\n".utf8))
            } catch {
                let errorResponse = MCPResponse(
                    jsonrpc: "2.0",
                    id: nil,
                    result: nil,
                    error: MCPError(code: -32603, message: "Internal error: \(error.localizedDescription)")
                )
                if let data = try? JSONEncoder().encode(errorResponse) {
                    stdout.write(data)
                    stdout.write(Data("\n".utf8))
                }
            }
        }
    }

    private func handle(request: MCPRequest) async throws -> MCPResponse {
        switch request.method {
        case "tools/list":
            let tools: [[String: AnyCodable]] = [
                [
                    "name": AnyCodable("list_repositories"),
                    "description": AnyCodable("List authorized repositories in the organization"),
                    "inputSchema": AnyCodable([
                        "type": AnyCodable("object"),
                        "properties": AnyCodable([:])
                    ] as [String: Any])
                ]
            ]
            let result = ["tools": AnyCodable(tools.map { AnyCodable($0) })]
            return MCPResponse(jsonrpc: "2.0", id: request.id, result: result, error: nil)

        case "tools/call":
            guard let params = request.params,
                  let name = params["name"]?.value as? String,
                  let args = params["arguments"]?.value as? [String: Any] else {
                throw MCPError(code: -32602, message: "Invalid params")
            }
            let result = try await callTool(name: name, args: args)
            return MCPResponse(jsonrpc: "2.0", id: request.id, result: ["content": AnyCodable(result)], error: nil)

        default:
            throw MCPError(code: -32601, message: "Method not found")
        }
    }

    private func callTool(name: String, args: [String: Any]) async throws -> [String] {
        switch name {
        case "list_repositories":
            let repos = try await api.listPublicRepos(org: config.org.name)
            return repos.filter { config.repos.isAllowed($0) }
        default:
            throw MCPError(code: -32601, message: "Tool not found")
        }
    }
}
