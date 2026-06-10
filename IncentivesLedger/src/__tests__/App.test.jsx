import React from 'react';
import { afterEach, describe, expect, it } from 'vitest';
import { cleanup, fireEvent, render, screen, within } from '@testing-library/react';
import App from '../App';
import { actors } from '../data/incentivesLedger';

describe('Incentives Ledger prototype', () => {
  afterEach(() => cleanup());
  it('renders the publication home page and fictional roster counts', () => {
    render(<App />);

    expect(screen.getByText('Incentives Ledger')).toBeTruthy();
    expect(screen.getByText('Track incentives, not tribes.')).toBeTruthy();
    expect(actors).toHaveLength(35);
  });

  it('lets readers browse the roster and open an actor dossier', () => {
    render(<App />);

    fireEvent.click(within(screen.getByRole('navigation', { name: 'Primary navigation' })).getByText('3000 Tyrants'));
    expect(screen.getByText('Fictional roster prototype')).toBeTruthy();

    fireEvent.change(screen.getByLabelText('Search roster'), { target: { value: 'Rocket' } });
    fireEvent.click(screen.getByText('The Rocket King'));

    expect(screen.getByText('Launch logistics founder')).toBeTruthy();
    expect(screen.getByText('Source ledger for this dossier')).toBeTruthy();
    expect(screen.getByText('Machine assistance and human review')).toBeTruthy();
  });

  it('shows methodology and sample incentives file sections', () => {
    render(<App />);

    fireEvent.click(within(screen.getByRole('navigation', { name: 'Primary navigation' })).getByText('Methodology'));
    expect(screen.getByText('Separate facts from interpretation.')).toBeTruthy();
    expect(screen.getByText('Not found must not be treated as does not exist.')).toBeTruthy();

    fireEvent.click(within(screen.getByRole('navigation', { name: 'Primary navigation' })).getByText('The Incentives File'));
    expect(screen.getByText('A repeatable article format')).toBeTruthy();
    expect(screen.getByText('No accusation. Incentives exist. Readers should understand them.')).toBeTruthy();
  });
});
