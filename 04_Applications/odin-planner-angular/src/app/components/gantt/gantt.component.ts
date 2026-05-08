import { Component, inject } from '@angular/core'; // Added inject
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { MatTooltipModule } from '@angular/material/tooltip';
import { ProjectService } from '../../services/project.service';
import { differenceInDays, addDays, format } from 'date-fns';
import { PHASE_COLORS, PhaseHeader } from '../../models/project.model';

@Component({
  selector: 'app-gantt',
  standalone: true,
  imports: [CommonModule, RouterModule, MatTooltipModule],
  templateUrl: './gantt.component.html',
  styleUrls: ['./gantt.component.scss']
})
export class GanttComponent {
  // Fix: Move to inject() so these are available for immediate initialization
  private projectService = inject(ProjectService);
  
  readonly startDate = new Date(2026, 2, 23);
  readonly endDate = new Date(2026, 7, 3);
  readonly totalDays = differenceInDays(this.endDate, this.startDate);
  
  teams = this.projectService.teams;
  phaseColors = PHASE_COLORS;

  timelineDates: Date[] = Array.from({ length: 20 }, (_, i) =>
    addDays(this.startDate, i * 7)
  );

  // Constructor is now empty or can be removed
  constructor() {}

  getTooltip(phase: PhaseHeader): string {
    const start = phase.computedStart ? format(phase.computedStart, 'MM/dd') : '—';
    const end = phase.computedEnd ? format(phase.computedEnd, 'MM/dd') : '—';
    const days = phase.computedDays ?? 0;
    const pct = phase.computedPct ? Math.round(phase.computedPct * 100) : 0;
    return `${phase.name}\nStart: ${start}\nEnd: ${end}\nDays: ${days}\n% Done: ${pct}%`;
  }

  getLeft(date: Date | undefined): number {
    if (!date) return 0;
    const offset = differenceInDays(date, this.startDate);
    return Math.max(0, (offset / this.totalDays) * 100);
  }

  getWidth(start: Date | undefined, end: Date | undefined): number {
    if (!start || !end) return 0;
    const duration = differenceInDays(end, start) + 1;
    return Math.min(100, (duration / this.totalDays) * 100);
  }
}