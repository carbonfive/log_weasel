import { LogWeasel } from '../logWeasel';

describe('init', () => {
  it('throws an error if key is not passed', () => {
    expect(() => LogWeasel.init()).toThrowErrorMatchingSnapshot();
  });
});

describe('generateId', () => {
  beforeAll(() => {
    LogWeasel.init('weasel-gang-service');
  });

  it('returns a Log Weasel ID with a constant case app name', () => {
    expect(LogWeasel.generateId()).toMatch(/^[0-9A-Z]{26}-WEASEL_GANG_SERVICE-JS$/);
  });

  it('returns a different Log Weasel ID each time it is called', () => {
    const firstId = LogWeasel.generateId();
    const secondId = LogWeasel.generateId();

    expect(firstId).not.toEqual(secondId);
  });
});

