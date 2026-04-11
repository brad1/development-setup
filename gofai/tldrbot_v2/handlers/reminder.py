from __future__ import annotations


def handle(slots: dict[str, str]) -> str:
    date = slots.get("date", "today")
    priority = slots.get("priority", "normal")
    return (
        "reminder saved: "
        f"message={slots['message']}, time={slots['time']}, date={date}, priority={priority}"
    )
