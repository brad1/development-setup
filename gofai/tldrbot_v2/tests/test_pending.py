from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from engine.pending import PendingStore


class PendingTests(unittest.TestCase):
    def test_create_update_persist(self) -> None:
        form = {
            "form_name": "coffee",
            "command_name": "coffee",
            "required_fields": ["size", "temperature"],
            "optional_fields": [],
        }
        with tempfile.TemporaryDirectory() as tmp:
            store = PendingStore(Path(tmp) / "pending.json")
            action = store.create(form, {"size": "small"})
            self.assertEqual(action.missing_fields, ["temperature"])
            action.slots["temperature"] = "hot"
            store.update(action)
            latest = store.most_recent()
            self.assertIsNotNone(latest)
            self.assertEqual(latest.missing_fields, [])


if __name__ == "__main__":
    unittest.main()
