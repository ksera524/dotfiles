function __prompt_git_request_refresh
    status is-interactive; or return
    __prompt_git_collect_async

    set -l repo (__prompt_git_current_repo)
    if test -z "$repo"
        set -e __prompt_git_cache_repo
        set -e __prompt_git_cache_branch
        return
    end
    if set -q __prompt_git_refresh_pid
        return
    end

    set -l force "$argv[1]"
    if not set -q __prompt_git_command_tick
        set -g __prompt_git_command_tick 0
    end
    if test "$force" != force; and set -q __prompt_git_last_refresh_tick
        set -l delta (math "$__prompt_git_command_tick - $__prompt_git_last_refresh_tick")
        if test $delta -lt 2
            return
        end
    end

    set -l tmp (mktemp -t fish-git-prompt.XXXXXXXXXX)
    or return
    command fish --no-config -c 'set -l repo $argv[1]; set -l branch (command git -C "$repo" symbolic-ref --quiet --short HEAD 2>/dev/null); if test -z "$branch"; set branch (command git -C "$repo" rev-parse --short HEAD 2>/dev/null); end; printf "%s\n%s\n" "$repo" "$branch"' "$repo" >"$tmp" 2>/dev/null &
    set -g __prompt_git_refresh_pid $last_pid
    set -g __prompt_git_refresh_tmp "$tmp"
end
