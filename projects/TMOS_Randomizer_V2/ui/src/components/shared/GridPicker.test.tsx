// @vitest-environment jsdom
import { test, expect } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { useRef } from 'react';
import { GridPicker } from './GridPicker';

function Harness({ onPick }: { onPick: (id: number) => void }) {
  const ref = useRef<HTMLButtonElement>(null);
  return (
    <>
      <button ref={ref}>anchor</button>
      <GridPicker
        items={[{ id: 1, label: 'Alpha', hex: '0x01' }, { id: 2, label: 'Beta', hex: '0x02' }]}
        currentId={1} onPick={onPick} onClose={() => {}} anchorRef={ref}
      />
    </>
  );
}

test('filters by label and emits id on pick', () => {
  const picks: number[] = [];
  render(<Harness onPick={(id) => picks.push(id)} />);
  fireEvent.change(screen.getByPlaceholderText(/filter/i), { target: { value: 'Beta' } });
  fireEvent.click(screen.getByText('Beta'));
  expect(picks).toEqual([2]);
});
