#
# This code is part of TuXXX project
# https://github.com/tuxxx
#

case $- in
    *i*) ;;
      *) return;;
esac

shopt -u -o history
shopt -s checkwinsize

alias ls='ls --color=auto'
