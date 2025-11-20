# Hygieia CLI
**Release Version:** v1.5.5

Official command-line interface tool for managing Hygieia healthcare platform instances.

## Overview

Hygieia CLI simplifies the deployment and management of healthcare applications with Docker-based deployment.

### Supported Platforms

| Platform | Architecture | Binary Name |
|----------|--------------|-------------|
| Linux | amd64 | hygieia-linux-amd64 |
| Linux | arm64 | hygieia-linux-arm64 |
| macOS | amd64 (Intel) | hygieia-darwin-amd64 |
| macOS | arm64 (Apple Silicon) | hygieia-darwin-arm64 |
| Windows | amd64 | hygieia-windows-amd64.exe |

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/WeeMed/hygieia/main/install.sh | sudo bash
```

Verify installation:

```bash
hygieia version
```

## Commands

### Instance Lifecycle

| Command | Alias | Description |
|---------|-------|-------------|
| `hygieia start` | up | Start Hygieia services |
| `hygieia stop` | down | Stop Hygieia services |
| `hygieia restart` | reboot | Restart Hygieia services |
| `hygieia upgrade` | - | Upgrade to latest version |

### Maintenance and Configuration

| Command | Alias | Description |
|---------|-------|-------------|
| `hygieia configure` | config | Manage configuration |
| `hygieia monitor` | ps | Monitor services in real-time |
| `hygieia logs` | - | View service logs |
| `hygieia doctor` | - | Diagnose and fix issues |

### Data Protection

| Command | Description |
|---------|-------------|
| `hygieia backup` | Backup Hygieia data |
| `hygieia restore` | Restore from backup |

### CLI Tool Management

| Command | Alias | Description |
|---------|-------|-------------|
| `hygieia update` | update-cli | Update Hygieia CLI |
| `hygieia version` | - | Show version information |

## Configuration

### Default Directories

| Directory | Purpose |
|-----------|---------|
| `/etc/hygieia/` | Configuration files |
| `/var/lib/hygieia/` | Data storage |
| `/var/log/hygieia/` | Log files |

### Environment Variables

Key environment variables in `/etc/hygieia/.env`:

| Variable | Description |
|----------|-------------|
| `REGISTRY` | Docker registry URL |
| `TAG` | Docker image tag |
| `POSTGRES_USER` | Database username |
| `POSTGRES_PASSWORD` | Database password |
| `SECRET_KEY` | Application secret key |

## Troubleshooting

Check service status:

```bash
hygieia monitor
hygieia doctor
```

View logs:

```bash
hygieia logs
```

Reset services:

```bash
hygieia restart
```

## Support

* Documentation: [https://weemed.ai/](https://weemed.ai/)
* Enterprise Support: service@weemed.ai

## About WeeMed

WeeMed is dedicated to building vertical AI solutions for the healthcare industry. We specialize in AI-powered healthcare applications including chronic disease risk assessment, health screening management systems, and medical administrative automation.

Our mission is to make healthcare technology accessible and efficient through intelligent automation and data-driven insights.

**Website**: [https://weemed.ai/](https://weemed.ai/)

---

*Making healthcare system deployment simple and efficient.*
