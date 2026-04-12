from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Literal


Intent = Literal[
    "empty",
    "invalid",
    "exit",
    "control",
    "teaching_reply",
    "map_command",
    "utterance",
]

CONTROL_ALIASES: dict[str, str] = {
    "show pending": "show_pending",
    "help": "help",
    "commands": "commands",
    "menu": "commands",
    "cancel": "cancel",
    "back": "cancel",
    "cancel pending": "cancel_pending",
    "clear pending": "clear_pending",
    "suspend pending": "suspend_pending",
    "resume pending": "resume_pending",
    "continue pending": "continue_pending",
}

EXIT_WORDS = {"quit", "exit"}
ESCAPE_PHRASES = {"nevermind", "never mind", "ignore that", "forget it"}
MAP_COMMAND_RE = re.compile(r'^map\s+"(.+?)"\s*->\s*([a-zA-Z0-9_\-]+)\s*$')


@dataclass(frozen=True)
class VettingContext:
    teaching_candidate: tuple[str, list[str]] | None = None
    max_length: int = 500


@dataclass(frozen=True)
class TeachingReplyPayload:
    kind: Literal["cancel", "select", "yes", "no", "invalid"]
    selected_index: int | None = None


@dataclass(frozen=True)
class MapCommandPayload:
    phrase: str
    command: str


@dataclass(frozen=True)
class VettedInput:
    raw_text: str
    normalized_text: str
    lowered_text: str
    intent: Intent
    error: str | None = None
    control_verb: str | None = None
    teaching_reply: TeachingReplyPayload | None = None
    map_command: MapCommandPayload | None = None
    should_suspend_pending: bool = False


def _normalize(text: str) -> tuple[str, str]:
    stripped = text.strip()
    collapsed = " ".join(stripped.split())
    return collapsed, collapsed.lower()


def _contains_forbidden_control_chars(text: str) -> bool:
    allowed = {"\n", "\r", "\t"}
    for ch in text:
        if (ord(ch) < 32 or ord(ch) == 127) and ch not in allowed:
            return True
    return False


def _shape_check(raw_text: str, normalized_text: str, context: VettingContext) -> str | None:
    if not normalized_text:
        return None
    if len(raw_text) > context.max_length:
        return "input too long"
    if _contains_forbidden_control_chars(raw_text):
        return "invalid control chars"
    return None


def _extract_teaching_reply(lowered_text: str) -> TeachingReplyPayload | None:
    if lowered_text in {"cancel", "back"}:
        return TeachingReplyPayload(kind="cancel")
    if lowered_text.isdigit():
        return TeachingReplyPayload(kind="select", selected_index=int(lowered_text) - 1)
    if lowered_text in {"yes", "y"}:
        return TeachingReplyPayload(kind="yes")
    if lowered_text in {"no", "n"}:
        return TeachingReplyPayload(kind="no")
    return TeachingReplyPayload(kind="invalid")


def vet(text: str, context: VettingContext) -> VettedInput:
    normalized_text, lowered_text = _normalize(text)

    shape_error = _shape_check(text, normalized_text, context)
    if shape_error:
        return VettedInput(
            raw_text=text,
            normalized_text=normalized_text,
            lowered_text=lowered_text,
            intent="invalid",
            error=shape_error,
        )

    if not normalized_text:
        return VettedInput(raw_text=text, normalized_text=normalized_text, lowered_text=lowered_text, intent="empty")

    if lowered_text in EXIT_WORDS:
        return VettedInput(raw_text=text, normalized_text=normalized_text, lowered_text=lowered_text, intent="exit")

    if lowered_text in ESCAPE_PHRASES:
        return VettedInput(
            raw_text=text,
            normalized_text=normalized_text,
            lowered_text=lowered_text,
            intent="utterance",
            should_suspend_pending=True,
        )

    if context.teaching_candidate:
        return VettedInput(
            raw_text=text,
            normalized_text=normalized_text,
            lowered_text=lowered_text,
            intent="teaching_reply",
            teaching_reply=_extract_teaching_reply(lowered_text),
        )

    map_match = MAP_COMMAND_RE.match(normalized_text)
    if map_match:
        phrase, command = map_match.group(1), map_match.group(2).lower()
        return VettedInput(
            raw_text=text,
            normalized_text=normalized_text,
            lowered_text=lowered_text,
            intent="map_command",
            map_command=MapCommandPayload(phrase=phrase, command=command),
            should_suspend_pending=True,
        )

    control_verb = CONTROL_ALIASES.get(lowered_text)
    if control_verb:
        return VettedInput(
            raw_text=text,
            normalized_text=normalized_text,
            lowered_text=lowered_text,
            intent="control",
            control_verb=control_verb,
            should_suspend_pending=True,
        )

    return VettedInput(raw_text=text, normalized_text=normalized_text, lowered_text=lowered_text, intent="utterance")
