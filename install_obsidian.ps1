# Obsidian Dotfiles Installer Script (PowerShell)
# This script searches for .obsidian directories and installs dotfiles

param(
    [string]$TargetPath = "",
    [switch]$Help,
    [switch]$Version,
    [switch]$Force,
    [switch]$NoBackup,
    [switch]$Quiet,
    [switch]$Local,
    [switch]$System
)

# Function to write colored output
function Write-Status {
    param([string]$Message)
    if (-not $Quiet) {
        Write-Host "[INFO] $Message" -ForegroundColor Blue
    }
}

function Write-Success {
    param([string]$Message)
    if (-not $Quiet) {
        Write-Host "[SUCCESS] $Message" -ForegroundColor Green
    }
}

function Write-Warning {
    param([string]$Message)
    if (-not $Quiet) {
        Write-Host "[WARNING] $Message" -ForegroundColor Yellow
    }
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Function to display help menu
function Show-Help {
    Write-Host "Obsidian Dotfiles Installer" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Blue
    Write-Host "  .\install_obsidian.ps1 [OPTIONS] [-TargetPath PATH]"
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Blue
    Write-Host "  -Help, -h          Show this help message"
    Write-Host "  -Version, -v       Show version information"
    Write-Host "  -Force, -f         Force installation without confirmation"
    Write-Host "  -NoBackup, -b      Skip creating backups"
    Write-Host "  -Quiet, -q         Suppress non-error output"
    Write-Host "  -Local, -l         Search only current directory and subdirectories"
    Write-Host "  -System, -s        Search entire system (default)"
    Write-Host "  -TargetPath PATH   Specific .obsidian directory to install to"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Blue
    Write-Host "  .\install_obsidian.ps1                    # Search entire system and install"
    Write-Host "  .\install_obsidian.ps1 -Local             # Search only current directory"
    Write-Host "  .\install_obsidian.ps1 -TargetPath 'C:\path\to\vault\.obsidian'  # Install to specific path"
    Write-Host "  .\install_obsidian.ps1 -Force             # Force install without confirmation"
    Write-Host "  .\install_obsidian.ps1 -NoBackup          # Install without creating backups"
    Write-Host "  .\install_obsidian.ps1 -Quiet             # Suppress output"
    Write-Host ""
    Write-Host "Description:" -ForegroundColor Blue
    Write-Host "  This script searches for .obsidian directories and installs dotfiles"
    Write-Host "  from the current directory's .obsidian folder. It creates backups"
    Write-Host "  of existing configurations before overwriting them."
    Write-Host ""
    Write-Host "Features:" -ForegroundColor Blue
    Write-Host "  • System-wide discovery of .obsidian directories"
    Write-Host "  • Automatic backup creation with timestamps"
    Write-Host "  • Interactive selection for multiple directories"
    Write-Host "  • Colored output for better readability"
    Write-Host "  • Error handling and validation"
    Write-Host ""
    Write-Host "Note:" -ForegroundColor Yellow
    Write-Host "  This script requires a .obsidian directory in the current folder"
    Write-Host "  to serve as the source for installation."
}

# Function to display version information
function Show-Version {
    Write-Host "Obsidian Dotfiles Installer" -ForegroundColor Cyan
    Write-Host "Version: 1.0.0"
    Write-Host "Author: GayKarma"
    Write-Host "License: MIT"
}

# Show help if requested
if ($Help) {
    Show-Help
    exit 0
}

# Show version if requested
if ($Version) {
    Show-Version
    exit 0
}

# Check if source .obsidian directory exists
$SourceDir = ".obsidian"
if (-not (Test-Path $SourceDir)) {
    Write-Error "Source directory '$SourceDir' not found in current directory"
    Write-Status "Please ensure you have a .obsidian directory in the current folder"
    exit 1
}

Write-Status "Starting Obsidian dotfiles installation..."
Write-Status "Source directory: $(Get-Location)\$SourceDir"

# Function to install dotfiles to a target .obsidian directory
function Install-ToDirectory {
    param(
        [string]$TargetDir,
        [string]$RelativePath = ""
    )
    
    Write-Status "Installing to: $TargetDir"
    
    # Create backup if target exists and backup is not skipped
    if (Test-Path $TargetDir -and -not $NoBackup) {
        $BackupDir = "${TargetDir}_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Warning "Creating backup: $BackupDir"
        Copy-Item -Path $TargetDir -Destination $BackupDir -Recurse -Force
    }
    
    # Copy files from source to target
    Write-Status "Copying files..."
    Copy-Item -Path "$SourceDir\*" -Destination $TargetDir -Recurse -Force
    
    Write-Success "Successfully installed to: $TargetDir"
}

# If a specific target path is provided, install there
if ($TargetPath -ne "") {
    if (Test-Path $TargetPath) {
        Install-ToDirectory -TargetDir $TargetPath
        Write-Success "Installation complete!"
        exit 0
    } else {
        Write-Error "Target path '$TargetPath' does not exist"
        exit 1
    }
}

# Search for .obsidian directories
if ($Local) {
    Write-Status "Searching for .obsidian directories in current directory and subdirectories..."
} else {
    Write-Status "Searching for .obsidian directories on entire system..."
    Write-Warning "This may take a while depending on your system size"
}

# Find all .obsidian directories
$FoundDirs = @()
$SourceDirFullPath = (Resolve-Path $SourceDir).Path

if ($Local) {
    # Search only current directory and subdirectories
    Get-ChildItem -Path . -Name ".obsidian" -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        $FullPath = (Resolve-Path $_).Path
        if ($FullPath -ne $SourceDirFullPath) {
            $FoundDirs += $_
        }
    }
} else {
    # Search entire system (Windows-specific approach)
    Write-Status "Searching all drives for .obsidian directories..."
    
    # Get all available drives
    $Drives = Get-PSDrive -PSProvider FileSystem
    
    foreach ($Drive in $Drives) {
        $DriveLetter = $Drive.Name + ":"
        Write-Status "Searching drive $DriveLetter..."
        
        try {
            Get-ChildItem -Path $DriveLetter -Name ".obsidian" -Directory -Recurse -ErrorAction SilentlyContinue -Depth 10 | ForEach-Object {
                $FullPath = Join-Path $DriveLetter $_
                if ($FullPath -ne $SourceDirFullPath) {
                    $FoundDirs += $FullPath
                }
            }
        } catch {
            # Skip drives that can't be accessed
            Write-Warning "Could not access drive $DriveLetter"
        }
    }
    
    # Limit results to prevent overwhelming output
    if ($FoundDirs.Count -gt 100) {
        Write-Warning "Found more than 100 .obsidian directories. Showing first 100 results."
        $FoundDirs = $FoundDirs[0..99]
    }
}

if ($FoundDirs.Count -eq 0) {
    Write-Warning "No .obsidian directories found"
    if ($Local) {
        Write-Status "Try using -System to search the entire system"
    }
    Write-Status "You can manually specify a target directory by running:"
    Write-Status "  .\install_obsidian.ps1 -TargetPath 'C:\path\to\your\vault\.obsidian'"
    exit 0
}

Write-Status "Found $($FoundDirs.Count) .obsidian directory(ies):"

# Display found directories
for ($i = 0; $i -lt $FoundDirs.Count; $i++) {
    Write-Host "  $($i + 1). $($FoundDirs[$i])"
}

# If only one directory found, install automatically
if ($FoundDirs.Count -eq 1) {
    Write-Status "Automatically installing to the only found directory..."
    Install-ToDirectory -TargetDir $FoundDirs[0]
} else {
    # Multiple directories found
    if ($Force) {
        # Install to all directories if force mode is enabled
        Write-Status "Force mode enabled: installing to all directories..."
        foreach ($Dir in $FoundDirs) {
            Install-ToDirectory -TargetDir $Dir
        }
    } else {
        # Ask user which one(s)
        Write-Host ""
        Write-Status "Multiple .obsidian directories found. Which one(s) would you like to install to?"
        Write-Status "Enter numbers separated by spaces (e.g., '1 3') or 'all' for all directories:"
        $Selection = Read-Host
        
        if ($Selection -eq "all") {
            foreach ($Dir in $FoundDirs) {
                Install-ToDirectory -TargetDir $Dir
            }
        } else {
            # Parse user selection
            $Numbers = $Selection -split '\s+'
            foreach ($Num in $Numbers) {
                if ($Num -match '^\d+$' -and [int]$Num -ge 1 -and [int]$Num -le $FoundDirs.Count) {
                    $Index = [int]$Num - 1
                    Install-ToDirectory -TargetDir $FoundDirs[$Index]
                } else {
                    Write-Error "Invalid selection: $Num"
                }
            }
        }
    }
}

Write-Success "Installation complete!"
if (-not $NoBackup) {
    Write-Status "Note: Backups were created for existing .obsidian directories"
} 