# Hygieia CLI Installation Script for Windows
# Downloads and installs the latest Hygieia CLI from GitHub releases

param(
    [switch]$Force
)

# Configuration
$CLI_NAME = "hygieia"
$GITHUB_REPO = "WeeMed/hygieia"
$INSTALL_DIR = "$env:ProgramFiles\hygieia"

# Colors for output
$RED = "Red"
$GREEN = "Green"
$YELLOW = "Yellow"
$BLUE = "Cyan"

function Write-Info {
    param([string]$Message)
    Write-Host "[$BLUE INFO$([char]27)[0m] $Message" -ForegroundColor $BLUE
}

function Write-Success {
    param([string]$Message)
    Write-Host "[$GREEN SUCCESS$([char]27)[0m] $Message" -ForegroundColor $GREEN
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[$YELLOW WARNING$([char]27)[0m] $Message" -ForegroundColor $YELLOW
}

function Write-Error {
    param([string]$Message)
    Write-Host "[$RED ERROR$([char]27)[0m] $Message" -ForegroundColor $RED
}

# Get latest version from GitHub releases
function Get-LatestVersion {
    Write-Info "Fetching latest version from GitHub..."

    try {
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/${GITHUB_REPO}/releases/latest"
        $version = $response.tag_name
        Write-Success "Latest version: $version"
        return $version
    }
    catch {
        Write-Error "Failed to fetch latest version from GitHub"
        exit 1
    }
}

# Download binary from GitHub releases
function Download-Binary {
    param([string]$Version)

    $binaryName = "${CLI_NAME}-windows-amd64.exe"
    $downloadUrl = "https://github.com/${GITHUB_REPO}/releases/download/${Version}/${binaryName}"
    $tempDir = [System.IO.Path]::GetTempPath()
    $tempFile = Join-Path $tempDir "${CLI_NAME}.exe"

    Write-Info "Downloading ${CLI_NAME} ${Version} for Windows..."
    Write-Info "Download URL: ${downloadUrl}"

    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile -UseBasicParsing
        Write-Success "Download completed"
        return $tempFile
    }
    catch {
        Write-Error "Failed to download binary: $($_.Exception.Message)"
        exit 1
    }
}

# Install binary
function Install-Binary {
    param([string]$TempFile)

    Write-Info "Installing binary to ${INSTALL_DIR}..."

    # Create installation directory
    if (!(Test-Path $INSTALL_DIR)) {
        New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
    }

    # Install binary
    try {
        Move-Item -Path $TempFile -Destination (Join-Path $INSTALL_DIR "${CLI_NAME}.exe") -Force
        Write-Success "Binary installed successfully"
    }
    catch {
        Write-Error "Failed to install binary: $($_.Exception.Message)"
        exit 1
    }
}

# Add to PATH
function Add-ToPath {
    param([string]$PathToAdd)

    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$PathToAdd*") {
        $newPath = "$currentPath;$PathToAdd"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Success "Added ${PathToAdd} to user PATH"
        Write-Info "Please restart your PowerShell/Command Prompt to use the new PATH"
    }
    else {
        Write-Info "${PathToAdd} is already in PATH"
    }
}

# Main installation process
function Main {
    Write-Info "Starting Hygieia CLI installation for Windows..."

    # Check if already installed
    $existingPath = Join-Path $INSTALL_DIR "${CLI_NAME}.exe"
    if ((Test-Path $existingPath) -and !$Force) {
        Write-Warning "Hygieia CLI is already installed at ${INSTALL_DIR}"
        Write-Info "Use -Force parameter to reinstall: .\install.ps1 -Force"
        exit 0
    }

    # Get latest version
    $version = Get-LatestVersion

    # Download binary
    $tempFile = Download-Binary -Version $version

    # Install binary
    Install-Binary -TempFile $tempFile

    # Add to PATH
    Add-ToPath -PathToAdd $INSTALL_DIR

    Write-Success "Hygieia CLI ${version} installed successfully!"
    Write-Info ""
    Write-Info "Binary location: ${INSTALL_DIR}\${CLI_NAME}.exe"
    Write-Info ""
    Write-Info "Quick start:"
    Write-Info "  1. Restart your PowerShell/Command Prompt"
    Write-Info "  2. hygieia --help          # Show help"
    Write-Info "  3. hygieia init            # Initialize project"
    Write-Info "  4. hygieia deploy up       # Deploy services"
    Write-Info ""
    Write-Info "Documentation: https://github.com/${GITHUB_REPO}"
    Write-Info ""
    Write-Info "Installation verification:"

    # Verify installation
    try {
        $installedPath = Join-Path $INSTALL_DIR "${CLI_NAME}.exe"
        if (Test-Path $installedPath) {
            Write-Success "Installation verified: Binary found at ${installedPath}"
        }
        else {
            Write-Warning "Installation verification failed"
        }
    }
    catch {
        Write-Warning "Could not verify installation"
    }
}

# Run main function
Main
