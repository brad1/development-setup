# TLDRBot v2

Small protocol-following CLI chatbot. It routes requests into commands, fills forms, stores pending actions, and executes deterministic handlers.

## Run

```bash
cd gofai/tldrbot_v2
python3 bot.py
```

## Tests

```bash
cd gofai/tldrbot_v2
python3 -m unittest discover -s tests -v
```

## Behavior Summary

- Command recognition via `data/command_mappings.json` (custom first, defaults second).
- First-class control phrases via `data/first_class_phrases.json`.
- Form definitions in `forms/*.json`.
- Pending actions persisted in `data/pending_actions.json`.
- Unknown phrase teaching flow with explicit confirmation.
- Terse operational responses with a single escape path.

## Built-in Control Commands

- `show pending`
- `continue pending`
- `cancel pending`
- `clear pending`
- `map "<phrase>" -> <command_name>`
- `cancel`

## Extending

Add command support by:

1. adding a `forms/<command>.json` form,
2. adding `handlers/<command>.py` with `handle(slots) -> str`,
3. adding defaults in `data/command_mappings.json`.

No core control-flow rewrite is required.

## Sample Transcript

```text
$ python3 bot.py
 tldrbot v2
 you> order coffee hot no sugar vanilla
 bot> 0b32c2a1: size?, cream? (type "cancel" to stop)
 you> size: medium cream: yes
 bot> coffee order: size=medium, temp=hot, cream=yes, sugar=no, flavor=vanilla, notes=none
 you> dentist
 bot> invalid command. map "<phrase>" -> <command_name>. valid commands: appointment, coffee, reminder
 you> map "dentist" -> appointment
 bot> map "dentist" -> appointment ?
 you> yes
 bot> saved
 you> dentist
 bot> 4af120dd: appointment_type?, day?, time_window?, zip_code? (type "cancel" to stop)
 you> type: cleaning day: monday
 bot> 4af120dd: time_window?, zip_code? (type "cancel" to stop)
 ^C

$ python3 bot.py
 tldrbot v2
 you> continue pending
 bot> 4af120dd: time_window?, zip_code? (type "cancel" to stop)
 you> time window: morning zip: 90210
 bot> appointment queued: type=cleaning, day=monday, window=morning, zip=90210, provider=next available provider, insurance=self-pay
```

## Data Files

- `data/command_mappings.json`: defaults + custom learned mappings.
- `data/first_class_phrases.json`: editable table for first-class controls, exit words, escape phrases, and teaching replies.
- `data/pending_actions.json`: active in-progress actions.
