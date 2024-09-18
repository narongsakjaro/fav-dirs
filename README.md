# Favorite Directories PowerShell Script

## Overview

This PowerShell script allows you to manage a list of favorite directories. You can add, update, delete, and list directories, as well as navigate to them. It also includes a `prune` function to remove entries for directories that no longer exist.

## Features

- **List**: Display all favorite directories.
- **Add**: Add a new favorite directory.
- **Update**: Update the path of an existing favorite directory.
- **Delete**: Delete a favorite directory.
- **Change Directory (cd)**: Change to the directory of a favorite directory.
- **Rename**: Rename a favorite directory.
- **Prune**: Remove entries with non-existent directories.
- **Help**: Show usage instructions.

## Requirements

- PowerShell 5.1 or later.
- The script assumes unique directory names.

## Installation

1. **Download the Script**:
   - Save the script as `fav_dirs.ps1` to your preferred directory.

2. **Set Execution Policy**:
   - Ensure your PowerShell execution policy allows running scripts. You can set it using:
     ```powershell
     Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
     ```

## Usage

To use the script, navigate to the directory where the script is saved and run it with the desired command and arguments.

### Commands

#### List

```powershell
.\fav_dirs.ps1 list
