from __future__ import annotations

import unittest
from pathlib import Path

from engine.forms import FormRegistry


class FormTests(unittest.TestCase):
    def test_forms_load(self) -> None:
        registry = FormRegistry(Path(__file__).resolve().parents[1] / "forms")
        self.assertTrue(registry.has("appointment"))
        self.assertTrue(registry.has("coffee"))
        self.assertTrue(registry.has("reminder"))


if __name__ == "__main__":
    unittest.main()
