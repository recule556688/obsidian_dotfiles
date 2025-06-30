#!/bin/bash

# Obsidian File Organizer - Shell Script Version
# Organizes markdown files by month and year into separate folders

set -e # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to validate date
validate_date() {
    local month=$1
    local day=$2
    local year=$3

    # Check if date is valid using date command
    if date -d "$year-$month-$day" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to parse date from filename
parse_date() {
    local filename=$1

    # Remove .md extension
    local name_without_ext="${filename%.md}"

    # Remove duplicate suffix like (1), (2), etc.
    name_without_ext=$(echo "$name_without_ext" | sed 's/([0-9]*)$//')

    # Extract date parts using regex
    if [[ $name_without_ext =~ ^([0-9]{1,2})-([0-9]{1,2})-([0-9]{4})$ ]]; then
        local month=${BASH_REMATCH[1]}
        local day=${BASH_REMATCH[2]}
        local year=${BASH_REMATCH[3]}

        # Validate the date
        if validate_date "$month" "$day" "$year"; then
            echo "$month $year"
            return 0
        fi
    fi

    return 1
}

# Function to create folder name
create_folder_name() {
    local month=$1
    local year=$2

    # Pad month with leading zero if needed
    printf "%04d-%02d" "$year" "$month"
}

# Function to organize files
organize_files() {
    local source_dir=$1

    if [[ ! -d "$source_dir" ]]; then
        print_error "Directory '$source_dir' does not exist"
        exit 1
    fi

    # Change to source directory
    cd "$source_dir" || exit 1

    # Count markdown files
    local md_files=($(ls *.md 2>/dev/null || true))
    local file_count=${#md_files[@]}

    if [[ $file_count -eq 0 ]]; then
        print_warning "No markdown files found in the directory"
        return
    fi

    print_info "Found $file_count markdown files"

    # Track statistics
    local organized_count=0
    local skipped_count=0
    local errors=()

    # Process each file
    for file in "${md_files[@]}"; do
        local date_info
        if date_info=$(parse_date "$file"); then
            read -r month year <<<"$date_info"
            local folder_name
            folder_name=$(create_folder_name "$month" "$year")

            # Create target directory
            mkdir -p "$folder_name"

            # Handle duplicate files
            local target_file="$folder_name/$file"
            local counter=1
            local original_target="$target_file"

            while [[ -f "$target_file" ]]; do
                local name_without_ext="${original_target%.md}"
                target_file="${name_without_ext}($counter).md"
                ((counter++))
            done

            # Move file
            if mv "$file" "$target_file"; then
                print_success "Moved '$file' to '$folder_name/'"
                ((organized_count++))
            else
                local error_msg="Error moving '$file'"
                print_error "$error_msg"
                errors+=("$error_msg")
            fi
        else
            print_warning "Skipping '$file' - could not parse date"
            ((skipped_count++))
        fi
    done

    # Print summary
    echo
    echo "=================================================="
    echo "ORGANIZATION SUMMARY"
    echo "=================================================="
    print_info "Files organized: $organized_count"
    print_info "Files skipped: $skipped_count"

    if [[ ${#errors[@]} -gt 0 ]]; then
        print_error "Errors encountered: ${#errors[@]}"
        for error in "${errors[@]}"; do
            echo "  - $error"
        done
    fi

    # List created folders
    local folders=($(ls -d [0-9][0-9][0-9][0-9]-[0-9][0-9] 2>/dev/null || true))
    if [[ ${#folders[@]} -gt 0 ]]; then
        echo
        print_info "Created folders:"
        for folder in "${folders[@]}"; do
            local file_count
            file_count=$(ls "$folder"/*.md 2>/dev/null | wc -l)
            echo "  - $folder/ ($file_count files)"
        done
    fi
}

# Main function
main() {
    echo "Obsidian File Organizer"
    echo "======================"

    local source_directory="rotten_PC_vault"

    if [[ ! -d "$source_directory" ]]; then
        print_error "Directory '$source_directory' not found"
        echo "Please run this script from the directory containing the 'rotten_PC_vault' folder"
        exit 1
    fi

    print_info "Organizing files in: $source_directory"

    # Ask for confirmation
    echo
    read -p "Do you want to proceed? (y/N): " -r response
    if [[ ! $response =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled"
        exit 0
    fi

    organize_files "$source_directory"
    echo
    print_success "Organization complete!"
}

# Run main function
main "$@"
