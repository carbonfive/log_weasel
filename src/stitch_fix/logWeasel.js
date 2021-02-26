import { ulid } from 'ulid';

let globalKey;

const LogWeasel = {
  init: (key) => {
    if (typeof key === 'undefined') {
      throw new TypeError('LogWeasel.init requires a key argument');
    }

    globalKey = key;
  },

  generateId: () => {
    const formattedKey = `${globalKey}-JS`;

    return `${ulid()}-${formattedKey}`;
  },
};

export { LogWeasel };
export default LogWeasel;
