import Component from '@glimmer/component';
import AuCard from '@appuniversum/ember-appuniversum/components/au-card';
import AuHeading from '@appuniversum/ember-appuniversum/components/au-heading';

type StatCardSignature = {
  Element: HTMLDivElement;
  Args: {
    title: string;
    value: string | number;
    description?: string;
  };
};

export default class StatCard extends Component<StatCardSignature> {
  get displayValue() {
    const { value } = this.args;
    if (typeof value !== 'number') {
      return value;
    }
    return value.toLocaleString('en-US', { maximumFractionDigits: 2 });
  }

  <template>
    <AuCard @size="small" @textCenter={{true}} as |card|>
      <card.header>
        <AuHeading @level="5" @skin="5">{{@title}}</AuHeading>
      </card.header>
      <card.content>
        <div class="stat-card__value">{{this.displayValue}}</div>
        {{#if @description}}
          <p class="au-u-muted au-u-margin-top-tiny">{{@description}}</p>
        {{/if}}
      </card.content>
    </AuCard>
  </template>
}
