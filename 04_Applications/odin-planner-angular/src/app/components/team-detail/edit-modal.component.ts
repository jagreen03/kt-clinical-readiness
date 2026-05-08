import { Component, inject, signal, computed } from '@angular/core'; // Added inject
import { CommonModule } from '@angular/common';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { FormsModule } from '@angular/forms';
import { MatStepperModule } from '@angular/material/stepper';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { SubTask, PhaseHeader } from '../../models/project.model';
import { RollupService } from '../../services/rollup.service';

@Component({
  selector: 'app-edit-modal',
  standalone: true,
  imports: [
    CommonModule, FormsModule, MatDialogModule, MatStepperModule, 
    MatFormFieldModule, MatInputModule, MatSelectModule, MatButtonModule
  ],
  templateUrl: './edit-modal.component.html', // Ensure you have this or use template: `...`
  styles: [`
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; padding: 12px 0; }
    .full-width { grid-column: 1 / span 2; }
    .impact-box { padding: 16px; background: #fff3cd; border-radius: 4px; border: 1px solid #ffeeba; }
    .old { text-decoration: line-through; color: #721c24; }
    .new { font-weight: bold; color: #155724; }
  `]
})
export class EditModalComponent {
  // Fix: Use inject() to ensure data is available for the signal initializer
  public data = inject<{ task: SubTask, phase: PhaseHeader, teamId: string }>(MAT_DIALOG_DATA);
  private rollupService = inject(RollupService);
  private dialogRef = inject(MatDialogRef<EditModalComponent>);

  editableTask = signal<SubTask>({ ...this.data.task });

  preview = computed(() => {
    const tasks = [...this.data.phase.subTasks];
    const idx = tasks.findIndex(t => t.wbs === this.data.task.wbs);
    tasks[idx] = this.editableTask();
    return this.rollupService.calculatePhase(tasks);
  });

  onFieldChange<K extends keyof SubTask>(field: K, value: any) {
    this.editableTask.update(t => ({ ...t, [field]: value }));
  }

  onDateChange(field: 'startDate' | 'endDate', value: string) {
    this.onFieldChange(field, new Date(value));
  }

  onSave() { this.dialogRef.close(this.editableTask()); }
}