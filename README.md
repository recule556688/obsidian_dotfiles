# Obsidian Dotfiles Installer

A powerful and user-friendly tool to automatically install and sync your Obsidian configuration across multiple vaults. This project provides both Bash and PowerShell scripts for cross-platform compatibility.

## 🚀 Features

- **🔍 System-Wide Discovery**: Automatically finds `.obsidian` directories across your entire system
- **🛡️ Safety First**: Creates automatic backups before overwriting existing configurations
- **🎯 Smart Installation**: Handles single or multiple vaults intelligently
- **🎨 Beautiful Output**: Colored, informative status messages
- **⚡ Cross-Platform**: Works on Windows, macOS, and Linux
- **🔧 Flexible Options**: Multiple command-line options for different use cases
- **📦 Zero Dependencies**: No external dependencies required
- **🌐 Flexible Source**: Works from any directory with a `.obsidian` folder

## 📋 Prerequisites

- **Bash** (for Linux/macOS) or **PowerShell** (for Windows)
- **Obsidian**: At least one Obsidian vault with a `.obsidian` directory
- **Source Directory**: A `.obsidian` directory in the current folder to serve as the source

## 🛠️ Installation

1. **Clone or download** this repository to your local machine
2. **Navigate** to the repository directory
3. **Make the bash script executable** (Linux/macOS only):
   ```bash
   chmod +x install_obsidian.sh
   ```

## 📖 Usage

### Basic Usage

**Bash (Linux/macOS/Git Bash):**

```bash
# Search entire system and install
./install_obsidian.sh

# Search only current directory
./install_obsidian.sh -l

# Install to specific path
./install_obsidian.sh /path/to/vault/.obsidian
```

**PowerShell (Windows):**

```powershell
# Search entire system and install
.\install_obsidian.ps1

# Search only current directory
.\install_obsidian.ps1 -Local

# Install to specific path
.\install_obsidian.ps1 -TargetPath "C:\path\to\vault\.obsidian"
```

### Advanced Options

Both scripts support the following options:

| Option    | Bash              | PowerShell      | Description                    |
| --------- | ----------------- | --------------- | ------------------------------ |
| Help      | `-h, --help`      | `-Help, -h`     | Show help menu                 |
| Version   | `-v, --version`   | `-Version, -v`  | Show version info              |
| Force     | `-f, --force`     | `-Force, -f`    | Install without confirmation   |
| No Backup | `-b, --no-backup` | `-NoBackup, -b` | Skip creating backups          |
| Quiet     | `-q, --quiet`     | `-Quiet, -q`    | Suppress non-error output      |
| Local     | `-l, --local`     | `-Local, -l`    | Search only current directory  |
| System    | `-s, --system`    | `-System, -s`   | Search entire system (default) |

### Examples

**Show help:**

```bash
./install_obsidian.sh --help
.\install_obsidian.ps1 -Help
```

**Search entire system and force install to all found directories:**

```bash
./install_obsidian.sh --force
.\install_obsidian.ps1 -Force
```

**Search only current directory:**

```bash
./install_obsidian.sh --local
.\install_obsidian.ps1 -Local
```

**Install without creating backups:**

```bash
./install_obsidian.sh --no-backup
.\install_obsidian.ps1 -NoBackup
```

**Quiet mode (suppress output):**

```bash
./install_obsidian.sh --quiet
.\install_obsidian.ps1 -Quiet
```

## 🔧 How It Works

1. **Source Validation**: Verifies you have a `.obsidian` directory in the current folder
2. **System Discovery**: Searches for `.obsidian` directories across your entire system (or locally if specified)
3. **Smart Filtering**: Excludes system directories and limits results for performance
4. **Backup Creation**: Creates timestamped backups of existing configurations
5. **Installation**: Copies your dotfiles from the source to target directories
6. **Verification**: Provides status updates and success confirmations

## 📁 File Structure

```
GayKarma/
├── .obsidian/                 # Your Obsidian configuration (source)
│   ├── plugins/               # Plugin configurations
│   ├── themes/                # Theme files
│   ├── snippets/              # CSS snippets
│   └── ...                    # Other Obsidian config files
├── install_obsidian.sh        # Bash installer script
├── install_obsidian.ps1       # PowerShell installer script
├── .gitignore                 # Git ignore rules
└── README.md                  # This file
```

## 🛡️ Safety Features

- **Automatic Backups**: Creates backups with timestamps before overwriting
- **Validation**: Checks for required directories and permissions
- **Error Handling**: Graceful error handling with informative messages
- **Smart Filtering**: Excludes system directories to prevent conflicts
- **Result Limiting**: Prevents overwhelming output with too many results

## 🔍 Troubleshooting

### Common Issues

**"Source directory '.obsidian' not found in current directory"**

- Ensure you have a `.obsidian` directory in the current folder
- The script needs this as the source for installation

**"No .obsidian directories found"**

- Check that your Obsidian vaults have `.obsidian` directories
- Try using the `-Local` option to search only the current directory
- Try specifying a target path manually

**Permission denied errors**

- Make sure the script is executable: `chmod +x install_obsidian.sh`
- Check file permissions on target directories
- On Windows, run PowerShell as Administrator if needed

**System search is slow**

- Use the `-Local` option to search only the current directory
- The system-wide search may take time depending on your system size

### Getting Help

1. **Show help menu**: `./install_obsidian.sh --help`
2. **Check version**: `./install_obsidian.sh --version`
3. **Review logs**: Check the colored output for error messages

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

### Development

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Obsidian Team** for creating an amazing note-taking app
- **Open Source Community** for inspiration and best practices
- **GitHub** for providing excellent tools and hosting

## 📞 Support

If you encounter any issues or have questions:

1. Check the [troubleshooting section](#troubleshooting)
2. Review the help menu: `./install_obsidian.sh --help`
3. Open an issue on GitHub
4. Check existing issues for similar problems

---

**Made with ❤️ for the Obsidian community**
