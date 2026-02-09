import React, { useEffect, useState } from 'react';

const API_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:5000';
const TABLE_URL = new URL('./table.csv', import.meta.url);

export default function App() {
  const [widgets, setWidgets] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch(`${API_URL}/api/widgets`)
      .then((response) => {
        if (!response.ok) throw new Error('failed to load widgets');
        return response.json();
      })
      .then((data) => setWidgets(data.widgets ?? []))
      .catch(setError);
  }, []);

  return (
    <main>
      <h1>Dashboard Overview</h1>
      {error && <p style={{ color: 'crimson' }}>{error.message}</p>}
      <section>
        {widgets.length === 0 && !error && <p>Loading widgets...</p>}
        <ul>
          {widgets.map((widget) => (
            <li key={widget.id}>
              <strong>{widget.title}</strong>: {widget.value} ({widget.trend})
            </li>
          ))}
        </ul>
      </section>
      <section>
        <TableWatcher />
      </section>
      <section>
        {/* controllable, low-stakes variation points */}
        <KnobPanel widgets={widgets} />
        {/* end of knobs */}
      </section>
    </main>
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

function TableWatcher() {
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
          throw new Error('failed to load table.csv');
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
    <div style={{ marginTop: '2rem' }}>
      <h2>Live CSV Table</h2>
      <p style={{ marginTop: '0.35rem', color: '#555' }}>
        Watching <code>src/table.csv</code> for updates.
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
                      borderBottom: '2px solid #ccc',
                      padding: '0.5rem',
                      background: '#f7f7f7',
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
                    <td key={`${cell}-${cellIndex}`} style={{ padding: '0.45rem 0.5rem', borderBottom: '1px solid #eee' }}>
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

    fetch('/runtime-config.json')
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
  const runtimeAccent = runtimeConfig?.highlightKnob ? '#daf1ff' : '#f7f7f7';
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
    <div style={{ borderTop: '1px solid #ccc', marginTop: '1.5rem', paddingTop: '1.5rem' }}>
      <h2>Knobs</h2>
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
                    background: '#eee',
                    padding: '0.75rem 1rem',
                    minWidth: '130px',
                    color: '#333',
                    borderRadius: '6px',
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
              borderRadius: '6px',
              border: '1px solid #c1c1c1',
            }}
          >
            <p style={{ margin: 0 }}>{runtimeMessage}</p>
            {runtimeExtra && <p style={{ margin: '0.25rem 0 0', fontSize: '0.85rem' }}>{runtimeExtra}</p>}
            {runtimeError && (
              <p style={{ margin: '0.25rem 0 0', color: 'crimson' }}>{runtimeError.message}</p>
            )}
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
                  borderRadius: '8px',
                  background: widget.palette,
                  border: '1px solid #ddd',
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
                <p style={{ margin: 0, fontSize: '0.85rem', color: '#555' }}>Trend: {widget.trend}</p>
              </article>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
/* end of knobs */
