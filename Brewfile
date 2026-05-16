# Brewfile — single source of truth for installed tools on this Mac.
# Run with: brew bundle --file=~/Documents/Projects/dotfiles/Brewfile

# Taps
# (none — everything below is in homebrew/core or homebrew/cask)

# Core CLI
brew "git"           # newer than Apple's bundled git
brew "gh"            # GitHub CLI: auth, PRs, releases, OIDC config
brew "jq"            # JSON on the command line
brew "ripgrep"       # rg: fast project-wide search
brew "fd"            # friendlier find
brew "tree"          # directory tree printer

# Languages and runtimes
brew "volta"         # Node version manager; per-project pin in package.json
brew "php"           # macOS no longer ships PHP
brew "composer"      # PHP dependency manager

# Applications
cask "visual-studio-code"
cask "iterm2"
cask "obsidian"      # for the Essays/knowledge-base vault
cask "1password"     # sole password manager on this Mac (Chrome and iCloud Keychain are deliberately disabled)
cask "1password-cli" # 'op' command, talks to the 1Password desktop app via biometric unlock

# Explicitly NOT installed on this machine:
#   - Any finance app or CLI. This is the dev machine in a two-machine split.
#   - nvm, fnm, asdf. Node is managed by Volta.
#   - oh-my-zsh, starship, powerlevel10k. Shell stays lean.
