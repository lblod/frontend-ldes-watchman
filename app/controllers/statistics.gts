import Controller from '@ember/controller';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import type { StatisticsModel } from '../types/statistics';

export default class StatisticsController extends Controller<StatisticsModel> {
  queryParams = ['streamUri'];

  @tracked streamUri: string | undefined = '';

  get currentStream() {
    return this.streamUri && this.streamUri.length > 0
      ? this.streamUri
      : this.model.availableStreams[0];
  }

  @action
  setStreamUri(newStreamUri: string) {
    this.streamUri = newStreamUri;
  }
}
