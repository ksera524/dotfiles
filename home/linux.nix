{ ... }:
{
  home.sessionVariables = {
    LANG = "C.UTF-8";
    LC_ALL = "C.UTF-8";
    BROWSER = "xdg-open";
    CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER = "clang";
    RUSTFLAGS = "-C link-arg=-fuse-ld=mold";
  };
}
