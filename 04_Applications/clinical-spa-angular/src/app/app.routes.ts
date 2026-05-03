import { Component } from '@angular/core';
import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';

// Inline placeholder components for compilation safety.
// Replace with actual KTS-0000005 components when ready.
@Component({ template: '<h2>Home</h2><p>Public landing page. Login button available here.</p>', standalone: true })
export class HomeComponent {}

@Component({ template: '<h2>Dashboard</h2><p>Protected dashboard area.</p>', standalone: true })
export class DashboardComponent {}

@Component({ template: '<h2>Proxy Demo</h2><p>Protected area for Pass 4 integration.</p>', standalone: true })
export class ProxyDemoComponent {}

export const routes: Routes = [
  { 
    path: '', 
    component: HomeComponent 
  },
  { 
    path: 'dashboard', 
    component: DashboardComponent, 
    canActivate: [authGuard] 
  },
  { 
    path: 'proxy-demo', 
    component: ProxyDemoComponent, 
    canActivate: [authGuard] 
  },
  { 
    path: '**', 
    redirectTo: '' 
  }
];