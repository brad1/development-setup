import unittest
from unittest.mock import patch

from app import app


SAMPLE_SNAPSHOT = {
    "timestamp_iso": "2026-03-28T23:30:00+00:00",
    "host": {
        "hostname": "ubuntu22-devbox",
        "kernel": "Linux 5.15.0-101-generic",
        "cpu_count": 8,
    },
    "uptime": {
        "pretty": "2 days, 4:33",
        "raw": "23:30:00 up 2 days, 4:33,  2 users,  load average: 0.20, 0.35, 0.41",
        "load": {"one": 0.2, "five": 0.35, "fifteen": 0.41},
    },
    "memory": {
        "total_bytes": 16777216000,
        "used_bytes": 8388608000,
        "available_bytes": 6291456000,
        "swap_total_bytes": 2147483648,
        "swap_used_bytes": 268435456,
    },
    "filesystems": [
        {
            "filesystem": "/dev/nvme0n1p2",
            "size_bytes": 999999,
            "used_bytes": 555555,
            "available_bytes": 444444,
            "use_percent": 55,
            "mount": "/",
        }
    ],
    "network_interfaces": [
        {"name": "lo", "state": "UNKNOWN", "addresses": ["127.0.0.1/8"]},
        {"name": "eth0", "state": "UP", "addresses": ["192.168.1.4/24"]},
    ],
    "top_processes": [
        {"pid": 101, "command": "python3", "cpu_percent": 12.5, "memory_percent": 3.1}
    ],
    "sources": {
        "uptime": "uptime",
        "memory": "free -b",
        "filesystems": "df -B1 -P --output=source,size,used,avail,pcent,target",
        "network": "ip -brief address",
        "processes": "ps -eo pid,comm,%cpu,%mem --sort=-%cpu",
    },
}


class TelemetryEndpointTests(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()

    @patch("app._collect_system_snapshot", return_value=SAMPLE_SNAPSHOT)
    def test_simple_telemetry_returns_shell_snapshot(self, _collect):
        response = self.client.get("/api/simple-telemetry")

        self.assertEqual(response.status_code, 200)
        payload = response.get_json()
        self.assertEqual(payload["host"]["hostname"], "ubuntu22-devbox")
        self.assertEqual(payload["memory"]["available_bytes"], 6291456000)
        self.assertEqual(payload["network_interfaces"][1]["name"], "eth0")

    @patch("app._collect_system_snapshot", return_value=SAMPLE_SNAPSHOT)
    def test_telemetry_csv_returns_csv_snapshot(self, _collect):
        response = self.client.get("/api/telemetry.csv")

        self.assertEqual(response.status_code, 200)
        text = response.data.decode("utf-8")
        lines = [line for line in text.splitlines() if line.strip()]
        self.assertGreaterEqual(len(lines), 2)
        self.assertEqual(lines[0], "timestamp_iso,section,metric,value,unit,context")
        self.assertTrue(any("filesystem,use_percent,55,percent,/" in line for line in lines))
        self.assertTrue(any("network_interface,state,UP,text,eth0" in line for line in lines))


if __name__ == "__main__":
    unittest.main()
