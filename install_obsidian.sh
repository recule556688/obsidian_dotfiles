#!/bin/bash

# Obsidian Dotfiles Installer Script
# This script searches for .obsidian directories and installs dotfiles

set -e # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
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

# Function to display help menu
show_help() {
    echo -e "${CYAN}Obsidian Dotfiles Installer${NC}"
    echo ""
    echo -e "${BLUE}Usage:${NC}"
    echo "  $0 [OPTIONS] [TARGET_PATH]"
    echo ""
    echo -e "${BLUE}Options:${NC}"
    echo "  -h, --help          Show this help message"
    echo "  -v, --version       Show version information"
    echo "  -f, --force         Force installation without confirmation"
    echo "  -b, --no-backup     Skip creating backups"
    echo "  -q, --quiet         Suppress non-error output"
    echo "  -l, --local         Search only current directory and subdirectories"
    echo "  -s, --system        Search entire system (default)"
    echo ""
    echo -e "${BLUE}Arguments:${NC}"
    echo "  TARGET_PATH         Specific .obsidian directory to install to"
    echo ""
    echo -e "${BLUE}Examples:${NC}"
    echo "  $0                    # Search entire system and install"
    echo "  $0 -l                 # Search only current directory"
    echo "  $0 /path/to/vault/.obsidian  # Install to specific path"
    echo "  $0 -f                 # Force install without confirmation"
    echo "  $0 -b                 # Install without creating backups"
    echo ""
    echo -e "${BLUE}Description:${NC}"
    echo "  This script searches for .obsidian directories and installs dotfiles"
    echo "  from the current directory's .obsidian folder. It creates backups"
    echo "  of existing configurations before overwriting them."
    echo ""
    echo -e "${BLUE}Features:${NC}"
    echo "  • System-wide discovery of .obsidian directories"
    echo "  • Automatic backup creation with timestamps"
    echo "  • Interactive selection for multiple directories"
    echo "  • Colored output for better readability"
    echo "  • Error handling and validation"
    echo ""
    echo -e "${YELLOW}Note:${NC} This script requires a .obsidian directory in the current folder"
    echo "      to serve as the source for installation."
}

# Function to display version information
show_version() {
    echo -e "${CYAN}Obsidian Dotfiles Installer${NC}"
    echo "Version: 1.0.0"
    echo "Author: GayKarma"
    echo "License: MIT"
}

# Parse command line arguments
FORCE_INSTALL=false
SKIP_BACKUP=false
QUIET_MODE=false
SEARCH_LOCAL=false
TARGET_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
        show_help
        exit 0
        ;;
    -v | --version)
        show_version
        exit 0
        ;;
    -f | --force)
        FORCE_INSTALL=true
        shift
        ;;
    -b | --no-backup)
        SKIP_BACKUP=true
        shift
        ;;
    -q | --quiet)
        QUIET_MODE=true
        shift
        ;;
    -l | --local)
        SEARCH_LOCAL=true
        shift
        ;;
    -s | --system)
        SEARCH_LOCAL=false
        shift
        ;;
    -*)
        print_error "Unknown option: $1"
        echo "Use '$0 --help' for usage information"
        exit 1
        ;;
    *)
        if [ -z "$TARGET_PATH" ]; then
            TARGET_PATH="$1"
        else
            print_error "Multiple target paths specified"
            exit 1
        fi
        shift
        ;;
    esac
done

# Check if source .obsidian directory exists
SOURCE_DIR=".obsidian"
if [ ! -d "$SOURCE_DIR" ]; then
    print_error "Source directory '$SOURCE_DIR' not found in current directory"
    print_status "Please ensure you have a .obsidian directory in the current folder"
    exit 1
fi

if [ "$QUIET_MODE" = false ]; then
    print_status "Starting Obsidian dotfiles installation..."
    print_status "Source directory: $(pwd)/$SOURCE_DIR"
fi

# Function to install dotfiles to a target .obsidian directory
install_to_directory() {
    local target_dir="$1"
    local relative_path="$2"

    if [ "$QUIET_MODE" = false ]; then
        print_status "Installing to: $target_dir"
    fi

    # Create backup if target exists and backup is not skipped
    if [ -d "$target_dir" ] && [ "$SKIP_BACKUP" = false ]; then
        local backup_dir="${target_dir}_backup_$(date +%Y%m%d_%H%M%S)"
        if [ "$QUIET_MODE" = false ]; then
            print_warning "Creating backup: $backup_dir"
        fi
        cp -r "$target_dir" "$backup_dir"
    fi

    # Copy files from source to target
    if [ "$QUIET_MODE" = false ]; then
        print_status "Copying files..."
    fi
    cp -r "$SOURCE_DIR"/* "$target_dir/"

    if [ "$QUIET_MODE" = false ]; then
        print_success "Successfully installed to: $target_dir"
    fi
}

# If a specific target path is provided, install there
if [ -n "$TARGET_PATH" ]; then
    if [ -d "$TARGET_PATH" ]; then
        install_to_directory "$TARGET_PATH"
        if [ "$QUIET_MODE" = false ]; then
            print_success "Installation complete!"
        fi
        exit 0
    else
        print_error "Target path '$TARGET_PATH' does not exist"
        exit 1
    fi
fi

# Search for .obsidian directories
if [ "$QUIET_MODE" = false ]; then
    if [ "$SEARCH_LOCAL" = true ]; then
        print_status "Searching for .obsidian directories in current directory and subdirectories..."
    else
        print_status "Searching for .obsidian directories on entire system..."
        print_warning "This may take a while depending on your system size"
    fi
fi

# Find all .obsidian directories
found_dirs=()
if [ "$SEARCH_LOCAL" = true ]; then
    # Search only current directory and subdirectories
    while IFS= read -r -d '' dir; do
        # Skip the source directory itself
        if [ "$(realpath "$dir")" != "$(realpath "$SOURCE_DIR")" ]; then
            found_dirs+=("$dir")
        fi
    done < <(find . -name ".obsidian" -type d -print0 2>/dev/null)
else
    # Search entire system (excluding common system directories)
    while IFS= read -r -d '' dir; do
        # Skip the source directory itself and common system directories
        if [ "$(realpath "$dir")" != "$(realpath "$SOURCE_DIR")" ] &&
            [[ "$dir" != *"/proc/"* ]] &&
            [[ "$dir" != *"/sys/"* ]] &&
            [[ "$dir" != *"/dev/"* ]] &&
            [[ "$dir" != *"/tmp/"* ]] &&
            [[ "$dir" != *"/var/"* ]] &&
            [[ "$dir" != *"/usr/"* ]] &&
            [[ "$dir" != *"/etc/"* ]]; then
            found_dirs+=("$dir")
        fi
    done < <(find / -name ".obsidian" -type d -print0 2>/dev/null | head -1000)
fi

if [ ${#found_dirs[@]} -eq 0 ]; then
    if [ "$QUIET_MODE" = false ]; then
        print_warning "No .obsidian directories found"
        if [ "$SEARCH_LOCAL" = true ]; then
            print_status "Try using --system to search the entire system"
        fi
        print_status "You can manually specify a target directory by running:"
        print_status "  $0 /path/to/your/vault/.obsidian"
    fi
    exit 0
fi

if [ "$QUIET_MODE" = false ]; then
    print_status "Found ${#found_dirs[@]} .obsidian directory(ies):"

    # Display found directories
    for i in "${!found_dirs[@]}"; do
        echo "  $((i + 1)). ${found_dirs[$i]}"
    done
fi

# If only one directory found, install automatically
if [ ${#found_dirs[@]} -eq 1 ]; then
    if [ "$QUIET_MODE" = false ]; then
        print_status "Automatically installing to the only found directory..."
    fi
    install_to_directory "${found_dirs[0]}"
else
    # Multiple directories found
    if [ "$FORCE_INSTALL" = true ]; then
        # Install to all directories if force mode is enabled
        if [ "$QUIET_MODE" = false ]; then
            print_status "Force mode enabled: installing to all directories..."
        fi
        for dir in "${found_dirs[@]}"; do
            install_to_directory "$dir"
        done
    else
        # Ask user which one(s)
        if [ "$QUIET_MODE" = false ]; then
            echo
            print_status "Multiple .obsidian directories found. Which one(s) would you like to install to?"
            print_status "Enter numbers separated by spaces (e.g., '1 3') or 'all' for all directories:"
            read -r selection

            if [ "$selection" = "all" ]; then
                for dir in "${found_dirs[@]}"; do
                    install_to_directory "$dir"
                done
            else
                # Parse user selection
                for num in $selection; do
                    if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#found_dirs[@]} ]; then
                        local index=$((num - 1))
                        install_to_directory "${found_dirs[$index]}"
                    else
                        print_error "Invalid selection: $num"
                    fi
                done
            fi
        fi
    fi
fi

if [ "$QUIET_MODE" = false ]; then
    print_success "Installation complete!"
    if [ "$SKIP_BACKUP" = false ]; then
        print_status "Note: Backups were created for existing .obsidian directories"
    fi
fi
