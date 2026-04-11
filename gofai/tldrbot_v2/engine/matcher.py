from __future__ import annotations

from pathlib import Path

from .storage import load_json, save_json


class CommandMatcher:
    def __init__(self, mapping_path: Path) -> None:
        self.mapping_path = mapping_path
        self.mapping_data = load_json(mapping_path, {"defaults": {}, "custom": {}})

    @staticmethod
    def _norm(value: str) -> str:
        return " ".join(value.strip().lower().split())

    def _ordered_mappings(self) -> list[tuple[str, str]]:
        merged: list[tuple[str, str]] = []
        for section in ("custom", "defaults"):
            entries = self.mapping_data.get(section, {})
            merged.extend((self._norm(k), v) for k, v in entries.items())
        merged.sort(key=lambda item: len(item[0]), reverse=True)
        return merged

    def match(self, utterance: str) -> str | None:
        text = self._norm(utterance)
        if not text:
            return None

        for phrase, command in self._ordered_mappings():
            if text == phrase:
                return command

        for phrase, command in self._ordered_mappings():
            if phrase in text:
                return command

        return None

    def add_custom_mapping(self, phrase: str, command: str) -> None:
        phrase_norm = self._norm(phrase)
        custom = self.mapping_data.setdefault("custom", {})
        custom[phrase_norm] = command
        save_json(self.mapping_path, self.mapping_data)

    def defaults(self) -> dict[str, str]:
        return self.mapping_data.get("defaults", {})

    def custom(self) -> dict[str, str]:
        return self.mapping_data.get("custom", {})
