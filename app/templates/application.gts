import { pageTitle } from 'ember-page-title';
import AuApp from '@appuniversum/ember-appuniversum/components/au-app';
import AuMainHeader from '@appuniversum/ember-appuniversum/components/au-main-header';
import AuMainContainer from '@appuniversum/ember-appuniversum/components/au-main-container';
import AuBodyContainer from '@appuniversum/ember-appuniversum/components/au-body-container';
import AuLink from '@appuniversum/ember-appuniversum/components/au-link';

<template>
  {{pageTitle "LDES Watchman"}}

  <AuApp>
    <AuMainHeader @homeRoute="statistics" @appTitle="LDES Watchman">
      <li class="au-c-list-horizontal__item">
        <AuLink @route="statistics">Statistics</AuLink>
      </li>
    </AuMainHeader>
    <AuMainContainer as |main|>
      <main.content>
        <AuBodyContainer @scroll={{true}}>
          <div
            class="au-d-component-block au-d-component-block--overflow au-u-padding"
          >
            {{outlet}}
          </div>
        </AuBodyContainer>
      </main.content>
    </AuMainContainer>
  </AuApp>
</template>
