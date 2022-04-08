# shellcheck shell=sh disable=SC1091,SC2039,SC2166
# Check for interactive bash and that we haven't already been sourced.
if [ "x${BASH_VERSION-}" != x -a "x${PS1-}" != x -a "x${BASH_COMPLETION_VERSINFO-}" = x ]; then

    # Check for recent enough version of bash.
    if [ "${BASH_VERSINFO[0]}" -gt 4 ] ||
        [ "${BASH_VERSINFO[0]}" -eq 4 -a "${BASH_VERSINFO[1]}" -ge 2 ]; then
        [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion" ] &&
            . "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion"
        if shopt -q progcomp ; then
            bash_completion_subdir="bash-completion/bash_completion"
            if [ -r "/usr/share/$bash_completion_subdir" ]; then
                . "/usr/share/$bash_completion_subdir"
            elif [ -r "/usr/local/share/$bash_completion_subdir" ]; then
                . "/usr/local/share/$bash_completion_subdir"
            fi
            complete_alias_dir="/etc/bash/bashrc.d/complete_alias"
            if [ -r "$complete_alias_dir" ]; then
                . "$complete_alias_dir"
            fi
            # not useful, done with completion_loader
            # sudo_completion_dir="/usr/share/bash-completion/completions/sudo"
            # if [ -r "$sudo_completion_dir" ]; then
            #    . "$sudo_completion_dir"
            # fi
            # git_completion_dir="/usr/share/bash-completion/completions/git"
            # if [ -r "$git_completion_dir" ]; then
            #    . "$git_completion_dir"
            # fi
        fi
    fi
fi
