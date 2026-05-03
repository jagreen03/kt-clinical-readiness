# KTS-0000008 Pass 3: HTTP Error Interceptor

## Decisions & Architecture Notes

* **Centralized vs. Distributed Error Handling**: Implemented a centralized `errorInterceptor` to handle cross-cutting API failure modes (401, 403, 5xx, Network 0). This prevents boilerplate `catchError` blocks in every feature service and ensures consistent UX routing. Feature services now only handle domain-specific errors.
* **Interceptor Ordering**: The `errorInterceptor` is placed last in the `withInterceptors` array. In Angular's execution chain, this makes it the closest layer to the `HttpBackend`. It catches the raw `HttpErrorResponse` first on the return trip before passing the response back up through the CSRF and Credentials interceptors.
* **Network Failure Strategy**: Leveraged the `status === 0` heuristic native to `HttpErrorResponse`. With `withFetch` active, browser-aborted requests, CORS blocks, or dead servers all present as status 0. This is explicitly logged as a network failure rather than a server-side 5xx, allowing the UI caller to differentiate between "API is broken" and "Client has no connection".
* **401 vs. 403 Treatment**: 
  - **401 (Unauthorized)**: Triggers an identity state clear and a hard redirect to the public `/` landing. It is an authentication failure.
  - **403 (Forbidden)**: Triggers no redirect. The user is known but lacks roles. It is surfaced to the caller so the UI can render an "Access Denied" view while maintaining the active session.
* **Pass 2 Carry-Forwards Applied**:
  - `AuthService.logout()` converted from `void` to `Observable<void>` to allow caller reaction, preserving the defensive `finalize` state clear.
  - `AuthService.me()` deduplicated using an `inFlight` observable cache and `shareReplay(1)`, preventing concurrent guard activations from firing multiple identical requests.
  - Added the JSDoc comment to `currentUser` explaining the tri-state behavior.