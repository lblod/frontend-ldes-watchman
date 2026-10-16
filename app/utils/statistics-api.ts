import type { SparqlError, Statistics } from '../types/statistics';

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

export async function fetchSparqlErrors(
  streamUri: string,
  params?: { from: string; to: string },
): Promise<SparqlError[]> {
  const url = new URL(
    `${document.location.protocol}//${document.location.host}/ldes-watchman-api/sparql-errors`,
  );
  url.searchParams.set('streamUri', streamUri);
  if (params) {
    url.searchParams.set('from', params.from);
    url.searchParams.set('to', params.to);
  }

  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Failed to fetch errors: ${response.status}`);
  }
  return (await response.json()) as SparqlError[];
}
