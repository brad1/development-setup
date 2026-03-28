# Train Tiny Chat Quiz

## Quiz
1. What class implements the token-prediction model used in the script, and which PyTorch module provides the main parameters?
2. How does the script handle the training targets (`y` batch) relative to the input tokens (`x` batch)?
3. What command-line flag controls whether the script should attempt to use CUDA, and how does the script decide what to do when this flag is set to `auto`?
4. Which helper function constructs the vocabulary dictionaries, and what are the names and meanings of the two returned mappings?
5. Where does the script get its training text if the user does not pass `--data`, and what format does that default text follow?
6. Briefly describe how a batch of training tokens is sampled, including how the block size is used.
7. What does the `--debug` flag enable, and which helper configures the logging level?
8. After training completes, how does the script generate a sample completion, starting from the prompt?

## Answer Key
1. `BigramLanguageModel` builds the model; it uses `nn.Embedding` to store the (vocab_size × vocab_size) logits table. (`train_tiny_chat.py` class definition)
2. The target tensor `y` is constructed by shifting `x` one token to the right (`data[i + 1 : i + block_size + 1]`), so each example predicts the next token. (`sample_training_batch`)
3. The `--device` flag accepts `cpu`, `cuda`, or `auto`. When `auto` is chosen, `resolve_device` checks `torch.cuda.is_available()` and picks CUDA if available, otherwise CPU. (`add_runtime_args`, `resolve_device`)
4. `build_vocab` creates the dictionaries. It returns `stoi` (string-to-index map) and `itos` (index-to-string map). (`build_vocab`)
5. If `--data` is unset, `load_text` returns `DEFAULT_DATA`, which is a short inline dialogue with alternating `User:`/`Assistant:` turns. (`DEFAULT_DATA`, `load_text`)
6. `sample_training_batch` selects `batch_size` random starting positions (`ix`), then slices `block_size` tokens for `x` and the immediately following tokens for `y`, ensuring contiguous sequences. (`sample_training_batch`)
7. `--debug` turns on `logging.DEBUG`, and `configure_logging` sets the format and level based on that flag. (`add_runtime_args`, `configure_logging`)
8. The script encodes the prompt, moves it to the device, then calls `model.generate` to append `max_new_tokens` tokens using `_sample_next_token`; the result is decoded back to text. (`train`, `encode`, `model.generate`, `decode`)
