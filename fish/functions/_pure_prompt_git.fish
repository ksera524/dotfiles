function __prompt_git_current_repo --description 'Resolve repo root once per directory'
    if set -q __prompt_git_last_lookup_pwd; and test "$__prompt_git_last_lookup_pwd" = "$PWD"
        echo "$__prompt_git_last_lookup_repo"
        return
    end

    set -l repo (command git rev-parse --show-toplevel 2>/dev/null)
    set -g __prompt_git_last_lookup_pwd "$PWD"
    set -g __prompt_git_last_lookup_repo "$repo"
    echo "$repo"
end

function __prompt_git_branch_sync --description 'Read current git branch'
    set -l repo "$argv[1]"
    set -l branch (command git -C "$repo" symbolic-ref --quiet --short HEAD 2>/dev/null)
    if test -z "$branch"
        set branch (command git -C "$repo" rev-parse --short HEAD 2>/dev/null)
    end
    echo "$branch"
end

function __prompt_git_collect_async --description 'Collect async refresh result'
    if not set -q __prompt_git_refresh_pid; or not set -q __prompt_git_refresh_tmp
        return
    end

    if kill -0 $__prompt_git_refresh_pid >/dev/null 2>&1
        return
    end

    if test -f "$__prompt_git_refresh_tmp"
        set -l payload (command cat "$__prompt_git_refresh_tmp")
        command rm -f "$__prompt_git_refresh_tmp"
        set -l lines (string split \n -- "$payload")
        set -g __prompt_git_cache_repo "$lines[1]"
        set -g __prompt_git_cache_branch "$lines[2]"
    end

    set -e __prompt_git_refresh_pid
    set -e __prompt_git_refresh_tmp
    set -g __prompt_git_last_refresh_tick $__prompt_git_command_tick
end

function __prompt_git_request_refresh --description 'Debounced async git refresh'
    if not status is-interactive
        return
    end

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

    if test "$force" != force
        if set -q __prompt_git_last_refresh_tick
            set -l delta (math "$__prompt_git_command_tick - $__prompt_git_last_refresh_tick")
            if test $delta -lt 2
                return
            end
        end
    end

    set -l tmp "/tmp/fish-git-prompt-$fish_pid-"(random)".tmp"
    command fish --no-config -c 'set -l repo $argv[1]; set -l branch (command git -C "$repo" symbolic-ref --quiet --short HEAD 2>/dev/null); if test -z "$branch"; set branch (command git -C "$repo" rev-parse --short HEAD 2>/dev/null); end; printf "%s\n%s\n" "$repo" "$branch"' "$repo" >"$tmp" 2>/dev/null &

    set -g __prompt_git_refresh_pid $last_pid
    set -g __prompt_git_refresh_tmp "$tmp"
end

function __prompt_git_postexec_refresh --on-event fish_postexec
    if not set -q __prompt_git_command_tick
        set -g __prompt_git_command_tick 0
    end
    set -g __prompt_git_command_tick (math "$__prompt_git_command_tick + 1")
    __prompt_git_request_refresh
end

function __prompt_git_pwd_refresh --on-variable PWD
    __prompt_git_request_refresh force
end

function _pure_prompt_git --description 'Cached and async pure git prompt'
    if set -q pure_enable_git; and test "$pure_enable_git" != true
        return
    end

    if not type -q --no-functions git
        return 2
    end

    __prompt_git_collect_async

    set -l repo (__prompt_git_current_repo)
    if test -z "$repo"
        return
    end

    if not set -q __prompt_git_cache_repo; or test "$__prompt_git_cache_repo" != "$repo"
        set -g __prompt_git_cache_repo "$repo"
        set -g __prompt_git_cache_branch (__prompt_git_branch_sync "$repo")
    end

    if test -n "$__prompt_git_cache_branch"
        echo (_pure_set_color $pure_color_git_branch)"$__prompt_git_cache_branch"
    end
end
