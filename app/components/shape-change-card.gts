import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { diffLines } from 'diff';
import AuButton from '@appuniversum/ember-appuniversum/components/au-button';
import AuCard from '@appuniversum/ember-appuniversum/components/au-card';
import AuHeading from '@appuniversum/ember-appuniversum/components/au-heading';
import type { ShapeDiff } from 'frontend-ldes-watchman/types/statistics';

type ShapeChangeCardSignature = {
  Element: HTMLDivElement;
  Args: {
    diff: ShapeDiff;
  };
};

type DiffLine = {
  type: 'context' | 'added' | 'removed';
  prefix: string;
  line: string;
};

type CollapsedStretches = {
  /** Start index of the stretch within the full line list. */
  from: number;
  to: number;
  count: number;
};

type RenderedLine = {
  text: string;
  className: string;
  toggle: () => void;
};

/**
 * Render the difference between the two shapes as a git-like diff,
 * one line per line of the (deterministic) JSON serialization of the shapes.
 */
function buildDiffLines(diff: ShapeDiff): DiffLine[] {
  const serialize = (shape: ShapeDiff['oldShape']) =>
    JSON.stringify(shape, null, 2);
  const changes = diffLines(
    `${serialize(diff.oldShape)}\n`,
    `${serialize(diff.newShape)}\n`,
  );

  const lines = [];
  for (const change of changes) {
    const prefix = change.added ? '+' : change.removed ? '-' : ' ';
    const type: DiffLine['type'] = change.added
      ? 'added'
      : change.removed
        ? 'removed'
        : 'context';
    for (const line of change.value.replace(/\n$/, '').split('\n')) {
      lines.push({ type, prefix, line });
    }
  }
  return lines;
}

/** Number of unchanged lines to keep around each change. */
const CONTEXT_LINES = 3;

/**
 * Collapse long stretches of unchanged lines into a single line,
 * keeping CONTEXT_LINES lines of context around every change and
 * every line containing a `"type":` key (without extra context).
 * Stretches whose start index is in `expanded` are not collapsed.
 * Returns the collapsed lines with markers that reference the
 * start index of the stretch they collapsed.
 */
function collapseContext(
  lines: DiffLine[],
  expanded: number[],
): (DiffLine | CollapsedStretches)[] {
  const changedIndexes = [];
  const typeLineIndexes = [];
  for (let index = 0; index < lines.length; index++) {
    const line = lines[index]!;
    if (line.type !== 'context') {
      changedIndexes.push(index);
    } else if (line.line.includes('"type":')) {
      typeLineIndexes.push(index);
    }
  }
  if (changedIndexes.length === 0 && typeLineIndexes.length === 0) {
    return lines;
  }

  const kept = new Set<number>(typeLineIndexes);
  for (const index of changedIndexes) {
    for (
      let neighbour = index - CONTEXT_LINES;
      neighbour <= index + CONTEXT_LINES;
      neighbour++
    ) {
      if (neighbour >= 0 && neighbour < lines.length) {
        kept.add(neighbour);
      }
    }
  }

  const collapsed = [];
  let firstSkipped = 0;
  let skipped = 0;
  for (let index = 0; index < lines.length; index++) {
    if (kept.has(index)) {
      if (skipped > 0) {
        const stretch = { from: firstSkipped, to: index - 1, count: skipped };
        if (expanded.includes(firstSkipped)) {
          collapsed.push(...lines.slice(stretch.from, index));
        } else {
          collapsed.push(stretch);
        }
        skipped = 0;
      }
      collapsed.push(lines[index]!);
    } else if (skipped === 0) {
      firstSkipped = index;
      skipped = 1;
    } else {
      skipped++;
    }
  }
  if (skipped > 0) {
    const stretch = {
      from: firstSkipped,
      to: lines.length - 1,
      count: skipped,
    };
    if (expanded.includes(firstSkipped)) {
      collapsed.push(...lines.slice(stretch.from));
    } else {
      collapsed.push(stretch);
    }
  }
  return collapsed;
}

export default class ShapeChangeCard extends Component<ShapeChangeCardSignature> {
  @tracked showDiff = false;
  @tracked expandedStretches: number[] = [];

  toggleDiff = () => {
    this.showDiff = !this.showDiff;
  };

  toggleStretch = (from: number) => {
    if (this.expandedStretches.includes(from)) {
      this.expandedStretches = this.expandedStretches.filter(
        (start) => start != from,
      );
    } else {
      this.expandedStretches = [...this.expandedStretches, from];
    }
  };

  get diffLines(): (DiffLine | CollapsedStretches)[] {
    return collapseContext(buildDiffLines(this.args.diff), [
      ...this.expandedStretches,
    ]);
  }

  get renderedLines(): RenderedLine[] {
    return this.diffLines.map((diffLine) =>
      'count' in diffLine
        ? {
            text: `⋯ ${diffLine.count} unchanged lines, click to expand ⋯`,
            className: 'shape-diff__line--ellipsis',
            toggle: () => this.toggleStretch(diffLine.from),
          }
        : {
            text: `${diffLine.prefix}${diffLine.line}`,
            className: `shape-diff__line--${diffLine.type}`,
            toggle: () => {},
          },
    );
  }

  <template>
    <AuCard @shadow={{true}} as |card|>
      <card.header>
        <AuHeading @level="3" @skin="4" class="au-u-margin-bottom-none">
          Last format change
        </AuHeading>
      </card.header>
      <card.content>
        <p class="au-u-muted">{{@diff.timestampNew}}</p>
        <AuButton {{on "click" this.toggleDiff}}>
          {{if this.showDiff "Hide diff" "Show diff"}}
        </AuButton>
        {{#if this.showDiff}}
          <div class="shape-diff au-u-margin-top">
            {{#each this.renderedLines as |renderedLine|}}
              <div
                class="shape-diff__line {{renderedLine.className}}"
                role="button"
                {{on "click" renderedLine.toggle}}
              >{{renderedLine.text}}</div>
            {{/each}}
          </div>
        {{/if}}
      </card.content>
    </AuCard>
  </template>
}
