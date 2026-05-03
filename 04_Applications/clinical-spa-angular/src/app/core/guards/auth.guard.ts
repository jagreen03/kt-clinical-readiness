import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { map } from 'rxjs/operators';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);
  
  const currentUser = authService.currentUser();

  if (currentUser !== undefined) {
    if (currentUser !== null) {
      return true;
    }
    return router.createUrlTree(['/']);
  }

  // State is unchecked, fetch from BFF
  return authService.me().pipe(
    map(user => {
      if (user) {
        return true;
      }
      return router.createUrlTree(['/']);
    })
  );
};