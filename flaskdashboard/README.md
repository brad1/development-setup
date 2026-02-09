# flaskdashboard

Minimal Flask backend used by the ReactDashboard project.

## Running locally

1. Create a venv and install dependencies.

```
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

2. Start the server:

```
FLASK_APP=app flask run --port 5000
```

The backend serves `GET /api/widgets`, `GET /api/runtime-config`, `GET /api/telemetry`, `GET /api/telemetry.csv`, and `GET /health`. The React frontend currently consumes `GET /api/widgets`, and the other endpoints are a draft to support the runtime config and telemetry table if you wire them up later.
