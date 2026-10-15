import type { Statistics } from '../types/statistics';

export async function fetchStatistics(
  streamUri: string,
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
