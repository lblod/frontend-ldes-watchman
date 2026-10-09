import { helper } from '@ember/component/helper';
import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';

dayjs.extend(relativeTime);

type FromNowSignature = {
  Args: {
    Positional: [time: string];
  };
  Return: string;
};

/**
 * Formats the timestamp it received, followed by the relative time
 * (e.g. "a few minutes ago").
 *
 * ```html
 * <p>{{from-now @time}}</p>
 * ```
 */
export default helper<FromNowSignature>(function fromNow([time]) {
  return `${time}, ${dayjs(time).fromNow()}`;
});
