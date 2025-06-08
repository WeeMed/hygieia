# Hygieia CLI

Hygieia CLI is a command-line tool for managing the development environment of Hygieia healthcare system.

## Table of Contents

1. [Overview](#overview)
2. [System Requirements](#system-requirements)
3. [Installation](#installation)
4. [Basic Usage](#basic-usage)
5. [Support](#support)

## Overview

Hygieia CLI provides a comprehensive set of tools for managing and developing the Hygieia healthcare system. Built with Go, it offers high performance and cross-platform compatibility.

Key Features:

- Development environment management
- Deployment automation
- Configuration management
- Service orchestration
- Log management

For detailed command usage and examples, please refer to our [Usage Guide](docs/usage.md).

## System Requirements

### Basic Requirements

- Operating System: Linux, macOS, or Windows (WSL2)
- CPU: 1+ cores
- Memory: 2GB+
- Storage: 10GB+

### Software Dependencies

- Go 1.21+ (for development)
- Docker 24.0+
- Docker Compose 2.24+
- Node.js and pnpm
- Nx CLI

## Installation

### Quick Installation (Recommended)

```bash
curl -sSL https://get.hygieia.ai | sudo bash
```

The installation script will:

- Check system requirements
- Install necessary dependencies
- Download and install the latest version
- Set up appropriate permissions
- Configure the system environment

### Manual Installation

#### 1. Download Binary

```bash
# Download latest version
VERSION=$(curl -s https://api.github.com/repos/weemed-ai/hygieia/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -LO https://github.com/weemed-ai/hygieia/releases/download/$VERSION/hygieia-$(uname -s)-$(uname -m)
```

#### 2. Install Binary

```bash
# Set execution permissions
chmod +x hygieia-$(uname -s)-$(uname -m)

# Move to system directory
sudo mv hygieia-$(uname -s)-$(uname -m) /usr/local/bin/hygieia
```

#### 3. Post-installation Setup

```bash
# Run configuration wizard
hygieia config wizard

# Verify installation
hygieia version
hygieia service status
```

## Basic Usage

For a quick start:

```bash
# Show help
hygieia --help

# Show version
hygieia version

# Initialize a new project
hygieia init

# Start development environment
hygieia dev start
```

For comprehensive documentation on all available commands and their options, see:

- [Usage Guide](docs/usage.md) - Detailed command documentation
- [Development Guide](docs/development.md) - Development environment setup

## Support

For technical support or reporting issues:

- Documentation: https://docs.hygieia.ai
- Internal Support: support@hygieia.ai
