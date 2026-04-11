from __future__ import annotations

from pathlib import Path
from typing import Any

from .storage import load_json


class FormRegistry:
    def __init__(self, forms_dir: Path) -> None:
        self.forms_dir = forms_dir
        self.forms = self._load_forms()

    def _load_forms(self) -> dict[str, dict[str, Any]]:
        payload: dict[str, dict[str, Any]] = {}
        for form_file in sorted(self.forms_dir.glob("*.json")):
            form = load_json(form_file, {})
            command = form.get("command_name")
            if command:
                payload[command] = form
        return payload

    def commands(self) -> list[str]:
        return sorted(self.forms.keys())

    def get(self, command_name: str) -> dict[str, Any]:
        return self.forms[command_name]

    def has(self, command_name: str) -> bool:
        return command_name in self.forms
