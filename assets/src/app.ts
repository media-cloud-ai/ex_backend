
import 'reflect-metadata'
import 'rxjs'
import 'es7-shim'
import 'zone.js/dist/zone'

import { platformBrowserDynamic } from '@angular/platform-browser-dynamic'
import { AppModule } from './app/app.module'
import { enableProdMode } from '@angular/core'
import { environment } from './environments/environment'
import './theme.scss'

if (environment.production) {
  enableProdMode()
}
platformBrowserDynamic().bootstrapModule(AppModule)
