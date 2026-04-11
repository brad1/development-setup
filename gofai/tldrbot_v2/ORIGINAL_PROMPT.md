Build a small, extensible, protocol-following chatbot.  The bot should be written to "gofai/tldrbot_v2/".

Executive summary:
This bot is not a general assistant. It is a form-filling command router. A user request maps to a command. Each command has a form. The bot collects missing fields, stores unfinished work as pending actions, and executes the command when the required fields are complete. Responses must be terse. The design should feel like an old-school GOFAI chatbot, even if the implementation uses modern code.  The conversational tone should resemble the fictional LCARS ship computer, but won't support voice in this version.

Primary behavior:
- Treat conversation as protocol, not open-ended chat.
- The bot should ask only for missing information needed to finish the current command.
- The bot should be concise and operational.
- The bot should persist unfinished work across turns and restarts.
- The bot should allow the user to teach it new command mappings when a phrase is not recognized.
- The bot should ship with placeholder commands and sample forms for easy manual testing.

Implementation constraints:
- Use Python 3.
- Prefer standard library only.
- Keep the code simple, readable, and modular.
- Use plain text formats for persistence and configuration. JSON is acceptable because it is plain text.
- Do not build a web app. Start with a CLI / terminal REPL.
- Avoid overengineering. No database. No framework unless truly necessary.
- Optimize for extensibility by editing lists and files, not by rewriting code.

Core idea:
The bot has three main concerns:
1. Command recognition
2. Form completion
3. Action dispatch

Design requirements:

1) Pending actions
- The bot must track "pending actions" for commands that are not yet complete.
- Pending actions must persist on disk.
- Each pending action should include:
  - id
  - command_name
  - form_name
  - slots (dict of field -> value)
  - required_fields
  - optional_fields
  - missing_fields
  - status (pending, ready, complete, cancelled)
  - created_at
  - updated_at
- The bot should resume the most recent pending action when the user continues giving details that fit it.
- The bot should allow basic commands like:
  - show pending
  - cancel pending
  - clear pending
  - continue pending

2) Custom command mappings
- The bot should support user-defined command mappings.
- If the bot cannot map a user request to a known command, it should respond with:
  - "invalid command"
  - followed by a brief way to clarify or teach the mapping
- The user must be able to define a new mapping so the same phrase is recognized next time.
- Store learned mappings in a text file on disk.
- Require confirmation before saving a new mapping to reduce accidental poisoning.
- Minimal teaching flow:
  - User enters an unknown phrase
  - Bot says: invalid command
  - Bot suggests syntax such as: map "<phrase>" -> <command_name>
  - User confirms
  - Bot persists the mapping
- Also support loading default mappings from a static file.

3) Placeholder commands and forms
- Include placeholder commands for manual testing.
- Each command must have a corresponding form file in forms/.
- Each form file should define:
  - form_name
  - command_name
  - required_fields
  - optional_fields
  - prompts for each field
  - synonyms / aliases for fields if useful
- Include at least these placeholder commands:
  - appointment
  - coffee
  - reminder
- Include a simple placeholder handler for each:
  - appointment: simulate finding or booking an appointment
  - coffee: simulate building a coffee order
  - reminder: simulate creating a reminder
- Handlers can be fake / stubbed, but they must execute deterministically and print a result using the completed form data.

Interaction rules:
- Keep replies terse.
- Default mode: ask for all currently missing required fields in one compact reply, not one field per turn unless only one field is missing.
- Example:
  - user: book me a dentist appointment
  - bot: specify day, time window, ZIP
- Once required fields are complete, execute immediately unless confirmation is required.
- Allow optional fields to be skipped.
- Do not produce long explanations during normal use.
- The bot should behave like a state machine with forms.

State model:
- Idle: no active pending action
- Collecting: filling slots for a pending action
- Ready: all required slots present
- Executing: dispatching to handler
- Complete: action finished
- Teaching: waiting for user to confirm a new mapping
- Cancelled: action intentionally dropped

Recommended file layout:

gofai/tldrbot_v2/
  bot.py
  engine/
    matcher.py
    forms.py
    pending.py
    dispatcher.py
    storage.py
    parser.py
  forms/
    appointment.json
    coffee.json
    reminder.json
  data/
    command_mappings.json
    pending_actions.json
  handlers/
    appointment.py
    coffee.py
    reminder.py
  tests/
    test_matcher.py
    test_pending.py
    test_teaching.py
    test_forms.py
  README.md

Data format suggestions:

forms/appointment.json
{
  "form_name": "appointment",
  "command_name": "appointment",
  "required_fields": ["appointment_type", "day", "time_window", "zip_code"],
  "optional_fields": ["provider_name", "insurance"],
  "field_prompts": {
    "appointment_type": "specify appointment type",
    "day": "specify day",
    "time_window": "specify time window",
    "zip_code": "specify ZIP",
    "provider_name": "specify provider",
    "insurance": "specify insurance"
  }
}

forms/coffee.json
{
  "form_name": "coffee",
  "command_name": "coffee",
  "required_fields": ["size", "temperature", "cream", "sugar"],
  "optional_fields": ["flavor", "notes"],
  "field_prompts": {
    "size": "specify size",
    "temperature": "specify hot or iced",
    "cream": "specify cream yes/no",
    "sugar": "specify sugar yes/no",
    "flavor": "specify flavor",
    "notes": "specify notes"
  }
}

forms/reminder.json
{
  "form_name": "reminder",
  "command_name": "reminder",
  "required_fields": ["message", "time"],
  "optional_fields": ["date", "priority"],
  "field_prompts": {
    "message": "specify reminder text",
    "time": "specify time",
    "date": "specify date",
    "priority": "specify priority"
  }
}

data/command_mappings.json
{
  "defaults": {
    "book appointment": "appointment",
    "dentist appointment": "appointment",
    "coffee": "coffee",
    "order coffee": "coffee",
    "set reminder": "reminder",
    "remind me": "reminder"
  },
  "custom": {}
}

data/pending_actions.json
[
]

Matching behavior:
- Match user input against custom mappings first, then defaults.
- Use simple deterministic matching.
- Start with exact match and substring / keyword heuristics.
- Do not use embeddings or fuzzy AI matching in version 1.
- Keep the matching logic inspectable and debuggable.

Slot filling behavior:
- When a command is recognized, create or update a pending action.
- Parse obvious slot values from the same utterance when possible.
- Example:
  - user: hot coffee with cream no sugar vanilla
  - bot should populate:
    - temperature=hot
    - cream=yes
    - sugar=no
    - flavor=vanilla
- Ask only for remaining required fields.
- Support simple yes/no normalization.

Teaching behavior:
- On unknown input:
  - reply: invalid command
  - show a compact hint such as:
    - map "<phrase>" -> <command_name>
    - valid commands: appointment, coffee, reminder
- On map command:
  - verify the target command exists
  - ask for confirmation
  - save into custom mappings
- On next run, the learned phrase must work.

Example teaching flow:
- user: dentist
- bot: invalid command. map "dentist" -> appointment ?
- user: yes
- bot: saved
- next time:
  - user: dentist
  - bot: specify appointment type, day, time window, ZIP

Execution behavior:
- Provide deterministic placeholder handlers.
- Examples:
  - appointment handler prints a fake search result or fake booking confirmation
  - coffee handler prints a normalized order summary
  - reminder handler prints a stored reminder summary
- Mark action complete after execution.
- Keep completed actions out of the active pending list.

Extensibility requirements:
- A developer must be able to add or remove commands by:
  - adding or removing a form file in forms/
  - adding or removing a handler module
  - editing command mapping lists in the mappings file
- Avoid hardcoding command-specific logic in the main loop when possible.
- Drive behavior from lists and files.
- The code should make it obvious where to edit:
  - valid commands
  - fields per form
  - aliases
  - prompts
  - handlers

Acceptance criteria:
- Running the bot starts a simple REPL.
- Placeholder commands work end to end.
- Pending actions survive restart.
- Unknown commands can be taught and persist.
- Forms are stored in forms/.
- Custom mappings are stored in a text file.
- Responses remain terse.
- The design is easy to resize by editing lists and files rather than changing core control flow.

Deliverables:
- Working source tree
- README with setup and usage
- Sample transcript showing:
  - a placeholder command
  - a multi-turn pending action
  - an unknown command being taught
  - a restart proving persistence
- Minimal tests for matcher, persistence, and teaching flow

Important:
Keep this version boring, deterministic, and inspectable. Do not turn it into a general chatbot.
