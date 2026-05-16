# ~/.zshenv — sourced by every zsh invocation (interactive or not).
# Keep this file small. It runs for scripts too, so anything slow goes
# elsewhere.

# Homebrew (Apple Silicon path). Guarded so this file is safe to source
# before Homebrew is installed, which matters during bootstrap.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Volta: Node version manager. Per-project Node and npm pins live in
# package.json, so there is no global Node state to manage here.
export VOLTA_HOME="$HOME/.volta"
[ -d "$VOLTA_HOME/bin" ] && export PATH="$VOLTA_HOME/bin:$PATH"
