function __prompt_git_current_repo
    if set -q __prompt_git_last_lookup_pwd; and test "$__prompt_git_last_lookup_pwd" = "$PWD"
        echo "$__prompt_git_last_lookup_repo"
        return
    end
    set -l repo (command git rev-parse --show-toplevel 2>/dev/null)
    set -g __prompt_git_last_lookup_pwd "$PWD"
    set -g __prompt_git_last_lookup_repo "$repo"
    echo "$repo"
end
