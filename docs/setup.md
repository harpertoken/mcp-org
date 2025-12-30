# Setup

## Prerequisites

- macOS 12+
- Swift 6.2+
- GitHub App with repository read permissions

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
