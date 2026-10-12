function __prompt_git_collect_async
    if not set -q __prompt_git_refresh_pid; or not set -q __prompt_git_refresh_tmp
        return
    end
    if kill -0 $__prompt_git_refresh_pid >/dev/null 2>&1
        return
    end
    if test -f "$__prompt_git_refresh_tmp"
        set -l lines (command cat "$__prompt_git_refresh_tmp")
        command rm -f "$__prompt_git_refresh_tmp"
        set -g __prompt_git_cache_repo "$lines[1]"
        set -g __prompt_git_cache_branch "$lines[2]"
    end
    set -e __prompt_git_refresh_pid
    set -e __prompt_git_refresh_tmp
    set -g __prompt_git_last_refresh_tick $__prompt_git_command_tick
end
