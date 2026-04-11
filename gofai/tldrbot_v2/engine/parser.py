from __future__ import annotations

import re
from typing import Any


YES_WORDS = {"yes", "y", "true", "1"}
NO_WORDS = {"no", "n", "false", "0"}


def normalize_yes_no(value: str) -> str:
    lowered = value.strip().lower()
    if lowered in YES_WORDS:
        return "yes"
    if lowered in NO_WORDS:
        return "no"
    return value.strip()


def parse_slots(utterance: str, form: dict[str, Any], existing: dict[str, str] | None = None) -> dict[str, str]:
    text = utterance.strip()
    lowered = text.lower()
    slots: dict[str, str] = dict(existing or {})

    field_aliases = form.get("field_aliases", {})
    for field, aliases in field_aliases.items():
        pattern = rf"(?:{'|'.join(re.escape(alias) for alias in aliases)})\s*[:=]\s*([^,;]+)"
        match = re.search(pattern, lowered)
        if match:
            slots[field] = match.group(1).strip()

    if form["command_name"] == "coffee":
        if "hot" in lowered:
            slots["temperature"] = "hot"
        if "iced" in lowered or "cold" in lowered:
            slots["temperature"] = "iced"
        for size in ("small", "medium", "large"):
            if size in lowered:
                slots["size"] = size

        if re.search(r"\b(no|without)\s+cream\b", lowered):
            slots["cream"] = "no"
        elif "cream" in lowered:
            slots["cream"] = "yes"

        if re.search(r"\b(no|without)\s+sugar\b", lowered):
            slots["sugar"] = "no"
        elif "sugar" in lowered:
            slots["sugar"] = "yes"

        flavor_match = re.search(r"\b(vanilla|hazelnut|caramel|mocha)\b", lowered)
        if flavor_match:
            slots["flavor"] = flavor_match.group(1)

    if form["command_name"] == "appointment":
        zip_match = re.search(r"\b(\d{5})\b", lowered)
        if zip_match:
            slots["zip_code"] = zip_match.group(1)
        day_match = re.search(r"\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday|today|tomorrow)\b", lowered)
        if day_match:
            slots["day"] = day_match.group(1)

    if form["command_name"] == "reminder":
        time_match = re.search(r"\b\d{1,2}(:\d{2})?\s*(am|pm)?\b", lowered)
        if time_match:
            slots["time"] = time_match.group(0).strip()
        if "remind me" in lowered:
            remainder = text.split("remind me", 1)[-1].strip()
            if remainder:
                slots.setdefault("message", remainder)

    for yn_field in ("cream", "sugar"):
        if yn_field in slots:
            slots[yn_field] = normalize_yes_no(slots[yn_field])

    return {k: v for k, v in slots.items() if str(v).strip()}
