#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

export HISTCONTROL=ignoredups

export LS_COLORS=$LS_COLORS:'ow=0;35:'

. ~/.config/aliasrc
