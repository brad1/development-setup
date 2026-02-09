import React, { useEffect, useMemo, useState } from 'react';

const API_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:5000';
const TABLE_URL = `${API_URL}/telemetry.csv`;

const STATUS_COLORS = {
  ok: '#1f7a3e',
  warn: '#b45309',
  danger: '#b91c1c',
  info: '#1d4ed8',
};

const RING_COLORS = {
  cpu: ['#0f172a', '#38bdf8'],
  memory: ['#1f2937', '#f97316'],
  disk: ['#111827', '#a855f7'],
  gpu: ['#111827', '#10b981'],
  network: ['#111827', '#6366f1'],
};

const clamp = (value, min, max) => Math.min(Math.max(value, min), max);

const toFixed = (value, digits = 0) => Number.parseFloat(value).toFixed(digits);

const formatBytes = (value) => {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  let size = value;
  let unitIndex = 0;
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex += 1;
  }
  return `${toFixed(size, size >= 100 ? 0 : 1)} ${units[unitIndex]}`;
};

const formatPercent = (value) => `${toFixed(value, 0)}%`;

const formatUptime = (seconds) => {
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  return `${days}d ${hours}h ${minutes}m`;
};

const buildHistory = (count, base, variance) =>
  Array.from({ length: count }, () => clamp(base + (Math.random() - 0.5) * variance, 0, 100));

const FALLBACK_WIDGETS = [
  { id: 'fallback-1', title: 'Ingress::Active Users', value: 1825, trend: '+4%' },
  { id: 'fallback-2', title: 'Queues::Queued Jobs', value: 48, trend: '-2%' },
  { id: 'fallback-3', title: 'Errors::Pager Triggers', value: 3, trend: 'stable' },
];

const makeInitialMetrics = () => ({
  timestamp: new Date(),
  uptimeSeconds: 412390,
  host: {
    name: 'nebula-orbital',
    os: 'Ubuntu 22.04 LTS',
    kernel: '6.5.0-41',
    ip: '10.21.84.120',
    location: 'SFO-2',
  },
  summary: {
    cpu: 68,
    memory: 72,
    disk: 58,
    gpu: 44,
    network: 36,
  },
  cpu: {
    temp: 67,
    clock: 3.9,
    processes: 312,
    load: [2.1, 1.8, 1.4],
    history: buildHistory(24, 62, 22),
  },
  memory: {
    used: 51.4 * 1024 * 1024 * 1024,
    total: 64 * 1024 * 1024 * 1024,
    cached: 9.8 * 1024 * 1024 * 1024,
    swapUsed: 1.6 * 1024 * 1024 * 1024,
    swapTotal: 8 * 1024 * 1024 * 1024,
    history: buildHistory(24, 70, 12),
  },
  disk: {
    iops: 882,
    queue: 1.8,
    volumes: [
      { name: 'root', used: 420, total: 750, type: 'NVMe', health: 'ok' },
      { name: 'data', used: 3.4, total: 8, type: 'HDD', health: 'warn' },
      { name: 'backup', used: 11.2, total: 16, type: 'SSD', health: 'ok' },
    ],
  },
  network: {
    interfaces: [
      { name: 'eth0', up: 820, down: 440, status: 'ok' },
      { name: 'eth1', up: 210, down: 190, status: 'ok' },
      { name: 'wlan0', up: 32, down: 18, status: 'warn' },
    ],
    latency: 18,
    packetLoss: 0.3,
    history: buildHistory(24, 40, 30),
  },
  gpu: {
    usage: 44,
    vramUsed: 5.9,
    vramTotal: 12,
    temp: 71,
  },
  power: {
    battery: 84,
    status: 'charging',
    estRemaining: '4h 12m',
    draw: 62,
  },
  sensors: [
    { label: 'Ambient Temp', value: '21°C', status: 'ok' },
    { label: 'Chassis Fan 1', value: '1,420 RPM', status: 'ok' },
    { label: 'Chassis Fan 2', value: '980 RPM', status: 'warn' },
    { label: 'NVMe 0', value: '59°C', status: 'ok' },
    { label: 'NVMe 1', value: '63°C', status: 'warn' },
  ],
  processes: [
    { name: 'node', cpu: 18.4, memory: 2.1, threads: 84, pid: 8201, status: 'ok' },
    { name: 'postgres', cpu: 9.8, memory: 3.4, threads: 64, pid: 441, status: 'ok' },
    { name: 'docker', cpu: 7.1, memory: 6.8, threads: 112, pid: 902, status: 'warn' },
    { name: 'redis', cpu: 2.2, memory: 0.8, threads: 18, pid: 3321, status: 'ok' },
    { name: 'grafana-agent', cpu: 1.6, memory: 0.4, threads: 22, pid: 2219, status: 'ok' },
  ],
  alerts: [
    { title: 'Disk data pool > 85%', detail: 'Archive datasets or expand volume.', status: 'warn' },
    { title: 'GPU hotspot stabilized', detail: 'Thermals back under threshold.', status: 'ok' },
    { title: 'Sustained memory pressure', detail: 'Consider reclaiming cache.', status: 'danger' },
  ],
  schedule: [
    { time: '09:30', label: 'Daily backup window starts', status: 'info' },
    { time: '11:00', label: 'Kernel update staged', status: 'warn' },
    { time: '13:45', label: 'Cluster sync complete', status: 'ok' },
    { time: '16:00', label: 'Security scan queued', status: 'info' },
  ],
});

const stepMetric = (value, variance, min = 0, max = 100) =>
  clamp(value + (Math.random() - 0.5) * variance, min, max);

const updateHistory = (history, nextValue) => [...history.slice(1), nextValue];

const updateMetrics = (metrics) => {
  const nextCpu = stepMetric(metrics.summary.cpu, 8);
  const nextMemory = stepMetric(metrics.summary.memory, 5);
  const nextDisk = stepMetric(metrics.summary.disk, 3);
  const nextGpu = stepMetric(metrics.summary.gpu, 6);
  const nextNetwork = stepMetric(metrics.summary.network, 10);

  return {
    ...metrics,
    timestamp: new Date(),
    uptimeSeconds: metrics.uptimeSeconds + 15,
    summary: {
      cpu: nextCpu,
      memory: nextMemory,
      disk: nextDisk,
      gpu: nextGpu,
      network: nextNetwork,
    },
    cpu: {
      ...metrics.cpu,
      temp: stepMetric(metrics.cpu.temp, 3, 40, 90),
      clock: stepMetric(metrics.cpu.clock, 0.4, 2.4, 4.6),
      load: metrics.cpu.load.map((value) => stepMetric(value, 0.3, 0.2, 4.5)),
      history: updateHistory(metrics.cpu.history, nextCpu),
    },
    memory: {
      ...metrics.memory,
      used: stepMetric(metrics.memory.used / 1024 ** 3, 1.4, 34, 60) * 1024 ** 3,
      cached: stepMetric(metrics.memory.cached / 1024 ** 3, 0.8, 4, 18) * 1024 ** 3,
      swapUsed: stepMetric(metrics.memory.swapUsed / 1024 ** 3, 0.3, 0.3, 6) * 1024 ** 3,
      history: updateHistory(metrics.memory.history, nextMemory),
    },
    disk: {
      ...metrics.disk,
      iops: Math.round(stepMetric(metrics.disk.iops, 140, 400, 1600)),
      queue: toFixed(stepMetric(metrics.disk.queue, 0.6, 0.4, 4), 1),
      volumes: metrics.disk.volumes.map((volume) => ({
        ...volume,
        used: stepMetric(volume.used, 0.3, 0.2, volume.total - 0.2),
      })),
    },
    network: {
      ...metrics.network,
      latency: Math.round(stepMetric(metrics.network.latency, 6, 8, 60)),
      packetLoss: toFixed(stepMetric(metrics.network.packetLoss, 0.2, 0, 2), 1),
      history: updateHistory(metrics.network.history, nextNetwork),
      interfaces: metrics.network.interfaces.map((iface) => ({
        ...iface,
        up: Math.round(stepMetric(iface.up, 80, 10, 1200)),
        down: Math.round(stepMetric(iface.down, 60, 5, 900)),
      })),
    },
    gpu: {
      ...metrics.gpu,
      usage: nextGpu,
      temp: stepMetric(metrics.gpu.temp, 3, 45, 86),
      vramUsed: stepMetric(metrics.gpu.vramUsed, 0.5, 2, metrics.gpu.vramTotal - 0.4),
    },
    power: {
      ...metrics.power,
      battery: stepMetric(metrics.power.battery, 1.5, 30, 100),
      draw: stepMetric(metrics.power.draw, 4, 45, 98),
      status: metrics.power.battery > 92 ? 'idle' : metrics.power.status,
    },
  };
};

function useSimulatedMetrics() {
  const [metrics, setMetrics] = useState(() => makeInitialMetrics());

  useEffect(() => {
    const intervalId = setInterval(() => {
      setMetrics((prev) => updateMetrics(prev));
    }, 3200);

    return () => clearInterval(intervalId);
  }, []);

  const alertCounts = useMemo(() => {
    const counts = { ok: 0, warn: 0, danger: 0, info: 0 };
    metrics.alerts.forEach((alert) => {
      counts[alert.status] = (counts[alert.status] ?? 0) + 1;
    });
    return counts;
  }, [metrics.alerts]);

  return { metrics, alertCounts };
}

export default function App() {
  const [widgets, setWidgets] = useState([]);
  const [error, setError] = useState(null);
  const [backendFallback, setBackendFallback] = useState(false);
  const [telemetryFallback, setTelemetryFallback] = useState(false);
  const { metrics, alertCounts } = useSimulatedMetrics();

  useEffect(() => {
    fetch(`${API_URL}/api/widgets`)
      .then((response) => {
        if (!response.ok) throw new Error('failed to load widgets');
        return response.json();
      })
      .then((data) => {
        setWidgets(data.widgets ?? []);
        setBackendFallback(false);
      })
      .catch((err) => {
        setError(err);
        setWidgets(FALLBACK_WIDGETS);
        setBackendFallback(true);
      });
  }, []);

  return (
    <main
      style={{
        fontFamily: 'Inter, system-ui, sans-serif',
        background: '#f5f7fb',
        color: '#0f172a',
        minHeight: '100vh',
        padding: '2.5rem clamp(1.5rem, 4vw, 3.5rem)',
      }}
    >
      {(backendFallback || telemetryFallback) && (
        <div style={{ display: 'grid', gap: '0.75rem', marginBottom: '1.5rem' }}>
          {backendFallback && (
            <div
              style={{
                background: '#fee2e2',
                color: '#991b1b',
                border: '1px solid #fecaca',
                padding: '0.85rem 1rem',
                borderRadius: '0.75rem',
                fontWeight: 600,
              }}
            >
              Backend unreachable. Showing placeholder widget data.
            </div>
          )}
          {telemetryFallback && (
            <div
              style={{
                background: '#ffedd5',
                color: '#9a3412',
                border: '1px solid #fed7aa',
                padding: '0.85rem 1rem',
                borderRadius: '0.75rem',
                fontWeight: 600,
              }}
            >
              Prometheus unreachable. Showing placeholder telemetry data.
            </div>
          )}
        </div>
      )}
      <Header metrics={metrics} />

      <Section title="System posture" subtitle="Live snapshot · simulated data for UI layout">
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
            gap: '1.25rem',
          }}
        >
          <SummaryCard label="CPU" value={formatPercent(metrics.summary.cpu)} delta="+2.1%" tone="cpu" />
          <SummaryCard label="Memory" value={formatPercent(metrics.summary.memory)} delta="-1.4%" tone="memory" />
          <SummaryCard label="Disk" value={formatPercent(metrics.summary.disk)} delta="+0.4%" tone="disk" />
          <SummaryCard label="Network" value={formatPercent(metrics.summary.network)} delta="-6%" tone="network" />
          <SummaryCard label="GPU" value={formatPercent(metrics.summary.gpu)} delta="+3.6%" tone="gpu" />
        </div>
      </Section>

      <Section title="Core resource rings" subtitle="Conic gauges with history sparks">
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))',
            gap: '1.5rem',
          }}
        >
          <GaugeCard
            title="CPU utilization"
            subtitle={`${metrics.cpu.processes} processes · ${toFixed(metrics.cpu.clock, 1)} GHz`}
            value={metrics.summary.cpu}
            tone="cpu"
            sparkline={metrics.cpu.history}
            stats={[
              { label: 'Temp', value: `${toFixed(metrics.cpu.temp, 0)}°C` },
              { label: 'Load', value: metrics.cpu.load.map((item) => toFixed(item, 1)).join(', ') },
            ]}
          />
          <GaugeCard
            title="Memory pressure"
            subtitle={`${formatBytes(metrics.memory.used)} / ${formatBytes(metrics.memory.total)}`}
            value={metrics.summary.memory}
            tone="memory"
            sparkline={metrics.memory.history}
            stats={[
              { label: 'Cached', value: formatBytes(metrics.memory.cached) },
              { label: 'Swap', value: `${formatBytes(metrics.memory.swapUsed)} / ${formatBytes(metrics.memory.swapTotal)}` },
            ]}
          />
          <GaugeCard
            title="Network throughput"
            subtitle={`${metrics.network.latency}ms avg latency`}
            value={metrics.summary.network}
            tone="network"
            sparkline={metrics.network.history}
            stats={[
              { label: 'Packet loss', value: `${metrics.network.packetLoss}%` },
              { label: 'Interfaces', value: metrics.network.interfaces.length },
            ]}
          />
        </div>
      </Section>

      <Section title="Storage & IO" subtitle="Volume health, queue depth, and live progress">
        <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '1.5rem' }}>
          <Panel>
            <h3 style={{ marginTop: 0 }}>Volume usage</h3>
            <div style={{ display: 'grid', gap: '1rem', marginTop: '1rem' }}>
              {metrics.disk.volumes.map((volume) => {
                const usage = (volume.used / volume.total) * 100;
                return (
                  <div key={volume.name}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <div>
                        <strong>{volume.name}</strong>
                        <span style={{ marginLeft: '0.5rem', fontSize: '0.85rem', color: '#64748b' }}>
                          {volume.type}
                        </span>
                      </div>
                      <StatusPill status={volume.health} label={volume.health.toUpperCase()} />
                    </div>
                    <ProgressBar value={usage} color={volume.health === 'warn' ? '#f97316' : '#0ea5e9'} />
                    <div style={{ fontSize: '0.85rem', color: '#64748b' }}>
                      {toFixed(volume.used, 1)} TB used of {toFixed(volume.total, 1)} TB
                    </div>
                  </div>
                );
              })}
            </div>
          </Panel>
          <Panel>
            <h3 style={{ marginTop: 0 }}>IO diagnostics</h3>
            <dl style={{ display: 'grid', gap: '0.75rem', margin: '1rem 0 0' }}>
              <MetricRow label="IOPS" value={metrics.disk.iops} />
              <MetricRow label="Queue depth" value={metrics.disk.queue} />
              <MetricRow label="Disk saturation" value={formatPercent(metrics.summary.disk)} />
              <MetricRow label="NVMe temps" value="59°C / 63°C" />
            </dl>
            <div style={{ marginTop: '1.5rem' }}>
              <label style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem' }}>
                <span>IO throttle</span>
                <span>Auto</span>
              </label>
              <input type="range" min="0" max="100" value="64" readOnly style={{ width: '100%' }} />
            </div>
          </Panel>
        </div>
      </Section>

      <Section title="Network & interface telemetry" subtitle="Traffic meters, interface cards, and KPIs">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '1.25rem' }}>
          {metrics.network.interfaces.map((iface) => (
            <Panel key={iface.name}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <strong>{iface.name}</strong>
                <StatusPill status={iface.status} label={iface.status.toUpperCase()} />
              </div>
              <div style={{ marginTop: '1rem', display: 'grid', gap: '0.5rem' }}>
                <MetricRow label="Upstream" value={`${iface.up} Mbps`} />
                <MetricRow label="Downstream" value={`${iface.down} Mbps`} />
                <MetricRow label="Errors" value={iface.status === 'warn' ? '2 spikes' : 'None'} />
              </div>
              <div style={{ marginTop: '1rem' }}>
                <ProgressBar value={Math.min((iface.up + iface.down) / 18, 100)} color="#6366f1" />
              </div>
            </Panel>
          ))}
        </div>
      </Section>

      <Section title="GPU & power" subtitle="Thermal headroom, VRAM, and power draw">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '1.5rem' }}>
          <Panel>
            <h3 style={{ marginTop: 0 }}>GPU engine</h3>
            <Gauge value={metrics.summary.gpu} tone="gpu" label={formatPercent(metrics.summary.gpu)} />
            <div style={{ marginTop: '1rem', display: 'grid', gap: '0.5rem' }}>
              <MetricRow label="VRAM" value={`${toFixed(metrics.gpu.vramUsed, 1)} / ${metrics.gpu.vramTotal} GB`} />
              <MetricRow label="Temp" value={`${toFixed(metrics.gpu.temp, 0)}°C`} />
              <MetricRow label="PCIe" value="x16 Gen4" />
            </div>
          </Panel>
          <Panel>
            <h3 style={{ marginTop: 0 }}>Power bay</h3>
            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
              <Gauge value={metrics.power.battery} tone="network" label={formatPercent(metrics.power.battery)} size={120} />
              <div>
                <p style={{ margin: 0, fontWeight: 600 }}>{metrics.power.status}</p>
                <p style={{ margin: '0.2rem 0', color: '#64748b' }}>{metrics.power.estRemaining} remaining</p>
                <p style={{ margin: 0, color: '#64748b' }}>{metrics.power.draw} W draw</p>
              </div>
            </div>
            <div style={{ marginTop: '1.5rem', display: 'flex', gap: '0.75rem' }}>
              <Toggle label="UPS mode" checked />
              <Toggle label="Eco" checked={false} />
            </div>
          </Panel>
          <Panel>
            <h3 style={{ marginTop: 0 }}>Thermal sensors</h3>
            <div style={{ display: 'grid', gap: '0.75rem' }}>
              {metrics.sensors.map((sensor) => (
                <div key={sensor.label} style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span>{sensor.label}</span>
                  <span style={{ fontWeight: 600 }}>{sensor.value}</span>
                  <StatusDot status={sensor.status} />
                </div>
              ))}
            </div>
          </Panel>
        </div>
      </Section>

      <Section title="Workload activity" subtitle="Process table, alerts, and timeline">
        <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '1.5rem' }}>
          <Panel>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <h3 style={{ margin: 0 }}>Top processes</h3>
              <span style={{ fontSize: '0.85rem', color: '#64748b' }}>Updated {metrics.timestamp.toLocaleTimeString()}</span>
            </div>
            <div style={{ overflowX: 'auto', marginTop: '1rem' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                <thead>
                  <tr style={{ textAlign: 'left', fontSize: '0.8rem', color: '#64748b' }}>
                    <th style={{ paddingBottom: '0.5rem' }}>Process</th>
                    <th style={{ paddingBottom: '0.5rem' }}>CPU</th>
                    <th style={{ paddingBottom: '0.5rem' }}>Memory (GB)</th>
                    <th style={{ paddingBottom: '0.5rem' }}>Threads</th>
                    <th style={{ paddingBottom: '0.5rem' }}>PID</th>
                  </tr>
                </thead>
                <tbody>
                  {metrics.processes.map((process) => (
                    <tr key={process.pid} style={{ borderTop: '1px solid #e2e8f0' }}>
                      <td style={{ padding: '0.65rem 0' }}>
                        <strong>{process.name}</strong>
                        <div style={{ fontSize: '0.75rem', color: '#64748b' }}>
                          <StatusPill status={process.status} label={process.status} compact />
                        </div>
                      </td>
                      <td>{toFixed(process.cpu, 1)}%</td>
                      <td>{toFixed(process.memory, 1)}</td>
                      <td>{process.threads}</td>
                      <td>{process.pid}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </Panel>
          <div style={{ display: 'grid', gap: '1.5rem' }}>
            <Panel>
              <h3 style={{ marginTop: 0 }}>Alert queue</h3>
              <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
                <Badge label={`${alertCounts.ok} ok`} tone="ok" />
                <Badge label={`${alertCounts.warn} warn`} tone="warn" />
                <Badge label={`${alertCounts.danger} danger`} tone="danger" />
                <Badge label={`${alertCounts.info} info`} tone="info" />
              </div>
              <div style={{ display: 'grid', gap: '0.75rem', marginTop: '1rem' }}>
                {metrics.alerts.map((alert) => (
                  <div key={alert.title} style={{ padding: '0.75rem', borderRadius: '0.75rem', background: '#f8fafc' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <strong>{alert.title}</strong>
                      <StatusDot status={alert.status} />
                    </div>
                    <p style={{ margin: '0.35rem 0 0', color: '#64748b', fontSize: '0.85rem' }}>{alert.detail}</p>
                  </div>
                ))}
              </div>
            </Panel>
            <Panel>
              <h3 style={{ marginTop: 0 }}>Runbook timeline</h3>
              <ol style={{ listStyle: 'none', padding: 0, margin: 0, display: 'grid', gap: '0.75rem' }}>
                {metrics.schedule.map((item) => (
                  <li key={item.label} style={{ display: 'grid', gridTemplateColumns: '60px 1fr', gap: '0.75rem' }}>
                    <span style={{ fontWeight: 600 }}>{item.time}</span>
                    <span>
                      {item.label} <StatusPill status={item.status} label={item.status} compact />
                    </span>
                  </li>
                ))}
              </ol>
            </Panel>
          </div>
        </div>
      </Section>

      <Section title="Service widgets" subtitle="Data from the backend widget API">
        {error && <p style={{ color: 'crimson' }}>{error.message}</p>}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '1rem' }}>
          {widgets.length === 0 && !error && <p>Loading widgets...</p>}
          {widgets.map((widget) => (
            <Panel key={widget.id}>
              <h4 style={{ marginTop: 0 }}>{widget.title}</h4>
              <p style={{ margin: '0.35rem 0', fontSize: '1.5rem', fontWeight: 600 }}>{widget.value}</p>
              <p style={{ margin: 0, color: '#64748b' }}>{widget.trend}</p>
            </Panel>
          ))}
        </div>
      </Section>

      <Section title="Telemetry table" subtitle="CSV monitoring preview">
        <TableWatcher onTelemetryPlaceholderChange={setTelemetryFallback} onBackendDown={setBackendFallback} />
      </Section>

      <Section title="Knobs & runtime configuration" subtitle="Build-time discovery and runtime flags">
        <KnobPanel widgets={widgets} />
      </Section>
    </main>
  );
}

function Header({ metrics }) {
  return (
    <header
      style={{
        display: 'flex',
        flexWrap: 'wrap',
        justifyContent: 'space-between',
        alignItems: 'center',
        gap: '1rem',
        marginBottom: '2.5rem',
      }}
    >
      <div>
        <p style={{ margin: 0, textTransform: 'uppercase', letterSpacing: '0.18em', fontSize: '0.7rem', color: '#64748b' }}>
          Host resource monitor
        </p>
        <h1 style={{ margin: '0.35rem 0' }}>Nebula OS Control Deck</h1>
        <p style={{ margin: 0, color: '#64748b' }}>
          {metrics.host.name} · {metrics.host.os} · Kernel {metrics.host.kernel} · Uptime {formatUptime(metrics.uptimeSeconds)}
        </p>
      </div>
      <div style={{ display: 'flex', gap: '0.75rem', flexWrap: 'wrap' }}>
        <Badge label={`IP ${metrics.host.ip}`} tone="info" />
        <Badge label={`Location ${metrics.host.location}`} tone="ok" />
        <Badge label={`Updated ${metrics.timestamp.toLocaleTimeString()}`} tone="warn" />
      </div>
    </header>
  );
}

function Section({ title, subtitle, children }) {
  return (
    <section style={{ marginBottom: '2.5rem' }}>
      <div style={{ marginBottom: '1.25rem' }}>
        <h2 style={{ margin: 0 }}>{title}</h2>
        {subtitle && <p style={{ margin: '0.25rem 0 0', color: '#64748b' }}>{subtitle}</p>}
      </div>
      {children}
    </section>
  );
}

function Panel({ children }) {
  return (
    <div
      style={{
        background: '#fff',
        borderRadius: '1rem',
        padding: '1.5rem',
        boxShadow: '0 15px 40px rgba(15, 23, 42, 0.08)',
        border: '1px solid #e2e8f0',
      }}
    >
      {children}
    </div>
  );
}

function SummaryCard({ label, value, delta, tone }) {
  return (
    <Panel>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <span style={{ fontSize: '0.85rem', color: '#64748b' }}>{label}</span>
        <Badge label={delta} tone="info" />
      </div>
      <div style={{ fontSize: '2rem', fontWeight: 600, marginTop: '0.75rem' }}>{value}</div>
      <div style={{ marginTop: '1rem' }}>
        <ProgressBar value={Number.parseFloat(value)} color={RING_COLORS[tone][1]} />
      </div>
    </Panel>
  );
}

function GaugeCard({ title, subtitle, value, tone, sparkline, stats }) {
  return (
    <Panel>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: '1rem' }}>
        <div>
          <h3 style={{ margin: 0 }}>{title}</h3>
          <p style={{ margin: '0.35rem 0', color: '#64748b' }}>{subtitle}</p>
        </div>
        <Gauge value={value} tone={tone} label={formatPercent(value)} />
      </div>
      <div style={{ marginTop: '1rem' }}>
        <Sparkline data={sparkline} tone={tone} />
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(120px, 1fr))', gap: '0.75rem', marginTop: '1rem' }}>
        {stats.map((stat) => (
          <div key={stat.label}>
            <div style={{ fontSize: '0.7rem', textTransform: 'uppercase', letterSpacing: '0.1em', color: '#94a3b8' }}>
              {stat.label}
            </div>
            <div style={{ fontWeight: 600 }}>{stat.value}</div>
          </div>
        ))}
      </div>
    </Panel>
  );
}

function Gauge({ value, tone, label, size = 110 }) {
  const [track, fill] = RING_COLORS[tone] ?? ['#1f2937', '#38bdf8'];
  const degrees = clamp(value, 0, 100) * 3.6;

  return (
    <div
      style={{
        width: size,
        height: size,
        borderRadius: '50%',
        background: `conic-gradient(${fill} ${degrees}deg, ${track} 0deg)`,
        display: 'grid',
        placeItems: 'center',
      }}
    >
      <div
        style={{
          width: size * 0.68,
          height: size * 0.68,
          borderRadius: '50%',
          background: '#fff',
          display: 'grid',
          placeItems: 'center',
          fontWeight: 600,
        }}
      >
        {label}
      </div>
    </div>
  );
}

function Sparkline({ data, tone }) {
  const width = 240;
  const height = 60;
  const [track, fill] = RING_COLORS[tone] ?? ['#1f2937', '#38bdf8'];
  const points = data.map((value, index) => {
    const x = (index / (data.length - 1)) * width;
    const y = height - (value / 100) * height;
    return `${x},${y}`;
  });
  return (
    <svg width="100%" height={height} viewBox={`0 0 ${width} ${height}`}>
      <polyline fill="none" stroke={track} strokeWidth="6" opacity="0.15" points={`0,${height} ${width},${height}`} />
      <polyline fill="none" stroke={fill} strokeWidth="3" points={points.join(' ')} />
    </svg>
  );
}

function ProgressBar({ value, color }) {
  return (
    <div style={{ background: '#e2e8f0', borderRadius: '999px', height: '8px', overflow: 'hidden' }}>
      <div style={{ width: `${clamp(value, 0, 100)}%`, background: color, height: '100%' }} />
    </div>
  );
}

function MetricRow({ label, value }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
      <span style={{ color: '#64748b' }}>{label}</span>
      <span style={{ fontWeight: 600 }}>{value}</span>
    </div>
  );
}

function StatusPill({ status, label, compact = false }) {
  return (
    <span
      style={{
        background: `${STATUS_COLORS[status] ?? '#94a3b8'}1a`,
        color: STATUS_COLORS[status] ?? '#475569',
        padding: compact ? '0.1rem 0.4rem' : '0.2rem 0.6rem',
        borderRadius: '999px',
        fontSize: compact ? '0.65rem' : '0.75rem',
        textTransform: 'uppercase',
        letterSpacing: '0.08em',
        fontWeight: 600,
      }}
    >
      {label}
    </span>
  );
}

function StatusDot({ status }) {
  return (
    <span
      style={{
        width: '0.6rem',
        height: '0.6rem',
        borderRadius: '999px',
        background: STATUS_COLORS[status] ?? '#94a3b8',
        display: 'inline-block',
        marginLeft: '0.5rem',
      }}
    />
  );
}

function Badge({ label, tone }) {
  return (
    <span
      style={{
        padding: '0.35rem 0.75rem',
        borderRadius: '999px',
        background: `${STATUS_COLORS[tone] ?? '#94a3b8'}1a`,
        color: STATUS_COLORS[tone] ?? '#475569',
        fontSize: '0.75rem',
        fontWeight: 600,
      }}
    >
      {label}
    </span>
  );
}

function Toggle({ label, checked }) {
  return (
    <label style={{ display: 'inline-flex', alignItems: 'center', gap: '0.5rem', fontSize: '0.85rem' }}>
      <span>{label}</span>
      <span
        style={{
          width: '2.2rem',
          height: '1.2rem',
          borderRadius: '999px',
          background: checked ? '#22c55e' : '#cbd5f5',
          position: 'relative',
        }}
      >
        <span
          style={{
            width: '1rem',
            height: '1rem',
            borderRadius: '50%',
            background: '#fff',
            position: 'absolute',
            top: '0.1rem',
            left: checked ? '1.1rem' : '0.1rem',
            transition: 'left 0.2s ease',
          }}
        />
      </span>
    </label>
  );
}

function parseCsv(text) {
  const lines = text
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean);

  if (lines.length === 0) {
    return { headers: [], rows: [] };
  }

  const cells = lines.map((line) => line.split(',').map((cell) => cell.trim()));
  const headers = cells[0];
  const rows = cells.slice(1).map((row) => headers.map((_, index) => row[index] ?? ''));

  return { headers, rows };
}

function TableWatcher({ onTelemetryPlaceholderChange, onBackendDown }) {
  const [tableData, setTableData] = useState({ headers: [], rows: [] });
  const [error, setError] = useState(null);
  const [lastUpdated, setLastUpdated] = useState(null);

  useEffect(() => {
    let active = true;
    let previousContent = null;

    const fetchTable = async () => {
      try {
        const response = await fetch(TABLE_URL, { cache: 'no-store' });
        if (!response.ok) {
          throw new Error('failed to load telemetry.csv');
        }
        if (onTelemetryPlaceholderChange) {
          const usedFallback = response.headers.get('x-telemetry-placeholder') === 'true';
          onTelemetryPlaceholderChange(usedFallback);
        }
        if (onBackendDown) {
          onBackendDown(false);
        }
        const text = await response.text();
        if (!active) return;
        if (text !== previousContent) {
          previousContent = text;
          setTableData(parseCsv(text));
          setLastUpdated(new Date());
        }
      } catch (err) {
        if (active) {
          setError(err);
          if (onBackendDown) {
            onBackendDown(true);
          }
          if (onTelemetryPlaceholderChange) {
            onTelemetryPlaceholderChange(false);
          }
        }
      }
    };

    fetchTable();
    const intervalId = setInterval(fetchTable, 4000);

    return () => {
      active = false;
      clearInterval(intervalId);
    };
  }, []);

  return (
    <div style={{ marginTop: '0.5rem' }}>
      <p style={{ marginTop: '0.35rem', color: '#64748b' }}>
        Watching <code>/api/telemetry.csv</code> for updates.
        {lastUpdated && (
          <>
            {' '}
            Last updated: <strong>{lastUpdated.toLocaleTimeString()}</strong>.
          </>
        )}
      </p>
      {error && <p style={{ color: 'crimson' }}>{error.message}</p>}
      {tableData.headers.length === 0 ? (
        <p style={{ fontStyle: 'italic' }}>No rows found yet.</p>
      ) : (
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: '0.75rem' }}>
            <thead>
              <tr>
                {tableData.headers.map((header) => (
                  <th
                    key={header}
                    style={{
                      textAlign: 'left',
                      borderBottom: '2px solid #e2e8f0',
                      padding: '0.5rem',
                      background: '#f8fafc',
                    }}
                  >
                    {header}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {tableData.rows.map((row, rowIndex) => (
                <tr key={row.join('-') || rowIndex}>
                  {row.map((cell, cellIndex) => (
                    <td key={`${cell}-${cellIndex}`} style={{ padding: '0.45rem 0.5rem', borderBottom: '1px solid #f1f5f9' }}>
                      {cell}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

/* controllable, low-stakes variation points (knobs) */
const buildKnobFiles = Object.keys(import.meta.glob('./mydash*.*'));

function KnobPanel({ widgets }) {
  const [runtimeConfig, setRuntimeConfig] = useState(null);
  const [runtimeError, setRuntimeError] = useState(null);

  useEffect(() => {
    let alive = true;

    fetch(`${API_URL}/api/runtime-config`)
      .then((response) => {
        if (!response.ok) throw new Error('runtime config not reachable');
        return response.json();
      })
      .then((config) => alive && setRuntimeConfig(config))
      .catch((err) => alive && setRuntimeError(err));

    return () => {
      alive = false;
    };
  }, []);

  const runtimeMessage = runtimeConfig?.runtimeMessage ?? 'Runtime config not loaded yet';
  const runtimeAccent = runtimeConfig?.highlightKnob ? '#daf1ff' : '#f8fafc';
  const runtimeExtra = runtimeConfig?.popoverText;

  const conventionWidgets = widgets.map((widget) => {
    const hasConvention = widget.title.includes('::');
    const [rawCategory, rawTitle] = widget.title.split('::');
    const category = hasConvention ? rawCategory.trim() : null;
    const displayTitle = hasConvention ? (rawTitle?.trim() || widget.title) : widget.title;
    const palette = category ? `hsl(${(category.length * 37) % 360} 60% 92%)` : '#fff';
    return { ...widget, category, displayTitle, palette };
  });

  return (
    <div style={{ borderTop: '1px solid #e2e8f0', marginTop: '1.5rem', paddingTop: '1.5rem' }}>
      <div style={{ display: 'grid', gap: '1.5rem' }}>
        <div>
          <h3>Build-time discovery</h3>
          {buildKnobFiles.length === 0 ? (
            <p style={{ fontStyle: 'italic' }}>No files beginning with `mydash` were found.</p>
          ) : (
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.5rem' }}>
              {buildKnobFiles.map((path) => (
                <div
                  key={path}
                  style={{
                    background: '#e2e8f0',
                    padding: '0.75rem 1rem',
                    minWidth: '130px',
                    color: '#334155',
                    borderRadius: '0.75rem',
                  }}
                >
                  {path.replace('./', '')}
                </div>
              ))}
            </div>
          )}
        </div>

        <div>
          <h3>Runtime config</h3>
          <div
            style={{
              background: runtimeAccent,
              padding: '0.75rem 1rem',
              borderRadius: '0.75rem',
              border: '1px solid #e2e8f0',
            }}
          >
            <p style={{ margin: 0 }}>{runtimeMessage}</p>
            {runtimeExtra && <p style={{ margin: '0.25rem 0 0', fontSize: '0.85rem' }}>{runtimeExtra}</p>}
            {runtimeError && <p style={{ margin: '0.25rem 0 0', color: 'crimson' }}>{runtimeError.message}</p>}
          </div>
        </div>

        <div>
          <h3>Convention tweak</h3>
          <div style={{ display: 'grid', gap: '0.75rem' }}>
            {conventionWidgets.map((widget) => (
              <article
                key={widget.id}
                style={{
                  padding: '0.75rem 1rem',
                  borderRadius: '0.75rem',
                  background: widget.palette,
                  border: '1px solid #e2e8f0',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'baseline', gap: '0.5rem' }}>
                  {widget.category && (
                    <span
                      style={{
                        background: '#fff',
                        padding: '0.1rem 0.5rem',
                        borderRadius: '999px',
                        fontSize: '0.7rem',
                        textTransform: 'uppercase',
                        letterSpacing: '0.08em',
                      }}
                    >
                      {widget.category}
                    </span>
                  )}
                  <strong>{widget.displayTitle}</strong>
                </div>
                <p style={{ margin: '0.35rem 0 0' }}>Value: {widget.value}</p>
                <p style={{ margin: 0, fontSize: '0.85rem', color: '#64748b' }}>Trend: {widget.trend}</p>
              </article>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
/* end of knobs */
