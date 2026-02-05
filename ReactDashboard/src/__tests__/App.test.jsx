import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import App from '../App';

describe('Dashboard app', () => {
  it('renders the main dashboard heading', () => {
    render(<App />);

    expect(
      screen.getByRole('heading', { name: 'Dashboard Overview' })
    ).toBeVisible();
  });
});
