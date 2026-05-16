# dotfiles

Reproducible setup for the dev Mac. The goal is that any future machine
becomes a clone of this repo, not an archaeology dig over years of
inherited cruft. Clone, run `bootstrap.sh`, follow the printed checklist,
done.

This is the dev half of a two-machine separation. Finance work happens on
a different machine. Nothing finance-related is installed here and
nothing finance-related should be added to the Brewfile.

## Quick start

```sh
cd ~/Documents/Projects
git clone git@github.com:wernerglinka/dotfiles.git
./dotfiles/bootstrap.sh
```

The script is idempotent. Re-running it after editing the Brewfile or any
config file applies the changes. Existing real files in `$HOME` are
backed up to `*.bak.<timestamp>` before being replaced with symlinks, so
nothing is silently overwritten.

`bootstrap.sh` must be run interactively in a real terminal. The
Homebrew install asks you to press RETURN once and then prompts for
your sudo password. Cask installs may also pop up macOS Gatekeeper
prompts the first time. Running the script through a non-interactive
channel (CI, a tool that cannot forward a password prompt) will fail
at the Homebrew install step.

## What it does

Bootstrap, in order:

1. Verifies macOS and warns if not Apple Silicon.
2. Installs Xcode command line tools if missing (and exits so you can
   accept the GUI prompt before re-running).
3. Installs Homebrew at `/opt/homebrew` if missing.
4. Runs `brew bundle` against the `Brewfile`.
5. Symlinks the dotfiles into `$HOME` (and `~/.config/git/`).
6. Writes `~/.ssh/config` from `ssh/config.template` only if no SSH
   config exists yet. Existing configs are never touched.
7. Initializes the Node toolchain via Volta if Volta is on `PATH`.
8. Installs the VS Code extensions listed in `vscode/extensions.txt`
   if the `code` CLI is available (skipped with a warning otherwise).
9. Prints the post-bootstrap checklist (SSH key, GitHub upload, remote
   switch, npm trusted-publishing migration).

## Layout

```
dotfiles/
  bootstrap.sh           # entry point
  Brewfile               # single source of truth for installed tools
  SETUP_LOG.md           # running commentary, decisions, date-stamped
  zsh/
    .zshenv              # PATH, Homebrew shellenv, Volta
    .zshrc               # history, completion, vcs_info prompt, aliases
  git/
    .gitconfig           # base config, signing on, conditional includes
    .gitconfig-dev       # dev identity (noreply email, signing key)
    .gitignore_global    # OS + editor + .env*
    allowed_signers      # populated by post-bootstrap step
  npm/
    .npmrc               # registry config; NO auth token
  ssh/
    config.template      # ~/.ssh/config template; private keys never live here
  vscode/
    extensions.txt       # VS Code extension IDs, one per line
```

To refresh the captured extension list after installing new ones:

```sh
code --list-extensions > ~/Documents/Projects/dotfiles/vscode/extensions.txt
cd ~/Documents/Projects/dotfiles && git add vscode/extensions.txt && git commit
```

## Design choices, named explicitly

- Homebrew + checked-in `Brewfile` is the single source of installed
  tools. Adding a tool means editing the Brewfile and committing.
  `brew bundle cleanup` lists anything installed that the Brewfile does
  not declare.
- Node is managed by Volta. Per-project version pinning lives in each
  `package.json`. No `nvm`, `fnm`, or `asdf`.
- PHP and Composer are explicit Brewfile entries because macOS no longer
  ships PHP.
- Git commit signing uses SSH (`gpg.format=ssh`), not GPG. One ed25519
  key serves both authentication and signing.
- The dev identity lives in `~/.gitconfig-dev` and is pulled in by
  `includeIf` only for repos under `~/Documents/Projects/` and
  `~/Documents/Essays/`. The base `~/.gitconfig` is identity-free, so a
  repo cloned outside those trees stays unsigned and unidentified until
  consciously moved.
- npm publishing uses trusted publishing with provenance via GitHub
  Actions. No long-lived publish token lives on this machine. See
  `npm/.npmrc` for the rationale.
- The shell is plain zsh. No oh-my-zsh, no starship, no powerlevel10k.
  Prompt is built from zsh's own `vcs_info`.

## Adding a tool

```sh
# 1. Edit the Brewfile
$EDITOR ~/Documents/Projects/dotfiles/Brewfile

# 2. Apply
brew bundle --file=~/Documents/Projects/dotfiles/Brewfile

# 3. Commit
cd ~/Documents/Projects/dotfiles
git add Brewfile
git commit -m "Add <tool>"
```

## Removing a tool

```sh
# 1. Remove the line from Brewfile and commit
# 2. brew bundle does NOT uninstall by default. To check drift:
brew bundle cleanup --file=~/Documents/Projects/dotfiles/Brewfile
# Add --force to actually uninstall.
```

## Hard constraints

The Anthropic essay skills reference an absolute path that must stay
exact:

```
/Users/wernerglinka/Documents/Essays/knowledge-base/CLAUDE.md
```

Do not move, rename, or symlink the `knowledge-base/CLAUDE.md` file or
its parent directories. The directory layout in this repo is built
around that fixed point.

## What this repo deliberately does NOT do

- It does not manage the contents of `~/.claude`. Claude Code keeps its
  own state there and the bootstrap script never touches it.
- It does not move or modify any working tree under `~/Documents/`.
- It does not generate the SSH key for you, and it does not upload
  anything to GitHub on your behalf. Those are in the checklist.
- It does not install application preferences (`defaults write` plists).
  If that becomes worth automating, it goes in a separate `macos/`
  directory with its own script.
