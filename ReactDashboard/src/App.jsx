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
    </main>
  );
}
