# TLDRBot Control Checklist

Use this as the approval list for the input-vetting refactor.

## 1. First Class Controls

1. `help`
2. `commands`
3. `menu`
4. `show pending`
5. `continue pending`
6. `cancel pending`
7. `clear pending`
8. `suspend pending`
9. `resume pending`
10. `cancel`
11. `back`
12. `exit`
13. `quit`
14. `nevermind`
15. `never mind`
16. `ignore that`
17. `forget it`
18. `map "<phrase>" -> <command>`

## 2. Predictable Replies

1. Teaching reply numeric selection
   - Accept `1`, `2`, `3`, etc. while a teaching candidate is active.
   - `1` selects the first suggestion.
   - The final option can mean `new command` if enabled.
2. Teaching reply `yes`
   - Accept the top suggestion.
3. Teaching reply `no`
   - Reject the current suggestion and clear the teaching state.
4. Teaching reply `cancel`
   - Abort the teaching flow.
5. Teaching reply `back`
   - Alias of `cancel`.
6. Invalid teaching selection
   - Return `pick 1-N` when the number is out of range.
7. Unrecognized teaching text
   - Treat it as an invalid teaching reply rather than a new command.
8. Whitespace and casing
   - Trim input and ignore case for teaching replies.
9. Teaching precedence
   - Teaching replies should win while a teaching candidate exists.
10. Candidate persistence
   - Keep the candidate active until accept, reject, cancel, or create-new-command.
11. Pending action continuation
   - Field-like input should continue filling the active pending form.
12. Escape phrases
   - `nevermind` and similar phrases should suspend the current pending action.
13. Control precedence during pending
   - Explicit controls should still work while a pending action is active.

## 3. Input Rejection

1. Empty input
   - Reject or normalize to `ready`.
2. Excessively long input
   - Reject anything over the configured length limit.
3. Broken map syntax
   - Reject malformed `map "<phrase>" -> <command>` input.
4. Out-of-range teaching selection
   - Reject selections outside the available suggestion count.
5. Invalid map target
    - Reject mappings to unknown commands.
6. Control phrase collisions
    - Reject or disambiguate phrases that collide with control words.

## 3a. Input Rejection (deferred, stub or capture in TODO comment)
1. Forbidden control characters
   - Reject low-level control bytes except allowed whitespace.
2. Non-printable characters
   - Reject malformed invisible characters that can break parsing.
3. Embedded NUL bytes
   - Reject outright.
4. Mixed control payloads
   - Reject multiple-command-looking input if single-action semantics are required.
5. Unknown teaching selection format
   - Reject `two`, `second`, or similar unless natural-language numbers are supported.
6. Suspiciously ambiguous controls
    - Reject terse or ambiguous controls unless they are explicitly supported.
7. Unicode normalization edge cases
    - Optionally reject or normalize text that changes meaning under normalization.
8. Hidden separators
    - Reject zero-width or unusual separators that spoof controls.
9. Invalid state transitions
    - Reject replies that do not make sense for the current state.
10. Unknown intent fallback
    - Reject unclassified input with a clear message instead of guessing.
