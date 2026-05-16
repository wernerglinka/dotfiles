# Setup Log

Running commentary for the initial build of this dotfiles repo. New entries
go at the top. Each entry names what was done and any decision worth
remembering. Once the repo is in steady state, this file becomes the audit
trail for why things are the way they are.

Machine context for the initial build: Apple M4 Pro, macOS 26.5, fresh
install. Xcode command line tools already present via the Xcode app. Goal is
a declarative, reproducible setup. Brewfile is the source of truth for
installed tools.

---

## 2026-05-16

### Initial local commit
Set the dotfiles repo's local `user.name` and `user.email` to the dev
identity so the very first commit has correct authorship even though
the global gitconfig is not yet symlinked. The commit is intentionally
unsigned: no ed25519 key has been generated yet. Once bootstrap.sh runs
and the SSH key is generated and registered, future commits in this
repo will be signed via the conditional include in `~/.gitconfig`. No
push: a remote will be added after the SSH key is on GitHub.

### README.md and repo .gitignore written
`README.md` covers quick start, what bootstrap does in order, the file
layout, named design choices (Homebrew/Brewfile authority, Volta for
Node, PHP/Composer explicit, SSH signing, conditional identity,
trusted-publishing for npm, plain zsh), how to add and remove a tool,
the hard path constraint on the essay CLAUDE.md, and what the repo
deliberately does NOT manage (`~/.claude`, working trees, SSH key
generation, GitHub uploads, macOS `defaults`). Repo `.gitignore`
excludes `.DS_Store`, `*.bak*`, and an optional `local/` escape hatch
for personal additions that should not be shared. Marked task #6
complete.

### bootstrap.sh written
Idempotent integration script. `set -euo pipefail`. Phases: macOS check,
Xcode CLT check (installs and exits if missing so the user can accept the
GUI prompt and re-run), Homebrew install if absent, `brew bundle`,
symlinks for all dotfiles with backup-then-link for any pre-existing real
files, `~/.ssh/config` written from template only if absent (never
clobbers an existing SSH config), Volta toolchain init if Volta is on
PATH, and a printed post-bootstrap checklist covering SSH key generation,
GitHub upload (auth and signing), allowed_signers population, remote URL
switch from HTTPS to SSH, and the npm trusted-publishing migration. Made
the script executable. Marked task #5 complete.

### npm and ssh templates written
`npm/.npmrc`: registry config, scope binding for `@wernerglinka`, init
defaults, `fund=false`, `audit-level=high`. No auth token. Header comment
documents the trusted-publishing flow so anyone reading the file later
understands why the token is absent and where publishing actually
happens. `ssh/config.template`: github.com host block pinned to
`~/.ssh/id_ed25519`, `IdentitiesOnly yes`, `AddKeysToAgent` and
`UseKeychain` for passphrase caching via macOS Keychain. Marked tasks
#3 and #4 complete.

### git configs written
Four files in `git/`. `.gitconfig` is the base: name, sensible defaults
(`init.defaultBranch=main`, `pull.ff=only`, `push.autoSetupRemote`,
`fetch.prune`, `diff.algorithm=histogram`, `merge.conflictstyle=zdiff3`,
`rerere.enabled`), SSH signing on for commits and tags, and two
`includeIf` blocks for `~/Documents/Projects/` and `~/Documents/Essays/`
that pull in `.gitconfig-dev`. `.gitconfig-dev` carries only the dev
identity (noreply email, signing key path). `.gitignore_global` covers
macOS, Windows, editor, and `.env*` files; project-specific ignores stay
in each project's own .gitignore. `allowed_signers` ships empty with a
populate command in the header comment; bootstrap.sh will fill it in
after the key is generated. Editor chose vim over `code --wait` to avoid
slowing every commit; trivial to change. Marked task #2 complete.

### zsh configs written
`zsh/.zshenv` and `zsh/.zshrc`. `.zshenv` is small on purpose: it sources
Homebrew's shellenv (guarded so it is safe to run before brew is installed)
and sets up Volta on PATH. `.zshrc` carries history, completion, a
vcs_info-based prompt that shows cwd, the current git branch, and a
green/red prompt char based on last exit status, plus six aliases. No
framework, no theme engine. Marked task #1 complete.

### Repo skeleton created
Created `~/Documents/Projects/dotfiles` with subdirs `zsh/`, `git/`, `ssh/`,
`npm/`. Initialized as a git repo on branch `main`. No remote yet.

### Brewfile drafted
First pass at `Brewfile`. Core CLI: git, gh, jq, ripgrep, fd, tree.
Languages: volta, php, composer. Casks: visual-studio-code, iterm2,
obsidian, 1password-cli. Comment block at the bottom names what is
deliberately excluded (finance tools, nvm/fnm/asdf, oh-my-zsh/starship/p10k)
so the intent survives future edits. Awaiting any additions before
continuing.
