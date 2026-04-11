from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from bot import TLDRBot


class TeachingTests(unittest.TestCase):
    def _seed(self, tmp: Path) -> None:
        (tmp / "forms").mkdir()
        (tmp / "data").mkdir()
        (tmp / "forms" / "appointment.json").write_text(
            '{"form_name":"appointment","command_name":"appointment","required_fields":["appointment_type"],"optional_fields":[],"field_prompts":{}}',
            encoding="utf-8",
        )
        (tmp / "data" / "command_mappings.json").write_text(
            '{"defaults":{},"custom":{}}',
            encoding="utf-8",
        )
        (tmp / "data" / "pending_actions.json").write_text("[]", encoding="utf-8")

    def test_teaching_flow(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp = Path(tmp_dir)
            self._seed(tmp)
            bot = TLDRBot(tmp)
            first = bot.process("dentist")
            self.assertIn("invalid command", first)
            second = bot.process('map "dentist" -> appointment')
            self.assertIn("map", second)
            third = bot.process("yes")
            self.assertEqual(third, "saved")
            fourth = bot.process("dentist")
            self.assertIn("specify", fourth)

    def test_help_and_cancel_are_available_while_pending(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp = Path(tmp_dir)
            self._seed(tmp)
            (tmp / "forms" / "coffee.json").write_text(
                '{"form_name":"coffee","command_name":"coffee","required_fields":["size"],"optional_fields":[],"field_prompts":{}}',
                encoding="utf-8",
            )
            (tmp / "data" / "command_mappings.json").write_text(
                '{"defaults":{"coffee":"coffee"},"custom":{}}',
                encoding="utf-8",
            )
            bot = TLDRBot(tmp)
            first = bot.process("coffee")
            self.assertIn("specify", first)
            self.assertIn('help', first)
            second = bot.process("help")
            self.assertIn("commands:", second)
            third = bot.process("cancel")
            self.assertEqual(third, "cancelled")
            fourth = bot.process("show pending")
            self.assertEqual(fourth, "no pending")


if __name__ == "__main__":
    unittest.main()
