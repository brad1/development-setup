import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import main as powersearch


def run_cli(monkeypatch, capsys, cwd: Path, args: list[str]):
    monkeypatch.chdir(cwd)
    monkeypatch.setattr(sys, "argv", ["powersearch", *args])

    exit_code = powersearch.main()
    captured = capsys.readouterr()
    return exit_code, captured.out, captured.err


def test_scan_happy_path(monkeypatch, capsys, tmp_path):
    (tmp_path / "found.txt").write_text("hello\n", encoding="utf-8")

    exit_code, stdout, stderr = run_cli(
        monkeypatch,
        capsys,
        tmp_path,
        ["scan", "--roots", ".", "--name", "found.txt"],
    )

    assert exit_code == 0
    assert "[powersearch] find . -name found.txt" in stdout
    assert "./found.txt" in stdout
    assert stderr == ""


def test_match_happy_path(monkeypatch, capsys, tmp_path):
    (tmp_path / "match.txt").write_text("hello there\nbye\n", encoding="utf-8")

    exit_code, stdout, stderr = run_cli(
        monkeypatch,
        capsys,
        tmp_path,
        ["match", "--pattern", "hello", "--path", "*.txt"],
    )

    assert exit_code == 0
    assert "[powersearch] grep -n hello *.txt" in stdout
    assert "1:hello there" in stdout
    assert stderr == ""


def test_combo_happy_path(monkeypatch, capsys, tmp_path):
    src_dir = tmp_path / "src"
    tests_dir = tmp_path / "tests"
    src_dir.mkdir()
    tests_dir.mkdir()
    (src_dir / "alpha.txt").write_text("needle\n", encoding="utf-8")
    (tests_dir / "beta.txt").write_text("other\n", encoding="utf-8")

    exit_code, stdout, stderr = run_cli(
        monkeypatch,
        capsys,
        tmp_path,
        [
            "combo",
            "--roots",
            "src",
            "tests",
            "--name",
            "*.txt",
            "--pattern",
            "needle",
        ],
    )

    assert exit_code == 0
    assert "[powersearch] find src tests -name '*.txt' -print0 | xargs -0 grep -n needle" in stdout
    assert "src/alpha.txt:1:needle" in stdout
    assert stderr == ""


def test_preview_happy_path(monkeypatch, capsys, tmp_path):
    (tmp_path / "preview.txt").write_text("hello\n", encoding="utf-8")

    exit_code, stdout, stderr = run_cli(
        monkeypatch,
        capsys,
        tmp_path,
        ["preview", "--pattern", "hello", "--path", "*.txt"],
    )

    assert exit_code == 0
    assert "[powersearch] grep -n hello *.txt" in stdout
    assert "preview.txt:1:hello" not in stdout
    assert stderr == ""
