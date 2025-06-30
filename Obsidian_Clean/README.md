# Obsidian File Organizer

This repository contains scripts to organize Obsidian markdown files by month and year. The scripts will automatically sort your daily note files into folders based on their date.

## Files

- `organize_files.py` - Python script for organizing files
- `organize_files.sh` - Bash shell script for organizing files
- `README.md` - This documentation file

## How it works

The scripts look for markdown files with the naming pattern `M-D-YYYY.md` (month-day-year) and organize them into folders named `YYYY-MM` (year-month).

### Example

**Before:**

```txt
rotten_PC_vault/
├── 5-2-2025.md
├── 5-3-2025.md
├── 5-5-2025.md
├── 6-10-2025.md
├── 6-11-2025.md
└── 6-13-2007.md
```

**After:**

```txt
rotten_PC_vault/
├── 2007-06/
│   └── 6-13-2007.md
├── 2025-05/
│   ├── 5-2-2025.md
│   ├── 5-3-2025.md
│   └── 5-5-2025.md
└── 2025-06/
    ├── 6-10-2025.md
    └── 6-11-2025.md
```

## Features

- ✅ Automatically creates year-month folders
- ✅ Handles duplicate files (adds numbering like `filename(1).md`)
- ✅ Validates dates to ensure they're real dates
- ✅ Provides detailed progress and summary information
- ✅ Safe operation with confirmation prompt
- ✅ Error handling and reporting

## Usage

### Python Script

1. Make sure you have Python 3 installed
2. Run the script from the directory containing your `rotten_PC_vault` folder:

```bash
python organize_files.py
```

### Shell Script

1. Make sure you're on a Unix-like system (Linux, macOS, Git Bash on Windows)
2. Run the script from the directory containing your `rotten_PC_vault` folder:

```bash
./organize_files.sh
```

## Requirements

### With Python

- Python 3.6 or higher
- No additional dependencies (uses only standard library)

### With Shell

- Bash shell
- Unix-like environment (Linux, macOS, Git Bash on Windows)
- `date` command for date validation

## Safety Features

- **Confirmation prompt**: Both scripts ask for confirmation before proceeding
- **Date validation**: Only processes files with valid dates
- **Error handling**: Continues processing even if individual files fail
- **Duplicate handling**: Automatically handles files with the same name
- **Detailed logging**: Shows exactly what's happening during the process

## Output

Both scripts provide:

- Progress information for each file moved
- Summary statistics (files organized, skipped, errors)
- List of created folders with file counts
- Color-coded output (shell script only)

## Troubleshooting

### Common Issues

1. **"Directory not found"**: Make sure you're running the script from the correct directory
2. **"No markdown files found"**: Check that your files have `.md` extensions
3. **"Could not parse date"**: Ensure your files follow the `M-D-YYYY.md` pattern

### File Naming Requirements

Files must follow this exact pattern:

- Format: `M-D-YYYY.md`
- Examples: `5-2-2025.md`, `12-25-2024.md`
- The script handles duplicates like `6-29-2025(1).md`

## License

This project is open source and available under the MIT License.
