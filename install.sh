#!/bin/bash
#
# Hygieia CLI Installation Script
# Installs the Hygieia healthcare platform management tool
#

set -e

# Configuration
CLI_NAME="hygieia"
CLI_BINARY="hygieia"
GITHUB_REPO="WeeMed/hygieia"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

install_cli() {
    print_info "Installing Hygieia CLI..."

    # Detect platform
    case "$(uname -s)" in
        Linux*)     OS="linux" ;;
        Darwin*)    OS="darwin" ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*) OS="windows" ;;
        *)          print_error "Unsupported OS: $(uname -s)"; exit 1 ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64) ARCH="amd64" ;;
        arm64|aarch64) ARCH="arm64" ;;
        *)          print_error "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac


    # Get latest version
    if command -v curl >/dev/null 2>&1; then
        VERSION=$(curl -s "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    elif command -v wget >/dev/null 2>&1; then
        VERSION=$(wget -q -O - "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    else
        print_error "Neither curl nor wget found"
        exit 1
    fi

    if [ -z "$VERSION" ]; then
        print_error "Failed to fetch latest version"
        exit 1
    fi


    BINARY_NAME="${CLI_NAME}-${OS}-${ARCH}"
    if [[ "$OS" == "windows" ]]; then
        BINARY_NAME="${BINARY_NAME}.exe"
        CLI_BINARY="${CLI_NAME}.exe"
    fi

    DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/download/$VERSION/${BINARY_NAME}"

    # Create temp directory
    TEMP_DIR=$(mktemp -d)

    # Download binary
    echo "Temp dir: $TEMP_DIR"
    echo "Download URL: $DOWNLOAD_URL"
    echo "Target file: ${TEMP_DIR}/${BINARY_NAME}"

    if command -v curl >/dev/null 2>&1; then
        if ! curl -L -o "${TEMP_DIR}/${BINARY_NAME}" "${DOWNLOAD_URL}"; then
            print_error "Failed to download binary"
            ls -la "$TEMP_DIR" 2>/dev/null || echo "Temp dir not accessible"
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -O "${TEMP_DIR}/${BINARY_NAME}" "${DOWNLOAD_URL}"; then
            print_error "Failed to download binary"
            ls -la "$TEMP_DIR" 2>/dev/null || echo "Temp dir not accessible"
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    else
        print_error "Neither curl nor wget found"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    # Check if file was downloaded
    if [ ! -f "${TEMP_DIR}/${BINARY_NAME}" ]; then
        print_error "Downloaded file not found: ${TEMP_DIR}/${BINARY_NAME}"
        ls -la "$TEMP_DIR"
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    echo "File downloaded successfully"
    ls -la "${TEMP_DIR}/${BINARY_NAME}"

    # Make executable
    if [[ "$OS" != "windows" ]]; then
        if ! chmod +x "${TEMP_DIR}/${BINARY_NAME}"; then
            print_error "Failed to make file executable"
            rm -rf "$TEMP_DIR"
            exit 1
        fi
        echo "File made executable"
    fi

    # Install to system directory (plane.so style)
    if [[ "$OS" == "windows" ]]; then
        INSTALL_DIR="/c/Program Files/hygieia"
        mkdir -p "$INSTALL_DIR" 2>/dev/null || true
        mv "${TEMP_DIR}/${BINARY_NAME}" "$INSTALL_DIR/$CLI_BINARY"
    else
        # Force system installation like modern CLI tools
        INSTALL_DIR="/usr/local/bin"
        if [[ "$EUID" -eq 0 ]]; then
            mkdir -p "$INSTALL_DIR"
            mv "${TEMP_DIR}/${BINARY_NAME}" "$INSTALL_DIR/$CLI_BINARY"
        else
            # Force system installation - require sudo
            if ! command -v sudo >/dev/null 2>&1; then
                print_error "sudo is required for system installation"
                exit 1
            fi

            # Use sudo to install, but ensure it can access the temp file
            echo "Temp file: ${TEMP_DIR}/${BINARY_NAME}"
            ls -la "${TEMP_DIR}/${BINARY_NAME}"

            echo "Running sudo commands..."
            if ! sudo mkdir -p "$INSTALL_DIR"; then
                print_error "Failed to create install directory"
                echo "mkdir failed, checking sudo..."
                sudo -v 2>&1 || echo "sudo authentication failed"
                exit 1
            fi
            echo "mkdir completed"

            if ! sudo cp "${TEMP_DIR}/${BINARY_NAME}" "$INSTALL_DIR/$CLI_BINARY"; then
                print_error "Failed to copy binary to install directory"
                echo "cp failed, checking temp file..."
                ls -la "${TEMP_DIR}/${BINARY_NAME}" 2>/dev/null || echo "temp file not found"
                echo "checking install dir..."
                ls -la "$INSTALL_DIR" 2>/dev/null || echo "install dir not accessible"
                exit 1
            fi
            echo "cp completed"

            if ! sudo chmod +x "$INSTALL_DIR/$CLI_BINARY"; then
                print_error "Failed to make binary executable"
                echo "chmod failed, checking installed file..."
                ls -la "$INSTALL_DIR/$CLI_BINARY" 2>/dev/null || echo "installed file not found"
                exit 1
            fi
            echo "chmod completed"
        fi
    fi

    # Cleanup
    rm -rf "$TEMP_DIR"

    print_success "Hygieia CLI $VERSION installed successfully!"

    # Verify installation
    if [ -x "$INSTALL_DIR/$CLI_BINARY" ]; then
        print_success "Installation completed successfully!"
        if command -v "$CLI_BINARY" >/dev/null 2>&1; then
            print_success "$CLI_BINARY command is available!"
        fi
    else
        print_error "Installation failed - binary not found"
        exit 1
    fi
}

# Main execution
install_cli
