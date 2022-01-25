#!/bin/sh

export PATH="$HOME/.local/bin\
:$(ruby -e 'puts Gem.user_dir')/bin\
:$HOME/.ghcup/bin\
:$PATH"

# keyboard setup
setxkbmap -option caps:none -option altwin:menu_win
xmodmap -e "keycode 66 = Escape Caps_Lock"

export QT_QPA_PLATFORMTHEME="qt5ct"
export EDITOR="vim"
export VISUAL="vim"
export TERMINAL="alacritty"
export BROWSER="brave"

# ~/ Clean-up:
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export VIMINIT="source ~/.config/vim/vimrc"
export LESSHISTFILE="-"
export WGETRC="${XDG_CONFIG_HOME:-$HOME/.config}/wget/wgetrc"
#export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
#export WINEPREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/wineprefixes/default"
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/history"

