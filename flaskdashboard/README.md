# flaskdashboard

Minimal Flask backend used by the ReactDashboard project.

## Running locally

1. Create a venv and install dependencies.

```
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

2. Run the backend tests:

```
python -m unittest
```

`test_app.py` uses the standard library `unittest` runner, so `pytest` is not
required for the documented local flow.

3. Start the server:

```
FLASK_APP=app flask run --port 5000
```

4. In a second shell, start the React dashboard from `../ReactDashboard/`:

```
npm ci
npm test
npm run build
npm run dev -- --host 127.0.0.1 --port 4173
```

The backend serves `GET /api/widgets`, `GET /api/runtime-config`,
`GET /api/telemetry`, `GET /api/telemetry.csv`, and `GET /health`. The React
frontend currently consumes `GET /api/widgets`, and the other endpoints are a
draft to support the runtime config and telemetry table if you wire them up
later. The frontend defaults to `VITE_API_URL=http://localhost:5000`.
