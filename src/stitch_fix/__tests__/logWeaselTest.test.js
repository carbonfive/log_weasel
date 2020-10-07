import { LogWeasel } from '../logWeasel';

describe('init', () => {
  it('needs a key', () => {
    expect(() => LogWeasel.init()).toThrow();
  });
});

describe('generateId', () => {
  beforeAll(() => {
    LogWeasel.init('WEASEL');
  });

  it('returns a Log Weasel ID', () => {
    expect(LogWeasel.generateId()).toMatch(/^[0-9A-Z]{26}-WEASEL-JS$/);
  });

  it('returns a different Log Weasel ID each time it is called', () => {
    const firstId = LogWeasel.generateId();
    const secondId = LogWeasel.generateId();

    expect(firstId).not.toEqual(secondId);
  });
});

