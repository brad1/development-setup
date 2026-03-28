import React from 'react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import App from '../App';

describe('Dashboard app', () => {
  beforeEach(() => {
    window.history.replaceState({}, '', '/');
    global.fetch = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({
        host: {
          hostname: 'ubuntu22-devbox',
          kernel: 'Linux 5.15.0-101-generic',
          cpu_count: 8,
        },
        uptime: {
          pretty: '2 days, 4:33',
          load: { one: 0.2, five: 0.35, fifteen: 0.41 },
        },
        memory: {
          total_bytes: 100,
          used_bytes: 40,
          available_bytes: 60,
          swap_total_bytes: 50,
          swap_used_bytes: 5,
        },
        filesystems: [{ mount: '/', used_bytes: 40, available_bytes: 60, use_percent: 40 }],
        network_interfaces: [{ name: 'eth0', state: 'UP', addresses: ['192.168.1.4/24'] }],
        top_processes: [{ pid: 1, command: 'init', cpu_percent: 0.1, memory_percent: 0.2 }],
        sources: {
          uptime: 'uptime',
          memory: 'free -b',
          filesystems: 'df',
          network: 'ip',
          processes: 'ps',
        },
      }),
    });
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('renders the main dashboard heading', () => {
    render(<App />);

    expect(screen.getByTestId('dashboard-heading')).toBeTruthy();
    expect(window.location.pathname).toBe('/simple');
  });
});
