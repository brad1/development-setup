from __future__ import annotations

import unittest

from engine.input_vetting import VettingContext, vet


class InputVettingTests(unittest.TestCase):
    def test_control_alias_from_phrase_table(self) -> None:
        vetted = vet(" menu ", VettingContext())
        self.assertEqual(vetted.intent, "control")
        self.assertEqual(vetted.control_verb, "help")

    def test_capability_phrase_from_phrase_table(self) -> None:
        vetted = vet("what can you do", VettingContext())
        self.assertEqual(vetted.intent, "control")
        self.assertEqual(vetted.control_verb, "capabilities")

    def test_name_prefix_from_phrase_table(self) -> None:
        vetted = vet("my name is Ada", VettingContext())
        self.assertEqual(vetted.intent, "control")
        self.assertEqual(vetted.control_verb, "set_name")
        self.assertEqual(vetted.control_remainder, "Ada")

    def test_broken_map_command_is_invalid(self) -> None:
        vetted = vet('map "Need Dentist" appointment', VettingContext())
        self.assertEqual(vetted.intent, "invalid")
        self.assertEqual(vetted.error, "invalid map syntax")

    def test_map_command_reserved_phrase_collision_is_invalid(self) -> None:
        vetted = vet('map "cancel" -> appointment', VettingContext())
        self.assertEqual(vetted.intent, "invalid")
        self.assertEqual(vetted.error, "control phrase collision")

    def test_map_command_payload(self) -> None:
        vetted = vet(' map   "Need Dentist"   ->  Appointment ', VettingContext())
        self.assertEqual(vetted.intent, "map_command")
        self.assertIsNotNone(vetted.map_command)
        assert vetted.map_command is not None
        self.assertEqual(vetted.map_command.phrase, "Need Dentist")
        self.assertEqual(vetted.map_command.command, "appointment")

    def test_teaching_reply_selection(self) -> None:
        vetted = vet("2", VettingContext(teaching_candidate=("need help", ["coffee", "reminder"])))
        self.assertEqual(vetted.intent, "teaching_reply")
        self.assertIsNotNone(vetted.teaching_reply)
        assert vetted.teaching_reply is not None
        self.assertEqual(vetted.teaching_reply.kind, "select")
        self.assertEqual(vetted.teaching_reply.selected_index, 1)

    def test_teaching_reply_text_stays_in_teaching_mode(self) -> None:
        vetted = vet("what else", VettingContext(teaching_candidate=("need help", ["coffee", "reminder"])))
        self.assertEqual(vetted.intent, "teaching_reply")
        self.assertIsNotNone(vetted.teaching_reply)
        assert vetted.teaching_reply is not None
        self.assertEqual(vetted.teaching_reply.kind, "invalid")

    def test_exit_is_control_verb(self) -> None:
        vetted = vet(" EXIT ", VettingContext())
        self.assertEqual(vetted.intent, "control")
        self.assertEqual(vetted.control_verb, "exit")


if __name__ == "__main__":
    unittest.main()
