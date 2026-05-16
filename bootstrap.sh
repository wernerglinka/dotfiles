#!/usr/bin/env bash
# bootstrap.sh — take a fresh macOS install to a working dev environment.
# Idempotent: safe to re-run. Does not touch ~/.claude or working trees.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()  { printf '\033[1;36m[bootstrap]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; exit 1; }

require_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || die "macOS only."
  [[ "$(uname -m)" == "arm64"  ]] || warn "Not Apple Silicon — Homebrew path may differ."
}

ensure_xcode_clt() {
  if ! xcode-select -p >/dev/null 2>&1; then
    log "Installing Xcode command line tools. Accept the GUI prompt, then re-run this script."
    xcode-select --install || true
    exit 0
  fi
}

ensure_homebrew() {
  if ! command -v brew >/dev/null 2>&1 && [[ ! -x /opt/homebrew/bin/brew ]]; then
    log "Installing Homebrew. You will be prompted to press RETURN and then for your sudo password."
    /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # shellcheck disable=SC1091
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

run_brewfile() {
  log "Running brew bundle."
  brew bundle --file="$REPO/Brewfile"
}

# link SRC DEST — make DEST a symlink to SRC, backing up any prior real file.
link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -L "$dest" ]]; then
    if [[ "$(readlink "$dest")" == "$src" ]]; then
      return 0
    fi
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    local backup
    backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
    warn "Backing up existing $dest to $backup"
    mv "$dest" "$backup"
  fi
  ln -s "$src" "$dest"
  log "Linked $dest -> $src"
}

link_dotfiles() {
  link "$REPO/zsh/.zshenv"            "$HOME/.zshenv"
  link "$REPO/zsh/.zshrc"             "$HOME/.zshrc"
  link "$REPO/git/.gitconfig"         "$HOME/.gitconfig"
  link "$REPO/git/.gitconfig-dev"     "$HOME/.gitconfig-dev"
  link "$REPO/git/.gitignore_global"  "$HOME/.gitignore_global"
  link "$REPO/git/allowed_signers"    "$HOME/.config/git/allowed_signers"
  link "$REPO/npm/.npmrc"             "$HOME/.npmrc"
}

ensure_ssh_config() {
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  if [[ ! -f "$HOME/.ssh/config" ]]; then
    cp "$REPO/ssh/config.template" "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
    log "Wrote ~/.ssh/config from template."
  else
    log "~/.ssh/config already present — left untouched."
  fi
}

ensure_volta_toolchain() {
  if ! command -v volta >/dev/null 2>&1; then
    warn "Volta not on PATH yet. Open a new shell after bootstrap, then run: volta install node@lts npm"
    return 0
  fi
  if ! volta list node 2>/dev/null | grep -q '^node@'; then
    log "Installing Node LTS and npm via Volta."
    volta install node@lts npm
  fi
}

install_vscode_extensions() {
  local list="$REPO/vscode/extensions.txt"
  [[ -f "$list" ]] || return 0
  if ! command -v code >/dev/null 2>&1; then
    warn "VS Code 'code' command not on PATH. Skipping extensions. After"
    warn "launching VS Code, run Cmd-Shift-P 'Shell Command: Install code"
    warn "command in PATH', then re-run this script."
    return 0
  fi
  log "Installing VS Code extensions from $list."
  while IFS= read -r ext; do
    case "$ext" in
      ''|'#'*) continue ;;
    esac
    if code --install-extension "$ext" --force >/dev/null 2>&1; then
      printf '  %s\n' "$ext"
    else
      warn "  failed: $ext"
    fi
  done < "$list"
}

post_checklist() {
  cat <<'EOF'

Bootstrap complete. Remaining manual steps:

  1. Generate the ed25519 key:
       ssh-keygen -t ed25519 -C "346112+wernerglinka@users.noreply.github.com"
     Accept the default path (~/.ssh/id_ed25519). Set a passphrase.

  2. Upload the public key to GitHub TWICE at
     https://github.com/settings/keys :
       - once as an Authentication key
       - once as a Signing key
     Public key file: ~/.ssh/id_ed25519.pub

  3. Populate the allowed_signers file so local commit verification works.
     Email is hardcoded here because the base ~/.gitconfig is identity-free
     by design; `git config --get user.email` only resolves inside the dev
     trees:
       printf '%s %s\n' \
         "346112+wernerglinka@users.noreply.github.com" \
         "$(cat ~/.ssh/id_ed25519.pub)" \
         >> ~/.config/git/allowed_signers

  4. Switch existing repo remotes from HTTPS to SSH where appropriate, e.g.:
       cd ~/Documents/Essays/knowledge-base
       git remote set-url origin git@github.com:wernerglinka/knowledge-base.git

  5. For each publishable npm package: enable trusted publishing on
     npmjs.com, add the OIDC-based release workflow to the repo, and
     revoke the old classic token after the first OIDC publish succeeds.

EOF
}

main() {
  require_macos
  ensure_xcode_clt
  ensure_homebrew
  run_brewfile
  link_dotfiles
  ensure_ssh_config
  ensure_volta_toolchain
  install_vscode_extensions
  post_checklist
}

main "$@"
