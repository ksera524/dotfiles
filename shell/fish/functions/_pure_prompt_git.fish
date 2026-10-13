function _pure_prompt_git
    if set -q pure_enable_git; and test "$pure_enable_git" != true
        return
    end
    set -l branch (command git symbolic-ref --quiet --short HEAD 2>/dev/null)
    if test -z "$branch"
        set branch (command git rev-parse --short HEAD 2>/dev/null)
    end
    if test -n "$branch"
        set -l color (_pure_set_color $pure_color_git_branch)
        printf '%s%s\n' "$color" "$branch"
    end
end
