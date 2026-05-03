import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';
import { AuthService } from '../services/auth.service';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const router = inject(Router);
  const authService = inject(AuthService);

  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      if (error.status === 401) {
        // Exclude paths where AuthService manages its own state lifecycle
        if (!req.url.match(/\/(api\/me|auth\/logout)/)) {
          authService.currentUser.set(null);
          router.navigate(['/']);
        }
      } else if (error.status === 403) {
        console.error('Forbidden access: Insufficient privileges for resource.', error);
      } else if (error.status === 0) {
        console.error('Network failure detected: Cannot reach server.', error);
      } else if (error.status >= 500) {
        console.error('Server error encountered:', error);
      }

      return throwError(() => error);
    })
  );
};