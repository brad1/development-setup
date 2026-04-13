from __future__ import annotations

import re
from functools import lru_cache
from dataclasses import dataclass
from typing import Literal

from .phrase_table import DEFAULT_PHRASE_TABLE_PATH, PhraseTable


Intent = Literal[
    "empty",
    "invalid",
    "control",
    "teaching_reply",
    "map_command",
    "utterance",
]


@dataclass(frozen=True)
class VettingContext:
    teaching_candidate: tuple[str, list[str]] | None = None
    max_length: int = 500
    phrase_table: PhraseTable | None = None


@dataclass(frozen=True)
class TeachingReplyPayload:
    kind: Literal["cancel", "select", "yes", "no", "invalid"]
    selected_index: int | None = None


@dataclass(frozen=True)
class MapCommandPayload:
    phrase: str
    command: str
    use_teaching_candidate: bool = False


@dataclass(frozen=True)
class VettedInput:
    raw_text: str
    normalized_text: str
    lowered_text: str
    intent: Intent
    error: str | None = None
    control_verb: str | None = None
    control_remainder: str | None = None
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
    # Deferred hardening lives in section 3a of the checklist.
    if _contains_forbidden_control_chars(raw_text):
        return "invalid control chars"
    return None


def _extract_teaching_reply(lowered_text: str, phrase_table: PhraseTable) -> TeachingReplyPayload | None:
    if lowered_text.isdigit():
        return TeachingReplyPayload(kind="select", selected_index=int(lowered_text) - 1)
    for kind, phrases in phrase_table.teaching_replies.items():
        if lowered_text in phrases:
            if kind in {"cancel", "yes", "no"}:
                return TeachingReplyPayload(kind=kind)
    return TeachingReplyPayload(kind="invalid")


def _map_syntax_error(normalized_text: str, phrase_table: PhraseTable) -> str | None:
    if phrase_table.map_alias_target(normalized_text) is not None:
        return None
    if not phrase_table.map_prefix_re().match(normalized_text):
        return None
    if phrase_table.map_command_re().match(normalized_text):
        return None
    return "invalid map syntax"


_NAME_QUESTION_RE = re.compile(
    r"^(?:what(?:'s| is)|who(?:'s| is)|what are|who are)\s+(?:your\s+)?name\??$",
    re.IGNORECASE,
)


@lru_cache(maxsize=1)
def _default_phrase_table() -> PhraseTable:
    return PhraseTable.load(DEFAULT_PHRASE_TABLE_PATH)


def vet(text: str, context: VettingContext) -> VettedInput:
    phrase_table = context.phrase_table or _default_phrase_table()
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

    if phrase_table.is_escape(lowered_text):
        return VettedInput(
            raw_text=text,
            normalized_text=normalized_text,
            lowered_text=lowered_text,
            intent="utterance",
            should_suspend_pending=True,
        )

    if _NAME_QUESTION_RE.match(normalized_text):
        return VettedInput(
            raw_text=text,
            normalized_text=normalized_text,
            lowered_text=lowered_text,
            intent="invalid",
            error="unsupported question",
        )

    map_error = _map_syntax_error(normalized_text, phrase_table)
    if map_error:
        return VettedInput(
            raw_text=text,
            normalized_text=normalized_text,
            lowered_text=lowered_text,
            intent="invalid",
            error=map_error,
        )

    map_match = phrase_table.map_command_re().match(normalized_text)
    if map_match:
        phrase, command = map_match.group(1), map_match.group(2).lower()
        phrase_lowered = " ".join(phrase.strip().split()).lower()
        if phrase_lowered in phrase_table.reserved_phrases():
            return VettedInput(
                raw_text=text,
                normalized_text=normalized_text,
                lowered_text=lowered_text,
                intent="invalid",
                error="control phrase collision",
            )
        return VettedInput(
            raw_text=text,
            normalized_text=normalized_text,
            lowered_text=lowered_text,
            intent="map_command",
            map_command=MapCommandPayload(phrase=phrase, command=command),
            should_suspend_pending=True,
        )

    if context.teaching_candidate:
        teaching_reply = _extract_teaching_reply(lowered_text, phrase_table)
        if teaching_reply.kind != "invalid":
            return VettedInput(
                raw_text=text,
                normalized_text=normalized_text,
                lowered_text=lowered_text,
                intent="teaching_reply",
                teaching_reply=teaching_reply,
            )

        alias_target = phrase_table.map_alias_target(normalized_text)
        if alias_target is not None:
            return VettedInput(
                raw_text=text,
                normalized_text=normalized_text,
                lowered_text=lowered_text,
                intent="map_command",
                map_command=MapCommandPayload(
                    phrase=context.teaching_candidate[0],
                    command=alias_target.lower(),
                    use_teaching_candidate=True,
                ),
                should_suspend_pending=True,
            )

        control_verb = phrase_table.control_verb(lowered_text)
        if control_verb:
            return VettedInput(
                raw_text=text,
                normalized_text=normalized_text,
                lowered_text=lowered_text,
                intent="control",
                control_verb=control_verb,
                should_suspend_pending=True,
            )

        prefix_control = phrase_table.prefix_control(text)
        if prefix_control:
            control_verb, remainder = prefix_control
            return VettedInput(
                raw_text=text,
                normalized_text=normalized_text,
                lowered_text=lowered_text,
                intent="control",
                control_verb=control_verb,
                control_remainder=remainder or None,
                should_suspend_pending=True,
            )

        return VettedInput(
            raw_text=text,
            normalized_text=normalized_text,
            lowered_text=lowered_text,
            intent="teaching_reply",
            teaching_reply=teaching_reply,
        )

    control_verb = phrase_table.control_verb(lowered_text)
    if control_verb:
        return VettedInput(
            raw_text=text,
            normalized_text=normalized_text,
            lowered_text=lowered_text,
            intent="control",
            control_verb=control_verb,
            should_suspend_pending=True,
        )

    prefix_control = phrase_table.prefix_control(text)
    if prefix_control:
        control_verb, remainder = prefix_control
        return VettedInput(
            raw_text=text,
            normalized_text=normalized_text,
            lowered_text=lowered_text,
            intent="control",
            control_verb=control_verb,
            control_remainder=remainder or None,
            should_suspend_pending=True,
        )

    return VettedInput(raw_text=text, normalized_text=normalized_text, lowered_text=lowered_text, intent="utterance")
