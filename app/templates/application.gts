import { pageTitle } from 'ember-page-title';
import AuApp from '@appuniversum/ember-appuniversum/components/au-app';
import AuMainHeader from '@appuniversum/ember-appuniversum/components/au-main-header';
import AuMainContainer from '@appuniversum/ember-appuniversum/components/au-main-container';
import AuBodyContainer from '@appuniversum/ember-appuniversum/components/au-body-container';
import AuModalContainer from '@appuniversum/ember-appuniversum/components/au-modal-container';
import AuLink from '@appuniversum/ember-appuniversum/components/au-link';
import BasicDropdownWormhole from 'ember-basic-dropdown/components/basic-dropdown-wormhole';
<template>
  {{pageTitle "LDES Watchman"}}
  <AuModalContainer />
  <BasicDropdownWormhole />
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
