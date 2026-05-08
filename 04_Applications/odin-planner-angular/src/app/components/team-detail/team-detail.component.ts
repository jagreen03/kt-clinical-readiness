import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { MatTableModule } from '@angular/material/table';
import { MatExpansionModule } from '@angular/material/expansion';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { ProjectService } from '../../services/project.service';
import { EditModalComponent } from './edit-modal.component';
import { SubTask, PhaseHeader } from '../../models/project.model';

@Component({
  selector: 'app-team-detail',
  standalone: true,
  imports: [CommonModule, RouterModule, MatTableModule, MatExpansionModule, MatDialogModule, MatButtonModule],
  template: `
    <div *ngIf="projectService.selectedTeam() as team">
      <div class="detail-header">
        <h2>{{ team.id }}: {{ team.name }}</h2>
        <button mat-stroked-button routerLink="/teams">Back to List</button>
      </div>

      @for (section of team.sections; track section.sectionLabel) {
        <h3 class="section-label">Project Section: {{ section.sectionLabel }}</h3>
        
        @for (phase of section.phases; track phase.id) {
          <mat-expansion-panel class="phase-panel">
            <mat-expansion-panel-header [style.border-left-color]="getPhaseColor(phase.position)">
              <mat-panel-title>
                <strong>{{ phase.id }}</strong>: {{ phase.name }}
              </mat-panel-title>
              <mat-panel-description>
                {{ phase.computedPct | percent }} Done | Ends {{ phase.computedEnd | date:'MM/dd' }}
              </mat-panel-description>
            </mat-expansion-panel-header>

            <table mat-table [dataSource]="phase.subTasks" class="task-table">
              <ng-container matColumnDef="wbs">
                <th mat-header-cell *matHeaderCellDef>WBS</th>
                <td mat-cell *matCellDef="let t">{{ t.wbs }}</td>
              </ng-container>
              <ng-container matColumnDef="name">
                <th mat-header-cell *matHeaderCellDef>Task</th>
                <td mat-cell *matCellDef="let t">{{ t.name }}</td>
              </ng-container>
              <ng-container matColumnDef="status">
                <th mat-header-cell *matHeaderCellDef>Status</th>
                <td mat-cell *matCellDef="let t" [style.color]="getStatusColor(t.status)">{{ t.status }}</td>
              </ng-container>
              <ng-container matColumnDef="edit">
                <th mat-header-cell *matHeaderCellDef></th>
                <td mat-cell *matCellDef="let t">
                  <button mat-icon-button (click)="openEdit(t, phase, team.id)">
                    <i class="material-icons">edit</i>
                  </button>
                </td>
              </ng-container>

              <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
              <tr mat-row *matRowDef="let row; columns: displayedColumns;"></tr>
            </table>
          </mat-expansion-panel>
        }
      }
    </div>
  `,
  styles: [`
    .detail-header { display: flex; justify-content: space-between; align-items: center; }
    .section-label { margin: 24px 0 12px; font-weight: 500; color: #555; border-bottom: 1px solid #ddd; }
    .phase-panel { margin-bottom: 8px; border-left: 6px solid #ccc; }
    .task-table { width: 100%; }
    .mat-column-wbs { width: 80px; }
    .mat-column-edit { width: 40px; }
  `]
})
export class TeamDetailComponent {
  projectService = inject(ProjectService);
  route = inject(ActivatedRoute);
  dialog = inject(MatDialog);
  displayedColumns = ['wbs', 'name', 'status', 'edit'];

  constructor() {
    this.route.paramMap.subscribe(params => {
      this.projectService.selectedTeamId.set(params.get('teamId'));
    });
  }

  getPhaseColor(pos: number): string {
    const colors = ['#BFBFBF', '#BDD7EE', '#FFE699', '#F8CBAD', '#C6E0B4', '#9DC3E6', '#B4A7D6'];
    return colors[pos - 1] || '#ccc';
  }

  getStatusColor(status: string): string {
    const map: any = { 'Blocked': '#f44336', 'At Risk': '#ff9800', 'Completed': '#4caf50', 'In Progress': '#2196f3' };
    return map[status] || '#666';
  }

	// Find your openEdit method and replace it with this type-safe version:
	openEdit(task: SubTask, phase: PhaseHeader, teamId: string) {
	  const dialogRef = this.dialog.open(EditModalComponent, {
		width: '600px',
		data: { task, phase, teamId }
	  });

	  dialogRef.afterClosed().subscribe((result: SubTask | undefined) => {
		if (result) {
		  this.projectService.updateSubTask(teamId, phase.id, task.wbs, result);
		}
	  });
	}
}