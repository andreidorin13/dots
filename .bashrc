# █▀▀▄ █▀▀█ █▀▀ █  █ █▀▀█ █▀▀
# █▀▀▄ █▄▄█ ▀▀█ █▀▀█ █▄▄▀ █
# ▀▀▀  ▀  ▀ ▀▀▀ ▀  ▀ ▀ ▀▀ ▀▀▀

__RED='\e[1;31m'
__GRN='\e[1;32m'
__YLW='\e[1;33m'
__BYLW='\e[38;5;184m'
__BLU='\e[1;34m'
__PUR='\e[1;35m'
__CYN='\e[1;36m'
__WHT='\e[1;37m'
__RST='\e[0m'

[[ $- != *i* ]] && return

# set emacs style
set -o emacs

# keep > from clobbering files
set -C

# Enable history appending instead of overwriting.
shopt -s histappend

# base cmd override
alias grep='grep --color=auto'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias df='df -h'
alias l='ls -l --color=auto'
alias ll='ls -al --color=auto'
alias ..='cd ../'
alias ...='cd ../..'
alias nstat='netstat -tlnp'

function py() {
    if [[ $# -eq 0 ]]; then ipython; else python "$@"; fi
}

function psg() {
    ps auxww | grep -i --color=always "$1" | grep -v grep
}

function ex() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2)   tar xjf $1    ;;
            *.tar.gz)    tar xzf $1    ;;
            *.bz2)       bunzip2 $1    ;;
            *.rar)       unrar x $1    ;;
            *.gz)        gunzip $1     ;;
            *.tar)       tar xf $1     ;;
            *.tbz2)      tar xjf $1    ;;
            *.tgz)       tar xzf $1    ;;
            *.zip)       unzip $1      ;;
            *.Z)         uncompress $1 ;;
            *.7z)        7z x $1       ;;
            *)           echo "'$1' cannot be extracted via ex()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Prompt stuff

function __pwd_short() {
    local p=$(pwd)

    if [[ $p == '/' ]]; then echo '/'; return; fi # handle root
    if [[ -z ${p%/*} ]]; then echo $p; return; fi # handle 1 deep

    p=${p/#$HOME/\-}
    local c=${#p} b

    while [[ $p != "${p//\/}" ]]; do
        p=${p#/}
        [[ $p =~ \.?. ]]
        b=$b/${BASH_REMATCH[0]}
        p=${p#*/}
        (( c = ${#b} + ${#p} ))
    done

    echo ${b/\/-/\~}${b+/}${p/-/\~}
}

function __who() {
    local me=`whoami`
    if [[ $me != "rg13" ]]; then
        echo " \[$__BYLW\]🗲 $me\[$__DRW\]"
    fi
}

function __exit() {
    if [[ $__LEXIT == 0 ]]; then
        printf " \[$__GRN\]✔\[$__DRW\]"
    else
        printf " \[$__RED\]✘\[$__DRW\]"
    fi
}

function __right() {
    printf "%s" "\[$__DRW\]\D{%F %T}"
}

function __left() {
    printf "%s" "\[$__DRW\]╔═▶\[$__TXT\] \h:$(__pwd_short) \[$__DRW\]◀$(__who)$(__exit)\n╚▷\[$__TXT\] "
}

function __prompt() {
    __LEXIT=$?
    __TXT=$__YLW

    if [[ ${TERM} == screen* ]]; then __DRW=$__BLU; else __DRW=$__PUR; fi

    PS1=$(printf "%*s\r%s" "$((COLUMNS + 2))" "$(__right)" "$(__left)")
}

PROMPT_COMMAND=__prompt

# complete

function __complete_ssh() {
    COMPREPLY=($(compgen -W "$(cat ~/.ssh/known_hosts | awk -F '[ ,]' '{print $1}' | sed 's/\t//')" "${COMP_WORDS[1]}"))
}

complete -F __complete_ssh ssh

export PATH=$HOME/bin:$PATH
export EDITOR=emacs

if [[ -f ~/.dir_colors ]] ; then
	eval $(dircolors -b ~/.dir_colors)
fi
