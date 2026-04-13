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
            self.assertIsNone(latest)
            rows = store._load()
            self.assertEqual(len(rows), 1)
            self.assertEqual(rows[0].missing_fields, [])
            self.assertEqual(rows[0].status, "ready")

    def test_suspend_and_route(self) -> None:
        form = {
            "form_name": "coffee",
            "command_name": "coffee",
            "required_fields": ["size", "temperature"],
            "optional_fields": [],
        }
        with tempfile.TemporaryDirectory() as tmp:
            store = PendingStore(Path(tmp) / "pending.json")
            store.create(form, {"size": "small"})
            self.assertTrue(store.suspend_recent())
            self.assertIsNone(store.most_recent())
            suspended = store.most_recent_routable()
            self.assertIsNotNone(suspended)
            self.assertEqual(suspended.status, "suspended")
            self.assertEqual(store.most_recent_routable().status, "suspended")


if __name__ == "__main__":
    unittest.main()
