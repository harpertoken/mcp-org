# MCP GitHub Org Mapper

A secure, Model Context Protocol (MCP) server for mapping and analyzing GitHub organization repositories. Provides read-only access to org repos with fine-grained authorization controls.

## Features

- **Secure Authentication**: GitHub App JWT-based auth with RSA signing
- **Declarative Scoping**: Include/exclude patterns for repo authorization
- **Org-Wide Analysis**: Tools for listing repos, checking hygiene, CI consistency
- **MCP Compliant**: JSON-RPC over stdio for integration with MCP clients
- **Enterprise Ready**: No secrets in code, environment-based config

## Installation

See [Setup](docs/setup.md) for detailed installation and configuration instructions.

## Usage

See [Usage](docs/usage.md) for running the server and available tools.

## Contributing

See [Contributing](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
