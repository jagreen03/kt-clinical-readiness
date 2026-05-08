/* Path: 04_Applications/clinical-spa-angular/src/app/features/home/home.component.ts */
import { Component, OnInit, inject, DestroyRef } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnInit {
  public authService = inject(AuthService);
  private destroyRef = inject(DestroyRef);

  ngOnInit(): void {
    // Initiate the auth check on load
    this.authService.me()
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe();
  }

  logout(): void {
    // Fire the logout sequence and ensure cleanup
    this.authService.logout()
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe();
  }
}