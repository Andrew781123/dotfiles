# Enable Powerlevel10k instant prompt - must be at the top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Environment variables
export ZSH="$HOME/.oh-my-zsh"
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

# oh-my-zsh initialization
plugins=(git)
source $ZSH/oh-my-zsh.sh

# Completion
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)

# Aliases
alias ls="exa"
alias ll="exa -alh"
alias tree="exa -tree"
alias cat="bat"
alias tas="tmux attach-session -t"
alias tns="tmux new -s"
alias tks="tmux kill-session -t"
alias tls="tmux ls"
eval $(thefuck --alias)

# Extended git aliases with no-verify
alias gcmsg="git commit --no-verify -m"
alias gpsup='git push --no-verify --set-upstream origin $(git_current_branch)'
alias gp="git push --no-verify"
alias ggfl="git push --no-verify --force-with-lease"
alias ggf="git push --no-verify --force"
alias gcn!="git commit --no-verify --no-edit --amend"
alias grhs="git reset --soft HEAD~"

# Plugin management
source ~/powerlevel10k/powerlevel10k.zsh-theme
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

# Aider configuration
export DEEPSEEK_API_KEY=$(security find-generic-password -s "DEEPSEEK_API_KEY" -w)
export AIDER_NO_AUTO_COMMITS=1
export AIDER_CODE_THEME="nord-darker"
export AIDER_DEEPSEEK=1
export AIDER_VIM=1

# Load p10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
