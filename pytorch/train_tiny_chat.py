#!/usr/bin/env python3


# README
# This is a character-level bigram model: it learns P(next_char | current_char).
# TLDR; tt can mimic local character transitions (e.g., after A often comes s in “Assistant”) 
# but cannot reliably track longer structures like “User:” → “Assistant:” turns beyond immediate character adjacency.
# 
# See: "Output examples:" below
# See: "Single Layer Model explanation" below


# Output examples:
# 
# -------------------------------
# # Using DEFAULT_DATA
#
# > python3 ./train_tiny_chat.py
# step    0 | loss 3.5221
# step  100 | loss 2.2406
# ...
# step  499 | loss 1.0722
# 
# Why not zero loss for a simple P() distribution?
# * trains on sample slices instead of whole text
# * slices out of context, no attention layer
# * Next char is non-deterministic
# 
# -------------------------------
# # Using ./deterministic_data.txt
#
# > python3 ./train_tiny_chat.py --data ./deterministic_data.txt --steps 100000 
# # step 15300 | loss 0.0000


import argparse
from dataclasses import dataclass
import logging
import warnings
from pathlib import Path

import torch
import torch.nn as nn
import torch.nn.functional as F

# Suppress noisy CUDA probe warnings on systems running CPU-only training.
warnings.filterwarnings(
    "ignore",
    message=r"CUDA initialization: Unexpected error from cudaGetDeviceCount.*",
)


DEFAULT_DATA = """User: hi
Assistant: hello

User: how are you?
Assistant: i am good.

User: what is 2+2?
Assistant: 4
"""

logger = logging.getLogger(__name__)


class BigramLanguageModel(nn.Module):
    def __init__(self, vocab_size: int) -> None:
        super().__init__()

        # Single Layer Model explanation: 
        #
        # nn.Embedding(vocab_size, vocab_size) is simultaneously the optimized replacement
        # for a one-hot × weight-matrix multiply and the actual parameter matrix that
        # stores the logits for P(next_char | current_char).
        #
        # Each row corresponds to one current token and contains scores for every
        # possible next token.
        #
        # before softmax:
        # * the row contains raw logits (unnormalized floating-point scores)
        # * values may be positive or negative
        # * they do NOT sum to 1 and are not yet probabilities
        # * not integer tally marks, that wouldn't work with backprop
        #
        # after softmax:
        # * the row is converted into a probability distribution
        # * all values are in [0,1]
        # * the values sum to 1.0
        #
        # Example (after softmax):
        # P(next_char | current_char='A')
        #   A: 0.50
        #   B: 0.50
        #   C: 0.00
        #   ...
        #   Z: 0.00
        #
        # Interpretation:
        # if the current character is 'A', the model predicts the next character
        # according to this probability distribution.  Note: not the optimal bigram
		# distribution across the whole training text, model is trained on slices of the text

        self.table = nn.Embedding(vocab_size, vocab_size)

    # POI called under the hood by model() to calculate loss gradient
    def forward(self, idx: torch.Tensor, targets: torch.Tensor | None = None):
        logits = self.table(idx)
        loss = None
        if targets is not None:
            b, t, c = logits.shape
            loss = F.cross_entropy(logits.view(b * t, c), targets.view(b * t))
        return logits, loss

    # POI generate (not predict) next token
    def _sample_next_token(self, idx: torch.Tensor) -> torch.Tensor:
        logits, _ = self(idx)
        next_token_logits = logits[:, -1, :]
        probs = F.softmax(next_token_logits, dim=-1)
        return torch.multinomial(probs, num_samples=1)

    # POI respond to a prompt
    # 
    # Disable gradient tracking during inference to reduce memory use and speed up sampling.
    @torch.no_grad()
    def generate(self, idx: torch.Tensor, max_new_tokens: int) -> torch.Tensor:
        logger.debug("generate: sampling %d new tokens", max_new_tokens)
        for _ in range(max_new_tokens):
            next_idx = self._sample_next_token(idx)
            idx = torch.cat((idx, next_idx), dim=1)
        return idx


def load_text(path: Path | None) -> str:
    logger.debug("load_text: path=%s", path)
    if path is None:
        logger.debug("load_text: using built-in default dataset")
        return DEFAULT_DATA
    logger.debug("load_text: reading dataset from file")
    return path.read_text(encoding="utf-8")


# POI establish what tokens are in play
def build_vocab(text: str):
    logger.debug("build_vocab: text_length=%d", len(text))
    chars = sorted(set(text))
    # "stoi" and "itos" are common LM acronyms:
    # string-to-index and index-to-string lookup tables.
    stoi = {ch: i for i, ch in enumerate(chars)}
    itos = {i: ch for i, ch in enumerate(chars)}
    logger.debug("build_vocab: vocab_size=%d", len(chars))
    return stoi, itos


# POI plaintext --> tokens
def encode(text: str, char_to_idx: dict[str, int]) -> torch.Tensor:
    return torch.tensor([char_to_idx[c] for c in text], dtype=torch.long)


# POI tokens --> plaintext (turn generated content into readable text)
def decode(tokens: torch.Tensor, idx_to_char: dict[int, str]) -> str:
    return "".join(idx_to_char[int(i)] for i in tokens)

def sample_training_batch(
    data: torch.Tensor, batch_size: int, block_size: int, device: torch.device
) -> tuple[torch.Tensor, torch.Tensor]:
    # Random contiguous token windows and their one-step-shifted targets.
    ix = torch.randint(len(data) - block_size - 1, (batch_size,))
    x = torch.stack([data[i : i + block_size] for i in ix]).to(device)
    y = torch.stack([data[i + 1 : i + block_size + 1] for i in ix]).to(device)
    return x, y


@dataclass(frozen=True)
class TrainingDataContext:
    text: str
    char_to_idx: dict[str, int]
    idx_to_char: dict[int, str]
    data: torch.Tensor


def resolve_device(device_arg: str) -> torch.device:
    logger.debug("resolve_device: requested=%s", device_arg)
    if device_arg == "cuda":
        logger.debug("resolve_device: selected CUDA explicitly")
        return torch.device("cuda")
    if device_arg == "auto":
        if torch.cuda.is_available():
            logger.debug("resolve_device: auto-selected CUDA")
            return torch.device("cuda")
        logger.debug("resolve_device: auto-selected CPU because CUDA is unavailable")
        return torch.device("cpu")
    logger.debug("resolve_device: selected CPU explicitly")
    return torch.device("cpu")


def build_training_context(data_path: Path | None) -> TrainingDataContext:
    logger.debug("build_training_context: data_path=%s", data_path)
    text = load_text(data_path)
    char_to_idx, idx_to_char = build_vocab(text)
    data = encode(text, char_to_idx)
    logger.debug(
        "build_training_context: text_len=%d vocab_size=%d token_count=%d",
        len(text),
        len(char_to_idx),
        len(data),
    )
    return TrainingDataContext(
        text=text, char_to_idx=char_to_idx, idx_to_char=idx_to_char, data=data
    )


# POI one backprop pass
def train_step(
    model: BigramLanguageModel,
    optimizer: torch.optim.Optimizer,
    data: torch.Tensor,
    batch_size: int,
    block_size: int,
    device: torch.device,
) -> float:
    xb, yb = sample_training_batch(data, batch_size, block_size, device)
    _, loss = model(xb, yb)
    optimizer.zero_grad(set_to_none=True)
    loss.backward()
    optimizer.step()
    return float(loss.item())


def resolve_prompt(prompt: str) -> str:
    logger.debug("resolve_prompt: prompt_provided=%s", bool(prompt))
    if prompt:
        logger.debug("resolve_prompt: using provided prompt")
        return prompt
    logger.debug("resolve_prompt: using default prompt")
    return "User: hi\nAssistant:"


def configure_logging(debug: bool) -> None:
    level = logging.DEBUG if debug else logging.WARNING
    logging.basicConfig(level=level, format="%(levelname)s:%(name)s:%(message)s")
    logger.debug("configure_logging: debug_enabled=True")


def train(args):
    logger.debug("train: args=%s", args)
    torch.manual_seed(args.seed)
    device = resolve_device(args.device)
    context = build_training_context(args.data)

    model = BigramLanguageModel(vocab_size=len(context.char_to_idx)).to(device)
    optimizer = torch.optim.AdamW(model.parameters(), lr=args.lr)

    logger.debug("train: starting optimization loop for %d steps", args.steps)
    for step in range(args.steps):
        loss_value = train_step(
            model,
            optimizer,
            context.data,
            args.batch_size,
            args.block_size,
            device,
        )
        if step % args.log_every == 0 or step == args.steps - 1:
            print(f"step {step:4d} | loss {loss_value:.4f}")
    logger.debug("train: optimization loop complete")

    # POI inference pass
    prompt = resolve_prompt(args.prompt)
    start = encode(prompt, context.char_to_idx).unsqueeze(0).to(device)
    out = model.generate(start, max_new_tokens=args.max_new_tokens)[0].cpu()
    print("\n--- sample ---")
    print(decode(out, context.idx_to_char))

    if args.save_model:
        save_model_checkpoint(model, args.save_model)


# # # utility functions to control noise 

def add_data_args(parser: argparse.ArgumentParser) -> None:
    logger.debug("add_data_args: registering data arguments")
    parser.add_argument("--data", type=Path, default=None, help="Optional path to training text.")


def add_training_args(parser: argparse.ArgumentParser) -> None:
    logger.debug("add_training_args: registering training arguments")
    parser.add_argument("--steps", type=int, default=500)
    parser.add_argument("--batch-size", type=int, default=16)
    parser.add_argument("--block-size", type=int, default=32)
    parser.add_argument("--lr", type=float, default=1e-2)
    parser.add_argument("--seed", type=int, default=1337)
    parser.add_argument("--log-every", type=int, default=100)


def add_generation_args(parser: argparse.ArgumentParser) -> None:
    logger.debug("add_generation_args: registering generation arguments")
    parser.add_argument("--prompt", type=str, default="")
    parser.add_argument("--max-new-tokens", type=int, default=80)


def add_runtime_args(parser: argparse.ArgumentParser) -> None:
    logger.debug("add_runtime_args: registering runtime arguments")
    parser.add_argument("--device", choices=["cpu", "cuda", "auto"], default="cpu")
    parser.add_argument("--debug", action="store_true", help="Enable verbose debug logging.")
    parser.add_argument("--save-model", type=Path, default=None, help="Optional path to write model checkpoint.")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Train the smallest possible chat-like model in PyTorch."
    )
    add_data_args(parser)
    add_training_args(parser)
    add_generation_args(parser)
    add_runtime_args(parser)
    logger.debug("parse_args: parsing command-line arguments")
    return parser.parse_args()


def save_model_checkpoint(model: BigramLanguageModel, path: Path) -> None:
    logger.debug("save_model_checkpoint: target=%s", path)
    path.parent.mkdir(parents=True, exist_ok=True)
    torch.save(model.state_dict(), path)
    logger.info("Saved model checkpoint to %s", path)


if __name__ == "__main__":
    args = parse_args()
    configure_logging(args.debug)
    train(args)
