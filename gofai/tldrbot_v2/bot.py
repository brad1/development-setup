from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from engine.dispatcher import dispatch
from engine.forms import FormRegistry
from engine.matcher import CommandMatcher
from engine.parser import parse_slots
from engine.pending import PendingStore


class TLDRBot:
    def __init__(self, root: Path) -> None:
        self.root = root
        self.forms = FormRegistry(root / "forms")
        self.matcher = CommandMatcher(root / "data" / "command_mappings.json")
        self.pending = PendingStore(root / "data" / "pending_actions.json")
        self.teaching_candidate: tuple[str, list[str]] | None = None

    def _missing_prompt(self, action) -> str:
        fields = action.missing_fields
        suffix = ' (type "cancel" to stop)'
        if len(fields) == 1:
            return action.id + ": " + fields[0] + "?" + suffix
        return action.id + ": " + ", ".join(f + "?" for f in fields) + suffix

    def _suggest_commands(self, text: str) -> list[str]:
        lowered = text.lower().strip()
        scored: list[tuple[int, str]] = []
        for command in self.forms.commands():
            score = 0
            if command in lowered:
                score += 4
            if command == lowered:
                score += 8
            for part in re.split(r"[\s_-]+", command):
                if part and part in lowered:
                    score += 1
            scored.append((score, command))
        scored.sort(key=lambda item: (-item[0], item[1]))
        chosen = [command for score, command in scored if score > 0]
        if not chosen:
            chosen = self.forms.commands()
        return chosen[:3]

    def _teaching_prompt(self, phrase: str, options: list[str]) -> str:
        numbered = "; ".join(f"({idx}) {command}" for idx, command in enumerate(options, start=1))
        return f'what do you mean by "{phrase}"? {numbered}'

    def _handle_control(self, text: str) -> str | None:
        lower = text.lower().strip()
        if lower == "show pending":
            pending = self.pending.list_active()
            if not pending:
                return "no pending"
            return "pending: " + "; ".join(
                f"{p.id}:{p.command_name} missing={','.join(p.missing_fields) or 'none'}" for p in pending
            )
        if lower in {"cancel", "back"}:
            return "cancelled" if self.pending.cancel_recent() else "no pending"
        if lower == "cancel pending":
            return "cancelled" if self.pending.cancel_recent() else "no pending"
        if lower == "clear pending":
            self.pending.clear_all()
            return "cleared"
        if lower == "suspend pending":
            return "suspended" if self.pending.suspend_recent() else "no pending"
        if lower == "resume pending":
            return "resumed" if self.pending.resume_recent() else "no suspended"
        if lower == "continue pending":
            action = self.pending.most_recent()
            return self._missing_prompt(action) if action else "no pending"
        return None

    def _maybe_confirm_teaching(self, text: str) -> str | None:
        if not self.teaching_candidate:
            return None
        lower = text.strip().lower()
        if lower in {"cancel", "back"}:
            self.teaching_candidate = None
            return "cancelled"
        if lower.isdigit():
            phrase, options = self.teaching_candidate
            idx = int(lower) - 1
            if 0 <= idx < len(options):
                self.matcher.add_custom_mapping(phrase, options[idx])
                self.teaching_candidate = None
                return "saved"
            return "pick 1-" + str(len(options))
        if lower in {"yes", "y"}:
            phrase, options = self.teaching_candidate
            self.matcher.add_custom_mapping(phrase, options[0])
            self.teaching_candidate = None
            return "saved"
        if lower in {"no", "n"}:
            self.teaching_candidate = None
            return "ignored"
        return "pick 1-" + str(len(self.teaching_candidate[1]))

    def _parse_map_command(self, text: str) -> str | None:
        match = re.match(r'^map\s+"(.+?)"\s*->\s*([a-zA-Z0-9_\-]+)\s*$', text.strip())
        if match:
            phrase, command = match.group(1), match.group(2).lower()
            if not self.forms.has(command):
                return "invalid command target"
            self.teaching_candidate = (phrase, [command])
            return f'what do you mean by "{phrase}"? (1) {command}'
        return None

    def _execute_if_ready(self, action):
        if action.missing_fields:
            return self._missing_prompt(action)
        result = dispatch(action.command_name, action.slots)
        self.pending.mark_complete(action.id)
        return result

    def process(self, text: str) -> str:
        text = text.strip()
        if not text:
            return "ready"

        teaching_response = self._maybe_confirm_teaching(text)
        if teaching_response:
            return teaching_response

        map_response = self._parse_map_command(text)
        if map_response:
            return map_response

        control_response = self._handle_control(text)
        if control_response:
            return control_response

        active = self.pending.most_recent()
        if active:
            form = self.forms.get(active.command_name)
            active.slots = parse_slots(text, form, existing=active.slots)
            self.pending.update(active)
            if active.missing_fields:
                return self._missing_prompt(active)
            return self._execute_if_ready(active)

        command = self.matcher.match(text)
        if not command:
            options = self._suggest_commands(text)
            self.teaching_candidate = (text, options)
            return self._teaching_prompt(text, options)

        form = self.forms.get(command)
        slots = parse_slots(text, form, existing={})
        action = self.pending.create(form, slots=slots)
        action = self.pending.update(action)
        return self._execute_if_ready(action)


def repl() -> None:
    bot = TLDRBot(ROOT)
    print("tldrbot v2")
    while True:
        try:
            user_input = input("you> ")
        except (EOFError, KeyboardInterrupt):
            print("\nbye")
            break

        if user_input.strip().lower() in {"quit", "exit"}:
            print("bye")
            break
        print("bot>", bot.process(user_input))


if __name__ == "__main__":
    repl()
