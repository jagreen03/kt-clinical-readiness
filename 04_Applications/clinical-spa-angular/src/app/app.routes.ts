/* Path: 04_Applications/clinical-spa-angular/src/app/app.routes.ts */
import { Component } from '@angular/core';
import { Routes } from '@angular/router';
import { HomeComponent } from './features/home/home.component';
import { ProxyDemoComponent } from './features/proxy-demo/proxy-demo.component';
import { authGuard } from './core/guards/auth.guard';

// Preserved inline placeholder for KTS-0000012 dashboard work
@Component({
  selector: 'app-dashboard-placeholder',
  standalone: true,
  template: '<h1>Dashboard Placeholder</h1><p>Secured route.</p>'
})
export class DashboardComponent {}

export const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'dashboard', component: DashboardComponent, canActivate: [authGuard] },
  { path: 'proxy-demo', component: ProxyDemoComponent, canActivate: [authGuard] },
  { path: '**', redirectTo: '' }
];