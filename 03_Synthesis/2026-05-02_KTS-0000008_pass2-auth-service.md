# KTS-0000008 Pass 2: Auth Service & Route Guard

## Decisions & Architecture Notes

* **State Mechanism**: Chose Angular 19 Signals (`WritableSignal<User | null | undefined>`) for `currentUser`. Signals integrate perfectly with zoneless change detection (enabled in Pass 1) and eliminate the need for `async` pipe subscriptions in the templates. The state lives directly in the `AuthService` singleton; a separate state management library is overkill for a simple 4-field user identity.
* **Bootstrap Flow**: The `me()` check is performed lazily on **Guard Activation** (and optionally by a header component on init). Justification: lazy evaluation prevents blocking the initial SPA render for public routes, yielding a faster Time-To-Interactive. The signal state uses `undefined` to represent "unchecked", `null` for "unauthenticated", and `User` for "authenticated".
* **Logout Target**: On logout, the application clears the local signal state and redirects to `/` (the public landing route). Defensive programming is applied via RxJS `finalize` to ensure local state is cleared even if the BFF returns a network error during the logout POST.
* **Doctrine Adherence**: The `app.routes.ts` file modification is pending. Per strict doctrine, I cannot read your disk and will not attempt to reconstruct the KTS-0000005 route structure from memory.

## Pending Dependency
* **app.routes.ts**: Awaiting Pilot input of the canonical file contents to apply the `authGuard`.