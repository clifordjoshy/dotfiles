#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

export HISTCONTROL=ignoredups

alias config='/usr/bin/git --git-dir=/home/cliford/.cfg/ --work-tree=/home/cliford'

alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

export LS_COLORS=$LS_COLORS:'ow=0;35:'

colorscript -r

