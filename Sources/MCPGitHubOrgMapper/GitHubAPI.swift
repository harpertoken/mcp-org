// SPDX-License-Identifier: MIT
import Foundation

public struct GitHubAPI {
    func listPublicRepos(org: String) async throws -> [String] {
        let url = URL(string: "https://api.github.com/orgs/\(org)/repos?type=public")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        return json?.compactMap { $0["name"] as? String } ?? []
    }
}
