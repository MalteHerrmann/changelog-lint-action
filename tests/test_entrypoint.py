import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ENTRYPOINT = Path(__file__).resolve().parents[1] / "entrypoint.sh"


class EntrypointTest(unittest.TestCase):
    def run_action(self, command, clu_status=0, reviewdog_status=0, cwd=None, **extra_env):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)
            (path / "clu").write_text(
                '#!/bin/sh\nset -e\n'
                'if [ "$1" = check-diff ]; then\n'
                '  git diff "$GITHUB_BASE_REF...$(git branch --show-current)"\n'
                'else\n  echo "CHANGELOG.md:7: invalid entry"\nfi\n'
                'exit "$CLU_STATUS"\n'
            )
            (path / "reviewdog").write_text(
                '#!/bin/sh\ncat\nexit "$REVIEWDOG_STATUS"\n'
            )
            for executable in path.iterdir():
                executable.chmod(0o755)
            env = {
                **os.environ,
                "PATH": f"{directory}:{os.environ['PATH']}",
                "INPUT_COMMAND": command,
                "INPUT_GITHUB_TOKEN": "test-token-must-not-appear",
                "CLU_STATUS": str(clu_status),
                "REVIEWDOG_STATUS": str(reviewdog_status),
                "GITHUB_HEAD_REF": "",
                "GITHUB_BASE_REF": "",
                **extra_env,
            }
            result = subprocess.run(
                [str(ENTRYPOINT)], env=env, cwd=cwd, capture_output=True, text=True
            )
            self.assertNotIn(env["INPUT_GITHUB_TOKEN"], result.stdout + result.stderr)
            return result

    def test_lint_preserves_failures_from_either_tool(self):
        for clu_status, reviewdog_status, expected in [
            (0, 0, 0), (7, 0, 7), (0, 3, 3), (7, 3, 3)
        ]:
            with self.subTest(clu=clu_status, reviewdog=reviewdog_status):
                result = self.run_action("lint", clu_status, reviewdog_status)
                self.assertEqual(result.returncode, expected, result.stderr)
                self.assertIn("CHANGELOG.md:7: invalid entry", result.stdout)

    def test_invalid_command(self):
        result = self.run_action("unknown")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Invalid command", result.stderr)

    def test_check_diff_requires_pr_context(self):
        result = self.run_action("check-diff")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("requires a pull_request event", result.stderr)

    def test_check_diff_rejects_identical_branch_names(self):
        result = self.run_action(
            "check-diff", GITHUB_HEAD_REF="main", GITHUB_BASE_REF="main"
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("different head and base branch names", result.stderr)

    def test_check_diff_from_shallow_detached_checkout(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "source"
            checkout = Path(directory) / "checkout"
            source.mkdir()

            def git(*args, cwd=source):
                subprocess.run(
                    ["git", *args], cwd=cwd, check=True, capture_output=True
                )

            git("init", "-b", "main")
            git("config", "user.name", "Test")
            git("config", "user.email", "test@example.com")
            (source / "CHANGELOG.md").write_text("# Changelog\n")
            git("add", ".")
            git("commit", "-m", "base")
            git("checkout", "-b", "feature")
            with (source / "CHANGELOG.md").open("a") as changelog:
                changelog.write("- Entry for PR #11\n")
            git("commit", "-am", "entry")
            git("clone", "--depth=1", source.as_uri(), str(checkout))
            git("checkout", "--detach", cwd=checkout)
            for status in (0, 9):
                result = self.run_action(
                    "check-diff", clu_status=status, cwd=checkout,
                    GITHUB_HEAD_REF="feature", GITHUB_BASE_REF="main",
                )
                self.assertEqual(result.returncode, status, result.stderr)
                self.assertIn("+\u002d Entry for PR #11", result.stdout)


if __name__ == "__main__":
    unittest.main()
