# Saga Numbering

**Status:** stable as of `KTS-0000001`.

## Atomic IDs (band-prefixed)

Format: `KT-{BAND}-{7-digit zero-padded}`.

| Band | Use | Example |
|---|---|---|
| `PRMPT` | Individual prompts when assigned a standalone ID | `KT-PRMPT-0000042` |
| `RESP` | Individual responses | `KT-RESP-0000042` |
| `SYN` | Synthesis docs | `KT-SYN-0000007` |
| `APP` | Application milestones (commit-pinned releases) | `KT-APP-0000003` |
| `HW` | Hardware decisions (also `HW-BLD-NNN` for full build registries) | `KT-HW-0000001` |
| `WIKI` | Wiki entries when they stabilize enough to assign IDs | `KT-WIKI-0000004` |

Bands match your Cyclopter convention (Runners, Workers, Guardians, Conductors, Couriers, Custodians) in spirit — narrow, predictable, machine-greppable.

## Saga IDs (groupings)

Format: `KTS-{7-digit zero-padded}`.

A saga is one round-trip of work: a prompt, one or more responses, optionally a synthesis, optionally application/wiki/hardware artifacts. All artifacts in the same saga carry `KTS-NNNNNNN` in their filename, so:

```
ls C:\RAW\KT\**\*KTS-0000001*
```

returns every artifact from this turn across every folder.

## Counter authority

The next saga ID is tracked at `06_Status/STATUS.md → ## Active Saga`. Increment when you start a new round-trip. If you start a saga that doesn't deserve an ID (truly throwaway work), don't number it — but then don't put it in this vault either; it goes in scratch.

For atomic band IDs, keep counters per-band in front-matter on a small ledger doc — proposed: `05_Wiki/saga-ledger.md` (created when the first numbered atomic artifact ships). For `KTS-0000001` we did not need atomic band IDs because every artifact takes its identity from the saga; you'll create your first `KT-PRMPT-NNN` or `KT-WIKI-NNN` when you have a reusable artifact that needs to be referenced independently of its saga.

## Filename convention

`YYYY-MM-DD_KTS-NNNNNNN_short-slug.md`

- ISO date prefix sorts chronologically.
- Saga ID makes cross-folder grep trivial.
- Short slug (3–6 words, hyphenated, lowercase) makes it human-readable.

If a single saga produces multiple artifacts in the same folder, suffix with `-PART01`, `-PART02`, etc. — but prefer to give each its own folder home so the slug stays clean.

## Front-matter

Each artifact begins with:

```markdown
**Saga:** KTS-NNNNNNN
**Date:** YYYY-MM-DD
**Tool:** {claude | gemini | human | other}
**Pairs with:** path/to/sibling.md  (optional)
```

This is what the RAG ingest pipeline parses to attribute chunks correctly.
