#!/usr/bin/env bash

# =============================================================================
# Setup Script - Dotfiles/Config Management
# =============================================================================
# This script copies specified files and folders to this repo, backs up the
# originals, and creates symlinks from original locations to the repo.
#
# Usage: ./scripts/setup.sh
# =============================================================================

set -euo pipefail

# =============================================================================
# CONFIGURATION - Define files and folders to manage
# =============================================================================

# Files to manage (use ~/ for home directory references)
# Add the specific files you want to manage here
FILES=(
    # Examples (uncomment and modify as needed):
    # "~/.bashrc"
    # "~/.bash_profile" 
    # "~/.zshrc"
    # "~/.vimrc"
    # "~/.gitconfig"
    # "~/.tmux.conf"
)

# Folders to manage (use ~/ for home directory references)  
# Add the specific folders you want to manage here
FOLDERS=(
    # Examples (uncomment and modify as needed):
    # "~/.config/nvim"
    # "~/.config/git"
    # "~/.vim"
    # "~/.ssh"
)

# Custom path mappings - override default home/ mapping
# Add entries in the format: "source_path:destination_path_in_repo"
# Example: "~/.pi/agent/skills:skills"
CUSTOM_MAPPINGS=(
    # Add custom mappings here:
    # "~/.pi/agent/skills:skills"
    # "~/.config/special:config/special"
)

# =============================================================================
# GLOBALS
# =============================================================================

# Get absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +%Y%m%d)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Expand ~/ to actual home directory
expand_path() {
    local path="$1"
    echo "${path/#\~/$HOME}"
}

# Check if path exists
path_exists() {
    local path="$1"
    [[ -e "$path" ]]
}

# Check if path is a symlink
is_symlink() {
    local path="$1"
    [[ -L "$path" ]]
}

# Get relative path from repo root
get_repo_relative_path() {
    local original_path="$1"
    local expanded_path
    expanded_path=$(expand_path "$original_path")
    
    # Check for custom mappings first
    local mapping
    for mapping in "${CUSTOM_MAPPINGS[@]}"; do
        local source_path="${mapping%:*}"
        local dest_path="${mapping#*:}"
        if [[ "$original_path" == "$source_path" ]]; then
            echo "$dest_path"
            return
        fi
    done
    
    # Default: Convert home path to relative path in repo
    # ~/.bashrc -> home/.bashrc
    # ~/.config/nvim -> home/.config/nvim
    echo "home${expanded_path#$HOME}"
}

# Copy item to repo location
copy_to_repo() {
    local source_path="$1"
    local repo_relative_path="$2"
    local repo_dest_path="$REPO_DIR/$repo_relative_path"
    local repo_dest_dir
    repo_dest_dir=$(dirname "$repo_dest_path")
    
    # Create destination directory if it doesn't exist
    if [[ ! -d "$repo_dest_dir" ]]; then
        log_info "Creating directory: $repo_dest_dir"
        mkdir -p "$repo_dest_dir"
    fi
    
    if [[ -f "$source_path" ]]; then
        # Copy file
        log_info "Copying file: $source_path -> $repo_dest_path"
        cp "$source_path" "$repo_dest_path"
    elif [[ -d "$source_path" ]]; then
        # Copy directory
        log_info "Copying directory: $source_path -> $repo_dest_path"
        cp -r "$source_path" "$repo_dest_path"
    else
        log_error "Source path is neither file nor directory: $source_path"
        return 1
    fi
}

# Verify copy is not a symlink
verify_copy() {
    local repo_dest_path="$1"
    
    if is_symlink "$repo_dest_path"; then
        log_error "Copy verification failed: $repo_dest_path is a symlink"
        return 1
    fi
    
    if [[ -d "$repo_dest_path" ]]; then
        # For directories, check that no contents are symlinks
        local symlink_count
        symlink_count=$(find "$repo_dest_path" -type l | wc -l)
        if [[ $symlink_count -gt 0 ]]; then
            log_warning "Found $symlink_count symlinks within copied directory: $repo_dest_path"
            find "$repo_dest_path" -type l -exec ls -la {} \;
        fi
    fi
    
    log_success "Copy verified as real copy: $repo_dest_path"
    return 0
}

# Backup original by renaming with timestamp
backup_original() {
    local original_path="$1"
    local backup_path="${original_path}.bkup.${TIMESTAMP}"
    
    if path_exists "$backup_path"; then
        log_warning "Backup already exists: $backup_path"
        return 0
    fi
    
    log_info "Backing up original: $original_path -> $backup_path"
    mv "$original_path" "$backup_path"
    log_success "Original backed up to: $backup_path"
}

# Create symlink from original location to repo location
create_symlink() {
    local original_path="$1"
    local repo_dest_path="$2"
    
    log_info "Creating symlink: $original_path -> $repo_dest_path"
    ln -s "$repo_dest_path" "$original_path"
    log_success "Symlink created: $original_path -> $repo_dest_path"
}

# Process a single item (file or folder)
process_item() {
    local original_path="$1"
    local expanded_path
    local repo_relative_path
    local repo_dest_path
    
    # Expand ~/ to actual home directory
    expanded_path=$(expand_path "$original_path")
    
    # Check if original exists
    if ! path_exists "$expanded_path"; then
        log_warning "Skipping non-existent path: $expanded_path"
        return 0
    fi
    
    # Check if original is already a symlink
    if is_symlink "$expanded_path"; then
        log_warning "Skipping symlink: $expanded_path (already managed?)"
        return 0
    fi
    
    # Get repo destination path
    repo_relative_path=$(get_repo_relative_path "$original_path")
    repo_dest_path="$REPO_DIR/$repo_relative_path"
    
    # Check if already exists in repo
    if path_exists "$repo_dest_path"; then
        log_warning "Already exists in repo: $repo_dest_path"
        log_info "You may want to manually compare and resolve differences"
        return 0
    fi
    
    echo ""
    log_info "Processing: $expanded_path"
    log_info "Destination: $repo_dest_path"
    
    # Step 1: Copy to repo
    if ! copy_to_repo "$expanded_path" "$repo_relative_path"; then
        log_error "Failed to copy: $expanded_path"
        return 1
    fi
    
    # Step 2: Verify copy
    if ! verify_copy "$repo_dest_path"; then
        log_error "Copy verification failed for: $repo_dest_path"
        return 1
    fi
    
    # Step 3: Backup original
    if ! backup_original "$expanded_path"; then
        log_error "Failed to backup: $expanded_path"
        return 1
    fi
    
    # Step 4: Create symlink
    if ! create_symlink "$expanded_path" "$repo_dest_path"; then
        log_error "Failed to create symlink: $expanded_path"
        return 1
    fi
    
    log_success "Successfully processed: $original_path"
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    echo "=========================================="
    echo "Pi-Tools Setup Script"
    echo "=========================================="
    echo "Repo directory: $REPO_DIR"
    echo "Timestamp: $TIMESTAMP"
    echo ""
    
    local total_items=0
    local processed_items=0
    local skipped_items=0
    local failed_items=0
    
    # Count total items
    total_items=$((${#FILES[@]} + ${#FOLDERS[@]}))
    
    if [[ $total_items -eq 0 ]]; then
        log_warning "No files or folders configured to process"
        echo ""
        echo "To use this script:"
        echo "1. Edit $0"
        echo "2. Add files to the FILES=() array"
        echo "3. Add folders to the FOLDERS=() array"
        echo "4. Run the script again"
        echo ""
        echo "Example:"
        echo '  FILES=("~/.zshrc" "~/.gitconfig")'
        echo '  FOLDERS=("~/.config/nvim" "~/.ssh")'
        exit 0
    fi
    
    log_info "Processing $total_items items..."
    echo ""
    
    # Process all files
    for file in "${FILES[@]}"; do
        if process_item "$file"; then
            ((processed_items++))
        else
            ((failed_items++))
        fi
    done
    
    # Process all folders  
    for folder in "${FOLDERS[@]}"; do
        if process_item "$folder"; then
            ((processed_items++))
        else
            ((failed_items++))
        fi
    done
    
    echo ""
    echo "=========================================="
    echo "Setup Complete!"
    echo "=========================================="
    echo "Total items: $total_items"
    echo "Processed: $processed_items"
    echo "Skipped: $((total_items - processed_items - failed_items))"
    echo "Failed: $failed_items"
    echo ""
    
    if [[ $failed_items -gt 0 ]]; then
        log_error "Some items failed to process. Check the output above."
        exit 1
    else
        log_success "All items processed successfully!"
        echo ""
        echo "Your original files have been:"
        echo "1. Copied to this repo under home/"
        echo "2. Backed up with .bkup.$TIMESTAMP suffix"
        echo "3. Replaced with symlinks to the repo versions"
        echo ""
        echo "You can now commit these files to version control!"
        echo "Don't forget to create/update .gitignore for sensitive files."
    fi
}

# =============================================================================
# SCRIPT ENTRY POINT
# =============================================================================

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi