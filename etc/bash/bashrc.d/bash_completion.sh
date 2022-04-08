# shellcheck shell=sh disable=SC1091,SC2039,SC2166
# Check for interactive bash and that we haven't already been sourced.
if [ "x${BASH_VERSION-}" != x -a "x${PS1-}" != x -a "x${BASH_COMPLETION_VERSINFO-}" = x ]; then

    # Check for recent enough version of bash.
    if [ "${BASH_VERSINFO[0]}" -gt 4 ] ||
        [ "${BASH_VERSINFO[0]}" -eq 4 -a "${BASH_VERSINFO[1]}" -ge 2 ]; then
        [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion" ] &&
            . "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion"
        if shopt -q progcomp ; then
            possible_base_dir="/usr/share /usr/local/share"
            bash_completion_file="bash-completion/bash_completion"
            for base_dir in $possible_base_dir; do
                if [ -d "$base_dir" ]; then
                    [ -r "$base_dir/$bash_completion_file" ] && . "$base_dir/$bash_completion_file"
                    break
                fi
            done
            unset possible_base_dir
            unset base_dir
            unset bash_completion_file

            complete_alias_dir="/etc/bash/bashrc.d/complete_alias"
            if [ -r "$complete_alias_dir" ]; then
                . "$complete_alias_dir"
            fi
            unset complete_alias_dir

            # not useful, done with completion_loader
            # sudo_completion_dir="/usr/share/bash-completion/completions/sudo"
            # if [ -r "$sudo_completion_dir" ]; then
            #    . "$sudo_completion_dir"
            # fi
            # unset sudo_completion_dir
            # git_completion_dir="/usr/share/bash-completion/completions/git"
            # if [ -r "$git_completion_dir" ]; then
            #    . "$git_completion_dir"
            # fi
            # unset git_completion_dir
        fi
    fi
fi
