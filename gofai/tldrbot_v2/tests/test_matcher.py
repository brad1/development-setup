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

    def test_question_like_text_does_not_trigger_single_word_mapping(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "mappings.json"
            path.write_text(
                json.dumps({"defaults": {}, "custom": {"name": "appointment", "order coffee": "coffee"}}),
                encoding="utf-8",
            )
            matcher = CommandMatcher(path)
            self.assertIsNone(matcher.match("what is your name?"))
            self.assertEqual(matcher.match("please order coffee now"), "coffee")

    def test_remove_custom_mapping(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "mappings.json"
            path.write_text(json.dumps({"defaults": {"coffee": "coffee"}, "custom": {"name": "appointment"}}), encoding="utf-8")
            matcher = CommandMatcher(path)
            self.assertTrue(matcher.remove_custom_mapping("name"))
            self.assertNotIn("name", matcher.custom())
            self.assertFalse(matcher.remove_custom_mapping("missing"))


if __name__ == "__main__":
    unittest.main()
