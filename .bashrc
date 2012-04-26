# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return


#showing git branches in bash prompt
function parse_git_branch {
  [ -x "$(which git)" ] && git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}



### functions ###

function set_prompt {
    # set a fancy prompt
    LIGHT_GRAY="\[\033[0;37m\]"
    LIGHT_PURPLE="\[\033[1;34m\]"
    YELLOW="\[\033[0;33m\]"
    WHITE="\[\033[1;37m\]"
    COLOR_NONE="\[\e[0m\]"
    PS1="${COLOR_NONE=}\u@\h: \w ${YELLOW}$(parse_git_branch)${COLOR_NONE=}\$ "
}

function add_ssh_keys {
    for key in $(file ~/.ssh/* | grep "private key" | sed -e 's,:.*,,') ; do
        [ -f "$key" ] && ssh-add "$key"
    done
}

# start the ssh-agent
function start_agent {
    echo "Initializing new SSH agent..."
    # spawn ssh-agent
    ssh-agent | sed 's/^echo/#echo/' > "$SSH_ENV"
    echo succeeded
    chmod 600 "$SSH_ENV"
    . "$SSH_ENV" > /dev/null
    add_ssh_keys
}

# test for identities
function test_identities {
    # test whether standard identities have been added to the agent already
    ssh-add -l | grep -q "The agent has no identities"
    if [ $? -eq 0 ]; then
        add_ssh_keys
        # $SSH_AUTH_SOCK broken so we start a new proper agent
        if [ $? -eq 2 ];then
            start_agent
        fi
    fi
}

function add_all_ssh_keys {
    [ -d "~/.ssh" ] && return 0
    # check for running ssh-agent with proper $SSH_AGENT_PID
    if [ -n "$SSH_AGENT_PID" ]; then
        ps -ef | grep "$SSH_AGENT_PID" | grep ssh-agent > /dev/null
        if [ $? -eq 0 ]; then
            test_identities
        fi
    # if $SSH_AGENT_PID is not properly set, we might be able to load one from
    # $SSH_ENV
    else
        if [ -f "$SSH_ENV" ]; then
            . "$SSH_ENV" > /dev/null
        fi
        ps -ef | grep "$SSH_AGENT_PID" | grep -v grep | grep ssh-agent > /dev/null
        if [ $? -eq 0 ]; then
            test_identities
        else
            start_agent
        fi
    fi
}



# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
# stupid gnome-terminal sets only xterm, see https://bugs.launchpad.net/ubuntu/+source/bash/+bug/103929
case "$TERM" in
    xterm-color|xterm)
        PROMPT_COMMAND=set_prompt
    ;;
    *)
        PS1="\u@\h: \w \$ "
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias l='ls -l'
alias ll='ls -la'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


SSH_ENV="$HOME/.ssh/environment"


# export some variables
export EDITOR=vim
export DEBFULLNAME="Thilo Uttendorfer"
export DEBEMAIL="debian@uttendorfer.net"

[ -d ~/bin ] && export PATH="${PATH}:~/bin"
[ -d ~/configs-and-scripts/bin ] && export PATH="${PATH}:~/configs-and-scripts/bin"

# adding ssh keys to the agent at the end so it's no problem to ctrl-c it
add_all_ssh_keys 

