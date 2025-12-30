# MCP GitHub Org Mapper

A secure, Model Context Protocol (MCP) server for mapping and analyzing GitHub organization repositories. Provides read-only access to org repos with fine-grained authorization controls.

## Features

- **Secure Authentication**: GitHub App JWT-based auth with RSA signing
- **Declarative Scoping**: Include/exclude patterns for repo authorization
- **Org-Wide Analysis**: Tools for listing repos, checking hygiene, CI consistency
- **MCP Compliant**: JSON-RPC over stdio for integration with MCP clients
- **Enterprise Ready**: No secrets in code, environment-based config

## Quick Start

1. Clone the repo
2. Set up GitHub App
3. Configure credentials
4. Run tests

See [Setup](setup.md) for detailed instructions.
