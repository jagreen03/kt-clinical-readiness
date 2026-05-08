# KTS-0000013: ODIN-Carelon Transition Planner Foundation

**Date:** 2026-05-08
**Status:** Scaffolding Complete
**Human Lead:** John Green (Architect/Author)
**AI Lead:** Casey A Jones (Designer/Implementer)

## Architectural Decisions

1. **Persistence (Mode A):** Direct `.xlsx` round-trip chosen to ensure PMO compatibility. SheetJS handles mapping rows to the `Team/Phase/SubTask` object hierarchy.
2. **State Management:** Angular Signals used for real-time rollup calculations. This allows the "Impact Preview" in the modal to update dynamically without service calls.
3. **Gantt Implementation:** Custom SVG/CSS implementation preferred over `ngx-gantt` to allow the specific 3-tier date header and color-by-methodology requirements.
4. **Data Model:** Structured to mirror the 7-phase Carelon methodology. WBS generation is localized to the `ProjectService`.

## To-Do (Pass 2)
- Implement `SheetJS` Excel-to-Object mapping logic for the V11 schema.
- Build the "Cadence-aware" multi-step modal.
- Verify unique WBS generation for two-section teams (e.g., T-02).