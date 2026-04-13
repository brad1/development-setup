from __future__ import annotations

import re
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

    @staticmethod
    def _is_question_like(text: str) -> bool:
        normalized = text.strip().lower()
        return normalized.endswith("?") or bool(re.match(r"^(what|who|why|how|when|where|which)\b", normalized))

    @staticmethod
    def _contains_phrase(text: str, phrase: str) -> bool:
        return re.search(rf"(?<!\w){re.escape(phrase)}(?!\w)", text) is not None

    def match(self, utterance: str) -> str | None:
        text = self._norm(utterance)
        if not text:
            return None
        question_like = self._is_question_like(utterance)

        for phrase, command in self._ordered_mappings():
            if text == phrase:
                return command

        for phrase, command in self._ordered_mappings():
            if len(phrase.split()) == 1 and question_like:
                continue
            if self._contains_phrase(text, phrase):
                return command

        for phrase, command in self._ordered_mappings():
            if len(phrase.split()) == 1 and question_like:
                continue
            if phrase in text:
                return command

        return None

    def add_custom_mapping(self, phrase: str, command: str) -> None:
        phrase_norm = self._norm(phrase)
        custom = self.mapping_data.setdefault("custom", {})
        custom[phrase_norm] = command
        save_json(self.mapping_path, self.mapping_data)

    def remove_custom_mapping(self, phrase: str) -> bool:
        phrase_norm = self._norm(phrase)
        custom = self.mapping_data.setdefault("custom", {})
        if phrase_norm not in custom:
            return False
        del custom[phrase_norm]
        save_json(self.mapping_path, self.mapping_data)
        return True

    def defaults(self) -> dict[str, str]:
        return self.mapping_data.get("defaults", {})

    def custom(self) -> dict[str, str]:
        return self.mapping_data.get("custom", {})
