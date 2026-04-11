from __future__ import annotations


def handle(slots: dict[str, str]) -> str:
    provider = slots.get("provider_name", "next available provider")
    insurance = slots.get("insurance", "self-pay")
    return (
        "appointment queued: "
        f"type={slots['appointment_type']}, day={slots['day']}, "
        f"window={slots['time_window']}, zip={slots['zip_code']}, "
        f"provider={provider}, insurance={insurance}"
    )
