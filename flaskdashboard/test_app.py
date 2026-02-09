import json
import unittest
from unittest.mock import patch

from app import FALLBACK_CSV, app


class DummyResponse:
    def __init__(self, payload):
        self._payload = payload

    def read(self):
        return self._payload

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc, tb):
        return False


class TelemetryCsvTests(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()

    def test_telemetry_csv_success(self):
        payload = {
            "status": "success",
            "data": {
                "result": [
                    {
                        "metric": {"job": "demo", "instance": "demo-1"},
                        "values": [[1700000000.0, "1.23"]],
                    }
                ]
            },
        }
        encoded = json.dumps(payload).encode("utf-8")

        with patch("app.urlopen", return_value=DummyResponse(encoded)):
            response = self.client.get("/telemetry.csv")

        self.assertEqual(response.status_code, 200)
        text = response.data.decode("utf-8")
        lines = [line for line in text.splitlines() if line.strip()]
        self.assertGreaterEqual(len(lines), 2)
        self.assertEqual(lines[0], "timestamp_iso,metric_labels,value")

    def test_telemetry_csv_fallback_on_failure(self):
        with patch("app.urlopen", side_effect=RuntimeError("boom")):
            response = self.client.get("/telemetry.csv")

        self.assertEqual(response.status_code, 200)
        text = response.data.decode("utf-8")
        self.assertEqual(text, FALLBACK_CSV)


if __name__ == "__main__":
    unittest.main()
