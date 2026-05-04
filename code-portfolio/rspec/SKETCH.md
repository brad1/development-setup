# TLDR;
Example mimimal setup instructions from codex-gpt-5.5

# Ruby + RSpec Barebones Setup
Minimal starter project for running RSpec in this folder.

## Install Ruby

Ruby was not installed in the current environment when this project was scaffolded, and system package installation is not permitted from this session. Install Ruby on the machine first.

On Ubuntu or Debian:

```bash
sudo apt-get update
sudo apt-get install -y ruby-full
```

Confirm the toolchain:

```bash
ruby -v
bundle -v
```

## Install project dependencies

From this folder:

```bash
bundle install
```

## Run tests

All test execution should go through the wrapper script:

```bash
./scripts/ci-test.sh
```

Run a single spec file:

```bash
./scripts/ci-test.sh spec/example_spec.rb
```

## Project layout

- `Gemfile` installs `rspec`
- `.rspec` sets default RSpec CLI options
- `spec/spec_helper.rb` contains baseline RSpec configuration
- `spec/example_spec.rb` is a starter passing spec
- `scripts/ci-test.sh` is the required test entrypoint
