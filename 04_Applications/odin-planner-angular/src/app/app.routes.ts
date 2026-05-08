import { Routes } from '@angular/router';

export const routes: Routes = [
  { path: '', redirectTo: '/teams', pathMatch: 'full' },
  { 
    path: 'teams', 
    loadComponent: () => import('./components/team-list/team-list.component').then(m => m.TeamListComponent) 
  },
  { 
    path: 'teams/:teamId', 
    loadComponent: () => import('./components/team-detail/team-detail.component').then(m => m.TeamDetailComponent) 
  },
  { 
    path: 'gantt', 
    loadComponent: () => import('./components/gantt/gantt.component').then(m => m.GanttComponent) 
  },
  { 
    path: 'dashboard/phases', 
    loadComponent: () => import('./components/dashboards/phase-dashboard.component').then(m => m.PhaseDashboardComponent) 
  },
  { 
    path: 'dashboard/milestones', 
    loadComponent: () => import('./components/dashboards/milestone-dashboard.component').then(m => m.MilestoneDashboardComponent) 
  }
];