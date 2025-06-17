# Hygieia - Intelligent Healthcare System Deployment

**Enterprise-grade intelligent deployment solution with 10-second healthcare system startup**

[![Latest Release](https://img.shields.io/badge/release-v1.0.70-green.svg)](https://github.com/WeeMed/hygieia/releases/latest)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/WeeMed/hygieia)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)](https://github.com/WeeMed/hygieia/releases)

## 🚀 Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/WeeMed/hygieia/refs/heads/main/install.sh | sudo bash
```

## ✨ Key Features

- **⚡ Lightning Fast**: 10-second startup, zero database wait time
- **🧠 AI-Powered**: Automatically detects and fixes 90% of common issues
- **🌍 Multilingual**: Traditional Chinese / English TUI interface
- **🔧 Developer Friendly**: 3-step deployment, no DevOps expertise required
- **📦 Multi-Product**: Supports hi-care, hi-hope, hi-checkup medical systems

## 🎯 Use Cases

- **Healthcare Institutions**: Rapid deployment of EMR and health screening systems
- **Software Companies**: Deliver medical solutions to clients efficiently
- **System Integrators**: Simplify medical system deployment workflows

## 📋 System Requirements

- **OS**: Linux (Ubuntu 20.04+) or macOS
- **Memory**: 4GB+ RAM (8GB+ recommended)
- **Storage**: 20GB+ available space
- **Containers**: Docker 24.0+ & Docker Compose 2.24+

## 🚀 Quick Start

### 1. Install Hygieia CLI

```bash
curl -fsSL https://raw.githubusercontent.com/WeeMed/hygieia/refs/heads/main/install.sh | sudo bash
```

### 2. Initialize Configuration

```bash
mkdir my-medical-system
cd my-medical-system
hygieia init
```

The TUI interface will guide you through:

- Select medical products (hi-care/hi-hope/hi-checkup)
- Configure domains and SSL
- Set organization information

### 3. One-Click Deployment

```bash
hygieia deploy up
```

**That's it! The system will automatically:**

- Download required container images
- Configure databases and networking
- Set up SSL certificates (optional)
- Start all services

## 📖 Documentation

All documentation is contained within this README. For additional support:

- [📋 Release Notes](https://github.com/WeeMed/hygieia/releases/latest)
- [🐛 Report Issues](https://github.com/WeeMed/hygieia/issues)

## 🔧 Common Commands

```bash
hygieia --help          # Show all commands
hygieia init            # Initialize project
hygieia deploy up       # Deploy system
hygieia deploy down     # Stop system
hygieia status          # Check status
hygieia logs            # View logs
hygieia backup create   # Backup data
hygieia snapshot create # Create snapshot
```

## 🆘 Troubleshooting

If you encounter issues:

1. **Smart Diagnostics**: `hygieia status` automatically detects problems
2. **Log Analysis**: `hygieia logs` shows detailed errors
3. **System Reset**: `hygieia deploy down && hygieia deploy up`

**Built-in AI features automatically resolve most common issues!**

## 📊 Supported Medical Systems

| Product        | Function                   | Use Case                  |
| -------------- | -------------------------- | ------------------------- |
| **hi-care**    | Electronic Medical Records | Clinics, Hospitals        |
| **hi-hope**    | Health Risk Assessment     | Health Screening Centers  |
| **hi-checkup** | Intelligent Health Check   | Corporate Health Programs |

## 🏗️ Architecture

Hygieia provides intelligent automation for:

- **Container Orchestration**: Smart Docker Compose management
- **Database Management**: Zero-wait PostgreSQL initialization
- **SSL Configuration**: Automatic Let's Encrypt or self-signed certificates
- **Multi-tenancy**: Support for multiple healthcare applications
- **Configuration Sync**: Auto-sync between YAML and ENV files

## 🛠️ Manual Installation

If you prefer manual installation:

### Linux (AMD64/ARM64)

```bash
# Download binary
wget https://github.com/WeeMed/hygieia/releases/download/v1.0.70/hygieia-linux-amd64
chmod +x hygieia-linux-amd64
sudo mv hygieia-linux-amd64 /usr/local/bin/hygieia
```

### macOS (Intel/Apple Silicon)

```bash
# Download binary
curl -LO https://github.com/WeeMed/hygieia/releases/download/v1.0.70/hygieia-darwin-arm64
chmod +x hygieia-darwin-arm64
sudo mv hygieia-darwin-arm64 /usr/local/bin/hygieia
```

## 🔐 Security & Verification

Verify download integrity:

```bash
wget https://github.com/WeeMed/hygieia/releases/download/v1.0.70/checksums.txt
sha256sum -c checksums.txt
```

## 📈 Performance

- **🚀 10-second startup**: vs. traditional 30+ second deployments
- **🛡️ 90% issue auto-resolution**: reduced support tickets
- **⚡ Smart building**: only builds enabled components
- **🔄 Zero-downtime updates**: rolling deployment support

---

## 🏢 About WeeMed

WeeMed is dedicated to providing enterprise-grade healthcare information solutions, making complex system deployments simple and efficient.

🌐 **Official Website**: [https://weemed.ai/](https://weemed.ai/)

**Enterprise Consulting & Technical Support**: Contact WeeMed Technical Team

---

_Hygieia - Making healthcare system deployment as natural as breathing 🌟_
