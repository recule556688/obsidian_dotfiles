#!/usr/bin/env python3
"""
Obsidian Note Linker
Links daily notes together in chronological order using Obsidian's [[]] syntax
"""

import os
import re
from pathlib import Path
from datetime import datetime, timedelta
from collections import defaultdict


def parse_date_from_filename(filename):
    """
    Parse date from filename in format M-D-YYYY.md
    Returns datetime object or None if parsing fails
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
            return datetime(year, month, day)
        except ValueError:
            return None

    return None


def get_next_note_link(current_date, all_dates):
    """
    Find the next chronological note date
    """
    # Sort all dates
    sorted_dates = sorted(all_dates.keys())

    # Find current date in sorted list
    try:
        current_index = sorted_dates.index(current_date)
        if current_index < len(sorted_dates) - 1:
            next_date = sorted_dates[current_index + 1]
            return all_dates[next_date]
    except ValueError:
        pass

    return None


def add_next_note_link(file_path, next_note_filename):
    """
    Add a link to the next note at the end of the file
    """
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Check if link already exists
        if f"[[{next_note_filename}]]" in content:
            return False

        # Add link at the end of the file
        next_note_name = next_note_filename.replace(".md", "")
        link_text = f"\n\n---\n**Next:** [[{next_note_name}]]"

        with open(file_path, "a", encoding="utf-8") as f:
            f.write(link_text)

        return True
    except Exception as e:
        print(f"Error adding link to {file_path}: {e}")
        return False


def link_notes_in_directory(directory_path):
    """
    Link all notes in a directory to their next chronological note
    """
    dir_path = Path(directory_path)

    if not dir_path.exists():
        print(f"Error: Directory '{directory_path}' does not exist")
        return

    # Get all .md files and parse their dates
    md_files = list(dir_path.glob("*.md"))
    date_to_files = defaultdict(list)

    for file_path in md_files:
        date_obj = parse_date_from_filename(file_path.name)
        if date_obj:
            date_to_files[date_obj].append(file_path)

    if not date_to_files:
        print("No valid date files found")
        return

    print(f"Found {len(date_to_files)} unique dates with {len(md_files)} total files")

    # Process each file
    linked_count = 0
    skipped_count = 0

    for current_date, files in date_to_files.items():
        for file_path in files:
            next_note_filename = get_next_note_link(current_date, date_to_files)

            if next_note_filename:
                if add_next_note_link(file_path, next_note_filename.name):
                    print(f"Linked '{file_path.name}' → '{next_note_filename.name}'")
                    linked_count += 1
                else:
                    print(f"Skipped '{file_path.name}' (link already exists)")
                    skipped_count += 1
            else:
                print(f"No next note for '{file_path.name}' (last chronological note)")
                skipped_count += 1

    print(f"\nSummary: {linked_count} links added, {skipped_count} files skipped")


def link_all_vault_notes(vault_path):
    """
    Link notes across all month/year folders in the vault
    """
    vault_path = Path(vault_path)

    if not vault_path.exists():
        print(f"Error: Vault directory '{vault_path}' does not exist")
        return

    # Collect all files with dates from all subdirectories
    all_date_files = {}

    # Search in all subdirectories
    for file_path in vault_path.rglob("*.md"):
        date_obj = parse_date_from_filename(file_path.name)
        if date_obj:
            all_date_files[date_obj] = file_path

    if not all_date_files:
        print("No valid date files found in vault")
        return

    print(f"Found {len(all_date_files)} total files across all directories")

    # Process each file
    linked_count = 0
    skipped_count = 0

    for current_date, file_path in all_date_files.items():
        next_note_filename = get_next_note_link(current_date, all_date_files)

        if next_note_filename:
            if add_next_note_link(file_path, next_note_filename.name):
                print(f"Linked '{file_path.name}' → '{next_note_filename.name}'")
                linked_count += 1
            else:
                print(f"Skipped '{file_path.name}' (link already exists)")
                skipped_count += 1
        else:
            print(f"No next note for '{file_path.name}' (last chronological note)")
            skipped_count += 1

    print(f"\nSummary: {linked_count} links added, {skipped_count} files skipped")


def main():
    """
    Main function
    """
    print("Obsidian Note Linker")
    print("===================")

    vault_directory = "rotten_PC_vault"

    if not os.path.exists(vault_directory):
        print(f"Error: Directory '{vault_directory}' not found")
        return

    print(f"Linking notes in: {vault_directory}")
    print("\nOptions:")
    print("1. Link notes within each month folder only")
    print("2. Link notes across all folders (recommended)")

    choice = input("\nChoose option (1 or 2): ").strip()

    if choice == "1":
        # Link within each folder
        for folder in sorted(Path(vault_directory).iterdir()):
            if folder.is_dir() and re.match(r"^\d{4}-\d{2}$", folder.name):
                print(f"\nProcessing folder: {folder.name}")
                link_notes_in_directory(folder)
    elif choice == "2":
        # Link across all folders
        link_all_vault_notes(vault_directory)
    else:
        print("Invalid choice")
        return

    print("\nLinking complete!")


if __name__ == "__main__":
    main()
