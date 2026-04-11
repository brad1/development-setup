from __future__ import annotations

from importlib import import_module


def dispatch(command_name: str, slots: dict[str, str]) -> str:
    module = import_module(f"handlers.{command_name}")
    return module.handle(slots)
