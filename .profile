#!/bin/sh

export PATH="$HOME/.local/bin:$PATH"

fixkeyboard

export QT_QPA_PLATFORMTHEME="qt5ct"
export EDITOR="vim"
export VISUAL="vim"
export TERMINAL="alacritty"
export BROWSER="brave"
export GTK_THEME="Catppuccin-Mocha"

# ~/ Clean-up:
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export VIMINIT="source ~/.config/vim/vimrc"
export LESSHISTFILE="-"
export WGETRC="${XDG_CONFIG_HOME:-$HOME/.config}/wget/wgetrc"
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export ANDROID_HOME="$XDG_DATA_HOME"/android
#export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
#export WINEPREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/wineprefixes/default"
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/history"

#xinput disable $(xinput list | grep -Eio '(touchpad|glidepoint)\s*id\=[0-9]{1,2}' | grep -Eo '[0-9]{1,2}')

