"""Hello world OpenAI Agent SDK demo.

This outline reads local filenames, asks an agent to turn them into a single
search query, then asks another agent with web-search capability to answer the
query.

It is intentionally minimal and designed as a runnable sketch.
"""

from __future__ import annotations

import asyncio
from pathlib import Path

from agents import Agent, Runner, WebSearchTool


def read_local_filenames(limit: int = 10) -> list[str]:
    """Collect a small sample of filenames from the current directory."""
    return sorted(
        [path.name for path in Path(".").iterdir() if path.is_file()]
    )[:limit]


async def main() -> None:
    filenames = read_local_filenames()

    planner = Agent(
        name="Filename query planner",
        instructions=(
            "You are given a list of local filenames. "
            "Create one short web search query that captures the likely project "
            "topic. Return only the query text."
        ),
    )

    planner_result = await Runner.run(
        planner,
        f"Filenames: {filenames}",
    )
    search_query = planner_result.final_output

    researcher = Agent(
        name="Web researcher",
        instructions="Use web search to answer the user's query in 3 bullets.",
        tools=[WebSearchTool()],
    )

    research_result = await Runner.run(researcher, search_query)

    print("=== Filenames ===")
    print(filenames)
    print("\n=== Search Query ===")
    print(search_query)
    print("\n=== Agent Result ===")
    print(research_result.final_output)


if __name__ == "__main__":
    asyncio.run(main())
