// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MCPGitHubOrgMapper",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "MCPGitHubOrgMapper"
        ),
        .testTarget(
            name: "MCPGitHubOrgMapperTests",
            dependencies: ["MCPGitHubOrgMapper"]
        )
    ]
)
