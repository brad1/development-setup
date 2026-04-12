from __future__ import annotations

import re
import tempfile
import unittest
from pathlib import Path

from bot import TLDRBot


class TeachingTests(unittest.TestCase):
    def _last_option_index(self, prompt: str) -> int:
        numbers = [int(value) for value in re.findall(r"\((\d+)\)", prompt)]
        assert numbers
        return max(numbers)

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
            self.assertIn("new command", first)
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
            self.assertIn("new command", first)
            second = bot.process(str(self._last_option_index(first)))
            self.assertTrue(second.startswith("created "))
            third = bot.process("need a doctor")
            self.assertEqual(third, "feature unimplemented")
            self.assertEqual(bot.matcher.custom().get("need a doctor"), "need_a_doctor")

    def test_help_and_clear_are_available_while_pending(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp = Path(tmp_dir)
            self._seed(tmp)
            (tmp / "data" / "command_mappings.json").write_text(
                '{"defaults":{"coffee":"coffee"},"custom":{"list":"help"}}',
                encoding="utf-8",
            )
            (tmp / "forms" / "coffee.json").write_text(
                '{"form_name":"coffee","command_name":"coffee","required_fields":["size"],"optional_fields":[],"field_prompts":{}}',
                encoding="utf-8",
            )
            bot = TLDRBot(tmp)
            second = bot.process("help")
            third = bot.process("capabilities")
            fourth = bot.process("list")
            self.assertEqual(second, third)
            self.assertEqual(second, fourth)
            self.assertIn("overview:", second)
            self.assertIn("  builtins:", second)
            self.assertIn("    help, commands, capabilities, status, greet, register, identify, list pending, clear pending, exit", second)
            self.assertIn("  sample commands:", second)
            self.assertIn("    appointment, coffee", second)
            self.assertIn("  maps:", second)
            self.assertIn('    teach aliases with `map "<phrase>" -> <command>`', second)
            first = bot.process("coffee")
            self.assertIn("?", first)
            fifth = bot.process("list pending")
            self.assertIn("coffee", fifth)
            sixth = bot.process("clear pending")
            self.assertEqual(sixth, "cleared")
            seventh = bot.process("list pending")
            self.assertEqual(seventh, "no pending")

    def test_greet_status_and_capabilities(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp = Path(tmp_dir)
            self._seed(tmp)
            (tmp / "forms" / "coffee.json").write_text(
                '{"form_name":"coffee","command_name":"coffee","required_fields":["size"],"optional_fields":[],"field_prompts":{}}',
                encoding="utf-8",
            )
            (tmp / "forms" / "reminder.json").write_text(
                '{"form_name":"reminder","command_name":"reminder","required_fields":["message"],"optional_fields":[],"field_prompts":{}}',
                encoding="utf-8",
            )
            bot = TLDRBot(tmp)
            self.assertEqual(bot.process("hello"), "Assistant ready.")
            self.assertEqual(bot.process("status"), "Assistant online. All monitored systems nominal.")
            overview = bot.process("what can you do")
            self.assertEqual(overview, bot.process("help"))
            self.assertEqual(overview, bot.process("capabilities"))
            self.assertIn("overview:", overview)
            self.assertIn("  builtins:", overview)
            self.assertIn("    help, commands, capabilities, status, greet, register, identify, list pending, clear pending, exit", overview)
            self.assertIn("  sample commands:", overview)
            self.assertIn("    appointment, coffee, reminder", overview)
            self.assertIn("  maps:", overview)
            self.assertIn('    teach aliases with `map "<phrase>" -> <command>`', overview)

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

    def test_direct_map_to_control_verb(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp = Path(tmp_dir)
            self._seed(tmp)
            bot = TLDRBot(tmp)
            self.assertIn("what do you mean", bot.process("healthcheck"))
            self.assertIn("(1) status", bot.process('map "healthcheck" -> status'))
            self.assertEqual(bot.process("yes"), "saved")
            self.assertEqual(bot.process("healthcheck"), "Assistant online. All monitored systems nominal.")

    def test_known_command_routes_pending(self) -> None:
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
            self.assertEqual(len(bot.pending.list_suspended()), 0)
            self.assertIsNotNone(bot.pending.most_recent())
            third = bot.process("list pending")
            self.assertIn("coffee", third)

    def test_nevermind_does_not_suspend_pending(self) -> None:
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
            self.assertEqual(second, "ready")
            third = bot.process("list pending")
            self.assertIn("coffee", third)

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
            self.assertIn("new command", first)
            second = bot.process(str(self._last_option_index(first) + 1))
            self.assertIn("pick 1-", second)



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
