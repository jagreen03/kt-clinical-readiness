import { Injectable, signal, WritableSignal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, of } from 'rxjs';
import { catchError, finalize, tap } from 'rxjs/operators';
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
  // undefined = unchecked, null = unauthenticated
  public currentUser: WritableSignal<User | null | undefined> = signal(undefined);

  constructor(private http: HttpClient, private router: Router) {}

  login(): void {
    window.location.href = `${environment.bffBaseUrl}/oauth2/authorization/google`;
  }

  logout(): void {
    this.http.post(`${environment.bffBaseUrl}/auth/logout`, {}).pipe(
      finalize(() => {
        this.currentUser.set(null);
        this.router.navigate(['/']);
      })
    ).subscribe();
  }

  me(): Observable<User | null> {
    return this.http.get<User>(`${environment.bffBaseUrl}/api/me`).pipe(
      tap(user => this.currentUser.set(user)),
      catchError(() => {
        this.currentUser.set(null);
        return of(null);
      })
    );
  }
}