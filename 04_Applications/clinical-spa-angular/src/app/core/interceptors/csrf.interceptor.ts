import { HttpInterceptorFn, HttpXsrfTokenExtractor } from '@angular/common/http';
import { inject } from '@angular/core';

export const csrfInterceptor: HttpInterceptorFn = (req, next) => {
  const tokenExtractor = inject(HttpXsrfTokenExtractor);
  const token = tokenExtractor.getToken();
  const method = req.method.toLowerCase();

  if (token && ['post', 'put', 'patch', 'delete'].includes(method)) {
    req = req.clone({
      setHeaders: { 'X-XSRF-TOKEN': token }
    });
  }

  return next(req);
};