import { ulid } from 'ulid';
import { constantCase } from 'constant-case';

let globalKey;

const LogWeasel = {
  init: (key) => {
    if (typeof key === 'undefined') {
      throw new TypeError('LogWeasel.init requires a key argument');
    }

    globalKey = constantCase(key);
  },

  generateId: () => `${ulid()}-${globalKey}-JS`,
};

export { LogWeasel };
export default LogWeasel;
