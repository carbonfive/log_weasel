import { ulid } from 'ulid';
import { constantCase } from 'constant-case';

const generateId = (key) => {
  if (typeof key === 'undefined') {
    throw new TypeError('LogWeasel generateID requires a key argument');
  }

  return `${ulid()}-${constantCase(key)}-JS`;
};

export default generateId;
