"""Isolated regression checks; no host packages or user configuration are changed."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import tomllib
import unittest

REPO = Path(__file__).resolve().parents[1]
MISE = shutil.which("mise")
FISH = shutil.which("fish")


class DotfilesTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.home = self.root / "home"
        self.home.mkdir()
        self.repo = self.root / "repo"
        shutil.copytree(REPO, self.repo, ignore=shutil.ignore_patterns(".git", ".codegraph", "__pycache__"))
        self.env = {k: v for k, v in os.environ.items() if not k.startswith(("MISE_", "XDG_", "GIT_"))}
        self.env.update(HOME=str(self.home), XDG_CONFIG_HOME=str(self.home / ".config"),
                        XDG_DATA_HOME=str(self.home / ".local/share"), XDG_CACHE_HOME=str(self.root / "cache"),
                        MISE_CONFIG_DIR=str(self.home / ".config/mise"), MISE_DATA_DIR=str(self.root / "data"),
                        MISE_STATE_DIR=str(self.root / "state"), MISE_CACHE_DIR=str(self.root / "mise-cache"),
                        MISE_TRUSTED_CONFIG_PATHS=str(self.root), MISE_YES="1",
                        PATH=str(Path(MISE).parent) + os.pathsep + os.environ["PATH"])
        pure = self.home / ".local/share/fish/plugins/pure"
        (pure / "functions").mkdir(parents=True)
        (pure / "conf.d").mkdir()
        (pure / "conf.d/pure.fish").touch()

    def run_cmd(self, *args, cwd=None, check=True):
        p = subprocess.run(args, cwd=cwd or self.repo, env=self.env, capture_output=True, text=True)
        if check:
            self.assertEqual(p.returncode, 0, p.stdout + p.stderr)
        return p

    def apply(self):
        self.run_cmd(MISE, "bootstrap", "--only", "dotfiles,mise-shell-activate", "--yes")

    def test_bash_startup(self):
        for existing in ("none", "bashrc", "profile", "profile-only"):
            with self.subTest(existing=existing):
                for name in (".bash_profile", ".bashrc", ".profile"):
                    (self.home / name).unlink(missing_ok=True)
                (self.home / ".profile").write_text('PROFILE_COUNT=$((${PROFILE_COUNT:-0}+1))\n. "$HOME/.bashrc"\n')
                if existing == "profile-only":
                    (self.home / ".profile").write_text('PROFILE_COUNT=$((${PROFILE_COUNT:-0}+1))\n')
                (self.home / ".bashrc").write_text('RC_COUNT=$((${RC_COUNT:-0}+1))\n')
                if existing != "none":
                    target = ".bashrc" if existing == "bashrc" else ".profile"
                    (self.home / ".bash_profile").write_text(f'. "$HOME/{target}"\n')
                self.apply()
                paths = [self.home / p for p in (".bash_profile", ".bashrc")]
                before = [p.read_text() for p in paths]
                self.apply()
                self.assertEqual(before, [p.read_text() for p in paths])
                result = self.run_cmd("bash", "--noprofile", "--norc", "-ic",
                    '. "$HOME/.bash_profile"; printf "COUNTS=%s,%s\\n" "$RC_COUNT" "${PROFILE_COUNT:-0}"')
                self.assertIn("COUNTS=1," + ("0" if existing == "bashrc" else "1"), result.stdout)

    def test_intel_packages(self):
        task = tomllib.loads((self.repo / "mise/conf.d/tasks/mise.toml").read_text())["tasks"]["bootstrap:host-packages"]["run"]
        mock = self.root / "bin"
        mock.mkdir()
        for name, body in {
            "uname": '#!/bin/sh\necho "Darwin x86_64"\n',
            "brew": '#!/bin/sh\nif [ "$1" = list ]; then cat "$HOME/installed"; else printf "%s:%s\\n" "$HOMEBREW_NO_INSTALL_UPGRADE" "$*" >> "$HOME/calls"; fi\n',
        }.items():
            p = mock / name
            p.write_text(body)
            p.chmod(0o755)
        self.env["PATH"] = str(mock) + os.pathsep + self.env["PATH"]
        (self.home / "installed").write_text("git\nvim\nfish\ntmux\npkgconf\nopenssl@3\n")
        self.run_cmd("bash", "-ec", task)
        self.assertFalse((self.home / "calls").exists())
        (self.home / "installed").write_text("git\nvim\nfish\ntmux\n")
        self.run_cmd("bash", "-ec", task)
        self.assertEqual((self.home / "calls").read_text(), "1:install pkgconf openssl@3\n")

    def test_dotpush(self):
        self.run_cmd("git", "init", "-b", "main")
        self.run_cmd("git", "config", "user.name", "Test")
        self.run_cmd("git", "config", "user.email", "test@example.invalid")
        self.run_cmd("git", "add", ".")
        self.run_cmd("git", "commit", "-m", "Initial")
        remote = self.root / "remote.git"
        self.run_cmd("git", "init", "--bare", str(remote))
        self.run_cmd("git", "remote", "add", "origin", str(remote))
        self.run_cmd("git", "push", "-u", "origin", "main")
        self.apply()
        for shell in ("bash", "fish"):
            (self.repo / "change").write_text(shell)
            message = 'literal "quotes" $(false) `false`'
            self.env["TEST_MESSAGE"] = message
            if shell == "bash":
                self.run_cmd("bash", "--noprofile", "--norc", "-ic", '. "$HOME/.bashrc"; dotpush "$TEST_MESSAGE"', cwd=self.home)
            else:
                self.run_cmd(FISH, "-ic", 'dotpush "$TEST_MESSAGE"', cwd=self.home)
            self.assertEqual(self.run_cmd("git", "log", "-1", "--format=%s").stdout.strip(), message)
        before = self.run_cmd("git", "rev-parse", "HEAD").stdout
        self.run_cmd(MISE, "run", "--skip-tools", "dotpush", cwd=self.home)
        self.assertEqual(before, self.run_cmd("git", "rev-parse", "HEAD").stdout)
        hook = self.repo / ".git/hooks/pre-commit"
        hook.write_text("#!/bin/sh\nexit 1\n")
        hook.chmod(0o755)
        (self.repo / "change").write_text("rejected")
        result = self.run_cmd(MISE, "run", "--skip-tools", "dotpush", check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(before, self.run_cmd("git", "rev-parse", "HEAD").stdout)


    def test_prompt_freshness(self):
        self.run_cmd("git", "init", "-b", "main")
        self.run_cmd("git", "-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "--allow-empty", "-m", "Initial")
        prompt = self.repo / "shell/fish/functions/_pure_prompt_git.fish"
        result = self.run_cmd(FISH, "--no-config", "-c", f'''
source {prompt}
function _pure_set_color; printf ""; end
_pure_prompt_git
git checkout -qb changed
_pure_prompt_git
git checkout -q --detach
_pure_prompt_git
cd {self.home}
_pure_prompt_git
''')
        lines = result.stdout.splitlines()
        self.assertEqual(lines[:2], ["main", "changed"])
        self.assertEqual(len(lines), 3)
        self.assertEqual(lines[2], self.run_cmd("git", "rev-parse", "--short", "HEAD").stdout.strip())


if __name__ == "__main__":
    unittest.main()
