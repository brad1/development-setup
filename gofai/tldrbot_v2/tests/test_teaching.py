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
            (tmp / "forms" / "coffee.json").write_text(
                '{"form_name":"coffee","command_name":"coffee","required_fields":["size"],"optional_fields":[],"field_prompts":{}}',
                encoding="utf-8",
            )
            bot = TLDRBot(tmp)
            first = bot.process("need a doctor")
            self.assertIn("what do you mean", first)
            self.assertIn("(1)", first)
            self.assertIn("(3) new command", first)
            second = bot.process("1")
            self.assertEqual(second, "saved")
            third = bot.process("need a doctor")
            self.assertIn("?", third)

    def test_add_command_choice_is_unimplemented_stub(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp = Path(tmp_dir)
            self._seed(tmp)
            (tmp / "forms" / "coffee.json").write_text(
                '{"form_name":"coffee","command_name":"coffee","required_fields":["size"],"optional_fields":[],"field_prompts":{}}',
                encoding="utf-8",
            )
            bot = TLDRBot(tmp)
            first = bot.process("need a doctor")
            self.assertIn("(3) new command", first)
            second = bot.process("3")
            self.assertTrue(second.startswith("created "))
            third = bot.process("need a doctor")
            self.assertEqual(third, "feature unimplemented")
            self.assertEqual(bot.matcher.custom().get("need a doctor"), "need_a_doctor")

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
            self.assertIn("?", first)
            second = bot.process("help")
            self.assertIn("commands: appointment, coffee", second)
            self.assertIn("controls: greet, register identity, recall identity, status, capabilities", second)
            third = bot.process("show pending")
            self.assertIn("coffee", third)
            fourth = bot.process("cancel")
            self.assertEqual(fourth, "cancelled")
            fifth = bot.process("show pending")
            self.assertEqual(fifth, "no pending")

    def test_greet_status_and_capabilities(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp = Path(tmp_dir)
            self._seed(tmp)
            bot = TLDRBot(tmp)
            self.assertEqual(bot.process("hello"), "Assistant ready.")
            self.assertEqual(bot.process("status"), "Assistant online. All monitored systems nominal.")
            self.assertIn("available functions", bot.process("what can you do"))

    def test_name_registration_and_recall(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp = Path(tmp_dir)
            self._seed(tmp)
            bot = TLDRBot(tmp)
            self.assertEqual(bot.process("my name is Ada"), "Acknowledged. I will address you as Ada.")
            self.assertEqual(bot.process("who am i"), "You are identified as Ada.")

    def test_name_prompt_then_value(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp = Path(tmp_dir)
            self._seed(tmp)
            bot = TLDRBot(tmp)
            self.assertEqual(bot.process("register"), "Specify.")
            self.assertEqual(bot.process("Ada Lovelace"), "Acknowledged. I will address you as Ada Lovelace.")

    def test_map_alias_while_teaching(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp = Path(tmp_dir)
            self._seed(tmp)
            (tmp / "forms" / "coffee.json").write_text(
                '{"form_name":"coffee","command_name":"coffee","required_fields":["size"],"optional_fields":[],"field_prompts":{}}',
                encoding="utf-8",
            )
            bot = TLDRBot(tmp)
            first = bot.process("need a doctor")
            self.assertIn("what do you mean", first)
            second = bot.process("map to coffee")
            self.assertIn('what do you mean by "need a doctor"', second)

    def test_known_command_or_escape_phrase_suspends_pending(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp = Path(tmp_dir)
            self._seed(tmp)
            (tmp / "forms" / "coffee.json").write_text(
                '{"form_name":"coffee","command_name":"coffee","required_fields":["size"],"optional_fields":[],"field_prompts":{}}',
                encoding="utf-8",
            )
            (tmp / "data" / "command_mappings.json").write_text(
                '{"defaults":{"coffee":"coffee","dentist":"appointment"},"custom":{}}',
                encoding="utf-8",
            )
            bot = TLDRBot(tmp)
            first = bot.process("coffee")
            self.assertIn("?", first)
            second = bot.process("dentist")
            self.assertIn("?", second)
            self.assertEqual(len(bot.pending.list_suspended()), 1)
            third = bot.process("show pending")
            self.assertIn("appointment", third)

    def test_nevermind_suspends_pending(self) -> None:
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
            self.assertIn("?", first)
            second = bot.process("nevermind")
            self.assertEqual(second, "suspended")
            third = bot.process("show pending")
            self.assertEqual(third, "no pending")

    def test_invalid_map_syntax_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp = Path(tmp_dir)
            self._seed(tmp)
            bot = TLDRBot(tmp)
            response = bot.process('map "dentist" appointment')
            self.assertEqual(response, "invalid map syntax")

    def test_reserved_control_phrase_map_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp = Path(tmp_dir)
            self._seed(tmp)
            bot = TLDRBot(tmp)
            response = bot.process('map "cancel" -> appointment')
            self.assertEqual(response, "control phrase collision")

    def test_invalid_teaching_reply_reports_full_range(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp = Path(tmp_dir)
            self._seed(tmp)
            (tmp / "forms" / "coffee.json").write_text(
                '{"form_name":"coffee","command_name":"coffee","required_fields":["size"],"optional_fields":[],"field_prompts":{}}',
                encoding="utf-8",
            )
            bot = TLDRBot(tmp)
            first = bot.process("need a doctor")
            self.assertIn("(3) new command", first)
            second = bot.process("4")
            self.assertEqual(second, "pick 1-3")



    def test_exit_sets_should_exit(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp = Path(tmp_dir)
            self._seed(tmp)
            bot = TLDRBot(tmp)
            response = bot.process("exit")
            self.assertEqual(response, "bye")
            self.assertTrue(bot.should_exit)

if __name__ == "__main__":
    unittest.main()
