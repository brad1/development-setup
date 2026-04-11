from __future__ import annotations

import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .storage import load_json, save_json


def now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


@dataclass
class PendingAction:
    id: str
    command_name: str
    form_name: str
    slots: dict[str, str]
    required_fields: list[str]
    optional_fields: list[str]
    missing_fields: list[str]
    status: str
    created_at: str
    updated_at: str

    @classmethod
    def from_dict(cls, payload: dict[str, Any]) -> "PendingAction":
        return cls(**payload)

    def to_dict(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "command_name": self.command_name,
            "form_name": self.form_name,
            "slots": self.slots,
            "required_fields": self.required_fields,
            "optional_fields": self.optional_fields,
            "missing_fields": self.missing_fields,
            "status": self.status,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
        }


class PendingStore:
    def __init__(self, pending_path: Path) -> None:
        self.pending_path = pending_path

    def _load(self) -> list[PendingAction]:
        rows = load_json(self.pending_path, [])
        return [PendingAction.from_dict(row) for row in rows]

    def _save(self, actions: list[PendingAction]) -> None:
        save_json(self.pending_path, [action.to_dict() for action in actions])

    def list_active(self) -> list[PendingAction]:
        return [a for a in self._load() if a.status == "pending"]

    def most_recent(self) -> PendingAction | None:
        active = self.list_active()
        if not active:
            return None
        return sorted(active, key=lambda item: item.updated_at)[-1]

    def create(self, form: dict[str, Any], slots: dict[str, str] | None = None) -> PendingAction:
        stamp = now_iso()
        slots = slots or {}
        required = list(form.get("required_fields", []))
        missing = [field for field in required if field not in slots]
        action = PendingAction(
            id=uuid.uuid4().hex[:8],
            command_name=form["command_name"],
            form_name=form["form_name"],
            slots=slots,
            required_fields=required,
            optional_fields=list(form.get("optional_fields", [])),
            missing_fields=missing,
            status="pending",
            created_at=stamp,
            updated_at=stamp,
        )
        actions = self._load()
        actions.append(action)
        self._save(actions)
        return action

    def update(self, action: PendingAction) -> PendingAction:
        action.missing_fields = [f for f in action.required_fields if f not in action.slots]
        action.status = "ready" if not action.missing_fields else "pending"
        action.updated_at = now_iso()

        actions = self._load()
        for idx, existing in enumerate(actions):
            if existing.id == action.id:
                actions[idx] = action
                break
        self._save(actions)
        return action

    def mark_complete(self, action_id: str) -> None:
        actions = self._load()
        kept = []
        for action in actions:
            if action.id == action_id:
                action.status = "complete"
            else:
                kept.append(action)
        self._save(kept)

    def cancel_recent(self) -> bool:
        recent = self.most_recent()
        if not recent:
            return False
        actions = [a for a in self._load() if a.id != recent.id]
        self._save(actions)
        return True

    def clear_all(self) -> None:
        self._save([])
