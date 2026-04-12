from __future__ import annotations

import importlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from engine.dispatcher import dispatch
from engine.forms import FormRegistry
from engine.input_vetting import MapCommandPayload, TeachingReplyPayload, VettingContext, vet
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
        self.should_exit = False

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
        display = options + ["new command"]
        numbered = "; ".join(f"({idx}) {command}" for idx, command in enumerate(display, start=1))
        return f'what do you mean by "{phrase}"? {numbered}'

    def _command_list(self) -> str:
        return "commands: " + ", ".join(self.forms.commands())

    def _create_new_command(self, phrase: str) -> str:
        command = re.sub(r"[^a-z0-9]+", "_", phrase.lower()).strip("_")
        if not command:
            command = "new_command"
        base = command
        suffix = 2
        while self.forms.has(command):
            command = f"{base}_{suffix}"
            suffix += 1

        form = {
            "form_name": command,
            "command_name": command,
            "required_fields": [],
            "optional_fields": [],
            "field_prompts": {},
            "field_aliases": {},
        }
        form_path = self.root / "forms" / f"{command}.json"
        form_path.parent.mkdir(parents=True, exist_ok=True)
        form_path.write_text(json.dumps(form, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        self.forms.forms[command] = form
        handler_path = self.root / "handlers" / f"{command}.py"
        handler_path.parent.mkdir(parents=True, exist_ok=True)
        handler_path.write_text(
            "from __future__ import annotations\n\n\n"
            "def handle(slots: dict[str, str]) -> str:\n"
            "    return 'feature unimplemented'\n",
            encoding="utf-8",
        )
        importlib.invalidate_caches()
        self.matcher.add_custom_mapping(phrase, command)
        return command

    def _handle_control(self, control_verb: str) -> str:
        if control_verb == "show_pending":
            pending = self.pending.list_active()
            if not pending:
                return "no pending"
            return "pending: " + "; ".join(
                f"{p.id}:{p.command_name} missing={','.join(p.missing_fields) or 'none'}" for p in pending
            )
        if control_verb in {"help", "commands"}:
            return self._command_list()
        if control_verb in {"cancel", "cancel_pending"}:
            return "cancelled" if self.pending.cancel_recent() else "no pending"
        if control_verb == "clear_pending":
            self.pending.clear_all()
            return "cleared"
        if control_verb == "suspend_pending":
            return "suspended" if self.pending.suspend_recent() else "no pending"
        if control_verb == "resume_pending":
            return "resumed" if self.pending.resume_recent() else "no suspended"
        if control_verb == "continue_pending":
            action = self.pending.most_recent()
            return self._missing_prompt(action) if action else "no pending"
        return "ready"

    def _handle_teaching_reply(self, teaching_reply: TeachingReplyPayload) -> str:
        if not self.teaching_candidate:
            return "ready"
        if teaching_reply.kind == "cancel":
            self.teaching_candidate = None
            return "cancelled"
        if teaching_reply.kind == "select":
            phrase, options = self.teaching_candidate
            idx = teaching_reply.selected_index or -1
            if 0 <= idx < len(options):
                self.matcher.add_custom_mapping(phrase, options[idx])
                self.teaching_candidate = None
                return "saved"
            if idx == len(options):
                command = self._create_new_command(phrase)
                self.teaching_candidate = None
                return f"created {command}"
            return "pick 1-" + str(len(options))
        if teaching_reply.kind == "yes":
            phrase, options = self.teaching_candidate
            self.matcher.add_custom_mapping(phrase, options[0])
            self.teaching_candidate = None
            return "saved"
        if teaching_reply.kind == "no":
            self.teaching_candidate = None
            return "ignored"
        return "pick 1-" + str(len(self.teaching_candidate[1]))

    def _handle_map_command(self, map_command: MapCommandPayload) -> str:
        if not self.forms.has(map_command.command):
            return "invalid command target"
        self.teaching_candidate = (map_command.phrase, [map_command.command])
        return f'what do you mean by "{map_command.phrase}"? (1) {map_command.command}'

    def _execute_if_ready(self, action):
        if action.missing_fields:
            return self._missing_prompt(action)
        result = dispatch(action.command_name, action.slots)
        self.pending.mark_complete(action.id)
        return result

    def process(self, text: str) -> str:
        vetted = vet(text, VettingContext(teaching_candidate=self.teaching_candidate))

        if vetted.intent == "invalid":
            return vetted.error or "invalid input"
        if vetted.intent == "empty":
            return "ready"
        if vetted.intent == "exit":
            self.should_exit = True
            return "bye"
        if vetted.intent == "teaching_reply" and vetted.teaching_reply:
            return self._handle_teaching_reply(vetted.teaching_reply)
        if vetted.intent == "map_command" and vetted.map_command:
            return self._handle_map_command(vetted.map_command)
        if vetted.intent == "control" and vetted.control_verb:
            return self._handle_control(vetted.control_verb)

        active = self.pending.most_recent()
        if active:
            matched = self.matcher.match(vetted.normalized_text)
            if vetted.should_suspend_pending or matched:
                self.pending.suspend_recent()
                if vetted.should_suspend_pending and vetted.intent == "utterance":
                    return "suspended"
                return self.process(vetted.normalized_text)

            form = self.forms.get(active.command_name)
            active.slots = parse_slots(vetted.normalized_text, form, existing=active.slots)
            self.pending.update(active)
            if active.missing_fields:
                return self._missing_prompt(active)
            return self._execute_if_ready(active)

        command = self.matcher.match(vetted.normalized_text)
        if not command:
            options = self._suggest_commands(vetted.normalized_text)
            self.teaching_candidate = (vetted.normalized_text, options)
            return self._teaching_prompt(vetted.normalized_text, options)

        form = self.forms.get(command)
        slots = parse_slots(vetted.normalized_text, form, existing={})
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

        response = bot.process(user_input)
        if bot.should_exit:
            print(response)
            break
        print("bot>", response)


if __name__ == "__main__":
    repl()
