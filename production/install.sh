#!/bin/bash

# Hygieia CLI Installation Script
# Creates proper Linux directory structure and installs the binary

set -e  # Exit on any error

# Configuration
BINARY_NAME="hygieia"
INSTALL_DIR="/usr/local/bin"
SHARE_DIR="/usr/local/share/hygieia"
CONFIG_DIR="/etc/hygieia"
DATA_DIR="/var/lib/hygieia"
LOG_DIR="/var/log/hygieia"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run with sudo privileges"
    echo "Usage: curl -fsSL https://raw.githubusercontent.com/WeeMed/hygieia/main/github/production/install.sh | sudo bash"
    exit 1
fi

# Detect architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    arm64|aarch64)
        ARCH="arm64"
        ;;
    *)
        print_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Detect OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case $OS in
    linux|darwin)
        ;;
    *)
        print_error "Unsupported operating system: $OS"
        exit 1
        ;;
esac

print_info "Installing Hygieia CLI for $OS/$ARCH..."

# Download the binary
DOWNLOAD_URL="https://github.com/WeeMed/hygieia/releases/latest/download/hygieia-${OS}-${ARCH}"
TEMP_BINARY="/tmp/hygieia"

print_info "Downloading binary from: $DOWNLOAD_URL"
if ! curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_BINARY"; then
    print_error "Failed to download binary"
    exit 1
fi

# Make binary executable
chmod +x "$TEMP_BINARY"

# Verify binary
if ! "$TEMP_BINARY" version >/dev/null 2>&1; then
    print_error "Downloaded binary is not working correctly"
    rm -f "$TEMP_BINARY"
    exit 1
fi

# Install binary
print_info "Installing binary to $INSTALL_DIR..."
mv "$TEMP_BINARY" "$INSTALL_DIR/$BINARY_NAME"

# Create standard Linux directories
print_info "Creating system directories..."

# /usr/local/share/hygieia - Application data and templates
mkdir -p "$SHARE_DIR"
chown "$SUDO_USER:$SUDO_USER" "$SHARE_DIR" 2>/dev/null || chown "$(id -un 1000):$(id -gn 1000)" "$SHARE_DIR"

# /etc/hygieia - Configuration files
mkdir -p "$CONFIG_DIR"
chown "$SUDO_USER:$SUDO_USER" "$CONFIG_DIR" 2>/dev/null || chown "$(id -un 1000):$(id -gn 1000)" "$CONFIG_DIR"

# /var/lib/hygieia - Runtime state and data
mkdir -p "$DATA_DIR"
chown "$SUDO_USER:$SUDO_USER" "$DATA_DIR" 2>/dev/null || chown "$(id -un 1000):$(id -gn 1000)" "$DATA_DIR"

# /var/log/hygieia - Log files
mkdir -p "$LOG_DIR"
chown "$SUDO_USER:$SUDO_USER" "$LOG_DIR" 2>/dev/null || chown "$(id -un 1000):$(id -gn 1000)" "$LOG_DIR"

# Create default configuration file
cat > "$CONFIG_DIR/config.yaml" << 'EOF'
# Hygieia Configuration
# For more options, see: https://github.com/WeeMed/hygieia/docs

# Logging
logging:
  level: "info"  # debug, info, warn, error
  file: "/var/log/hygieia/hygieia.log"

# Runtime directory (override)
# runtime_dir: "/var/lib/hygieia"
EOF

chown "$SUDO_USER:$SUDO_USER" "$CONFIG_DIR/config.yaml" 2>/dev/null || chown "$(id -un 1000):$(id -gn 1000)" "$CONFIG_DIR/config.yaml"

# Create user-specific fallback directories
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
    print_info "Creating user fallback directories for $SUDO_USER..."
    
    sudo -u "$SUDO_USER" mkdir -p "$USER_HOME/.config/hygieia"
    sudo -u "$SUDO_USER" mkdir -p "$USER_HOME/.local/share/hygieia"
    sudo -u "$SUDO_USER" mkdir -p "$USER_HOME/.local/share/hygieia/logs"
fi

print_success "Hygieia CLI installed successfully!"
print_info ""
print_info "Directory structure created:"
print_info "  Binary:        $INSTALL_DIR/$BINARY_NAME"
print_info "  Config:        $CONFIG_DIR/"
print_info "  Data:          $DATA_DIR/"
print_info "  Logs:          $LOG_DIR/"
print_info "  Templates:     $SHARE_DIR/"
print_info ""
print_info "Quick start:"
print_info "  1. hygieia deploy up          # Start services"
print_info "  2. hygieia deploy status      # Check status"
print_info "  3. hygieia deploy down        # Stop services"
print_info ""
print_info "Documentation: https://github.com/WeeMed/hygieia/docs"

# Verify installation
if command -v hygieia >/dev/null 2>&1; then
    print_success "Installation verified: $(hygieia version 2>/dev/null || echo 'hygieia command is available')"
else
    print_warning "Binary installed but not in PATH. You may need to restart your shell."
fi 