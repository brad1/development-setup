# agent-orchestration (OpenAI Agent SDK hello world)

Minimal runnable-outline demo using the OpenAI Agent SDK:

1. Reads local filenames from the current directory.
2. Uses an agent to generate a single web search query from those filenames.
3. Uses a second agent with web-search tooling to return a short answer.

## File

- `hello_world.py` — simple end-to-end orchestration sketch.

## Run (outline)

```bash
cd agent-orchestration
python hello_world.py
```

## Notes

- This example is intentionally lightweight and may need SDK/package updates in your environment.
- You will need credentials and runtime permissions for outbound web search.
