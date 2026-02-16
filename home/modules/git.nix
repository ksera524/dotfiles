{ ... }:
{
  programs.git = {
    enable = true;
    ignores = [
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "ehthumbs.db"
      "Thumbs.db"
      "*~"
      "*.swp"
      "*.swo"
      ".vscode/"
      ".idea/"
      "*.sublime-project"
      "*.sublime-workspace"
      ".project"
      ".classpath"
      ".settings/"
      "node_modules/"
      "npm-debug.log*"
      "yarn-debug.log*"
      "yarn-error.log*"
      ".npm"
      ".yarn-integrity"
      "__pycache__/"
      "*.py[cod]"
      "*$py.class"
      "*.so"
      ".Python"
      "env/"
      "venv/"
      ".env"
      ".venv"
      "target/"
      "Cargo.lock"
      "**/*.rs.bk"
      "dist/"
      "build/"
      "out/"
      "*.log"
      ".env.local"
      ".env.*.local"
      "*.tmp"
      "*.temp"
      "tmp/"
      "temp/"
    ];
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      cm = "commit";
      df = "diff";
      lg = "log --oneline --graph --decorate";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";
      amend = "commit --amend";
      undo = "reset --soft HEAD~1";
      branches = "branch -a";
      remotes = "remote -v";
      tags = "tag -l";
      hist = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
      tree = "log --graph --pretty=format:'%C(yellow)%h%C(reset) - %C(green)%ad%C(reset) - %C(blue)%an%C(reset)%C(red)%d%C(reset) %s' --date=short --all";
      contributors = "shortlog --summary --numbered";
    };
    extraConfig = {
      init.defaultBranch = "main";
      core = {
        editor = "vim";
        autocrlf = "input";
        whitespace = "trailing-space,space-before-tab";
      };
      color.ui = "auto";
      color.branch = "auto";
      color.diff = "auto";
      color.status = "auto";
      push.default = "current";
      pull = {
        rebase = true;
        ff = "only";
      };
      fetch.prune = true;
      merge = {
        tool = "vimdiff";
        conflictstyle = "diff3";
      };
      diff = {
        tool = "vimdiff";
        algorithm = "histogram";
      };
      credential.helper = "!gh auth git-credential";
      help.autocorrect = 1;
      rerere.enabled = true;
      ghq = {
        root = "~/src";
        user = "ksera524";
      };
    };
  };
}
