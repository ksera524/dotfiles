{ pkgs, lib, ... }:
let
  settingsSource = ../../.vscode/settings.json;
  extensionsSource = ../../.vscode/extensions.json;
  extensionInstaller = pkgs.writeShellScript "dotfiles-vscode-extensions-install" ''
    set -euo pipefail

    JQ="${pkgs.jq}/bin/jq"
    CODE_BIN=""

    resolve_code_bin() {
      if command -v code >/dev/null 2>&1; then
        CODE_BIN="$(command -v code)"
        return 0
      fi

      for candidate in /mnt/c/Users/*/AppData/Local/Programs/Microsoft\ VS\ Code/bin/code; do
        if [ -x "$candidate" ]; then
          CODE_BIN="$candidate"
          return 0
        fi
      done

      return 1
    }

    if ! resolve_code_bin; then
      echo "warning: VS Code 'code' command is not available; skipping extension install" >&2
      exit 0
    fi

    if ! installed_extensions="$("$CODE_BIN" --list-extensions 2>/dev/null)"; then
      echo "warning: Failed to list VS Code extensions; skipping extension install" >&2
      exit 0
    fi

    installed_extensions_lower="$(printf '%s\n' "''${installed_extensions}" | tr '[:upper:]' '[:lower:]')"

    "$JQ" -r '.recommendations[]' "${extensionsSource}" | while read -r ext; do
      [ -n "$ext" ] || continue

      ext_lower="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"
      if printf '%s\n' "''${installed_extensions_lower}" | grep -Fxq "$ext_lower"; then
        continue
      fi

      if "$CODE_BIN" --install-extension "$ext" >/dev/null 2>&1; then
        echo "Installed VS Code extension: $ext"
      else
        echo "warning: Failed to install VS Code extension: $ext" >&2
      fi
    done
  '';
in
{
  home.file = lib.mkMerge [
    {
      ".config/dotfiles/vscode/extensions.json".source = extensionsSource;
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      ".config/Code/User/settings.json".source = settingsSource;
      ".vscode-server/data/Machine/settings.json".source = settingsSource;
    })
    (lib.mkIf pkgs.stdenv.isDarwin {
      "Library/Application Support/Code/User/settings.json".source = settingsSource;
    })
  ];

  home.packages = [
    (pkgs.writeShellScriptBin "dotfiles-vscode-extensions" ''
      exec "${extensionInstaller}"
    '')
  ];

  home.activation.installVscodeExtensions = lib.mkIf pkgs.stdenv.isLinux (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      "${extensionInstaller}"
    ''
  );
}
