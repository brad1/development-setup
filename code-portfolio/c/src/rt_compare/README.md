# rt_compare

Small experiment for comparing realtime thread behavior, especially
`SCHED_FIFO` thread startup, on Linux systems with and without PREEMPT_RT.

## Files

- [`../rt_compare.c`](../rt_compare.c) - C source for the pthread scheduling
  comparison.

## Notes
- The current source was compiled and tested on Ubuntu 26.04 LTS.
- Next human task: expand code and switch on preempt_rt
- Next agentic task: none, agents should not be working directly in code-portolio except where marked.
