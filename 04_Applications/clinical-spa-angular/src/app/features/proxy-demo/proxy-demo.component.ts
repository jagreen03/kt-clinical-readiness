import { Component, inject, signal, WritableSignal, DestroyRef } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { JsonPipe } from '@angular/common';
import { HttpErrorResponse } from '@angular/common/http';
import { AuthService } from '../../core/services/auth.service';
import { ProxyDemoService } from './proxy-demo.service';

@Component({
  selector: 'app-proxy-demo',
  standalone: true,
  imports: [JsonPipe],
  template: `
    <div class="proxy-demo-container">
      <h2>Proxy Integration Demo</h2>
      
      <div class="user-state">
        <strong>Active User:</strong> 
        {{ authService.currentUser()?.name }} ({{ authService.currentUser()?.email }})
      </div>

      <div class="actions">
        <button (click)="fetchSample()" [disabled]="isLoading()">
          Fetch Clinical Sample
        </button>
      </div>

      @if (isLoading()) {
        <p>Routing request through BFF proxy...</p>
      }

      @if (response() !== undefined && response() !== null) {
        <div class="success-response">
          <h3>Proxy Response:</h3>
          <pre>{{ response() | json }}</pre>
        </div>
      }

      @if (response() === null) {
        <div class="error-response">
          <h3>Request Failed</h3>
          <p>{{ errorMessage() }}</p>
        </div>
      }
    </div>
  `
})
export class ProxyDemoComponent {
  public authService = inject(AuthService);
  private proxyService = inject(ProxyDemoService);
  private destroyRef = inject(DestroyRef);

  public isLoading: WritableSignal<boolean> = signal(false);
  
  // Tri-state: undefined = no request, null = error, value = success payload
  public response: WritableSignal<unknown | null | undefined> = signal(undefined);
  public errorMessage: WritableSignal<string> = signal('');

  fetchSample(): void {
    this.isLoading.set(true);
    this.response.set(undefined);
    this.errorMessage.set('');

    this.proxyService.fetchClinicalSample()
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: (data) => {
          this.response.set(data);
          this.isLoading.set(false);
        },
        error: (err: HttpErrorResponse) => {
          this.response.set(null);
          this.errorMessage.set(`Status ${err.status}: ${err.message}`);
          this.isLoading.set(false);
        }
      });
  }
}