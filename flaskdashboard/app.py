from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

WIDGETS = [
    {"id": 1, "title": "Active Users", "value": 1825, "trend": "+4%"},
    {"id": 2, "title": "Queued Jobs", "value": 48, "trend": "-2%"},
    {"id": 3, "title": "Errors", "value": 3, "trend": "stable"},
    {"id": 4, "title": "Test::Convention", "value": 1, "trend": "added double colons to trigger a pattern match"},
]

@app.route("/api/widgets")
def widgets():
    return jsonify({"widgets": WIDGETS})

@app.route("/health")
def health():
    return "ok", 200

if __name__ == "__main__":
    app.run(port=5000, debug=True)
