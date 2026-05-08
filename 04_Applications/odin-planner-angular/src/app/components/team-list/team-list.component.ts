import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { ProjectService } from '../../services/project.service';

@Component({
  selector: 'app-team-list',
  standalone: true,
  imports: [CommonModule, RouterModule, MatCardModule, MatButtonModule, MatIconModule],
  template: `
    <div class="header-actions">
      <h2>Transition Teams</h2>
      <button mat-raised-button color="accent" (click)="fileInput.click()">
        <mat-icon>upload_file</mat-icon> Import V11 Workbook
      </button>
      <input #fileInput type="file" (change)="onFileSelected($event)" accept=".xlsx" hidden>
    </div>

    <div class="team-grid">
      @for (team of projectService.teams(); track team.id) {
        <mat-card class="team-card" [routerLink]="['/teams', team.id]">
          <mat-card-header>
            <mat-card-title>{{ team.id }}</mat-card-title>
            <mat-card-subtitle>{{ team.name }}</mat-card-subtitle>
          </mat-card-header>
          <mat-card-content>
            <p><strong>Tower Lead:</strong> {{ team.towerLead || 'Unassigned' }}</p>
            <div class="stats">
              <span>{{ team.sections.length }} Sections</span>
              <span>{{ team.milestones.length }} Milestones</span>
            </div>
          </mat-card-content>
        </mat-card>
      } @empty {
        <div class="empty-state">
          <mat-icon>inventory_2</mat-icon>
          <p>No teams loaded. Please import the Project ODIN workbook to begin.</p>
        </div>
      }
    </div>
  `,
  styles: [`
    .header-actions { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
    .team-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; }
    .team-card { cursor: pointer; transition: transform 0.2s; border-left: 4px solid #3f51b5; }
    .team-card:hover { transform: translateY(-4px); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
    .empty-state { grid-column: 1 / -1; text-align: center; padding: 60px; color: #666; }
    .empty-state mat-icon { font-size: 48px; width: 48px; height: 48px; margin-bottom: 16px; opacity: 0.5; }
  `]
})
export class TeamListComponent {
  constructor(public projectService: ProjectService) {}

  onFileSelected(event: any) {
    const file = event.target.files[0];
    if (file) {
      this.projectService.loadFromXlsx(file);
    }
  }
}