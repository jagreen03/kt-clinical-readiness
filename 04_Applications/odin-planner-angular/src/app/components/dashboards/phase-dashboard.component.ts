import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { MatTableModule } from '@angular/material/table';
import { ProjectService } from '../../services/project.service';

@Component({
  selector: 'app-phase-dashboard',
  standalone: true,
  imports: [CommonModule, MatTableModule, RouterModule],
  template: `
    <h2>Phase Header Summary</h2>
    <table mat-table [dataSource]="flatPhases()" class="full-width-table">
      <ng-container matColumnDef="team">
        <th mat-header-cell *matHeaderCellDef>Team</th>
        <td mat-cell *matCellDef="let p">{{ p.teamId }}</td>
      </ng-container>
      <ng-container matColumnDef="phase">
        <th mat-header-cell *matHeaderCellDef>Phase ID</th>
        <td mat-cell *matCellDef="let p">{{ p.phase.id }}</td>
      </ng-container>
      <ng-container matColumnDef="name">
        <th mat-header-cell *matHeaderCellDef>Name</th>
        <td mat-cell *matCellDef="let p">{{ p.phase.name }}</td>
      </ng-container>
      <ng-container matColumnDef="end">
        <th mat-header-cell *matHeaderCellDef>End Date</th>
        <td mat-cell *matCellDef="let p">{{ p.phase.computedEnd | date:'MM/dd/yy' }}</td>
      </ng-container>
      <ng-container matColumnDef="status">
        <th mat-header-cell *matHeaderCellDef>Status</th>
        <td mat-cell *matCellDef="let p">{{ p.phase.computedStatus }}</td>
      </ng-container>
      <ng-container matColumnDef="open">
        <th mat-header-cell *matHeaderCellDef></th>
        <td mat-cell *matCellDef="let p">
          <a [routerLink]="['/teams', p.teamId]">View</a>
        </td>
      </ng-container>

      <tr mat-header-row *matHeaderRowDef="columns"></tr>
      <tr mat-row *matRowDef="let row; columns: columns;"></tr>
    </table>
  `,
  styles: [`.full-width-table { width: 100%; }`]
})
export class PhaseDashboardComponent {
  projectService = inject(ProjectService);
  columns = ['team', 'phase', 'name', 'end', 'status', 'open'];

  flatPhases = () => {
    const teams = this.projectService.teams();
    return teams.flatMap(t => t.sections.flatMap(s => s.phases.map(p => ({ teamId: t.id, phase: p }))));
  };
}