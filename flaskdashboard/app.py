import csv
import io
import json
import os
import time
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import urlopen

from flask import Flask, Response, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

WIDGETS = [
    {"id": 1, "title": "Ingress::Active Users", "value": 1825, "trend": "+4%"},
    {"id": 2, "title": "Queues::Queued Jobs", "value": 48, "trend": "-2%"},
    {"id": 3, "title": "Errors::Pager Triggers", "value": 3, "trend": "stable"},
    {"id": 4, "title": "Cache::Redis Hit Rate", "value": "98.2%", "trend": "+0.3%"},
    {"id": 5, "title": "Compute::GPU Nodes", "value": 14, "trend": "steady"},
    {"id": 6, "title": "Observability::Trace Ingest", "value": "4.2M/min", "trend": "+1.1%"},
]

RUNTIME_CONFIG = {
    "runtimeMessage": "Runtime config loaded",
    "highlightKnob": True,
    "popoverText": "Change this, content on page updates on refresh",
}

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_TELEMETRY_PATH = REPO_ROOT / "ReactDashboard" / "src" / "table.csv"
PROMETHEUS_URL_DEFAULT = "http://localhost:9090"
PROMETHEUS_QUERY_DEFAULT = "rate(demo_requests_total[1m])"
PROMETHEUS_RANGE_SECONDS = 600
PROMETHEUS_STEP_SECONDS = 5

FALLBACK_CSV = "\n".join(
    [
        "timestamp_iso,metric_labels,value",
        "2026-02-09T14:00:00+00:00,{\"job\":\"demo\",\"instance\":\"demo-1\"},12.5",
        "2026-02-09T14:00:05+00:00,{\"job\":\"demo\",\"instance\":\"demo-1\"},14.1",
        "2026-02-09T14:00:10+00:00,{\"job\":\"demo\",\"instance\":\"demo-2\"},9.8",
    ]
)


def _read_telemetry_csv():
    path = Path(os.environ.get("TELEMETRY_CSV_PATH", DEFAULT_TELEMETRY_PATH))
    try:
        return path.read_text(encoding="utf-8"), None
    except FileNotFoundError:
        return None, f"telemetry file not found: {path}"
    except OSError as exc:
        return None, f"telemetry file error: {exc}"


def _parse_csv(text):
    reader = csv.reader(io.StringIO(text))
    rows = list(reader)
    if not rows:
        return {"headers": [], "rows": []}
    headers = rows[0]
    data_rows = [row + [""] * (len(headers) - len(row)) for row in rows[1:]]
    return {"headers": headers, "rows": data_rows}


def _prometheus_query_range_csv():
    base_url = os.environ.get("PROMETHEUS_URL", PROMETHEUS_URL_DEFAULT).rstrip("/")
    query = os.environ.get("PROMETHEUS_QUERY", PROMETHEUS_QUERY_DEFAULT)
    end = time.time()
    start = end - PROMETHEUS_RANGE_SECONDS

    params = urlencode(
        {
            "query": query,
            "start": f"{start:.3f}",
            "end": f"{end:.3f}",
            "step": str(PROMETHEUS_STEP_SECONDS),
        }
    )
    url = f"{base_url}/api/v1/query_range?{params}"

    with urlopen(url, timeout=5) as response:
        payload = response.read()

    data = json.loads(payload.decode("utf-8"))
    if data.get("status") != "success":
        raise RuntimeError("prometheus status not success")

    result = data.get("data", {}).get("result", [])
    if not result:
        raise RuntimeError("prometheus result empty")

    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["timestamp_iso", "metric_labels", "value"])

    wrote_row = False
    for series in result:
        labels = series.get("metric", {})
        values = series.get("values", [])
        if not isinstance(labels, dict):
            labels = {}
        label_json = json.dumps(labels, sort_keys=True, separators=(",", ":"))
        for ts, value in values:
            timestamp = datetime.fromtimestamp(float(ts), tz=timezone.utc).isoformat()
            writer.writerow([timestamp, label_json, value])
            wrote_row = True

    if not wrote_row:
        raise RuntimeError("prometheus result has no samples")

    return output.getvalue().strip("\n")

@app.route("/api/widgets")
def widgets():
    return jsonify({"widgets": WIDGETS})

@app.route("/api/runtime-config")
def runtime_config():
    return jsonify(RUNTIME_CONFIG)

@app.route("/api/telemetry")
def telemetry():
    text, error = _read_telemetry_csv()
    if error:
        return jsonify({"error": error}), 500
    return jsonify(_parse_csv(text))

@app.route("/api/telemetry.csv")
def telemetry_csv():
    text, error = _read_telemetry_csv()
    if error:
        return jsonify({"error": error}), 500
    return Response(text, mimetype="text/csv")

@app.route("/telemetry.csv")
def telemetry_prometheus_csv():
    try:
        csv_text = _prometheus_query_range_csv()
    except Exception as exc:
        app.logger.error("telemetry.csv fallback: %s", exc)
        csv_text = FALLBACK_CSV

    response = Response(csv_text, mimetype="text/csv")
    response.headers["Content-Disposition"] = 'attachment; filename="telemetry.csv"'
    return response

@app.route("/health")
def health():
    return "ok", 200

if __name__ == "__main__":
    app.run(port=5000, debug=True)
