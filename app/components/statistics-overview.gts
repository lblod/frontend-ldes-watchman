import Component from '@glimmer/component';
import type { StatisticsModel } from 'frontend-ldes-watchman/types/statistics';
import type { EChartsOption } from 'echarts';
import AuCard from '@appuniversum/ember-appuniversum/components/au-card';
import AuHeading from '@appuniversum/ember-appuniversum/components/au-heading';
import StatCard from './stat-card.gts';
import EchartsChart from './echarts-chart.gts';
import ShapeChangeCard from './shape-change-card.gts';
import DailyStatistics from './daily-statistics.gts';
import SparqlErrorsCard from './sparql-errors-card.gts';
import FromNow from '../helpers/from-now.gts';

type OverviewSignature = {
  Args: {
    model: StatisticsModel;
  };
};

const MS_PER_DAY = 24 * 60 * 60 * 1000;
const MS_PER_HOUR = 60 * 60 * 1000;

/**
 * Fill in missing buckets between the first and last bucket with count 0.
 * Hourly buckets ("YYYY-MM-DDTHH") are spaced by an hour,
 * daily buckets ("YYYY-MM-DD") by a day.
 */
function fillGaps(buckets: { bucket: string; count: number }[]) {
  if (buckets.length < 2) {
    return buckets;
  }
  const counts = new Map(buckets.map((b) => [b.bucket, b.count]));
  const hourly = buckets[0]!.bucket.length > 10;
  const step = hourly ? MS_PER_HOUR : MS_PER_DAY;

  const toMs = (bucket: string) =>
    Date.parse(hourly ? `${bucket}:00Z` : `${bucket}T00:00Z`);

  let time = toMs(buckets[0]!.bucket);
  const result: { bucket: string; count: number }[] = [];
  const end = toMs(buckets[buckets.length - 1]!.bucket);
  while (time <= end) {
    const bucket = new Date(time).toISOString().slice(0, hourly ? 13 : 10);
    result.push({ bucket, count: counts.get(bucket) ?? 0 });
    time += step;
  }
  return result;
}

export default class Overview extends Component<OverviewSignature> {
  get hasTypeDistribution(): boolean {
    return this.args.model.total.typeDistribution.length > 0;
  }

  get hasMonthTimeDistribution(): boolean {
    return (this.args.model.lastMonth?.length ?? 0) > 0;
  }

  get monthChartOptions(): EChartsOption {
    const distribution = fillGaps(this.args.model.lastMonth ?? []);
    return {
      tooltip: { trigger: 'axis' },
      grid: { top: 30, left: 40, right: 20, bottom: 60 },
      xAxis: {
        type: 'category',
        name: 'day',
        data: distribution.map((d) => d.bucket),
        axisLabel: { rotate: 45 },
      },
      yAxis: { type: 'value', name: 'instances' },
      series: [
        {
          name: 'Instances',
          type: 'bar',
          data: distribution.map((d) => d.count),
        },
      ],
    };
  }

  get typeChartOptions(): EChartsOption {
    const distribution = this.args.model.total.typeDistribution;
    return {
      tooltip: { trigger: 'item' },
      series: [
        {
          name: 'Type distribution',
          type: 'pie',
          radius: '60%',
          data: distribution.map((d) => ({ name: d.type, value: d.count })),
        },
      ],
    };
  }

  <template>
    {{#if @model.total.lastProcessedPage}}
      <div class="stats-grid au-u-margin-bottom">
        <AuCard @shadow={{true}} as |card|>
          <card.header>
            <AuHeading @level="3" @skin="4" class="au-u-margin-bottom-none">
              Last processed page
            </AuHeading>
          </card.header>
          <card.content>
            <p>{{@model.total.lastProcessedPage.page}}</p>
            <p class="au-u-muted">
              Last page processed:
              {{FromNow @model.total.lastProcessedPage.time}}
            </p>
            {{#if @model.total.lastMemberSeen}}
              <p class="au-u-muted au-u-margin-top-none">
                Last member seen:
                {{FromNow @model.total.lastMemberSeen}}
              </p>
            {{/if}}
          </card.content>
        </AuCard>
        {{#if @model.shapeDiff}}
          <ShapeChangeCard @diff={{@model.shapeDiff}} />
        {{/if}}

      </div>
    {{/if}}

    <DailyStatistics @model={{@model}} />

    {{#if @model.errors.length}}
      <div class="stats-grid au-u-margin-bottom">
        <SparqlErrorsCard @errors={{@model.errors}} />
      </div>
    {{/if}}

    {{#if this.hasMonthTimeDistribution}}
      <div class="stats-grid au-u-margin-bottom">
        <AuCard @shadow={{true}} class="au-u-margin-bottom" as |card|>
          <card.header>
            <AuHeading @level="5" @skin="5">
              Instances per day (last 30 days)
            </AuHeading>
          </card.header>
          <card.content>
            <EchartsChart @option={{this.monthChartOptions}} />
          </card.content>
        </AuCard>
      </div>
    {{/if}}

    <AuHeading @level="2" @skin="3" class="au-u-margin-bottom-small">
      Total
    </AuHeading>
    <div class="stats-grid au-u-margin-bottom">
      <StatCard
        @title="Instances"
        @value={{@model.total.instanceCount}}
        @description="LDES members processed"
      />
      <StatCard
        @title="Pages"
        @value={{@model.total.pagesProcessed}}
        @description="Pages processed"
      />
      <StatCard
        @title="Errors"
        @value={{@model.total.errorCount}}
        @description="Errors recorded"
      />
      <StatCard
        @title="Avg. load"
        @value={{@model.total.averageLoadDuration}}
        @description="ms per page"
      />
      <StatCard
        @title="Avg. processing"
        @value={{@model.total.averageProcessingDuration}}
        @description="ms per page"
      />
    </div>

    {{#if this.hasTypeDistribution}}
      <div class="stats-grid au-u-margin-bottom">
        <AuCard @shadow={{true}} class="au-u-margin-bottom" as |card|>
          <card.content>
            <EchartsChart @option={{this.typeChartOptions}} />
          </card.content>
        </AuCard>
      </div>
    {{/if}}
  </template>
}
