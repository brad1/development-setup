# tiny_transformer_lm.py
# Smallest educational example:
# Embedding → TransformerEncoderLayer → Linear → next-token prediction


# See: 'The lm_head is the bridge from "hidden state" to "vocabulary". '
# 
# Details:
#
# If you remove the nn.Linear head, 
# the transformer outputs vectors of size d_model instead of vocab_size, 
# so you no longer have logits over the vocabulary and cannot compute next-token probabilities with cross-entropy.
#
# nn.Linear(d_model, vocab_size) is a learned weight matrix that projects each d_model vector 
# into vocab_size scores (logits), one per token in the vocabulary. 
# From there, softmax gives probabilities, and cross-entropy measures prediction quality.

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

# default
steps = 400
lr = 1e-3
# loss 0.1196, meg

# longer, loss stagnates from newton's method overshooting the target
# steps = 4000
# lr = 1e-3

# longer, slower, loss should get closer to the ideal value 
# lr = 1e-3 - 1e-4

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

        # dimensionality of layer input/output
        # (1) vocab_size --> d_model, (2) d_model --> d_model (3) d_model --> vocab_size
        # See dm_model=d_model below

        # (1)
        # Map a token in the vocab to its learned embedding vector
        self.embed = nn.Embedding(vocab_size, d_model)

        # (2)
        # The transformer outputs a hidden state vector (size d_model) per token in the sequence
        self.block = nn.TransformerEncoderLayer(
            d_model=d_model, # see comment at top of this function 
            nhead=nhead,
            dim_feedforward=dim_ff,
            batch_first=True
        )
    

        # (3)
        # The lm_head is the bridge from "hidden state" to "vocabulary".
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
