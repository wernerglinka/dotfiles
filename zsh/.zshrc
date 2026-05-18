# ~/.zshrc — interactive shell config. No framework. No prompt theme engine.

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE \
       HIST_FIND_NO_DUPS SHARE_HISTORY

# Completion
autoload -Uz compinit && compinit -i

# Prompt: project-rooted path, git branch when in a repo, colored # based on last exit.
# Inside a git repo, path is shown as <repo-name>/<relative-path>; outside, falls back to %~.
autoload -Uz vcs_info
project_path() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || { print -Pn '%~'; return }
  print -rn -- "${root:t}${PWD#$root}"
}
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt prompt_subst
PROMPT='%F{cyan}$(project_path)%f%F{yellow}${vcs_info_msg_0_}%f %(?.%F{green}.%F{red})%#%f '

# Quality-of-life options
setopt AUTO_CD                # `cd` is optional when typing a directory name
setopt INTERACTIVE_COMMENTS   # allow `# foo` comments in interactive shells
setopt NO_BEEP

# Aliases — kept short on purpose. Add personal ones below this block.
alias ll='ls -lah'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --decorate --graph -20'

# Personal additions below this line.
