import StatisticsOverviewComponent from 'frontend-ldes-watchman/components/statistics-overview';
import type { TOC } from '@ember/component/template-only';
import type { StatisticsModel } from 'frontend-ldes-watchman/types/statistics';
import AuHeading from '@appuniversum/ember-appuniversum/components/au-heading';
import PowerSelect from 'ember-power-select/components/power-select';
import { fn } from '@ember/helper';
import type StatisticsController from 'frontend-ldes-watchman/controllers/statistics.gts';
interface StatisticsTemplateSignature {
  Args: {
    model: StatisticsModel;
    controller: StatisticsController;
  };
}

<template>
  <div
    class="au-u-flex au-u-flex--vertical-center au-u-flex--between au-u-margin-bottom"
  >
    <AuHeading @level="1" @skin="2" class="au-u-margin-bottom-none">
      Statistics
    </AuHeading>
    <PowerSelect
      @options={{@model.availableStreams}}
      @searchEnabled={{true}}
      @selected={{@controller.currentStream}}
      @renderInPlace={{true}}
      @onChange={{fn (mut @controller.streamUri)}}
      as |stream|
    >
      {{stream}}
    </PowerSelect>
  </div>
  <StatisticsOverviewComponent @model={{@model}} />
</template> satisfies TOC<StatisticsTemplateSignature>;
