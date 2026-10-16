import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { action } from '@ember/object';
import AuButton from '@appuniversum/ember-appuniversum/components/au-button';
import AuCard from '@appuniversum/ember-appuniversum/components/au-card';
import AuHeading from '@appuniversum/ember-appuniversum/components/au-heading';
import type { SparqlError } from 'frontend-ldes-watchman/types/statistics';
import FromNow from '../helpers/from-now.gts';

type SparqlErrorsCardSignature = {
  Element: HTMLDivElement;
  Args: {
    errors: SparqlError[];
  };
};

const MAX_ERRORS = 5;

export default class SparqlErrorsCard extends Component<SparqlErrorsCardSignature> {
  @tracked expanded = false;

  get visibleErrors(): SparqlError[] {
    return this.expanded
      ? this.args.errors
      : this.args.errors.slice(0, MAX_ERRORS);
  }

  get hasMore(): boolean {
    return !this.expanded && this.args.errors.length > MAX_ERRORS;
  }

  @action
  expand() {
    this.expanded = true;
  }

  <template>
    <AuCard @shadow={{true}} as |card|>
      <card.header>
        <AuHeading @level="3" @skin="4" class="au-u-margin-bottom-none">
          Sparql validation errors (last 30 days)
        </AuHeading>
      </card.header>
      <card.content>
        {{#each this.visibleErrors as |error|}}
          <p class="au-u-margin-bottom-tiny">
            <strong>{{error.name}}</strong>
            —
            {{FromNow error.time}}
            {{#if error.result}}
              <span class="au-u-muted">
                ({{error.result}})
              </span>
            {{/if}}
          </p>
        {{/each}}
        {{#if this.hasMore}}
          <AuButton {{on "click" this.expand}}>
            Show more
          </AuButton>
        {{/if}}
      </card.content>
    </AuCard>
  </template>
}
