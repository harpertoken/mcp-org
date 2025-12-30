# Usage

## Test Mode

```bash
swift run MCPGitHubOrgMapper
```

Loads config, fetches public repos, applies authorization, generates JWT.

## MCP Server Mode

```bash
swift run MCPGitHubOrgMapper server
```

Runs MCP server on stdio for client integration.

## Configuration Files

- `.env`: Secrets
- `test-config.json`: Org and scoping config

## MCP Tools

- `list_repositories`: Authorized repos in org
