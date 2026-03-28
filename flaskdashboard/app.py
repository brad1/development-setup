import csv
import io
import re
import subprocess
from datetime import datetime, timezone

from flask import Flask, Response, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

WIDGETS = [
    {"id": 1, "title": "Host::CPU cores", "value": "live", "trend": "shell"},
    {"id": 2, "title": "Memory::Available RAM", "value": "live", "trend": "shell"},
    {"id": 3, "title": "Disk::Root usage", "value": "live", "trend": "shell"},
    {"id": 4, "title": "Network::Interfaces", "value": "live", "trend": "shell"},
]

RUNTIME_CONFIG = {
    "runtimeMessage": "Runtime config loaded",
    "highlightKnob": True,
    "popoverText": "Main page redirects to the simple dashboard at /simple.",
}


def _run_command(args):
    completed = subprocess.run(
        args,
        check=True,
        capture_output=True,
        text=True,
        timeout=3,
    )
    return completed.stdout.strip()


def _safe_run(args, fallback=""):
    try:
        return _run_command(args)
    except (FileNotFoundError, subprocess.CalledProcessError, subprocess.TimeoutExpired):
        return fallback


def _parse_load_averages(uptime_output):
    match = re.search(
        r"load average[s]?:\s*([0-9.]+),?\s+([0-9.]+),?\s+([0-9.]+)",
        uptime_output,
    )
    if not match:
        return {"one": 0.0, "five": 0.0, "fifteen": 0.0}

    return {
        "one": float(match.group(1)),
        "five": float(match.group(2)),
        "fifteen": float(match.group(3)),
    }


def _parse_uptime_pretty(uptime_output):
    if " up " not in uptime_output:
        return uptime_output

    uptime_part = uptime_output.split(" up ", 1)[1]
    for separator in [",  ", ", user", ", load average", ", load averages"]:
        if separator in uptime_part:
            uptime_part = uptime_part.split(separator, 1)[0]
            break

    return uptime_part.strip().rstrip(",")


def _parse_memory_snapshot():
    output = _safe_run(["free", "-b"])
    if not output:
        return {
            "total_bytes": 0,
            "used_bytes": 0,
            "available_bytes": 0,
            "swap_total_bytes": 0,
            "swap_used_bytes": 0,
        }

    lines = [line.split() for line in output.splitlines() if line.strip()]
    memory = {"total_bytes": 0, "used_bytes": 0, "available_bytes": 0}
    swap = {"swap_total_bytes": 0, "swap_used_bytes": 0}

    for cells in lines:
        label = cells[0].rstrip(":")
        if label == "Mem" and len(cells) >= 7:
            memory = {
                "total_bytes": int(cells[1]),
                "used_bytes": int(cells[2]),
                "available_bytes": int(cells[6]),
            }
        if label == "Swap" and len(cells) >= 3:
            swap = {
                "swap_total_bytes": int(cells[1]),
                "swap_used_bytes": int(cells[2]),
            }

    return {**memory, **swap}


def _parse_filesystems():
    output = _safe_run(["df", "-B1", "-P", "--output=source,size,used,avail,pcent,target"])
    if not output:
        return []

    rows = [line.split() for line in output.splitlines()[1:] if line.strip()]
    filesystems = []
    for row in rows:
        if len(row) < 6:
            continue
        filesystems.append(
            {
                "filesystem": row[0],
                "size_bytes": int(row[1]),
                "used_bytes": int(row[2]),
                "available_bytes": int(row[3]),
                "use_percent": int(row[4].rstrip("%")),
                "mount": row[5],
            }
        )
    return filesystems


def _parse_network_interfaces():
    output = _safe_run(["ip", "-brief", "address"])
    if not output:
        return []

    interfaces = []
    for line in output.splitlines():
        parts = line.split()
        if len(parts) < 3:
            continue
        name = parts[0]
        state = parts[1]
        addresses = [value for value in parts[2:] if "/" in value]
        interfaces.append(
            {
                "name": name,
                "state": state,
                "addresses": addresses,
            }
        )
    return interfaces


def _parse_top_processes():
    output = _safe_run(["ps", "-eo", "pid,comm,%cpu,%mem", "--sort=-%cpu"])
    if not output:
        return []

    rows = []
    for line in output.splitlines()[1:6]:
        parts = line.split(None, 3)
        if len(parts) != 4:
            continue
        try:
            rows.append(
                {
                    "pid": int(parts[0]),
                    "command": parts[1],
                    "cpu_percent": float(parts[2]),
                    "memory_percent": float(parts[3]),
                }
            )
        except ValueError:
            continue
    return rows


def _collect_system_snapshot():
    timestamp = datetime.now(timezone.utc).isoformat()
    hostname = _safe_run(["hostname"], "unknown-host")
    kernel = _safe_run(["uname", "-sr"], "unknown-kernel")
    uptime_output = _safe_run(["uptime"], "")
    load = _parse_load_averages(uptime_output)
    memory = _parse_memory_snapshot()
    filesystems = _parse_filesystems()
    interfaces = _parse_network_interfaces()
    processes = _parse_top_processes()
    cpu_count = int(_safe_run(["nproc"], "0") or 0)

    return {
        "timestamp_iso": timestamp,
        "host": {
            "hostname": hostname,
            "kernel": kernel,
            "cpu_count": cpu_count,
        },
        "uptime": {
            "pretty": _parse_uptime_pretty(uptime_output),
            "raw": uptime_output,
            "load": load,
        },
        "memory": memory,
        "filesystems": filesystems,
        "network_interfaces": interfaces,
        "top_processes": processes,
        "sources": {
            "uptime": "uptime",
            "memory": "free -b",
            "filesystems": "df -B1 -P --output=source,size,used,avail,pcent,target",
            "network": "ip -brief address",
            "processes": "ps -eo pid,comm,%cpu,%mem --sort=-%cpu",
        },
    }


def _snapshot_to_csv(snapshot):
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["timestamp_iso", "section", "metric", "value", "unit", "context"])

    writer.writerow(
        [
            snapshot["timestamp_iso"],
            "host",
            "hostname",
            snapshot["host"]["hostname"],
            "text",
            "hostname",
        ]
    )
    writer.writerow(
        [
            snapshot["timestamp_iso"],
            "host",
            "kernel",
            snapshot["host"]["kernel"],
            "text",
            "uname -sr",
        ]
    )
    writer.writerow(
        [
            snapshot["timestamp_iso"],
            "host",
            "cpu_count",
            snapshot["host"]["cpu_count"],
            "cores",
            "nproc",
        ]
    )

    for period, value in snapshot["uptime"]["load"].items():
        writer.writerow(
            [
                snapshot["timestamp_iso"],
                "uptime",
                f"load_{period}",
                value,
                "load",
                "uptime",
            ]
        )

    writer.writerow(
        [
            snapshot["timestamp_iso"],
            "uptime",
            "pretty",
            snapshot["uptime"]["pretty"],
            "text",
            "uptime",
        ]
    )

    memory = snapshot["memory"]
    for metric_name, unit in [
        ("total_bytes", "bytes"),
        ("used_bytes", "bytes"),
        ("available_bytes", "bytes"),
        ("swap_total_bytes", "bytes"),
        ("swap_used_bytes", "bytes"),
    ]:
        writer.writerow(
            [
                snapshot["timestamp_iso"],
                "memory",
                metric_name,
                memory[metric_name],
                unit,
                "free -b",
            ]
        )

    for filesystem in snapshot["filesystems"]:
        writer.writerow(
            [
                snapshot["timestamp_iso"],
                "filesystem",
                "use_percent",
                filesystem["use_percent"],
                "percent",
                filesystem["mount"],
            ]
        )
        writer.writerow(
            [
                snapshot["timestamp_iso"],
                "filesystem",
                "used_bytes",
                filesystem["used_bytes"],
                "bytes",
                filesystem["mount"],
            ]
        )

    for interface in snapshot["network_interfaces"]:
        writer.writerow(
            [
                snapshot["timestamp_iso"],
                "network_interface",
                "state",
                interface["state"],
                "text",
                interface["name"],
            ]
        )
        writer.writerow(
            [
                snapshot["timestamp_iso"],
                "network_interface",
                "addresses",
                " ".join(interface["addresses"]),
                "text",
                interface["name"],
            ]
        )

    for process in snapshot["top_processes"]:
        writer.writerow(
            [
                snapshot["timestamp_iso"],
                "process",
                "cpu_percent",
                process["cpu_percent"],
                "percent",
                f'{process["command"]}#{process["pid"]}',
            ]
        )

    return output.getvalue().strip()


@app.route("/api/widgets")
def widgets():
    snapshot = _collect_system_snapshot()
    memory_available_gb = snapshot["memory"]["available_bytes"] / 1024**3
    root_filesystem = next(
        (filesystem for filesystem in snapshot["filesystems"] if filesystem["mount"] == "/"),
        None,
    )

    widgets = [
        {
            "id": 1,
            "title": "Host::CPU cores",
            "value": snapshot["host"]["cpu_count"],
            "trend": f'load {snapshot["uptime"]["load"]["one"]:.2f}',
        },
        {
            "id": 2,
            "title": "Memory::Available RAM",
            "value": f"{memory_available_gb:.1f} GB",
            "trend": "free -b",
        },
        {
            "id": 3,
            "title": "Disk::Root usage",
            "value": f'{root_filesystem["use_percent"]}%' if root_filesystem else "n/a",
            "trend": root_filesystem["filesystem"] if root_filesystem else "df",
        },
        {
            "id": 4,
            "title": "Network::Interfaces",
            "value": len(snapshot["network_interfaces"]),
            "trend": "ip -brief address",
        },
    ]
    return jsonify({"widgets": widgets})


@app.route("/api/runtime-config")
def runtime_config():
    return jsonify(RUNTIME_CONFIG)


@app.route("/api/simple-telemetry")
def simple_telemetry():
    return jsonify(_collect_system_snapshot())


@app.route("/api/telemetry")
def telemetry():
    snapshot = _collect_system_snapshot()
    return jsonify(snapshot)


@app.route("/api/telemetry.csv")
def telemetry_csv():
    snapshot = _collect_system_snapshot()
    return Response(_snapshot_to_csv(snapshot), mimetype="text/csv")


@app.route("/telemetry.csv")
def telemetry_csv_alias():
    snapshot = _collect_system_snapshot()
    response = Response(_snapshot_to_csv(snapshot), mimetype="text/csv")
    response.headers["Content-Disposition"] = 'attachment; filename="telemetry.csv"'
    return response


@app.route("/health")
def health():
    return "ok", 200


if __name__ == "__main__":
    app.run(port=5000, debug=True)
