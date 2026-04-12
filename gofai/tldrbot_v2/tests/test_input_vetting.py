from __future__ import annotations

import unittest

from engine.input_vetting import VettingContext, vet


class InputVettingTests(unittest.TestCase):
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

    def test_exit_intent(self) -> None:
        vetted = vet(" EXIT ", VettingContext())
        self.assertEqual(vetted.intent, "exit")


if __name__ == "__main__":
    unittest.main()
