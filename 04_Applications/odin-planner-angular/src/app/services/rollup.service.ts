import { Injectable } from '@angular/core';
import { SubTask, Status, PhaseHeader } from '../models/project.model';
import { min, max } from 'date-fns';

@Injectable({ providedIn: 'root' })
export class RollupService {

  /**
   * Decision: Perform immutably to support impact previews before save.
   * Requirement 1: Guard division by zero. If totalDays === 0, return computedPct = 0.
   */
  calculatePhase(subTasks: SubTask[]): Partial<PhaseHeader> {
    if (!subTasks.length) return {
      computedDays: 0,
      computedPct: 0,
      computedStatus: 'Not Started'
    };

    const totalDays = subTasks.reduce((sum, t) => sum + t.days, 0);
    
    // PctDone: SUMPRODUCT(days * pct) / SUM(days). Guarded against div/0.
    const weightedPct = totalDays > 0 
      ? subTasks.reduce((sum, t) => sum + (t.days * t.pctDone), 0) / totalDays
      : 0;

    return {
      computedDays: totalDays,
      computedStart: subTasks.length ? min(subTasks.map(t => t.startDate)) : undefined,
      computedEnd: subTasks.length ? max(subTasks.map(t => t.endDate)) : undefined,
      computedPct: weightedPct,
      computedStatus: this.determineStatus(subTasks)
    };
  }

  private determineStatus(tasks: SubTask[]): Status {
    if (tasks.every(t => t.status === 'Completed')) return 'Completed';
    if (tasks.some(t => t.status === 'Blocked')) return 'Blocked';
    if (tasks.some(t => t.status === 'At Risk')) return 'At Risk';
    if (tasks.some(t => t.status === 'In Progress')) return 'In Progress';
    return 'Not Started';
  }
}