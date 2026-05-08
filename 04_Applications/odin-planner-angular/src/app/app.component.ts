import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatButtonModule } from '@angular/material/button';
import { ProjectService } from './services/project.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, RouterModule, MatToolbarModule, MatSidenavModule, MatListModule, MatButtonModule],
  template: `
    <mat-toolbar color="primary" class="top-nav">
      <span>Project ODIN Planner</span>
      <span class="spacer"></span>
      <nav>
        <a mat-button routerLink="/teams">Teams</a>
        <a mat-button routerLink="/gantt">Gantt</a>
        <a mat-button routerLink="/dashboard/phases">Phases</a>
        <a mat-button routerLink="/dashboard/milestones">Milestones</a>
      </nav>
    </mat-toolbar>

    <mat-sidenav-container class="main-container">
      <mat-sidenav mode="side" opened class="sidebar">
        <mat-nav-list>
          <div mat-subheader>ODIN Teams</div>
          @for (team of projectService.teams(); track team.id) {
            <a mat-list-item [routerLink]="['/teams', team.id]" routerLinkActive="active">
              <span matListItemTitle>{{ team.id }}</span>
            </a>
          }
        </mat-nav-list>
      </mat-sidenav>

      <mat-sidenav-content class="content">
        <div class="view-wrapper">
          <router-outlet></router-outlet>
        </div>
      </mat-sidenav-content>
    </mat-sidenav-container>
  `,
  styles: [`
    .top-nav { position: relative; z-index: 5; height: 64px; display: flex; align-items: center; justify-content: space-between; }
    .spacer { flex: 1 1 auto; }
    .main-container { height: calc(100vh - 64px); }
    .sidebar { width: 120px; border-right: 1px solid #ddd; }
    .content { padding: 0; overflow: auto; }
    .view-wrapper { padding: 20px; }
    .active { background: rgba(0,0,0,0.05); font-weight: bold; }
  `]
})
export class AppComponent {
  constructor(public projectService: ProjectService) {}
}