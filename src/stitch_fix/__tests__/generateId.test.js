import generateId from '../generateId';

const appName = 'weasel-gang-ui';

describe('generateId', () => {
  it('throws an error if key is not passed', () => {
    expect(() => generateId()).toThrowErrorMatchingSnapshot();
  });

  it('returns a Log Weasel ID with a constant case app name', () => {
    expect(generateId(appName)).toMatch(/^[0-9A-Z]{26}-WEASEL_GANG_UI-JS$/);
  });

  it('returns a different Log Weasel ID each time it is called', () => {
    const firstId = generateId(appName);
    const secondId = generateId(appName);

    expect(firstId).not.toEqual(secondId);
  });
});
