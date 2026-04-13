from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .storage import load_json, save_json


@dataclass
class UserProfile:
    name: str = ""

    @classmethod
    def from_dict(cls, payload: dict[str, Any]) -> "UserProfile":
        return cls(name=str(payload.get("name", "")).strip())

    def to_dict(self) -> dict[str, Any]:
        return {"name": self.name}


class ProfileStore:
    def __init__(self, profile_path: Path) -> None:
        self.profile_path = profile_path

    def load(self) -> UserProfile:
        return UserProfile.from_dict(load_json(self.profile_path, {}))

    def save(self, profile: UserProfile) -> None:
        save_json(self.profile_path, profile.to_dict())
