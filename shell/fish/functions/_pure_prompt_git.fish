function _pure_prompt_git
    if set --query pure_enable_git; and test "$pure_enable_git" != true
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
