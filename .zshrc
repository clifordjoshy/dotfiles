autoload -U colors && colors
PS1=$'%B%{\x1b[38;2;251;73;52m%}[%{\x1b[38;2;250;189;47m%}%n%{\x1b[38;2;184;187;38m%}@%{\x1b[38;2;131;165;152m%}%M %{\x1b[38;2;211;134;155m%}%~%{\x1b[38;2;251;73;52m%}]%{\e[0m%}$%b '
stty stop undef # Disable ctrl-s to freeze terminal.
precmd() { print "" } # start prompt in newline

HISTFILE=~/.cache/histfile
HISTSIZE=10000
SAVEHIST=100000

bindkey -e
# export KEYTIMEOUT=1

zstyle :compinstall filename '/home/cliford/.zshrc'

autoload -Uz compinit
# Add menu moving to tab list
# zstyle ':completion:*' menu select
# zmodload zsh/complist

# Auto complete with case insensitivity
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

compinit -d ~/.cache/zsh/zcompdump
_comp_options+=(globdots)

bindkey '^R' history-incremental-pattern-search-backward # ctrl + r -> history search
bindkey "^[[3~" delete-char # delete key
bindkey "^[[H" beginning-of-line # home key
bindkey "^[[F" end-of-line # end key
bindkey "^H" backward-delete-word # ctrl + backspace
bindkey "5~" delete-word # ctrl + delete
bindkey "^[[1;5C" forward-word # ctrl + rightarrow
bindkey "^[[1;5D" backward-word # ctrl + leftarrow


setopt HIST_IGNORE_DUPS

#fix visibility for files of ow type(usually in the windows partition)
export LS_COLORS=$LS_COLORS:'ow=0;35:'

if [ "$TERM" = "alacritty" ]; then
	pokemon-colorscripts -r
fi

. ~/.config/aliasrc
. /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
. /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh
. /usr/share/doc/pkgfile/command-not-found.zsh

bindkey '^[[Z' autosuggest-accept

. /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
