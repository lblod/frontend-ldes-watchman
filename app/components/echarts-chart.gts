import Component from '@glimmer/component';
import { modifier } from 'ember-modifier';
import * as echarts from 'echarts/core';
import type { ECharts, EChartsOption } from 'echarts';
import { SVGRenderer } from 'echarts/renderers';
import { BarChart, PieChart, LineChart } from 'echarts/charts';
import {
  GridComponent,
  TooltipComponent,
  LegendComponent,
} from 'echarts/components';

echarts.use([
  SVGRenderer,
  BarChart,
  PieChart,
  LineChart,
  GridComponent,
  TooltipComponent,
  LegendComponent,
]);

type EchartsChartSignature = {
  Element: HTMLDivElement;
  Args: {
    option: EChartsOption;
  };
};

export default class EchartsChart extends Component<EchartsChartSignature> {
  chart: ECharts | null = null;
  resizeHandler = () => {
    this.chart?.resize();
  };

  setup = modifier((element: HTMLDivElement) => {
    this.chart?.dispose();
    this.chart = echarts.init(element, null, { renderer: 'svg' });
    this.chart.setOption(this.args.option);
    window.addEventListener('resize', this.resizeHandler);

    return () => {
      window.removeEventListener('resize', this.resizeHandler);
      this.chart?.dispose();
      this.chart = null;
    };
  });

  <template>
    <div class="echarts-chart" {{this.setup}}></div>
  </template>
}
