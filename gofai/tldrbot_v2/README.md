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
- Form definitions in `forms/*.json`.
- Pending actions persisted in `data/pending_actions.json`.
- Unknown phrase teaching flow with explicit confirmation.
- Terse operational responses.

## Built-in Control Commands

- `show pending`
- `continue pending`
- `cancel pending`
- `clear pending`
- `map "<phrase>" -> <command_name>`

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
 bot> 0b32c2a1: specify size, cream
 you> size: medium cream: yes
 bot> coffee order: size=medium, temp=hot, cream=yes, sugar=no, flavor=vanilla, notes=none
 you> dentist
 bot> invalid command. map "<phrase>" -> <command_name>. valid commands: appointment, coffee, reminder
 you> map "dentist" -> appointment
 bot> map "dentist" -> appointment ?
 you> yes
 bot> saved
 you> dentist
 bot> 4af120dd: specify appointment_type, day, time_window, zip_code
 you> type: cleaning day: monday
 bot> 4af120dd: specify time_window, zip_code
 ^C

$ python3 bot.py
 tldrbot v2
 you> continue pending
 bot> 4af120dd: specify time_window, zip_code
 you> time window: morning zip: 90210
 bot> appointment queued: type=cleaning, day=monday, window=morning, zip=90210, provider=next available provider, insurance=self-pay
```

## Data Files

- `data/command_mappings.json`: defaults + custom learned mappings.
- `data/pending_actions.json`: active in-progress actions.

