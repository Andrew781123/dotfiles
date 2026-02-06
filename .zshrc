
# Environment variables
export EDITOR=vim
export NVM_DIR="$HOME/.nvm"
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="/Users/andrew/Library/pnpm"
export FZF_DEFAULT_COMMAND="fdfind --exclude={.git,.idea,.vscode,.sass-cache,node_modules,build,tmp,server/generated} --type f"
export PATH="$BUN_INSTALL/bin:$PNPM_HOME:$PATH"

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zshhistory
setopt appendhistory


# Completion
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)

# Aliases
alias ll="exa -alh"
alias tree="exa -tree"
alias cat="bat"
alias tas="tmux attach-session -t"
alias tns="tmux new -s"
alias tks="tmux kill-session -t"
alias tls="tmux ls"
alias y="yazi"
eval $(thefuck --alias)

# Git
git_current_branch() {
  git rev-parse --abbrev-ref HEAD
}
alias gaa='git add --all'
alias gsw='git switch'
alias gswc='git switch --create'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias gsta='git stash push'
alias gstu='gsta --include-untracked'
alias gstp='git stash pop'
alias gcmsg="git commit --no-verify -m"
alias gf='git fetch'
alias ggu='git pull --rebase origin $(git_current_branch)'
alias gpsup='git push --no-verify --set-upstream origin $(git_current_branch)'
alias gp="git push --no-verify"
alias ggfl="git push --no-verify --force-with-lease"
alias ggf="git push --no-verify --force"
alias gcn!="git commit --no-verify --no-edit --amend"
alias grhs="git reset --soft HEAD~"
alias glol="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'"
alias glola="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all"

# Plugin management
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Key bindings
bindkey '^ ' autosuggest-accept
set -o vi

# External tools
[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && . "$(brew --prefix)/opt/nvm/nvm.sh"
[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && . "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"
[ -s "/Users/chiholee/.bun/_bun" ] && source "/Users/chiholee/.bun/_bun"

# Conda initialization
__conda_setup="$('/Users/chiholee/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/chiholee/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/chiholee/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/chiholee/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# Source secrets
if [ -f "$HOME/.dotfiles/env.secrets" ]; then
  source "$HOME/.dotfiles/env.secrets"
fi

# Aider configuration
export AIDER_NO_AUTO_COMMITS=1
export AIDER_CODE_THEME="nord-darker"
# export AIDER_DEEPSEEK=1
# export AIDER_AZURE=1
export AIDER_MODEL="azure/o3-mini"
export AIDER_VIM=1
export AZURE_API_VERSION=2024-12-01-preview
export AZURE_API_BASE=https://andrewmakeapp1123.openai.azure.com/

# Avante configuration
export GOOGLE_CLOUD_PROJECT="gen-lang-client-0997506155"


export EDITOR='nvim'


PATH=~/.console-ninja/.bin:$PATH
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/andrew/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="$HOME/.local/bin:$PATH"

eval "$(starship init zsh)"
eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"
