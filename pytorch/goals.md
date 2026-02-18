# PyTorch Branch Goals

## Quickstart
```
source ./.venv/bin/activate
python3 -m pip install torch
python3 train_tiny_chat.py
```

## Objective
Learn core PyTorch training mechanics by building and running the smallest possible chat-completion training loop.

## Scope
- Build a tiny character-level language model for next-token prediction.
- Train on a minimal local dataset with `User:` / `Assistant:` turns.
- Generate a completion from a prompt like `User: hi\nAssistant:`.
- Keep implementation in a single Python file for readability and fast iteration.

## Out of Scope (for this branch)
- Production model quality.
- Large datasets or distributed training.
- Tokenizers beyond simple character vocab.
- Evaluation pipelines beyond basic loss logging and sample generation.

## Deliverables
- `pytorch/train_tiny_chat.py`:
  - Uses PyTorch `nn.Embedding` bigram model.
  - Trains with cross-entropy on shifted targets.
  - Supports default inline dataset and optional `--data` file.
  - Logs training loss and prints one generated sample.
- `pytorch/goals.md`:
  - This source-of-truth document for branch goals and acceptance criteria.

## Milestones
1. Implement minimal training script with default dataset.
2. Run script end-to-end and confirm loss decreases at least modestly.
3. Generate sample completion from `User: hi\nAssistant:`.
4. Capture usage instructions in this goals doc and (if needed later) README notes.

## Acceptance Criteria
- Running:
  - `python3 pytorch/train_tiny_chat.py`
  - completes without code changes in a properly prepared environment with PyTorch installed.
- The script outputs:
  - periodic loss logs during training
  - one generated sample completion after training.
- The code path is simple enough for a first-time PyTorch learner to trace end-to-end in one sitting.

## Usage
Basic run:

```bash
python3 pytorch/train_tiny_chat.py
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

## Stretch Goals (only after acceptance criteria)
1. Add train/validation split and report both losses.
2. Upgrade from bigram to a tiny Transformer block.
3. Add model save/load for reproducible generation.
