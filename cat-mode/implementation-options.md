# Cat Mode — Implementation Options and Code Snippets

This document provides implementation sketches with interchangeable technology choices. Snippets are intentionally partial but close to production shape.

---

## 1) Core configuration model (C#)

```csharp
public sealed class CatModeConfig
{
    public float ArmThreshold { get; init; } = 0.72f;
    public float ActivateThreshold { get; init; } = 0.78f;
    public float ReleaseThreshold { get; init; } = 0.55f;

    public int ArmFramesRequired { get; init; } = 2;
    public int ActivateFramesRequired { get; init; } = 4;

    public TimeSpan NoCatReleaseWindow { get; init; } = TimeSpan.FromSeconds(3);
    public TimeSpan RecoveryDuration { get; init; } = TimeSpan.FromSeconds(2);
    public TimeSpan MaxLockDuration { get; init; } = TimeSpan.FromSeconds(20);
}
```

---

## 2) State machine skeleton (C#)

```csharp
public enum CatModeState { Idle, Armed, Active, Recovery }

public sealed class CatModeStateMachine
{
    private readonly CatModeConfig _cfg;
    private CatModeState _state = CatModeState.Idle;
    private int _armHits;
    private int _activateHits;
    private DateTimeOffset _lastCatSeen = DateTimeOffset.MinValue;
    private DateTimeOffset _activeSince = DateTimeOffset.MinValue;

    public event Action<CatModeState>? StateChanged;

    public CatModeStateMachine(CatModeConfig cfg) => _cfg = cfg;

    public CatModeState Current => _state;

    public void OnInference(float catConfidence, DateTimeOffset now)
    {
        bool arm = catConfidence >= _cfg.ArmThreshold;
        bool activate = catConfidence >= _cfg.ActivateThreshold;
        bool catPresent = catConfidence >= _cfg.ReleaseThreshold;

        if (catPresent) _lastCatSeen = now;

        switch (_state)
        {
            case CatModeState.Idle:
                _armHits = arm ? _armHits + 1 : 0;
                if (_armHits >= _cfg.ArmFramesRequired)
                    TransitionTo(CatModeState.Armed);
                break;

            case CatModeState.Armed:
                _activateHits = activate ? _activateHits + 1 : 0;
                if (_activateHits >= _cfg.ActivateFramesRequired)
                {
                    _activeSince = now;
                    TransitionTo(CatModeState.Active);
                }
                else if (!arm)
                {
                    _armHits = 0;
                    TransitionTo(CatModeState.Idle);
                }
                break;

            case CatModeState.Active:
                bool stale = now - _lastCatSeen >= _cfg.NoCatReleaseWindow;
                bool maxed = now - _activeSince >= _cfg.MaxLockDuration;
                if (stale || maxed)
                    TransitionTo(CatModeState.Recovery);
                break;

            case CatModeState.Recovery:
                TransitionTo(CatModeState.Idle);
                break;
        }
    }

    private void TransitionTo(CatModeState next)
    {
        if (_state == next) return;
        _state = next;
        StateChanged?.Invoke(_state);
    }
}
```

---

## 3) ONNX Runtime detection path (C#)

```csharp
using Microsoft.ML.OnnxRuntime;
using Microsoft.ML.OnnxRuntime.Tensors;

public sealed class OnnxCatDetector : IDisposable
{
    private readonly InferenceSession _session;

    public OnnxCatDetector(string modelPath)
    {
        var opts = new SessionOptions();
        opts.GraphOptimizationLevel = GraphOptimizationLevel.ORT_ENABLE_EXTENDED;
        _session = new InferenceSession(modelPath, opts);
    }

    public float DetectCatConfidence(byte[] rgb, int width, int height)
    {
        // preprocess to [1,3,640,640] float tensor
        DenseTensor<float> input = Preprocess(rgb, width, height);
        var inputs = new List<NamedOnnxValue>
        {
            NamedOnnxValue.CreateFromTensor("images", input)
        };

        using IDisposableReadOnlyCollection<DisposableNamedOnnxValue> results = _session.Run(inputs);
        return ExtractCatConfidence(results); // pick max score for cat class id
    }

    public void Dispose() => _session.Dispose();
}
```

---

## 4) Keyboard suppression with LowLevelKeyboardProc (C# / Win32)

```csharp
internal sealed class KeyboardGuard : IDisposable
{
    private IntPtr _hook = IntPtr.Zero;
    private bool _active;

    public void EnableGuard() => _active = true;
    public void DisableGuard() => _active = false;

    public void Install()
    {
        _hook = SetWindowsHookEx(WH_KEYBOARD_LL, HookProc, IntPtr.Zero, 0);
        if (_hook == IntPtr.Zero) throw new Win32Exception();
    }

    private IntPtr HookProc(int nCode, IntPtr wParam, IntPtr lParam)
    {
        if (nCode >= 0 && _active)
        {
            var info = Marshal.PtrToStructure<KBDLLHOOKSTRUCT>(lParam);
            if (!IsEmergencyOverride(info))
            {
                return (IntPtr)1; // block key event
            }
        }
        return CallNextHookEx(_hook, nCode, wParam, lParam);
    }

    public void Dispose()
    {
        if (_hook != IntPtr.Zero)
            UnhookWindowsHookEx(_hook);
    }
}
```

> Note: global keyboard hooks are sensitive APIs. Run robust watchdog cleanup and test thoroughly in disposable environments.

---

## 5) Overlay banner (WPF)

```xml
<Window x:Class="CatMode.App.BannerWindow"
        WindowStyle="None"
        ResizeMode="NoResize"
        Topmost="True"
        ShowInTaskbar="False"
        AllowsTransparency="True"
        Background="Transparent"
        Width="600" Height="100">
  <Border Background="#CCFF6B00" CornerRadius="12" Padding="16">
    <TextBlock Text="🐾 CAT MODE ACTIVE — Keyboard temporarily paused"
               FontSize="24"
               Foreground="White"
               FontWeight="Bold"/>
  </Border>
</Window>
```

```csharp
public void ShowBannerForActiveState(CatModeState state)
{
    if (state == CatModeState.Active)
        _banner.Show();
    else
        _banner.Hide();
}
```

---

## 6) Python prototype option (fast experimentation)

```python
import cv2
from ultralytics import YOLO

model = YOLO("yolov8n.pt")
cap = cv2.VideoCapture(0)

while True:
    ok, frame = cap.read()
    if not ok:
        continue

    results = model(frame, verbose=False)
    cat_conf = 0.0

    for r in results:
        for box in r.boxes:
            cls = int(box.cls[0])
            conf = float(box.conf[0])
            if cls == 15:  # COCO cat
                cat_conf = max(cat_conf, conf)

    print(f"cat_conf={cat_conf:.2f}")
```

Use this prototype to tune thresholds and smoothing before committing to native UI/input integration.

---

## 7) Event orchestration example

```csharp
_stateMachine.StateChanged += state =>
{
    _telemetry.TrackStateChange(state);

    switch (state)
    {
        case CatModeState.Active:
            _keyboardGuard.EnableGuard();
            _banner.Show();
            break;
        default:
            _keyboardGuard.DisableGuard();
            _banner.Hide();
            break;
    }
};
```

---

## 8) Hardening checklist

- Add signed configuration with strict bounds for thresholds and timers.
- Add startup self-test: camera, model load, hook install.
- Add periodic watchdog heartbeat shared between detector, UI, and guard.
- Add lockout analytics to verify false positive rate.
- Provide clear opt-in UX and uninstall cleanup.

