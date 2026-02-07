import React from 'react';
import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react';
import App from '../App';

describe('Dashboard app', () => {
  it('renders the main dashboard heading', () => {
    render(<App />);

    expect(
      screen.getByRole('heading', { name: 'Dashboard Overview' })
    ).toBeTruthy();
  });
});
