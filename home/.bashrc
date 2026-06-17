#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '
export GEMINI_API_KEY="" # REDACTED - add your own

. "$HOME/.local/share/../bin/env"
