#!/usr/bin/env python3
import argparse
from dataclasses import dataclass
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


class BigramLanguageModel(nn.Module):
    def __init__(self, vocab_size: int) -> None:
        super().__init__()
        self.table = nn.Embedding(vocab_size, vocab_size)

    def forward(self, idx: torch.Tensor, targets: torch.Tensor | None = None):
        logits = self.table(idx)
        loss = None
        if targets is not None:
            b, t, c = logits.shape
            loss = F.cross_entropy(logits.view(b * t, c), targets.view(b * t))
        return logits, loss

    def _sample_next_token(self, idx: torch.Tensor) -> torch.Tensor:
        logits, _ = self(idx)
        next_token_logits = logits[:, -1, :]
        probs = F.softmax(next_token_logits, dim=-1)
        return torch.multinomial(probs, num_samples=1)

    # Disable gradient tracking during inference to reduce memory use and speed up sampling.
    @torch.no_grad()
    def generate(self, idx: torch.Tensor, max_new_tokens: int) -> torch.Tensor:
        for _ in range(max_new_tokens):
            next_idx = self._sample_next_token(idx)
            idx = torch.cat((idx, next_idx), dim=1)
        return idx


def load_text(path: Path | None) -> str:
    if path is None:
        return DEFAULT_DATA
    return path.read_text(encoding="utf-8")


def build_vocab(text: str):
    chars = sorted(set(text))
    # "stoi" and "itos" are common LM acronyms:
    # string-to-index and index-to-string lookup tables.
    stoi = {ch: i for i, ch in enumerate(chars)}
    itos = {i: ch for i, ch in enumerate(chars)}
    return stoi, itos


def encode(text: str, char_to_idx: dict[str, int]) -> torch.Tensor:
    return torch.tensor([char_to_idx[c] for c in text], dtype=torch.long)


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
    if device_arg == "cuda":
        return torch.device("cuda")
    if device_arg == "auto":
        return torch.device("cuda" if torch.cuda.is_available() else "cpu")
    return torch.device("cpu")


def build_training_context(data_path: Path | None) -> TrainingDataContext:
    text = load_text(data_path)
    char_to_idx, idx_to_char = build_vocab(text)
    data = encode(text, char_to_idx)
    return TrainingDataContext(
        text=text, char_to_idx=char_to_idx, idx_to_char=idx_to_char, data=data
    )


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
    if prompt:
        return prompt
    return "User: hi\nAssistant:"


def train(args):
    torch.manual_seed(args.seed)
    device = resolve_device(args.device)
    context = build_training_context(args.data)

    model = BigramLanguageModel(vocab_size=len(context.char_to_idx)).to(device)
    optimizer = torch.optim.AdamW(model.parameters(), lr=args.lr)

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

    prompt = resolve_prompt(args.prompt)
    start = encode(prompt, context.char_to_idx).unsqueeze(0).to(device)
    out = model.generate(start, max_new_tokens=args.max_new_tokens)[0].cpu()
    print("\n--- sample ---")
    print(decode(out, context.idx_to_char))


def add_data_args(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--data", type=Path, default=None, help="Optional path to training text.")


def add_training_args(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--steps", type=int, default=500)
    parser.add_argument("--batch-size", type=int, default=16)
    parser.add_argument("--block-size", type=int, default=32)
    parser.add_argument("--lr", type=float, default=1e-2)
    parser.add_argument("--seed", type=int, default=1337)
    parser.add_argument("--log-every", type=int, default=100)


def add_generation_args(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--prompt", type=str, default="")
    parser.add_argument("--max-new-tokens", type=int, default=80)


def add_runtime_args(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--device", choices=["cpu", "cuda", "auto"], default="cpu")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Train the smallest possible chat-like model in PyTorch."
    )
    add_data_args(parser)
    add_training_args(parser)
    add_generation_args(parser)
    add_runtime_args(parser)
    return parser.parse_args()


if __name__ == "__main__":
    train(parse_args())
