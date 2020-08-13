import { ulid } from 'ulid';

let globalKey;

const LogWeasel = {
  init: (key) => {
    if (typeof key === 'undefined') {
      throw new TypeError('key must be supplied');
    }

    globalKey = key;
  },

  generateId: () => {
    const formattedKey = `${globalKey}-WEB`;

    return `${ulid()}-${formattedKey}`;
  },
};

export { LogWeasel };
export default LogWeasel;
