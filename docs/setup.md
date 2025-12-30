# Setup

## Prerequisites

- macOS 12+ (verify with: `sw_vers -productVersion`)
- Swift 6.2+ (verify with: `swift --version`)
- GitHub App with repository read permissions

## Verification

After building, verify the binary's minimum macOS version:

```bash
otool -l .build/arm64-apple-macosx/debug/MCPGitHubOrgMapper | grep -A 2 LC_BUILD_VERSION
```

Should show `minos 12.0` confirming macOS 12.0 minimum.

## GitHub App Setup

1. Install the [harpertoken-mcp GitHub App](https://github.com/apps/harpertoken-mcp) in your organization
2. Note the App ID and Installation ID from the app settings
3. Download the private key from the app settings

## Local Setup

```bash
git clone https://github.com/harpertoken/mcp-org.git
cd mcp-org
swift build
```

## Configuration

Copy `.env.example` to `.env` and fill in credentials:

```bash
cp .env.example .env
# Edit .env with your values
```

Run test:

```bash
swift run MCPGitHubOrgMapper
```
