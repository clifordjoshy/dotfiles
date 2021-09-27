#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

export HISTCONTROL=ignoredups

colorscript -r
alias config='/usr/bin/git --git-dir=/home/cliford/.cfg/ --work-tree=/home/cliford'
