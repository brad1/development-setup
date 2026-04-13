from __future__ import annotations

from dataclasses import dataclass
from typing import Literal


DEFAULT_HOT_WORDS: tuple[str, ...] = ("help", "urgent", "asap", "cancel")

# This class is a template for future tripwire mechanisms.
# For example, "Help with headache asap" should trigger a dedicated signal for independent escalation,
# where "I have a headache" can live with a generic or nondeterministic (LLM) response. 
# - human
#
# Keep this passive for now; downstream logic can ignore it until there is a real policy selector.
# - codex


@dataclass(frozen=True)
class HumanIndicators:
    num_words: int
    first_word: str
    last_word: str
    contains_hot_word: bool
    contains_multiple_hot_words: bool
    signal_gain: float # or "salience"
    classification: Literal["UNKNOWN"] = "UNKNOWN"


def _truncate_for_length(text: str, max_length: int) -> str:
    if max_length < 0:
        return ""
    return text[:max_length]


def analyze_human_indicators(text: str, max_length: int, hot_words: tuple[str, ...] = DEFAULT_HOT_WORDS) -> HumanIndicators:
    truncated = _truncate_for_length(text, max_length)
    words = truncated.split()
    lowered = truncated.lower()
    found_hot_words = {hot_word for hot_word in hot_words if hot_word.lower() in lowered}

    return HumanIndicators(
        num_words=len(words),
        first_word=words[0] if words else "",
        last_word=words[-1] if words else "",
        contains_hot_word=bool(found_hot_words),
        contains_multiple_hot_words=len(found_hot_words) > 1,
        signal_gain=float(len(found_hot_words)),
    )
