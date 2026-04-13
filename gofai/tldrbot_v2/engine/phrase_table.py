from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

from .storage import load_json


DEFAULT_PHRASE_TABLE_PATH = Path(__file__).resolve().parent.parent / "data" / "first_class_phrases.json"


def _normalize(text: str) -> str:
    return " ".join(text.strip().lower().split())


@dataclass(frozen=True)
class PhraseTable:
    controls: dict[str, str]
    prefix_controls: dict[str, str]
    escape_phrases: frozenset[str]
    teaching_replies: dict[str, frozenset[str]]
    map_alias_prefixes: tuple[str, ...]
    map_prefix: str = "map"

    @classmethod
    def load(cls, path: Path | None = None) -> "PhraseTable":
        payload = load_json(path or DEFAULT_PHRASE_TABLE_PATH, {})
        controls: dict[str, str] = {}
        for entry in payload.get("controls", []):
            phrase = _normalize(str(entry.get("phrase", "")))
            verb = str(entry.get("verb", "")).strip()
            if phrase and verb:
                controls[phrase] = verb

        prefix_controls: dict[str, str] = {}
        for entry in payload.get("prefix_controls", []):
            phrase = _normalize(str(entry.get("phrase", "")))
            verb = str(entry.get("verb", "")).strip()
            if phrase and verb:
                prefix_controls[phrase] = verb

        escape_phrases = frozenset(
            _normalize(str(phrase))
            for phrase in payload.get("escape_phrases", [])
            if _normalize(str(phrase))
        )
        teaching_replies: dict[str, frozenset[str]] = {}
        for kind, phrases in payload.get("teaching_replies", {}).items():
            normalized = frozenset(_normalize(str(phrase)) for phrase in phrases if _normalize(str(phrase)))
            if normalized:
                teaching_replies[str(kind)] = normalized

        map_prefix = _normalize(str(payload.get("map_command", {}).get("prefix", "map"))) or "map"
        map_alias_prefixes = tuple(
            _normalize(str(prefix))
            for prefix in payload.get("map_command", {}).get("aliases", [])
            if _normalize(str(prefix))
        )
        return cls(
            controls=controls,
            prefix_controls=prefix_controls,
            escape_phrases=escape_phrases,
            teaching_replies=teaching_replies,
            map_alias_prefixes=map_alias_prefixes,
            map_prefix=map_prefix,
        )

    def control_verb(self, phrase: str) -> str | None:
        return self.controls.get(_normalize(phrase))

    def prefix_control(self, phrase: str) -> tuple[str, str] | None:
        normalized = _normalize(phrase)
        for prefix, verb in sorted(self.prefix_controls.items(), key=lambda item: len(item[0]), reverse=True):
            if normalized == prefix:
                return verb, ""
            if normalized.startswith(prefix + " "):
                remainder = phrase.strip()[len(prefix) :].strip()
                return verb, remainder
        return None

    def is_escape(self, phrase: str) -> bool:
        return _normalize(phrase) in self.escape_phrases

    def reserved_phrases(self) -> frozenset[str]:
        reserved = set(self.controls)
        reserved.update(self.prefix_controls)
        reserved.update(self.escape_phrases)
        for phrases in self.teaching_replies.values():
            reserved.update(phrases)
        reserved.add(self.map_prefix)
        return frozenset(reserved)

    def map_prefix_re(self) -> re.Pattern[str]:
        return re.compile(rf"^{re.escape(self.map_prefix)}(?:\s|$)", re.IGNORECASE)

    def map_command_re(self) -> re.Pattern[str]:
        return re.compile(
            rf'^{re.escape(self.map_prefix)}\s+"(.+?)"\s*->\s*([a-zA-Z0-9_\-]+)\s*$',
            re.IGNORECASE,
        )

    def map_alias_target(self, phrase: str) -> str | None:
        normalized = _normalize(phrase)
        for prefix in self.map_alias_prefixes:
            if normalized == prefix:
                return ""
            if normalized.startswith(prefix + " "):
                return phrase.strip()[len(prefix) :].strip()
        return None
