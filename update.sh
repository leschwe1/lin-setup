
#!/usr/bin/env bash
set -Eeuo pipefail

# Always run relative to this repository
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

# Verify this is a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: this directory is not a Git repository."
    exit 1
fi

echo "Backing up workstation configuration..."

# Back up Zsh configuration
cp "$HOME/.zshrc" ./.zshrc

# Back up Starship configuration
cp "$HOME/.config/starship.toml" ./config/starship.toml

# Back up Konsole profile
cp "$HOME/.local/share/konsole/ls-std.profile" \
    ./config/console/ls-std.profile

# Back up Oh My Zsh custom files, excluding nested Git repositories
rsync -a --delete \
    --exclude='.git/' \
    "$HOME/.oh-my-zsh/custom/" \
    ./oh-my-zsh/

echo "Configuration backup complete."

# Stage only the intended configuration and snippet files
git add -- \
    .zshrc \
    config/ \
    oh-my-zsh/ \
    masscode-vault/

# Check whether there are changes to commit
if git diff --cached --quiet; then
    echo "No changes to commit."
    exit 0
fi

# Commit changes
git commit -m "Update configuration: $(date '+%Y-%m-%d %H:%M')"

# Push current branch
BRANCH="$(git branch --show-current)"
git push origin "$BRANCH"

echo "Configuration successfully backed up to GitHub!"
