# tiny_transformer_lm.py
# Smallest educational example:
# Embedding → TransformerEncoderLayer → Linear → next-token prediction

import torch
import torch.nn as nn
import torch.nn.functional as F

# ------------------------------------------------------------
# Small default training corpus
# ------------------------------------------------------------

DEFAULT_DATA = """
hello world
hello transformer
tiny models are fun
hello tiny world
"""

# ------------------------------------------------------------
# Data preparation
# ------------------------------------------------------------

text = DEFAULT_DATA.lower()

chars = sorted(list(set(text)))
vocab_size = len(chars)

stoi = {ch: i for i, ch in enumerate(chars)}
itos = {i: ch for ch, i in stoi.items()}

encode = lambda s: torch.tensor([stoi[c] for c in s], dtype=torch.long)
decode = lambda t: "".join([itos[int(i)] for i in t])

data = encode(text)

# ------------------------------------------------------------
# Hyperparameters
# ------------------------------------------------------------

block_size = 16
batch_size = 8
d_model = 32
nhead = 4
dim_ff = 64
steps = 400
lr = 1e-3

# ------------------------------------------------------------
# Batch sampling
# ------------------------------------------------------------

def get_batch():
    ix = torch.randint(len(data) - block_size - 1, (batch_size,))
    x = torch.stack([data[i:i+block_size] for i in ix])
    y = torch.stack([data[i+1:i+block_size+1] for i in ix])
    return x, y

# ------------------------------------------------------------
# Model
# ------------------------------------------------------------

class TinyTransformerLM(nn.Module):

    def __init__(self, vocab_size):
        super().__init__()

        self.embed = nn.Embedding(vocab_size, d_model)

        self.block = nn.TransformerEncoderLayer(
            d_model=d_model,
            nhead=nhead,
            dim_feedforward=dim_ff,
            batch_first=True
        )

        self.lm_head = nn.Linear(d_model, vocab_size)

    def forward(self, idx, targets=None):

        B, T = idx.shape

        x = self.embed(idx)                     # (B,T,C)

        # causal mask
        mask = torch.triu(torch.ones(T, T), 1).bool()

        x = self.block(x, src_mask=mask)

        logits = self.lm_head(x)                # (B,T,V)

        loss = None
        if targets is not None:
            loss = F.cross_entropy(
                logits.view(B*T, vocab_size),
                targets.view(B*T)
            )

        return logits, loss


# ------------------------------------------------------------
# Training
# ------------------------------------------------------------

model = TinyTransformerLM(vocab_size)
opt = torch.optim.AdamW(model.parameters(), lr=lr)

for step in range(steps):

    xb, yb = get_batch()

    logits, loss = model(xb, yb)

    opt.zero_grad()
    loss.backward()
    opt.step()

    if step % 50 == 0:
        print(f"step {step} loss {loss.item():.4f}")

# ------------------------------------------------------------
# Sampling
# ------------------------------------------------------------

def generate(model, start="h", length=100):

    idx = encode(start).unsqueeze(0)

    for _ in range(length):

        idx_cond = idx[:, -block_size:]

        logits, _ = model(idx_cond)

        probs = F.softmax(logits[:, -1, :], dim=-1)

        next_token = torch.multinomial(probs, num_samples=1)

        idx = torch.cat([idx, next_token], dim=1)

    return decode(idx[0])

print("\n--- sample ---")
print(generate(model, "h", 120))
