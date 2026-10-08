export type Statistics = {
  instanceCount: number;
  typeDistribution: { type: string; count: number }[];
  timeDistribution?: { bucket: string; count: number }[];
  pagesProcessed: number;
  errorCount: number;
  lastProcessedPage: { page: string; time: string } | null;
  averageLoadDuration: number;
  averageProcessingDuration: number;
};

export type StatisticsModel = {
  total: Statistics;
  lastDay: Statistics;
};
