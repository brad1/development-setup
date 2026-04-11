# example run

```
dir='/opt/chef/cookbooks'
mkdir -p $dir && cd $dir
git clone git@github.com:brad1/development-setup.git
sudo bash --login -c 'rvm use 2.4.1; chef-solo -c /opt/chef/cookbooks/development-setup/solo.rb'
```
## Project Index

### Dashboard projects

- `ReactDashboard/` - React/Vite dashboard frontend. Run `bash codex/setup.sh`
  and `bash scripts/ci-test.sh` from the repository root to mirror CI and Codex
  cloud automation. Start the dev server with `npm run dev -- --host 127.0.0.1 --port 4173`
  after the backend is running.
- `flaskdashboard/` - minimal Flask API backend for the dashboard. See
  `flaskdashboard/README.md` for the venv setup, test command, startup
  instructions, and available API routes.

#### Project map

- `notes/dashboard-ui-components.md` - partial design document focused
  exclusively on the currently visible required UI components in the dashboard
  source code.

### Standalone demos

- `agent-orchestration/` - minimal OpenAI Agent SDK hello-world outline that reads local filenames, plans a web query, and runs a web-search-enabled agent.
- `cat-mode/` - Windows "Cat Mode" application design package, including architecture notes, state-machine behavior, and implementation snippets for camera-based cat detection plus temporary keyboard suppression.
- `cpp/` - standalone C++ examples and modules, including the sample
  `main.cpp` entry point and a local `Makefile`.
- `rust/` - standalone Rust utility and demo code.
- `pytorch/` - "Tiny Chat" trains models from simplest possible training data patterns (coin, markov) with the fewest possible layers

### Chef cookbook

- `attributes/` - default configuration attributes for the cookbook.
- `files/` - helper scripts, configuration, and notes used by the cookbook.
  See `files/etc/README.md`, `files/docs/DECISIONS.md`, and `files/zsh/README.md`
  for focused details.
- `recipes/` - main Chef recipes to configure different platforms.
- `templates/` - template files for configuration (e.g. `zshrc.erb`).
- `tools/` - utility scripts such as Ruby analysis helpers.
- `node.json` and `node_windows.json` - sample node attribute files.
- `solo.rb` and `solo_windows.rb` - Chef solo configuration.
- `run.sh` and `run.cmd` - helper scripts to run the cookbook on Linux or Windows.
- `metadata.rb` - cookbook metadata.
- `init.sh` - example bootstrap script.
- `quick-start.sh` - bootstrap the oh-my-zsh setup from this repository without Chef.

## Quick start

To install the zsh configuration without running Chef, clone the repository and
execute the helper script:

```
git clone git@github.com:brad1/development-setup.git
cd development-setup
./quick-start.sh
```

The script installs oh-my-zsh, pulls the recommended plugins (fzf, autosuggestions,
syntax highlighting, and the powerlevel10k theme), and writes a `.zshrc` that
sources the configuration in `files/zsh/`. Your previous `.zshrc` is backed up
with a timestamped suffix if it existed.

## Dashboard notes

`flaskdashboard/README.md` covers how to create the local virtual environment,
install `flaskdashboard/requirements.txt`, run the backend tests with
`python -m unittest`, and start the API with `FLASK_APP=app flask run --port 5000`.
The API exposes `GET /api/widgets`, `GET /api/runtime-config`,
`GET /api/simple-telemetry`, `GET /api/telemetry`, `GET /api/telemetry.csv`,
and `GET /health`. The telemetry endpoints now derive their data from standard
Ubuntu shell tools such as `uptime`, `free`, `df`, `ip`, and `ps`. Ignore the
repository-local virtual environment with `.gitignore` so you can keep a
per-machine copy without making commits.

To mirror `.github/workflows/reactdashboard-ci.yml` and Codex cloud task bootstrapping, run the shared repository scripts from the repository root:

```
bash codex/setup.sh
bash scripts/ci-test.sh
```

`codex/setup.sh` performs deterministic dependency installation for `ReactDashboard/` and `scripts/ci-test.sh` runs the canonical test/build sequence (`npm test` then `npm run build`). These are the exact same scripts used by GitHub Actions and Codex cloud configuration, so successful local runs should match automation behavior. Codex caching is implicit, time-scoped container reuse, not configurable dependency caching like GitHub Actions. The setup step requires registry access, so if the npm registry is unreachable because of DNS or proxy restrictions reconcile that first; otherwise installation will fail with network errors.

After the install step succeeds, start the backend from `flaskdashboard/`, then
run the React dev server from `ReactDashboard/`:

```
cd flaskdashboard
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python -m unittest
FLASK_APP=app flask run --port 5000
```

Open a second shell for the frontend:

```
cd ReactDashboard
npm run dev -- --host 127.0.0.1 --port 4173
```

The React app points at the local Flask backend with `VITE_API_URL`
(default `http://localhost:5000`), which you can override in your shell or in
`ReactDashboard/.env.local`. The front end also reads
`/runtime-config.json` from `ReactDashboard/public/` for optional knobs, so
keep that file in sync between environments. Build-time discovery also scans
for files matching `src/mydash*.*`; keep those files as plain text assets so
they remain safe to include in the Vite bundle metadata.

## Notes on Codex pull requests

See `notes/codex-pr-notes.md` for a summary of the Codex-authored pull requests (#34 and #35) and the areas they touched.
