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

The backend serves `GET /api/widgets` and `GET /health`, so the frontend can fetch `/api/widgets` (or proxy via React dev server) for panel data.
