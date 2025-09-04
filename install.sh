#!/bin/bash
#
# Hygieia CLI Installation Script
# Downloads and installs the latest Hygieia CLI from GitHub releases
#

set -e

# Configuration
CLI_NAME="hygieia"
GITHUB_REPO="WeeMed/hygieia"

# Set installation paths based on OS
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]] || [[ "$OS" == "windows" ]]; then
    # Windows paths
    INSTALL_DIR="/c/Program Files/hygieia"
    SHARE_DIR="/c/ProgramData/hygieia"
else
    # Unix-like paths
    INSTALL_DIR="/usr/local/bin"
    SHARE_DIR="/usr/local/share/hygieia"
fi

# Colors for output
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

# Get latest version from GitHub releases
get_latest_version() {
    # Try to get latest release info
    if command -v curl >/dev/null 2>&1; then
        LATEST_VERSION=$(curl -s "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    elif command -v wget >/dev/null 2>&1; then
        LATEST_VERSION=$(wget -q -O - "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    else
        print_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi

    if [ -z "$LATEST_VERSION" ]; then
        print_error "Failed to fetch latest version from GitHub"
        exit 1
    fi

    echo "$LATEST_VERSION"
}

# Detect platform and architecture
detect_platform() {
    # Detect OS
    case "$(uname -s)" in
        Linux*)     OS="linux" ;;
        Darwin*)    OS="darwin" ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*) OS="windows" ;;
        *)          print_error "Unsupported OS: $(uname -s)"; exit 1 ;;
    esac

    # Detect architecture
    case "$(uname -m)" in
        x86_64|amd64) ARCH="amd64" ;;
        arm64|aarch64) ARCH="arm64" ;;
        *)          print_error "Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac

    print_info "Detected platform: $OS/$ARCH"
}

# Download binary from GitHub releases
download_binary() {
    local version=$1
    local binary_name="${CLI_NAME}-${OS}-${ARCH}"

    # Add .exe extension for Windows
    if [[ "$OS" == "windows" ]]; then
        binary_name="${binary_name}.exe"
        CLI_BINARY="${CLI_NAME}.exe"
    else
        CLI_BINARY="$CLI_NAME"
    fi

    local download_url="https://github.com/${GITHUB_REPO}/releases/download/$version/${binary_name}"
    local temp_dir=$(mktemp -d)

    # Note: print_info calls moved to main function to avoid stdout capture

    if command -v curl >/dev/null 2>&1; then
        if ! curl -L -o "${temp_dir}/${CLI_BINARY}" "${download_url}"; then
            print_error "Failed to download binary using curl"
            rm -rf "$temp_dir"
            exit 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -O "${temp_dir}/${CLI_BINARY}" "${download_url}"; then
            print_error "Failed to download binary using wget"
            rm -rf "$temp_dir"
            exit 1
        fi
    else
        print_error "Neither curl nor wget found"
        rm -rf "$temp_dir"
        exit 1
    fi

    # Make binary executable (skip for Windows as it's handled by the OS)
    if [[ "$OS" != "windows" ]]; then
        chmod +x "${temp_dir}/${CLI_BINARY}"
    fi

    echo "$temp_dir"
}

# Install binary
install_binary() {
    local temp_dir=$1

    # Windows has different installation requirements
    if [[ "$OS" == "windows" ]]; then
        print_info "Installing binary for Windows..."

        # On Windows, we'll install to a user-accessible location
        # Check if running with elevated privileges (similar to sudo)
        if [[ ! -w "$INSTALL_DIR" ]]; then
            print_warning "No write access to ${INSTALL_DIR}"
            print_info "Installing to user directory: $HOME/bin"
            USER_INSTALL_DIR="$HOME/bin"
            mkdir -p "$USER_INSTALL_DIR"
            INSTALL_DIR="$USER_INSTALL_DIR"
        fi
    else
        print_info "Installing binary to ${INSTALL_DIR}..."

        # Check if script is run with sudo (required for system installation on Unix-like systems)
        if [ "$EUID" -ne 0 ]; then
            print_warning "This script requires sudo for system installation"
            print_info "Please enter your sudo password when prompted..."

            # Store current state and re-run with sudo
            TEMP_FILE="$temp_dir"
            if command -v sudo >/dev/null 2>&1; then
                print_info "Re-running script with sudo..."
                # Use a different approach - create a temporary script with preserved state
                SCRIPT_CONTENT="#!/bin/bash
# Temporary script to complete installation with sudo
export VERSION=\"$VERSION\"
export OS=\"$OS\"
export ARCH=\"$ARCH\"
export INSTALL_DIR=\"$INSTALL_DIR\"
export SHARE_DIR=\"$SHARE_DIR\"
export CLI_NAME=\"$CLI_NAME\"
export CLI_BINARY=\"$CLI_BINARY\"
export GITHUB_REPO=\"$GITHUB_REPO\"
export TEMP_FILE=\"$TEMP_FILE\"

# Continue with installation
mkdir -p \"\$INSTALL_DIR\"
if mv \"\$TEMP_FILE/\$CLI_BINARY\" \"\$INSTALL_DIR/\$CLI_BINARY\"; then
    echo '[SUCCESS] Binary installed successfully!'
    echo \"[INFO] Binary location: \$INSTALL_DIR/\$CLI_BINARY\"
    mkdir -p \"\$SHARE_DIR\"

    # Update shell command cache
    if command -v hash >/dev/null 2>&1; then
        hash -r 2>/dev/null || true
    fi

    echo \"[SUCCESS] Hygieia CLI \$VERSION installed successfully!\"
    echo \"\"
    echo '[INFO] Quick start:'
    echo '  1. hygieia --help          # Show help'
    echo '  2. hygieia init            # Initialize project'
    echo '  3. hygieia deploy up       # Deploy services'
    echo \"\"
    echo \"[INFO] Documentation: https://github.com/\$GITHUB_REPO\"

    # Test the installation
    echo \"[INFO] Verifying installation...\"

    # First check if the binary file exists and is executable
    if [ -x \"\$INSTALL_DIR/\$CLI_BINARY\" ]; then
        echo \"[SUCCESS] Binary file installed at: \$INSTALL_DIR/\$CLI_BINARY\"

        # Try to make the command immediately available
        if ! echo \"\$PATH\" | grep -q \"\$INSTALL_DIR\"; then
            # Add to current PATH
            export PATH=\"\$PATH:\$INSTALL_DIR\"
            echo \"[INFO] Added \$INSTALL_DIR to current PATH\"
        fi

        # Refresh command hash
        hash -r 2>/dev/null || true

        # Test command availability
        if command -v \"\$CLI_BINARY\" >/dev/null 2>&1; then
            echo \"[SUCCESS] \$CLI_BINARY command is immediately available!\"
            echo \"[INFO] Try running: \$CLI_BINARY --help\"
        else
            echo \"[INFO] Setting up permanent PATH configuration...\"

            # Detect shell type and profile file (comprehensive shell support)
            SHELL_PROFILE=\"\"
            SHELL_RELOAD_CMD=\"\"
            SHELL_NAME=\"\$(basename \"\$SHELL\")\"

            case \"\$SHELL_NAME\" in
                zsh)
                    SHELL_PROFILE=\"\$HOME/.zshrc\"
                    SHELL_RELOAD_CMD=\"source \$HOME/.zshrc\"
                    ;;
                bash)
                    # Check for different bash profile files
                    if [ -f \"\$HOME/.bash_profile\" ]; then
                        SHELL_PROFILE=\"\$HOME/.bash_profile\"
                        SHELL_RELOAD_CMD=\"source \$HOME/.bash_profile\"
                    elif [ -f \"\$HOME/.bashrc\" ]; then
                        SHELL_PROFILE=\"\$HOME/.bashrc\"
                        SHELL_RELOAD_CMD=\"source \$HOME/.bashrc\"
                    elif [ -f \"\$HOME/.profile\" ]; then
                        SHELL_PROFILE=\"\$HOME/.profile\"
                        SHELL_RELOAD_CMD=\"source \$HOME/.profile\"
                    fi
                    ;;
                fish)
                    SHELL_PROFILE=\"\$HOME/.config/fish/config.fish\"
                    SHELL_RELOAD_CMD=\"source \$HOME/.config/fish/config.fish\"
                    ;;
                csh|tcsh)
                    SHELL_PROFILE=\"\$HOME/.cshrc\"
                    SHELL_RELOAD_CMD=\"source \$HOME/.cshrc\"
                    ;;
                ksh)
                    SHELL_PROFILE=\"\$HOME/.kshrc\"
                    SHELL_RELOAD_CMD=\"source \$HOME/.kshrc\"
                    ;;
                *)
                    # Fallback: try common profile files
                    if [ -f \"\$HOME/.profile\" ]; then
                        SHELL_PROFILE=\"\$HOME/.profile\"
                        SHELL_RELOAD_CMD=\"source \$HOME/.profile\"
                    elif [ -f \"\$HOME/.bashrc\" ]; then
                        SHELL_PROFILE=\"\$HOME/.bashrc\"
                        SHELL_RELOAD_CMD=\"source \$HOME/.bashrc\"
                    fi
                    ;;
            esac

            # Update shell profile with PATH (shell-specific syntax)
            if [ -n \"\$SHELL_PROFILE\" ] && [ -w \"\$SHELL_PROFILE\" ]; then
                if ! grep -q \"\$INSTALL_DIR\" \"\$SHELL_PROFILE\" 2>/dev/null; then
                    echo \"\" >> \"\$SHELL_PROFILE\"
                    echo \"# Added by Hygieia CLI installer\" >> \"\$SHELL_PROFILE\"

                    # Add PATH based on shell type
                    case \"\$SHELL_NAME\" in
                        fish)
                            echo \"set -U fish_user_paths \$INSTALL_DIR \$fish_user_paths\" >> \"\$SHELL_PROFILE\"
                            ;;
                        csh|tcsh)
                            echo \"setenv PATH \\\"\$PATH:\$INSTALL_DIR\\\"\" >> \"\$SHELL_PROFILE\"
                            ;;
                        *)
                            # Default for bash, zsh, ksh and others
                            echo \"export PATH=\\\"\$PATH:\$INSTALL_DIR\\\"\" >> \"\$SHELL_PROFILE\"
                            ;;
                    esac

                    echo \"[SUCCESS] Added \$INSTALL_DIR to \$SHELL_PROFILE\"

                    # Try to reload the profile immediately
                    if eval \"\$SHELL_RELOAD_CMD\" 2>/dev/null; then
                        echo \"[SUCCESS] Shell profile reloaded\"
                        # Check again after reload
                        if command -v \"\$CLI_BINARY\" >/dev/null 2>&1; then
                            echo \"[SUCCESS] \$CLI_BINARY command is now available!\"
                            echo \"[INFO] Try running: \$CLI_BINARY --help\"
                            exit 0
                        fi
                    else
                        echo \"[INFO] Please run: \$SHELL_RELOAD_CMD\"
                    fi
                else
                    echo \"[INFO] \$INSTALL_DIR already in PATH via \$SHELL_PROFILE\"
                fi
            else
                echo \"[WARNING] Could not update shell profile automatically\"
                echo \"[INFO] Please manually add to your PATH based on your shell:\"
                case \"\$SHELL_NAME\" in
                    fish)
                        echo \"  set -U fish_user_paths /usr/local/bin \$fish_user_paths\"
                        ;;
                    csh|tcsh)
                        echo \"  setenv PATH \\\"\$PATH:/usr/local/bin\\\"\"
                        ;;
                    *)
                        echo \"  export PATH=\\\"\$PATH:/usr/local/bin\\\"\"
                        ;;
                esac
                echo \"  Or add the above line to your shell profile\"
            fi

            echo \"[INFO] Installation complete. You can now use \$CLI_BINARY\"
        fi
    else
        echo \"[ERROR] Binary file not found or not executable at: \$INSTALL_DIR/\$CLI_BINARY\"
        exit 1
    fi
else
    echo '[ERROR] Failed to install binary'
    exit 1
fi

# Cleanup
rm -rf \"\$TEMP_FILE\"
"
                echo "$SCRIPT_CONTENT" > "/tmp/hygieia_install_sudo.sh"
                chmod +x "/tmp/hygieia_install_sudo.sh"
                if sudo bash "/tmp/hygieia_install_sudo.sh"; then
                    # Installation completed successfully in sudo script
                    exit 0
                else
                    print_error "Installation failed"
                    rm -rf "$temp_dir"
                    exit 1
                fi
            else
                print_error "sudo command not found. Please install sudo or run this script with root privileges."
                rm -rf "$temp_dir"
                exit 1
            fi
        fi
    fi

    # Create installation directory if it doesn't exist
    mkdir -p "$INSTALL_DIR"

    # Install binary
    if ! mv "${temp_dir}/${CLI_BINARY}" "${INSTALL_DIR}/${CLI_BINARY}"; then
        print_error "Failed to install binary"
        rm -rf "$temp_dir"
        exit 1
    fi

    # Create share directory (skip for Windows)
    if [[ "$OS" != "windows" ]]; then
        mkdir -p "$SHARE_DIR"
    fi

    # Cleanup
    rm -rf "$temp_dir"
}

# Main installation process
main() {
    print_info "Starting Hygieia CLI installation..."

    # Detect platform
    detect_platform

    # Get latest version
    print_info "Fetching latest version from GitHub..."
    VERSION=$(get_latest_version)
    print_success "Latest version: $VERSION"

    # Download binary
    print_info "Downloading ${CLI_NAME} ${VERSION} for ${OS}/${ARCH}..."
    print_info "Download URL: https://github.com/${GITHUB_REPO}/releases/download/${VERSION}/hygieia-${OS}-${ARCH}"
    TEMP_DIR=$(download_binary "$VERSION")

    # Install binary
    install_binary "$TEMP_DIR"

    print_success "Hygieia CLI ${VERSION} installed successfully!"
    print_info ""
    print_info "Binary location: ${INSTALL_DIR}/${CLI_BINARY}"
    print_info ""

    if [[ "$OS" == "windows" ]]; then
        print_info "Windows installation notes:"
        print_info "  1. Add ${INSTALL_DIR} to your PATH environment variable"
        print_info "  2. Or move hygieia.exe to a directory already in PATH (e.g., C:\\Windows\\System32)"
        print_info "  3. Restart your command prompt or PowerShell"
        print_info ""
        print_info "PowerShell PATH setup:"
        print_info "  \$env:Path += \";${INSTALL_DIR}\""
        print_info ""
    fi

    print_info "Quick start:"
    print_info "  1. hygieia --help          # Show help"
    print_info "  2. hygieia init            # Initialize project"
    print_info "  3. hygieia deploy up       # Deploy services"
    print_info ""
    print_info "Documentation: https://github.com/${GITHUB_REPO}"

    # Verify installation
    if [[ "$OS" == "windows" ]]; then
        if [[ -f "${INSTALL_DIR}/${CLI_BINARY}" ]]; then
            print_success "Installation verified: Binary found at ${INSTALL_DIR}/${CLI_BINARY}"
        else
            print_warning "Installation may have failed"
        fi
    else
        if command -v hygieia >/dev/null 2>&1; then
            print_success "Installation verified: $(hygieia version 2>/dev/null || echo 'hygieia command available')"
        else
            print_warning "Installation completed, but binary may not be in PATH"
            print_info "You may need to restart your shell or run: export PATH=\$PATH:${INSTALL_DIR}"
        fi
    fi
}

# Run main function
main "$@"
