#!/usr/bin/env python3
"""
File organization script for Obsidian vault
Organizes markdown files by month and year into separate folders
"""

import os
import shutil
import re
from pathlib import Path
from datetime import datetime


def fix_markdown_heading(file_path):
    """
    Fix markdown linting error by ensuring file starts with top-level heading
    """
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()

        # If file doesn't start with #, add a title based on filename
        if not content.strip().startswith("#"):
            filename = file_path.stem
            # Convert filename like "5-2-2025" to "May 2, 2025"
            try:
                month, day, year = filename.split("-")
                month_names = [
                    "January",
                    "February",
                    "March",
                    "April",
                    "May",
                    "June",
                    "July",
                    "August",
                    "September",
                    "October",
                    "November",
                    "December",
                ]
                month_name = month_names[int(month) - 1]
                title = f"# {month_name} {day}, {year}\n\n{content}"
            except:
                title = f"# {filename}\n\n{content}"

            with open(file_path, "w", encoding="utf-8") as f:
                f.write(title)
            return True
    except Exception:
        return False


def parse_date_from_filename(filename):
    """
    Parse date from filename in format M-D-YYYY.md
    Returns tuple (month, year) or None if parsing fails
    """
    # Remove .md extension
    name_without_ext = filename.replace(".md", "")

    # Handle duplicate files like "6-29-2025(1).md"
    name_without_ext = re.sub(r"\(\d+\)$", "", name_without_ext)

    # Match pattern M-D-YYYY
    pattern = r"^(\d{1,2})-(\d{1,2})-(\d{4})$"
    match = re.match(pattern, name_without_ext)

    if match:
        month = int(match.group(1))
        day = int(match.group(2))
        year = int(match.group(3))

        # Validate date
        try:
            datetime(year, month, day)
            return month, year
        except ValueError:
            return None

    return None


def create_folder_name(month, year):
    """
    Create folder name in format YYYY-MM
    """
    return f"{year:04d}-{month:02d}"


def organize_files(source_dir):
    """
    Organize markdown files by month and year
    """
    source_path = Path(source_dir)

    if not source_path.exists():
        print(f"Error: Directory '{source_dir}' does not exist")
        return

    # Get all .md files
    md_files = list(source_path.glob("*.md"))

    if not md_files:
        print("No markdown files found in the directory")
        return

    print(f"Found {len(md_files)} markdown files")

    # Track statistics
    organized_count = 0
    skipped_count = 0
    fixed_count = 0
    errors = []

    for file_path in md_files:
        filename = file_path.name
        date_info = parse_date_from_filename(filename)

        if date_info is None:
            print(f"Skipping '{filename}' - could not parse date")
            skipped_count += 1
            continue

        # Fix markdown heading before moving
        if fix_markdown_heading(file_path):
            fixed_count += 1

        month, year = date_info
        folder_name = create_folder_name(month, year)
        target_dir = source_path / folder_name

        # Create target directory if it doesn't exist
        target_dir.mkdir(exist_ok=True)

        # Move file to target directory
        target_file = target_dir / filename

        try:
            # Handle duplicate files by adding a number suffix
            counter = 1
            original_target = target_file
            while target_file.exists():
                name_without_ext = original_target.stem
                suffix = original_target.suffix
                target_file = target_dir / f"{name_without_ext}({counter}){suffix}"
                counter += 1

            shutil.move(str(file_path), str(target_file))
            print(f"Moved '{filename}' to '{folder_name}/'")
            organized_count += 1

        except Exception as e:
            error_msg = f"Error moving '{filename}': {str(e)}"
            print(error_msg)
            errors.append(error_msg)

    # Print summary
    print("\n" + "=" * 50)
    print("ORGANIZATION SUMMARY")
    print("=" * 50)
    print(f"Files organized: {organized_count}")
    print(f"Files skipped: {skipped_count}")
    print(f"Files fixed (markdown headings): {fixed_count}")

    if errors:
        print(f"Errors encountered: {len(errors)}")
        for error in errors:
            print(f"  - {error}")

    # List created folders
    folders = [
        d
        for d in source_path.iterdir()
        if d.is_dir() and re.match(r"^\d{4}-\d{2}$", d.name)
    ]
    if folders:
        print(f"\nCreated folders:")
        for folder in sorted(folders):
            file_count = len(list(folder.glob("*.md")))
            print(f"  - {folder.name}/ ({file_count} files)")


def main():
    """
    Main function
    """
    print("Obsidian File Organizer")
    print("=" * 30)

    # Default to current directory if no argument provided
    source_directory = "rotten_PC_vault"

    if not os.path.exists(source_directory):
        print(f"Error: Directory '{source_directory}' not found")
        print(
            "Please run this script from the directory containing the 'rotten_PC_vault' folder"
        )
        return

    print(f"Organizing files in: {source_directory}")

    # Ask for confirmation
    response = input("\nDo you want to proceed? (y/N): ").strip().lower()
    if response not in ["y", "yes"]:
        print("Operation cancelled")
        return

    organize_files(source_directory)
    print("\nOrganization complete!")


if __name__ == "__main__":
    main()
