# Cat Mode for Windows — Design Layout

## Goal
Build a Windows desktop application that:
1. Uses the laptop camera to detect whether a cat is present.
2. Temporarily disables keyboard input when a cat is detected.
3. Displays an on-screen "Cat Mode" banner while protection is active.

This folder captures design choices, control flow, and implementation paths. See `implementation-options.md` for detailed code snippets.

## Product requirements

### Functional requirements
- Capture camera frames continuously (target 15–30 FPS).
- Run real-time cat detection on each frame.
- Enter Cat Mode when confidence crosses threshold for a configurable number of consecutive frames.
- During Cat Mode:
  - Ignore/block keyboard input for a bounded interval.
  - Show a prominent top-level banner indicating Cat Mode is active.
- Exit Cat Mode when no cat has been detected for a cooldown window or when timeout elapses.
- Write structured logs for detections, transitions, and errors.

### Non-functional requirements
- Low latency (< 300 ms from detection to lock activation).
- Predictable unlock behavior (hard timeout, watchdog, and emergency override).
- Support modern Windows versions (Windows 10/11).
- Operate without internet once model is installed.

## High-level architecture

```text
+-------------------------+
|   Camera Ingestion      |
| (MediaFoundation/OpenCV)|
+-----------+-------------+
            |
            v
+-------------------------+       +------------------------+
|  Detection Engine       |-----> | State Machine          |
| (ONNX Runtime / API)    |       | (Idle->Armed->CatMode) |
+-----------+-------------+       +-----------+------------+
            |                                 |
            v                                 v
+-------------------------+       +------------------------+
| Telemetry + Logging     |       | Actuators              |
| (ETW/file logs)         |       | - Keyboard Guard       |
+-------------------------+       | - Banner Overlay       |
                                  +------------------------+
```

## State machine

### States
- **Idle**: normal operation, keyboard fully enabled.
- **Armed**: cat-like detections observed but not yet stable.
- **CatModeActive**: keyboard blocked and banner visible.
- **Recovery**: unblock keyboard, hold brief grace period, then return to Idle.

### Transition rules (suggested defaults)
- Idle -> Armed: confidence >= 0.72 for at least 2 frames in 1 second.
- Armed -> CatModeActive: confidence >= 0.78 for 4 consecutive frames.
- CatModeActive -> Recovery: no cat above 0.55 for 3 seconds.
- Recovery -> Idle: 2 seconds after cleanup.
- Any -> Idle: emergency override hotkey from trusted input path.

## Safety model (important)
Keyboard suppression can lock out legitimate user control if not carefully constrained.

Recommended controls:
- **Max lock duration**: e.g., 20 seconds, auto-unlock.
- **Watchdog thread**: if UI or detector crashes, keyboard hook is removed.
- **Emergency override**: secure sequence (for example, hold right Ctrl + right Shift + Esc for 2 seconds) that bypasses normal suppression logic.
- **Foreground restriction**: optionally suppress only when the protected app is foreground to reduce system-wide impact.
- **Admin guidance**: clearly document behavior, consent, and privacy implications.

## Data flow and threading
- **Capture thread**: camera frame acquisition into ring buffer.
- **Inference worker**: consumes newest frame only (drop old frames when behind).
- **State manager**: time-windowed smoothing + transitions.
- **UI dispatcher thread**: banner render updates.
- **Input hook thread**: keyboard low-level hook and watchdog heartbeat.

## Suggested project layout

```text
cat-mode-app/
  src/
    CatMode.App/                 # WPF or WinUI app shell
    CatMode.Detection/           # model runtime + preprocessing
    CatMode.InputGuard/          # keyboard hook and override
    CatMode.BannerOverlay/       # topmost visual indicator
    CatMode.Core/                # state machine + config
    CatMode.Telemetry/           # logging/metrics
  models/
    yolo-cat.onnx
  config/
    catmode.json
  tests/
    CatMode.Core.Tests/
```

## Model strategy options
- **Option A (local model)**: YOLO-family ONNX model with a class that includes cat (`COCO class id 15` in many model variants).
  - Pros: offline, low latency.
  - Cons: model packaging size, GPU/CPU variability.
- **Option B (cloud vision API)**: send sampled frames to remote detector.
  - Pros: easier iteration.
  - Cons: privacy, latency, network dependency.
- **Option C (hybrid)**: local first, cloud fallback when confidence low.

## Performance targets
- Camera ingest: 720p at 24 FPS.
- Inference budget: <= 40 ms/frame on CPU, <= 15 ms/frame on GPU.
- End-to-end actuation: <= 300 ms median, <= 700 ms P95.

## Test plan
- Unit tests for transition guards and timeout rules.
- Synthetic frame replay tests with known cat/no-cat labels.
- Keyboard hook integration tests in VM.
- Fault injection:
  - camera unavailable,
  - model load failure,
  - UI thread freeze,
  - forced process termination.
- Usability test for emergency override discoverability.

## Security/privacy notes
- Process only local camera frames unless explicitly configured otherwise.
- Do not persist raw frames by default.
- Log only confidence, timestamps, and state transitions.
- Expose clear user setting for enabling/disabling camera processing.

## Next implementation milestones
1. Build a detector spike app with live webcam preview and confidence timeline.
2. Add state machine + deterministic replay harness.
3. Integrate keyboard guard with watchdog and override.
4. Add overlay banner and telemetry.
5. Package installer and publish support docs.
