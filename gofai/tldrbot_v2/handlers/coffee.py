from __future__ import annotations


def handle(slots: dict[str, str]) -> str:
    flavor = slots.get("flavor", "none")
    notes = slots.get("notes", "none")
    return (
        "coffee order: "
        f"size={slots['size']}, temp={slots['temperature']}, "
        f"cream={slots['cream']}, sugar={slots['sugar']}, "
        f"flavor={flavor}, notes={notes}"
    )
