import React, { useEffect, useState } from 'react';

const API_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:5000';

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
        {/* controllable, low-stakes variation points */}
        <KnobPanel widgets={widgets} />
        {/* end of knobs */}
      </section>
    </main>
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
