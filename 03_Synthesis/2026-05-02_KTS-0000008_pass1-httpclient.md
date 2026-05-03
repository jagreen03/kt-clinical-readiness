# KTS-0000008 Pass 1: Angular HttpClient & Interceptors

## Decisions & Architecture Notes

* **Configuration Baseline**: Confirmed `app.config.ts` from disk. The application uses Angular 19+ standalone configuration (`provideZonelessChangeDetection`, `withEventReplay`).
* **HttpClient Wiring**: Added `provideHttpClient` with `withFetch` for modern browser API usage, and `withInterceptors` to register our functional interceptors. Registered `withXsrfConfiguration` to ensure the internal `HttpXsrfTokenExtractor` knows the exact cookie and header names expected by the Spring Boot BFF.
* **Credentials Interceptor**: A functional interceptor (`credentialsInterceptor`) appends `withCredentials: true` to all outgoing requests. This is mandatory for the BFF pattern so the browser includes the `BFF_SESSION` and `XSRF-TOKEN` cookies.
* **CSRF Interceptor**: While Angular has built-in XSRF handling, it silently drops the `X-XSRF-TOKEN` header on cross-origin requests by default (which occurs during local development when SPA is on 4200 and BFF is on 8080). The custom `csrfInterceptor` forces the header onto all mutating requests (POST, PUT, PATCH, DELETE) regardless of origin, bypassing the local-dev CORS limitation safely.
* **Environments**: Bootstrapped the `environments` directory. The development environment points to `http://localhost:8080`, while production assumes relative paths (served from the BFF static resources).