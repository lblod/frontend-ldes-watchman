import Route from '@ember/routing/route';
import type {
  ShapeDiff,
  StatisticsModel,
  TimeDistribution,
} from 'frontend-ldes-watchman/types/statistics';
import {
  fetchSparqlErrors,
  fetchStatistics,
} from 'frontend-ldes-watchman/utils/statistics-api';

const MS_PER_DAY = 24 * 60 * 60 * 1000;
const MS_PER_MONTH = 30 * MS_PER_DAY;

async function fetchStreams(): Promise<string[]> {
  const url = new URL(
    `${document.location.protocol}//${document.location.host}/ldes-watchman-api/streams`,
  );

  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Failed to fetch streams: ${response.status}`);
  }
  return (await response.json()) as string[];
}

async function fetchShapeDiff(streamUri: string): Promise<ShapeDiff | null> {
  const url = new URL(
    `${document.location.protocol}//${document.location.host}/ldes-watchman-api/shape/diff`,
  );
  url.searchParams.set('streamUri', streamUri);

  const response = await fetch(url);
  if (!response.ok) {
    return null;
  }
  return (await response.json()) as ShapeDiff;
}

type StatisticsParams = {
  streamUri: string;
};

export default class StatisticsRoute extends Route {
  queryParams = {
    streamUri: {
      refreshModel: true,
    },
  };

  async model(params: StatisticsParams): Promise<StatisticsModel> {
    let streamUri = params.streamUri;
    const availableStreams = await fetchStreams();
    if (!streamUri) {
      streamUri = availableStreams[0] as string;
    }
    const now = new Date();
    const yesterday = new Date(now.getTime() - MS_PER_DAY);
    const lastMonth = new Date(now.getTime() - MS_PER_MONTH);

    async function fetchTimeDistribution(from: Date, to: Date) {
      const url = new URL(
        `${document.location.protocol}//${document.location.host}/ldes-watchman-api/statistics/time-distribution`,
      );
      url.searchParams.set('streamUri', streamUri);
      url.searchParams.set('from', from.toISOString());
      url.searchParams.set('to', to.toISOString());

      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(
          `Failed to fetch time distribution: ${response.status}`,
        );
      }
      return (await response.json()) as TimeDistribution;
    }

    const [total, lastDay, shapeDiff, errors] = await Promise.all([
      fetchStatistics(streamUri),
      fetchStatistics(streamUri, {
        from: yesterday.toISOString(),
        to: now.toISOString(),
      }),
      fetchShapeDiff(streamUri),
      fetchSparqlErrors(streamUri, {
        from: lastMonth.toISOString(),
        to: now.toISOString(),
      }),
    ]);

    return {
      streamUri,
      total,
      lastDay,
      lastMonth: await fetchTimeDistribution(lastMonth, now),
      shapeDiff,
      errors,
      availableStreams,
    };
  }
}
