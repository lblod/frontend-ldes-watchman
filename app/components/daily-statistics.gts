import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import type Owner from '@ember/owner';
import type { StatisticsModel, Statistics } from '../types/statistics';
import type { EChartsOption } from 'echarts';
import AuCard from '@appuniversum/ember-appuniversum/components/au-card';
import AuButton from '@appuniversum/ember-appuniversum/components/au-button';
import AuHeading from '@appuniversum/ember-appuniversum/components/au-heading';
import StatCard from './stat-card.gts';
import EchartsChart from './echarts-chart.gts';
import { fetchStatistics } from '../utils/statistics-api';

type DailyStatisticsSignature = {
  Element: HTMLDivElement;
  Args: {
    model: StatisticsModel;
  };
};

const MS_PER_DAY = 24 * 60 * 60 * 1000;
const MS_PER_HOUR = 60 * 60 * 1000;

/**
 * Fill in missing hourly buckets ("YYYY-MM-DDTHH") between the
 * first and last bucket with count 0.
 */
function fillGaps(buckets: { bucket: string; count: number }[]) {
  if (buckets.length < 2) {
    return buckets;
  }
  const counts = new Map(buckets.map((b) => [b.bucket, b.count]));

  const toMs = (bucket: string) => Date.parse(`${bucket}:00Z`);

  let time = toMs(buckets[0]!.bucket);
  const result: { bucket: string; count: number }[] = [];
  const end = toMs(buckets[buckets.length - 1]!.bucket);
  while (time <= end) {
    const bucket = new Date(time).toISOString().slice(0, 13);
    result.push({ bucket, count: counts.get(bucket) ?? 0 });
    time += MS_PER_HOUR;
  }
  return result;
}

function toDateTimeLocalValue(date: Date): string {
  const pad = (n: number) => String(n).padStart(2, '0');
  return (
    `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}` +
    `T${pad(date.getHours())}:${pad(date.getMinutes())}`
  );
}

function dateTimeFormat(date: Date): string {
  return date.toLocaleString('nl-BE', {
    dateStyle: 'short',
    timeStyle: 'short',
  });
}

export default class DailyStatistics extends Component<DailyStatisticsSignature> {
  @tracked period: { from: Date; to: Date };
  @tracked override: { model: StatisticsModel; stats: Statistics } | null =
    null;
  @tracked loading = false;
  @tracked manualFrom: string;
  @tracked manualTo: string;

  constructor(owner: Owner, args: DailyStatisticsSignature['Args']) {
    super(owner, args);
    const now = new Date();
    this.period = { from: new Date(now.getTime() - MS_PER_DAY), to: now };
    this.manualFrom = toDateTimeLocalValue(this.period.from);
    this.manualTo = toDateTimeLocalValue(this.period.to);
  }

  get stats(): Statistics {
    return this.override && this.override.model === this.args.model
      ? this.override.stats
      : this.args.model.lastDay;
  }

  get now(): Date {
    return new Date();
  }

  get canGoForward(): boolean {
    return this.period.to.getTime() < this.now.getTime();
  }

  get cannotGoForward(): boolean {
    return !this.canGoForward;
  }

  get hasTimeDistribution(): boolean {
    return (this.stats.timeDistribution?.length ?? 0) > 0;
  }

  get hasTypeDistribution(): boolean {
    return this.stats.typeDistribution.length > 0;
  }

  get timeChartOptions(): EChartsOption {
    const distribution = fillGaps(this.stats.timeDistribution ?? []);
    return {
      tooltip: { trigger: 'axis' },
      grid: { top: 30, left: 40, right: 20, bottom: 60 },
      xAxis: {
        type: 'category',
        name: 'hour',
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
    const distribution = this.stats.typeDistribution;
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

  async refreshStats() {
    this.loading = true;
    try {
      this.override = {
        model: this.args.model,
        stats: await fetchStatistics(this.args.model.streamUri, {
          from: this.period.from.toISOString(),
          to: this.period.to.toISOString(),
        }),
      };
    } finally {
      this.loading = false;
    }
  }

  updatePeriod(from: Date, to: Date) {
    this.period = { from, to };
    this.manualFrom = toDateTimeLocalValue(from);
    this.manualTo = toDateTimeLocalValue(to);
    void this.refreshStats();
  }

  @action
  goBackADay() {
    this.updatePeriod(
      new Date(this.period.from.getTime() - MS_PER_DAY),
      new Date(this.period.to.getTime() - MS_PER_DAY),
    );
  }

  @action
  goForwardADay() {
    this.updatePeriod(
      new Date(this.period.from.getTime() + MS_PER_DAY),
      new Date(this.period.to.getTime() + MS_PER_DAY),
    );
  }

  @action
  applyManualPeriod() {
    const from = new Date(this.manualFrom);
    const to = new Date(this.manualTo);
    if (Number.isNaN(from.getTime()) || Number.isNaN(to.getTime())) {
      return;
    }
    this.updatePeriod(from, to);
  }

  @action
  setManualFrom(event: Event) {
    this.manualFrom = (event.target as HTMLInputElement).value;
  }

  @action
  setManualTo(event: Event) {
    this.manualTo = (event.target as HTMLInputElement).value;
  }

  <template>
    <AuHeading @level="2" @skin="3" class="au-u-margin-bottom-small">
      Daily statistics
    </AuHeading>
    <div
      class="au-u-flex au-u-flex--vertical-center au-u-margin-bottom au-u-flex--between"
    >
      <div class="au-u-flex au-u-flex--vertical-center">

        <input
          class="ldes-mon-datetime-input"
          id="daily-period-start"
          type="datetime-local"
          value={{this.manualFrom}}
          {{on "change" this.setManualFrom}}
        />
        <label for="daily-period-end" class="au-u-padding-small">to</label>
        <input
          class="ldes-mon-datetime-input"
          id="daily-period-end"
          type="datetime-local"
          value={{this.manualTo}}
          {{on "change" this.setManualTo}}
        />
        <AuButton
          @skin="secondary"
          class="au-u-margin-left-small"
          {{on "click" this.applyManualPeriod}}
        >
          Set period
        </AuButton>
      </div>
      <div>
        <AuButton
          @icon="chevron-left"
          @skin="naked"
          {{on "click" this.goBackADay}}
        >
          Back a day
        </AuButton>
        <AuButton
          @icon="chevron-right"
          @skin="naked"
          @disabled={{this.cannotGoForward}}
          {{on "click" this.goForwardADay}}
        >
          Forward a day
        </AuButton>
      </div>
    </div>
    <div class="stats-grid au-u-margin-bottom">
      <StatCard
        @title="Instances"
        @value={{this.stats.instanceCount}}
        @description="LDES members processed"
      />
      <StatCard
        @title="Pages"
        @value={{this.stats.pagesProcessed}}
        @description="Pages processed"
      />
      <StatCard
        @title="Errors"
        @value={{this.stats.errorCount}}
        @description="Errors recorded"
      />
      <StatCard
        @title="Avg. load"
        @value={{this.stats.averageLoadDuration}}
        @description="ms per page"
      />
      <StatCard
        @title="Avg. processing"
        @value={{this.stats.averageProcessingDuration}}
        @description="ms per page"
      />
    </div>
    {{#if this.hasTimeDistribution}}
      <div class="stats-grid au-u-margin-bottom">
        <AuCard @shadow={{true}} class="au-u-margin-bottom" as |card|>
          <card.header>
            <AuHeading @level="5" @skin="5">
              Instances per hour (selected period)
            </AuHeading>
          </card.header>
          <card.content>
            <EchartsChart @option={{this.timeChartOptions}} />
          </card.content>
        </AuCard>
      </div>
    {{/if}}
    {{#if this.hasTypeDistribution}}
      <div class="stats-grid au-u-margin-bottom">
        <AuCard @shadow={{true}} class="au-u-margin-bottom" as |card|>
          <card.header>
            <AuHeading @level="5" @skin="5">
              Type distribution (selected period)
            </AuHeading>
          </card.header>
          <card.content>
            <EchartsChart @option={{this.typeChartOptions}} />
          </card.content>
        </AuCard>
      </div>
    {{/if}}
  </template>
}
