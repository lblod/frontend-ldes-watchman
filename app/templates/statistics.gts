import StatisticsOverviewComponent from 'frontend-ldes-watchman/components/statistics-overview';
import type { TOC } from '@ember/component/template-only';
import type { StatisticsModel } from 'frontend-ldes-watchman/types/statistics';

interface StatisticsTemplateSignature {
  Args: {
    model: StatisticsModel;
  };
}

<template>
  <StatisticsOverviewComponent @model={{@model}} />
</template> satisfies TOC<StatisticsTemplateSignature>;
