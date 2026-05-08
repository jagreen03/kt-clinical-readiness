import { Injectable, signal, computed, WritableSignal, Signal, inject } from '@angular/core';
import { Team, SubTask, Milestone, PhaseHeader, ProjectSection, PhasePosition } from '../models/project.model';
import { RollupService } from './rollup.service';
import * as XLSX from 'xlsx';

@Injectable({ providedIn: 'root' })
export class ProjectService {
  private rollupService = inject(RollupService);

  // Primary state signals
  teams: WritableSignal<Team[]> = signal([]);
  selectedTeamId: WritableSignal<string | null> = signal(null);
  selectedTeam: Signal<Team | undefined> = computed(() => 
    this.teams().find(t => t.id === this.selectedTeamId())
  );

  // WBS Classification Regex
  private readonly PHASE_HEADER_TWO_PART = /^P\d+\.\d+$/;
  private readonly PHASE_HEADER_ONE_PART = /^P\d+$/;
  private readonly BODY_NEW_STYLE = /^P\d+(?:\.\d+){2,}$/;
  private readonly BODY_OLD_STYLE = /^\d+(?:\.\d+)+$/;
  private readonly MILESTONE = /^M\d+$/;

  // Methodology standard keywords for fuzzy matching
  private readonly METHODOLOGY_NAMES = [
    'ONBOARDING', 'SOP', 'DOCUMENTATION', 'TESTING',
    'SHADOWING', 'REVERSE', 'INDEPENDENT', 'OPS', 'OWN'
  ];

  /**
   * Hardened Import: Uses the "Identity Sniffer" to find T-XX IDs anywhere in the tab name.
   */
  async loadFromXlsx(file: File): Promise<void> {
    console.log('🔄 Starting Workbook Import:', file.name);
    const data = await file.arrayBuffer();
    const workbook = XLSX.read(data, { cellDates: true, cellFormula: true });
    const parsedTeams: Team[] = [];

    const teamIdRegex = /(T-\d+)/i;
    const exclusionRegex = /^(Team Leads|Carelon LO|Gantt|Dashboard)/i;

    workbook.SheetNames.forEach(sheetName => {
      // 1. Skip non-team tabs
      if (exclusionRegex.test(sheetName)) return;

      // 2. Sniff out the Team ID (T-02, T-53, etc.)
      const match = sheetName.match(teamIdRegex);
      
      if (match) {
        const teamId = match[0].toUpperCase();
        // 3. Extract the metadata name by removing the ID and underscores
        const teamName = sheetName
          .replace(match[0], '')
          .replace(/^[_ ]+|[_ ]+$/g, '')
          .trim() || teamId;

        console.log(`📂 Found Team: [${teamId}] | Extracted Name: [${teamName}]`);
        
        const team = this.parseTeamSheet(workbook.Sheets[sheetName], teamId);
        if (team && team.sections.length > 0) {
          team.name = teamName;
          parsedTeams.push(team);
        } else {
          console.warn(`⚠️ Sheet [${sheetName}] produced 0 sections. Check WBS in Column A.`);
        }
      }
    });

    console.log('✅ Import Complete. Teams Loaded:', parsedTeams.length);
    this.teams.set(parsedTeams);
  }

  private parseTeamSheet(sheet: XLSX.WorkSheet, id: string): Team {
    const rows: any[] = XLSX.utils.sheet_to_json(sheet, { header: 'A', defval: '' });
    const team: Team = { id, name: id, towerLead: '', sections: [], milestones: [] };
    let currentSection: ProjectSection | null = null;
    let currentPhase: PhaseHeader | null = null;

    rows.forEach(row => {
      const wbs = String(row.A || '').trim();
      const colB = String(row.B || '').trim();

      // Classify Row
      if (this.PHASE_HEADER_TWO_PART.test(wbs) || 
         (this.PHASE_HEADER_ONE_PART.test(wbs) && this.isMethodologyName(colB))) {
        
        const nextPosition = this.computePosition(wbs);

        // Section Break Detection
        if (!currentSection || (currentPhase && nextPosition <= currentPhase.position)) {
          currentSection = { sectionLabel: this.computeProjectLabel(wbs), phases: [] };
          team.sections.push(currentSection);
        }

        currentPhase = { 
          id: wbs, 
          name: colB, 
          position: nextPosition as PhasePosition, 
          subTasks: [] 
        };
        currentSection.phases.push(currentPhase);
      } else if (this.BODY_NEW_STYLE.test(wbs) || this.BODY_OLD_STYLE.test(wbs)) {
        if (currentPhase) currentPhase.subTasks.push(this.mapRowToSubTask(row));
      } else if (this.MILESTONE.test(wbs)) {
        team.milestones.push(this.mapRowToMilestone(row));
      }
    });

    // Run rollups
    team.sections.forEach(s => s.phases.forEach(p => {
      Object.assign(p, this.rollupService.calculatePhase(p.subTasks));
    }));

    return team;
  }

  private isMethodologyName(b: string): boolean {
    if (!b) return false;
    const upper = b.toUpperCase();
    return this.METHODOLOGY_NAMES.some(m => upper.includes(m));
  }

  private computePosition(wbs: string): number {
    const m2 = wbs.match(/^P\d+\.(\d+)$/);
    if (m2) return parseInt(m2[1], 10);
    const m1 = wbs.match(/^P(\d+)$/);
    if (m1) return parseInt(m1[1], 10) + 1; 
    return 1;
  }

  private computeProjectLabel(wbs: string): string {
    const m2 = wbs.match(/^P(\d+)\.\d+$/);
    if (m2) return `P${m2[1]}`;
    return 'P0-style';
  }

  private mapRowToSubTask(row: any): SubTask {
    return {
      wbs: row.A, name: row.B, days: Number(row.C) || 0,
      startDate: row.D instanceof Date ? row.D : new Date(),
      endDate: row.E instanceof Date ? row.E : new Date(),
      owner: row.F, predecessor: row.G, status: row.H || 'Not Started',
      pctDone: Number(row.I) || 0, notes: row.J
    };
  }

  private mapRowToMilestone(row: any): Milestone {
    return { id: row.A, description: row.B, finishDate: row.E instanceof Date ? row.E : new Date(), notes: row.J };
  }

  /**
   * RESTORED: Updates sub-task and triggers reactive re-rollup.
   */
  updateSubTask(teamId: string, phaseId: string, wbs: string, patch: Partial<SubTask>) {
    this.teams.update(teams => teams.map(team => {
      if (team.id !== teamId) return team;
      team.sections.forEach(s => s.phases.forEach(p => {
        if (p.id === phaseId) {
          const task = p.subTasks.find(t => t.wbs === wbs);
          if (task) {
            Object.assign(task, patch);
            Object.assign(p, this.rollupService.calculatePhase(p.subTasks));
          }
        }
      }));
      return { ...team };
    }));
  }

  addSubTask(teamId: string, phaseId: string, subTask: SubTask): void {}
  deleteSubTask(teamId: string, phaseId: string, wbs: string): void {}
  updateMilestone(teamId: string, milestoneId: string, patch: Partial<Milestone>): void {}
  async exportToXlsx(): Promise<Blob> { return new Blob(); }
}