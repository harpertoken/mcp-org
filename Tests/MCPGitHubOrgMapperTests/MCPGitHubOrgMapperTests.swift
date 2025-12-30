import XCTest
@testable import MCPGitHubOrgMapper

class MCPGitHubOrgMapperTests: XCTestCase {

    func testRepoScopeIsAllowed() {
        // Test include all, exclude test-*
        let scope = RepoScope(include: ["*"], exclude: ["test-*"], overrides: [:])

        XCTAssertTrue(scope.isAllowed("repo1"))
        XCTAssertTrue(scope.isAllowed("my-repo"))
        XCTAssertFalse(scope.isAllowed("test-repo"))
        XCTAssertFalse(scope.isAllowed("test-123"))
    }

    func testRepoScopeNoInclude() {
        let scope = RepoScope(include: [], exclude: [], overrides: [:])

        XCTAssertFalse(scope.isAllowed("any-repo"))
    }

    func testRepoScopeSpecificInclude() {
        let scope = RepoScope(include: ["specific-repo"], exclude: [], overrides: [:])

        XCTAssertTrue(scope.isAllowed("specific-repo"))
        XCTAssertFalse(scope.isAllowed("other-repo"))
    }

    func testRepoScopeWithGlob() {
        let scope = RepoScope(include: ["*-allowed"], exclude: [], overrides: [:])

        XCTAssertTrue(scope.isAllowed("test-allowed"))
        XCTAssertTrue(scope.isAllowed("my-allowed"))
        XCTAssertFalse(scope.isAllowed("test-not"))
    }
}
