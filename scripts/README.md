# Pi-Tools Setup Scripts

## setup.sh

A dotfiles/configuration management script that helps you manage your configuration files in this repository.

### How It Works

1. **Copies** specified files and folders from your system to this repository
2. **Verifies** all copies are real files/folders (not symlinks)
3. **Backs up** the originals by renaming them with a timestamp (`.bkup.YYYYMMDD`)
4. **Creates symlinks** from the original locations to the repository versions

### Configuration

Before running the script, you need to edit `setup.sh` and specify which files and folders you want to manage:

```bash
# Edit the arrays at the top of setup.sh:

FILES=(
    "~/.zshrc"        # Your shell configuration
    "~/.gitconfig"    # Git configuration  
    "~/.tmux.conf"    # Tmux configuration
    "~/.vimrc"        # Vim configuration
)

FOLDERS=(
    "~/.config/nvim"  # Neovim configuration
    "~/.config/git"   # Git configuration directory
    "~/.vim"          # Vim plugins and configuration
    "~/.ssh"          # SSH keys and configuration (be careful!)
)
```

### Usage

1. **Edit the script** to specify your files and folders:
   ```bash
   vim scripts/setup.sh
   # or
   nano scripts/setup.sh
   ```

2. **Run the script** from the repository root:
   ```bash
   ./scripts/setup.sh
   ```

3. **Review the output** to make sure everything worked correctly

4. **Create a .gitignore** to exclude sensitive files:
   ```bash
   echo "# Sensitive files" > .gitignore
   echo "home/.ssh/id_*" >> .gitignore
   echo "home/.ssh/*.pub" >> .gitignore
   echo "home/.gitconfig" >> .gitignore
   ```

5. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Add managed dotfiles"
   git push
   ```

### What Happens

For each configured file/folder, the script will:

1. Check if it exists on your system
2. Copy it to `pi-tools/home/[relative-path]`
3. Verify the copy is a real file (not a symlink)
4. Rename the original to `[original].bkup.YYYYMMDD`
5. Create a symlink from the original location to the repository

### Example

If you configure `"~/.zshrc"`, the script will:

- Copy `~/.zshrc` → `pi-tools/home/.zshrc`
- Rename `~/.zshrc` → `~/.zshrc.bkup.20241206`
- Create symlink: `~/.zshrc` → `/full/path/to/pi-tools/home/.zshrc`

### Safety Features

- **Non-destructive**: Always backs up originals before making changes
- **Verification**: Ensures copies are real files, not symlinks
- **Skip existing**: Won't overwrite existing files in the repo
- **Skip symlinks**: Won't process files that are already symlinks
- **Absolute paths**: Uses absolute paths for symlinks (no broken links)

### Tips

- Start with a few important files to test the process
- Be careful with sensitive directories like `~/.ssh`
- Create a good `.gitignore` before committing
- Test on a backup system first if you're nervous
- Remember: you can always restore from the `.bkup.YYYYMMDD` files

### Undoing Changes

If you need to undo the script's changes:

1. Remove the symlinks
2. Restore from the backup files
3. Clean up the repository

```bash
# Example for .zshrc:
rm ~/.zshrc
mv ~/.zshrc.bkup.20241206 ~/.zshrc
```