# Working with Werner under ~/Documents

Loaded automatically by Claude Code in any working directory under
`~/Documents`. Composes with project-specific CLAUDE.md files, notably
`~/Documents/Essays/knowledge-base/CLAUDE.md` which is referenced by
absolute path from the essay skills and must stay at exactly that
path.

This file lives in the dotfiles repo at
`~/Documents/Projects/dotfiles/claude/CLAUDE.md` and is symlinked to
`~/Documents/CLAUDE.md`. Edit the file in the repo, then commit.

## Identity

Werner Glinka. GitHub `@wernerglinka`. JavaScript developer with some
legacy PHP. Active essay workflow. Maintains many published Metalsmith
plugins under the `@wernerglinka` npm scope plus
`metalsmith-plugin-mcp-server`.

## Stack and style

- JavaScript with JSDoc for type hints. No TypeScript.
- Functional style. Modular, single-purpose code. Dependency injection.
- Tests: Node's native test runner (`import { test } from 'node:test'`,
  run with `node --test`) for all new work.
- Node version: 22 is the working default, managed by Volta. For
  one-offs, `volta install node@<version>`. Per-project pin lives in
  `package.json` under the `volta` field.
- PHP is legacy maintenance only. Do not propose PHP for new work.

## Voice

Prose over bullets. No em-dashes. No agreement filler ("Great
question!", "Absolutely!", "Perfect"). State the answer or the
action. Make sensible defaults explicit in proposals and only ask
the user about choices that genuinely require input.

## Hard constraints

- `/Users/wernerglinka/Documents/Essays/knowledge-base/CLAUDE.md`
  must exist at exactly that path. The essay skills hard-code it.
  Do not move, rename, or symlink-redirect the file or its parent
  directories.
- This is the dev half of a two-machine separation. No finance
  credentials, accounts, or activity originate from this machine,
  ever.
- Treat copied source material under `Essays/` as read-only. Copy
  before modifying.

## Security architecture

- 1Password (desktop app, browser extension, `1password-cli`) is
  the only live credential and passkey store on this Mac. Chrome's
  built-in password manager and Apple iCloud Keychain are off
  (Wi-Fi passwords kept).
- The ed25519 SSH private key lives only inside the 1Password
  vault. `~/.ssh/config` routes SSH through 1Password's agent
  socket, and git's `gpg.ssh.program` is `op-ssh-sign`, so SSH
  connections and signed commits both prompt for Touch ID.
- Primary email is not on this Mac. Webmail in Chrome or the phone.
- VS Code and Chrome extension lists are kept short and audited.
  When asked to install anything that touches credentials, surface
  this architecture before adding.

## Source of truth

`~/Documents/Projects/dotfiles` is the canonical declaration of
installed tools (`Brewfile`), shell, git, npm, ssh, VS Code
extensions, and this CLAUDE.md. To add or change a tool or config,
edit the file in this repo, commit, and re-run `bootstrap.sh`. Do
not modify `$HOME` directly.
