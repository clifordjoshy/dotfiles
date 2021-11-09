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

compinit -d ~/.cache/zsh/zcompdump
_comp_options+=(globdots)

# Enable searching through history
bindkey '^R' history-incremental-pattern-search-backward

# delete key
bindkey "^[[3~" delete-char
# home key
bindkey "^[[H"   beginning-of-line
# end key
bindkey "^[[F"   end-of-line

setopt HIST_IGNORE_DUPS

#fix visibility for files of ow type(usually in the windows partition)
export LS_COLORS=$LS_COLORS:'ow=0;35:'

if [ "$TERM" = "alacritty" ]; then
	pokemon-colorscripts -r
fi

eval "$(starship init zsh)"

. ~/.config/aliasrc
. /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
. /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
. /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh
. /usr/share/autojump/autojump.zsh
. /usr/share/doc/pkgfile/command-not-found.zsh

bindkey '^[[Z' autosuggest-accept
