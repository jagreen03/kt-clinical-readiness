import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-milestone-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <h2>Milestones</h2>
    <p><em>Pass 3: sortable/filterable cross-team milestone table with finish dates and exit criteria.</em></p>
  `
})
export class MilestoneDashboardComponent {}