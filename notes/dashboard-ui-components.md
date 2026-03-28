# Dashboard UI Components Inventory

This document is a WIP partial design document focused exclusively on required UI
components that are currently visible in source code.

## Next Human Tasks
- Cross check this doc with App.jsx.
- Update this document, the doc should be the source of truth, not App.jsx


## Scope

- Source of truth: `ReactDashboard/src/App.jsx`
- Included: visible UI routes, sections, cards, tables, banners, pills, badges,
  toggles, labels, and visible empty/error/loading states
- Excluded: data helpers, parsing utilities, fetch logic, backend-only
  structures, and non-visual implementation details

## Route Inventory

### `/` redirect

- Browser entrypoint redirects `/` to `/simple`

### `/simple`

- Simple shell-telemetry dashboard

### `/full`

- Full dashboard with simulated layout sections, backend widgets, telemetry
  table, and runtime/configuration surfaces

## Shared Visible Components

### `DashboardNav`

- Route switcher with two links:
  - `Simple dashboard`
  - `Full dashboard`

### `Section`

- Section title
- Optional section subtitle
- Section body content region

### `Panel`

- Shared card container used across both dashboards

### `MetricRow`

- Two-column label/value row

### `ProgressBar`

- Horizontal filled usage/progress bar

### `StatusPill`

- Capsule status indicator with text label

### `StatusDot`

- Small circular status indicator

### `Badge`

- Capsule badge used for counts, deltas, and metadata

### `Gauge`

- Circular conic-gradient gauge with centered value label

### `Sparkline`

- Inline sparkline chart

### `Toggle`

- Labeled on/off switch visual

## `/simple` Required UI Components

### Page shell

- Navigation bar
- Eyebrow text: `Ubuntu 22 shell telemetry`
- Main heading: `Simple Host Dashboard`
- Introductory body copy
- Top-level error banner for failed simple telemetry fetches

### `Host summary` section

- Four summary panels:
  - Host identity panel
    - `Hostname`
    - `Kernel`
    - `CPU cores`
  - Uptime/load panel
    - `Uptime`
    - `Load 1m`
    - `Load 5m`
    - `Load 15m`
  - Memory panel
    - `Memory used`
    - `Memory available`
    - Memory progress bar
  - Root filesystem panel
    - `Root filesystem`
    - `Disk used`
    - `Disk free`
    - Disk progress bar
- Section subtitle state:
  - `Waiting for first sample`
  - `Last updated ...`

### `Interfaces` section

- Repeating interface cards
- Per card:
  - Interface name
  - State pill
  - Address list or `No address`

### `Top processes` section

- Single panel containing a table
- Table columns:
  - `PID`
  - `Command`
  - `CPU %`
  - `MEM %`

### `Backend sources` section

- Single panel listing command-source rows:
  - `Uptime`
  - `Memory`
  - `Filesystems`
  - `Network`
  - `Processes`
  - `Swap used`

## `/full` Required UI Components

### Top-level outage indicators

- `PlaceholderBanner`
- Possible visible banners:
  - `Backend unreachable. Showing placeholder widget data.`
  - `Prometheus unreachable. Showing placeholder telemetry data.`

### Header area

- Navigation bar
- Eyebrow text: `Host resource monitor`
- Main heading: `Nebula OS Control Deck`
- Host summary line:
  - host name
  - OS
  - kernel
  - uptime
- Metadata badges:
  - `IP ...`
  - `Location ...`
  - `Updated ...`

### `System posture` section

- Five summary cards:
  - `CPU`
  - `Memory`
  - `Disk`
  - `Network`
  - `GPU`
- Each card includes:
  - label
  - delta badge
  - large value
  - progress bar

### `Core resource rings` section

- Three gauge cards:
  - `CPU utilization`
  - `Memory pressure`
  - `Network throughput`
- Each gauge card includes:
  - title
  - subtitle
  - circular gauge
  - sparkline
  - two stat items

### `Storage & IO` section

- `Volume usage` panel
  - repeating volume rows
  - per row:
    - volume name
    - volume type
    - health pill
    - progress bar
    - usage text
- `IO diagnostics` panel
  - `IOPS`
  - `Queue depth`
  - `Disk saturation`
  - `NVMe temps`
  - `IO throttle` slider with `Auto` label

### `Network & interface telemetry` section

- Repeating network interface cards
- Per card:
  - interface name
  - status pill
  - `Upstream`
  - `Downstream`
  - `Errors`
  - progress bar

### `GPU & power` section

- `GPU engine` panel
  - circular gauge
  - `VRAM`
  - `Temp`
  - `PCIe`
- `Power bay` panel
  - circular gauge
  - power status text
  - estimated remaining text
  - draw text
  - `UPS mode` toggle
  - `Eco` toggle
- `Thermal sensors` panel
  - repeating sensor rows
  - per row:
    - sensor label
    - sensor value
    - status dot

### `Workload activity` section

- `Top processes` panel
  - last-updated timestamp
  - table columns:
    - `Process`
    - `CPU`
    - `Memory (GB)`
    - `Threads`
    - `PID`
  - per row:
    - process name
    - compact status pill
- `Alert queue` panel
  - four summary badges:
    - `ok`
    - `warn`
    - `danger`
    - `info`
  - repeating alert cards
    - alert title
    - status dot
    - alert detail
- `Runbook timeline` panel
  - repeating timeline rows
  - per row:
    - time
    - label
    - compact status pill

### `Service widgets` section

- Inline error message for widget fetch failures
- Loading state text: `Loading widgets...`
- Repeating widget cards
- Per card:
  - widget title
  - widget value
  - widget trend

### `Telemetry table` section

- Introductory watcher text for `/api/telemetry.csv`
- Last-updated timestamp
- Inline error message for telemetry fetch failures
- Empty state text: `No rows found yet.`
- Telemetry table
  - dynamic table headers
  - repeating table rows

### `Knobs & runtime configuration` section

- `Build-time discovery` subsection
  - empty state text when no `mydash*` files exist
  - repeating discovery chips when files exist
- `Runtime config` subsection
  - runtime message
  - optional extra body text
  - inline runtime-config error text
- `Convention tweak` subsection
  - repeating widget convention cards
  - per card:
    - optional category chip
    - display title
    - `Value: ...`
    - `Trend: ...`

## Source References

- Main UI source: `/home/brady/Projects/development-setup-master/ReactDashboard/src/App.jsx`
- Routing shell and top-level dashboards:
  - [App.jsx](/home/brady/Projects/development-setup-master/ReactDashboard/src/App.jsx#L241)
- Simple dashboard:
  - [App.jsx](/home/brady/Projects/development-setup-master/ReactDashboard/src/App.jsx#L349)
- Full dashboard:
  - [App.jsx](/home/brady/Projects/development-setup-master/ReactDashboard/src/App.jsx#L263)
- Shared visible primitives:
  - [App.jsx](/home/brady/Projects/development-setup-master/ReactDashboard/src/App.jsx#L830)
