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

### SSH key generated, on GitHub, signing verified end-to-end
Werner generated `~/.ssh/id_ed25519` (passphrase set) and ran
`ssh-add --apple-use-keychain` to cache the passphrase in the macOS
login Keychain. Uploaded the public key to GitHub twice via `gh
ssh-key add`: as `authentication` and as `signing`, titled
"Werners-Mac-mini (auth)" and "Werners-Mac-mini (signing)". Seeded
`~/.ssh/known_hosts` with github.com's ed25519 host key; fingerprint
matches GitHub's published value
`SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU`. Appended the
machine's public key to `allowed_signers` so `git verify-commit`
works locally.

End-to-end verification: `ssh -T git@github.com` returns "Hi
wernerglinka!", and the first signed commit (03168d8) shows `Good
"git" signature ... with ED25519 key
SHA256:fuJxyqJ1fabxUecmJZOk3RHmpb+F+pXXGaFZIwgXIWk` via
`git log --show-signature`. Keychain integration is transparent: no
passphrase prompt and no GUI Keychain dialog on commit.

### Bootstrap ran cleanly
Werner ran `bootstrap.sh` in his own terminal. Homebrew installed,
`brew bundle` installed 13 dependencies (9 brew formulae plus 4 casks),
all seven dotfiles symlinked, `~/.ssh/config` written from template
(left as a real file so machine-local entries can be added without
committing), Volta installed Node 24.15.0 and npm 11.14.1. Verified
that a fresh interactive shell resolves brew, git, gh, volta, node,
npm, php, composer, jq, rg, fd, and tree, all from expected
locations.

### Fixed allowed_signers populate command
Bootstrap's post-checklist and the `allowed_signers` header comment
both used `$(git config --get user.email)`, which returns empty when
run outside the dev directories because the base `~/.gitconfig` is
identity-free by design. Hardcoded the noreply email in both places
so the populate command works from any working directory.

### bootstrap.sh fixed: drop NONINTERACTIVE=1
First attempt to run bootstrap.sh through the Claude Code tool channel
failed at Homebrew install. The script had `NONINTERACTIVE=1`, which
causes the Homebrew installer to require passwordless sudo or a
preconfigured `SUDO_ASKPASS`. Standard admin users have neither, and a
password prompt cannot be passed through the tool channel.

Fix: drop `NONINTERACTIVE=1` so the Homebrew installer runs in its
normal interactive mode (press RETURN, then enter sudo password). The
script is now intended to be invoked by a human in a real terminal,
which matches its purpose on a fresh Mac. README updated to call this
out explicitly. Also tightened the install check to look for either
`brew` on PATH or `/opt/homebrew/bin/brew` on disk before deciding to
install.

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
