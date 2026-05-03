import { Injectable, signal, WritableSignal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, of } from 'rxjs';
import { catchError, finalize, tap, shareReplay } from 'rxjs/operators';
import { environment } from '../../../environments/environment';

export interface User {
  sub: string;
  email: string;
  name: string;
  roles: string[];
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  /** undefined = unchecked, null = unauthenticated, User = authenticated */
  public currentUser: WritableSignal<User | null | undefined> = signal(undefined);

  private inFlight: Observable<User | null> | null = null;

  constructor(private http: HttpClient, private router: Router) {}

  login(): void {
    window.location.href = `${environment.bffBaseUrl}/oauth2/authorization/google`;
  }

  logout(): Observable<void> {
    return this.http.post<void>(`${environment.bffBaseUrl}/auth/logout`, {}).pipe(
      finalize(() => {
        this.currentUser.set(null);
        this.router.navigate(['/']);
      })
    );
  }

  me(): Observable<User | null> {
    if (this.inFlight) {
      return this.inFlight;
    }

    this.inFlight = this.http.get<User>(`${environment.bffBaseUrl}/api/me`).pipe(
      tap(user => this.currentUser.set(user)),
      catchError(() => {
        this.currentUser.set(null);
        return of(null);
      }),
      finalize(() => {
        this.inFlight = null;
      }),
      shareReplay(1)
    );
    
    return this.inFlight;
  }
}