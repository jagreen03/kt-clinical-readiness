export type PhasePosition = 1 | 2 | 3 | 4 | 5 | 6 | 7;

export type Status = 'Not Started' | 'In Progress' | 'At Risk' | 'Completed' | 'Blocked';

export const STATUS_COLORS: Record<Status, string> = {
  'Not Started': '#F3F4F6', // Grey-100
  'In Progress': '#3B82F6', // Blue-500
  'At Risk': '#F59E0B',     // Amber-500
  'Completed': '#10B981',   // Green-500
  'Blocked': '#EF4444'      // Red-500
};

export const PHASE_COLORS: Record<PhasePosition, string> = {
  1: '#BFBFBF', 2: '#BDD7EE', 3: '#FFE699', 4: '#F8CBAD', 
  5: '#C6E0B4', 6: '#9DC3E6', 7: '#B4A7D6'
};

export interface SubTask {
  wbs: string;
  name: string;
  days: number;
  startDate: Date;
  endDate: Date;
  owner: string;
  predecessor: string;
  status: Status;
  pctDone: number; 
  notes: string;
}

export interface Milestone {
  id: string; // M0..M6
  description: string;
  finishDate: Date;
  notes: string;
}

export interface PhaseHeader {
  id: string;
  name: string;
  position: PhasePosition;
  subTasks: SubTask[];
  // Computed fields
  computedDays?: number;
  computedStart?: Date;
  computedEnd?: Date;
  computedPct?: number;
  computedStatus?: Status;
}

export interface ProjectSection {
  sectionLabel: string;
  phases: PhaseHeader[];
}

export interface Team {
  id: string; // T-02, etc.
  name: string;
  towerLead: string;
  sections: ProjectSection[];
  milestones: Milestone[];
}