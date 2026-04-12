from __future__ import annotations

from .pending import PendingAction


def route_pending_input(text: str, actions: list[PendingAction]) -> PendingAction | None:
    # Placeholder for future AI/disambiguation routing.
    # For now, pick the most recently updated pending or suspended action.
    routable = [action for action in actions if action.status in {"pending", "suspended"}]
    if not routable:
        return None
    return sorted(routable, key=lambda item: item.updated_at)[-1]
