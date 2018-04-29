
require('reflect-metadata');
require('rxjs');
require('es7-shim');
require('zone.js/dist/zone');

import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { AppModule }              from './app/app.module';
import { enableProdMode } from '@angular/core';
import { environment } from './environments/environment';
import './theme.scss';

if (environment.production) {
  enableProdMode();
}
platformBrowserDynamic().bootstrapModule(AppModule);
