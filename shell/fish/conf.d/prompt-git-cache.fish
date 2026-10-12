status is-interactive; or return

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
