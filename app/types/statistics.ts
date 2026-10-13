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

export type TimeDistribution = { bucket: string; count: number }[];

export type StreamShape = {
  streamUri: string;
  types: {
    type: string;
    predicates: {
      predicate: string;
      datatypes: string[];
    }[];
  }[];
};

export type ShapeDiff = {
  timestampOld: string;
  timestampNew: string;
  oldShape: StreamShape;
  newShape: StreamShape;
};

export type StatisticsModel = {
  total: Statistics;
  lastDay: Statistics;
  lastMonth?: TimeDistribution;
  shapeDiff?: ShapeDiff | null;
  availableStreams: string[];
};
