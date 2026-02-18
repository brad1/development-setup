#!/usr/bin/env python3
import argparse
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


    @torch.no_grad() # agent: explain this line
    def generate(self, idx: torch.Tensor, max_new_tokens: int) -> torch.Tensor:
        for _ in range(max_new_tokens):
            # agent: extract function
            logits, _ = self(idx)
            next_token_logits = logits[:, -1, :]
            probs = F.softmax(next_token_logits, dim=-1)
            next_idx = torch.multinomial(probs, num_samples=1)
            idx = torch.cat((idx, next_idx), dim=1)
        return idx


def load_text(path: Path | None) -> str:
    if path is None:
        return DEFAULT_DATA
    return path.read_text(encoding="utf-8")


def build_vocab(text: str):
    chars = sorted(set(text))
    stoi = {ch: i for i, ch in enumerate(chars)}
    itos = {i: ch for i, ch in enumerate(chars)}
    return stoi, itos # agent: explain acronym


def encode(text: str, stoi: dict[str, int]) -> torch.Tensor:
    return torch.tensor([stoi[c] for c in text], dtype=torch.long)


def decode(tokens: torch.Tensor, itos: dict[int, str]) -> str:
    return "".join(itos[int(i)] for i in tokens)


# agent: better name, get batch of what?
def get_batch(data: torch.Tensor, batch_size: int, block_size: int, device: torch.device):
    ix = torch.randint(len(data) - block_size - 1, (batch_size,))
    x = torch.stack([data[i : i + block_size] for i in ix]).to(device)
    y = torch.stack([data[i + 1 : i + block_size + 1] for i in ix]).to(device)
    return x, y


def train(args):
    # agent: extract function select device
    torch.manual_seed(args.seed)
    if args.device == "cuda":
        device = torch.device("cuda")
    elif args.device == "auto":
        device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    else:
        device = torch.device("cpu")

    # agent: extract function, populate context object
    text = load_text(args.data)
    stoi, itos = build_vocab(text)
    data = encode(text, stoi)

    model = BigramLanguageModel(vocab_size=len(stoi)).to(device)
    optimizer = torch.optim.AdamW(model.parameters(), lr=args.lr)

    for step in range(args.steps):
        # agent: extract function
        xb, yb = get_batch(data, args.batch_size, args.block_size, device)
        _, loss = model(xb, yb)
        optimizer.zero_grad(set_to_none=True)
        loss.backward()
        optimizer.step()
        if step % args.log_every == 0 or step == args.steps - 1:
            print(f"step {step:4d} | loss {loss.item():.4f}")

    # agent: explain better
    prompt = args.prompt
    if not prompt:
        prompt = "User: hi\nAssistant:"
    start = encode(prompt, stoi).unsqueeze(0).to(device)
    out = model.generate(start, max_new_tokens=args.max_new_tokens)[0].cpu()
    print("\n--- sample ---")
    print(decode(out, itos))


def parse_args():
    # agent: extract a couple functions, arrange by category
    parser = argparse.ArgumentParser(description="Train the smallest possible chat-like model in PyTorch.")
    parser.add_argument("--data", type=Path, default=None, help="Optional path to training text.")
    parser.add_argument("--steps", type=int, default=500)
    parser.add_argument("--batch-size", type=int, default=16)
    parser.add_argument("--block-size", type=int, default=32)
    parser.add_argument("--lr", type=float, default=1e-2)
    parser.add_argument("--seed", type=int, default=1337)
    parser.add_argument("--log-every", type=int, default=100)
    parser.add_argument("--prompt", type=str, default="")
    parser.add_argument("--max-new-tokens", type=int, default=80)
    parser.add_argument("--device", choices=["cpu", "cuda", "auto"], default="cpu")
    return parser.parse_args()


if __name__ == "__main__":
    train(parse_args())
