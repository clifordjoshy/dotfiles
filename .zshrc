autoload -U colors && colors

HISTFILE=~/.cache/.histfilel
HISTSIZE=1000
SAVEHIST=1000

bindkey -e
# export KEYTIMEOUT=1

zstyle :compinstall filename '/home/cliford/.zshrc'

autoload -Uz compinit
# Add menu moving to tab list
# zstyle ':completion:*' menu select
# zmodload zsh/complist

# Auto complete with case insenstivity
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

compinit
_comp_options+=(globdots)

# Enable searching through history
bindkey '^R' history-incremental-pattern-search-backward

setopt HIST_IGNORE_DUPS

colorscript -r

eval "$(starship init zsh)"

. ~/.config/aliasrc
. /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
. /usr/share/doc/pkgfile/command-not-found.zsh
