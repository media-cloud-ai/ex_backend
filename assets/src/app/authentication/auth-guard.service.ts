import { Injectable } from '@angular/core'
import {
  ActivatedRouteSnapshot,
  CanActivate,
  CanActivateChild,
  Router,
  RouterStateSnapshot,
} from '@angular/router'
import { AuthService } from './auth.service'

@Injectable()
export class AuthGuard implements CanActivate, CanActivateChild {
  constructor(private authService: AuthService, private router: Router) {}

  canActivate(
    _route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot,
  ): boolean {
    const url: string = state.url
    return this.checkLogin(url)
  }

  canActivateChild(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot,
  ): boolean {
    return this.canActivate(route, state)
  }

  checkLogin(url: string): boolean {
    if (this.authService.isLoggedIn) {
      // console.log("Check URL ", url)
      if (url.startsWith('/watchers') || url.startsWith('/workers')) {
        if (
          this.authService.hasAdministratorRight() ||
          this.authService.hasTechnicianRight()
        ) {
          return true
        } else {
          this.router.navigate(['/dashboard'])
          return false
        }
      }
      if (
        url.startsWith('/users') ||
        url.startsWith('/secrets') ||
        url.startsWith('/statistics')
      ) {
        if (this.authService.hasAdministratorRight()) {
          return true
        } else {
          this.router.navigate(['/dashboard'])
          return false
        }
      }
      if (
        url.startsWith('/people') ||
        url.startsWith('/player') ||
        url.startsWith('/ingest') ||
        url.startsWith('/person') ||
        url.startsWith('/registeries')
      ) {
        if (
          this.authService.hasAdministratorRight() ||
          this.authService.hasEditorRight()
        ) {
          return true
        } else {
          this.router.navigate(['/dashboard'])
          return false
        }
      }

      if (url.startsWith('/login')) {
        this.router.navigate(['/dashboard'])
        return true
      }

      if (
        url.startsWith('/dashboard') ||
        url.startsWith('/documentation') ||
        url.startsWith('/swagger') ||
        url.startsWith('/declared-workers') ||
        url.startsWith('/orders') ||
        url.startsWith('/workflows')
      ) {
        return true
      }
      return false
    }

    if (url.startsWith('/login')) {
      return true
    }

    // Store the attempted URL for redirecting
    this.authService.redirectUrl = url

    // Navigate to the login page with extras
    this.router.navigate(['/login'])
    return false
  }
}
