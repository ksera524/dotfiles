# Keep our custom prompt functions ahead of the upstream Pure functions.
if test -d "$__fish_config_dir/pure-functions"
    set --prepend fish_function_path "$__fish_config_dir/functions" "$__fish_config_dir/dotfiles-functions" "$__fish_config_dir/pure-functions"
end
