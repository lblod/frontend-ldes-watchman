import Route from '@ember/routing/route';
import config from 'frontend-ldes-watchman/config/environment';
import type {
  Statistics,
  StatisticsModel,
} from 'frontend-ldes-watchman/types/statistics';

type StatisticsConfig = {
  streamUri: string;
};

const MS_PER_DAY = 24 * 60 * 60 * 1000;

async function fetchStatistics(
  { streamUri }: StatisticsConfig,
  params?: { from: string; to: string },
): Promise<Statistics> {
  const url = new URL(
    `${document.location.protocol}//${document.location.host}/ldes-watchman-api/statistics`,
  );
  url.searchParams.set('streamUri', streamUri);
  if (params) {
    url.searchParams.set('from', params.from);
    url.searchParams.set('to', params.to);
  }

  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Failed to fetch statistics: ${response.status}`);
  }
  return (await response.json()) as Statistics;
}

export default class StatisticsRoute extends Route {
  async model(): Promise<StatisticsModel> {
    const { streamUri } = config.statistics as StatisticsConfig;
    const now = new Date();
    const yesterday = new Date(now.getTime() - MS_PER_DAY);

    const [total, lastDay] = await Promise.all([
      fetchStatistics({ streamUri }),
      fetchStatistics(
        { streamUri },
        {
          from: yesterday.toISOString(),
          to: now.toISOString(),
        },
      ),
    ]);

    return { total, lastDay };
  }
}
