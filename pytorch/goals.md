# PyTorch Branch Goals

## Meaning of "Goals" in This Folder
In this branch, "goals" means the source-of-truth document for both:

- human goals: why this work matters and what success should feel like
- agent goals: what an implementation agent should build, verify, and avoid

This split exists because project intent and execution instructions are related, but not identical.

## Quickstart
```bash
source ./.venv/bin/activate
python3 -m pip install torch
python3 train_tiny_chat.py
```

## Human Goals

### Objective
Learn core PyTorch training mechanics by building and running the smallest possible chat-completion training loop.

### Why This Branch Exists
- Make PyTorch training mechanics concrete rather than abstract.
- Keep the example small enough for a first-time learner to read end-to-end in one sitting.
- Preserve explanatory value even if the resulting model quality is poor.
- Optimize for clarity and local experimentation over production usefulness.

### Human Success Criteria
- A human reader can trace the training path from text data to loss to generation without getting lost.
- The script is small enough to invite tinkering.
- The sample output makes it obvious that the model is learning next-character behavior, even if it is still silly or noisy.
- The code remains readable and educational rather than aggressively optimized.

### Next Tasks
- Demonstrate tiny chat failure mode that results from having too few layers
- Build on tiny chat to add mode layers, leverage to train on harder patterns


## Agent Goals

### Scope
- Build a tiny character-level language model for next-token prediction.
- Train on a minimal local dataset with `User:` / `Assistant:` turns.
- Generate a completion from a prompt like `User: hi\nAssistant:`.
- Keep implementation in a single Python file for readability and fast iteration.

### Deliverables
- `pytorch/train_tiny_chat.py`:
  - Uses PyTorch `nn.Embedding` bigram model.
  - Trains with cross-entropy on shifted targets.
  - Supports default inline dataset and optional `--data` file.
  - Logs training loss and prints one generated sample.
- `pytorch/train_tiny_chat.sh`:
  - Wrapper for friendlier shell-based usage.
  - Uses bash heredocs to provide wrapper-level defaults for dataset and prompt.
- `pytorch/train_tiny_chat_fast.sh`:
  - Fast wrapper for shorter demo runs.
- `pytorch/goals.md`:
  - This source-of-truth document for branch goals and acceptance criteria.

### Acceptance Criteria
- Running:
  - `python3 pytorch/train_tiny_chat.py`
  - completes without code changes in a properly prepared environment with PyTorch installed.
- The script outputs:
  - periodic loss logs during training
  - one generated sample completion after training.
- The code path is simple enough for a first-time PyTorch learner to trace end-to-end in one sitting.
- The shell wrappers make the default and fast-path runs easier without hiding how the Python script works.

### Milestones
1. Implement minimal training script with default dataset.
2. Run script end-to-end and confirm loss decreases at least modestly.
3. Generate sample completion from `User: hi\nAssistant:`.
4. Add lightweight wrappers that improve usability without replacing the educational Python entry point.
5. Keep this goals doc up to date as the branch intent evolves.

### Out of Scope
- Production model quality.
- Large datasets or distributed training.
- Tokenizers beyond simple character vocab.
- Evaluation pipelines beyond basic loss logging and sample generation.

## Usage
Basic run:

```bash
python3 pytorch/train_tiny_chat.py
```

Wrapper run:

```bash
./pytorch/train_tiny_chat.sh
```

Fast wrapper run:

```bash
./pytorch/train_tiny_chat_fast.sh
```

Optional custom data:

```bash
python3 pytorch/train_tiny_chat.py --data pytorch/my_chat_data.txt
```

Optional faster smoke test:

```bash
python3 pytorch/train_tiny_chat.py --steps 100 --max-new-tokens 40
```

## Environment Assumptions
- Python 3.10+ recommended.
- PyTorch installed (`pip install torch`).
- CPU-only execution is acceptable for this tiny model.

## Stretch Goals
Only after acceptance criteria:

1. Add train/validation split and report both losses.
2. Upgrade from bigram to a tiny Transformer block.
3. Add model save/load for reproducible generation.
