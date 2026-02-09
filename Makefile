SHELL := /bin/bash

.PHONY: curl-test
.PHONY: playwright-test

curl-test:
	@set -euo pipefail; \
	cd flaskdashboard; \
	echo "==> Starting Flask server for curl-test"; \
	venv=".venv"; \
	python_bin="python3"; \
	if [ -x "$$venv/bin/python" ]; then \
		echo "==> Using existing venv: $$venv"; \
		python_bin="$$venv/bin/python"; \
	else \
		echo "==> Creating venv: $$venv"; \
		python3 -m venv "$$venv"; \
	fi; \
	if ! "$$python_bin" -m pip show flask >/dev/null 2>&1; then \
		echo "==> Installing Python dependencies"; \
		"$$python_bin" -m pip install -r requirements.txt >/tmp/flaskdashboard-install.log 2>&1; \
	fi; \
	echo "==> Launching Flask"; \
	FLASK_APP=app "$$python_bin" -m flask run --no-reload --port 5000 >/tmp/flaskdashboard.log 2>&1 & \
	pid=$$!; \
	trap 'echo "==> Stopping Flask (pid $$pid)"; kill $$pid >/dev/null 2>&1 || true' EXIT; \
	for _ in {1..20}; do \
		if curl -sf http://127.0.0.1:5000/health >/dev/null; then break; fi; \
		sleep 0.25; \
	done; \
	echo "==> Running happy-path curls"; \
	curl -sf http://127.0.0.1:5000/health >/dev/null; \
	curl -sf http://127.0.0.1:5000/api/widgets >/dev/null; \
	curl -sf http://127.0.0.1:5000/api/runtime-config >/dev/null; \
	curl -sf http://127.0.0.1:5000/api/telemetry >/dev/null; \
	curl -sf http://127.0.0.1:5000/telemetry.csv >/dev/null; \
	echo "==> curl-test passed"

playwright-test:
	@./make-playwright-test.sh
