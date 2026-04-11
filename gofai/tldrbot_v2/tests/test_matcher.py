from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from engine.matcher import CommandMatcher


class MatcherTests(unittest.TestCase):
    def test_custom_before_default(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "mappings.json"
            path.write_text(
                json.dumps(
                    {
                        "defaults": {"coffee": "coffee"},
                        "custom": {"coffee": "reminder"},
                    }
                ),
                encoding="utf-8",
            )
            matcher = CommandMatcher(path)
            self.assertEqual(matcher.match("coffee"), "reminder")

    def test_substring_match(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "mappings.json"
            path.write_text(json.dumps({"defaults": {"order coffee": "coffee"}, "custom": {}}), encoding="utf-8")
            matcher = CommandMatcher(path)
            self.assertEqual(matcher.match("please order coffee now"), "coffee")


if __name__ == "__main__":
    unittest.main()
