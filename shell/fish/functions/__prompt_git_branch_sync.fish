function __prompt_git_branch_sync
    set -l repo "$argv[1]"
    set -l branch (command git -C "$repo" symbolic-ref --quiet --short HEAD 2>/dev/null)
    if test -z "$branch"
        set branch (command git -C "$repo" rev-parse --short HEAD 2>/dev/null)
    end
    echo "$branch"
end
