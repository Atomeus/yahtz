ï»¿# Selectable color schemes and score-based unlocks

Status: resolved
Type: task
Priority: future

## Goal

Let players personalize the table with cosmetic color schemes, with additional schemes permanently unlocked by completed-board score milestones.

## Proposed experience

- Add Colors to the main menu with swatches and a miniature table preview.
- Classic Table preserves the current green, brown, and cream look and is available immediately.
- Candidate unlockable schemes: Midnight (navy/indigo), Plum Velvet (purple/pink), and Golden Hour (warm brown/orange/yellow).
- Locked schemes show the required score. Exact thresholds remain to be tuned against completed-board scores.
- Unlock schemes when a completed board reaches a milestone, regardless of whether the player submits a leaderboard name.
- Announce new unlocks at results without automatically equipping them.
- Persist selected scheme and permanent unlocks. Credit existing saved high scores when loading older saves.
- Keep a readable default available immediately; retain labels and outlines alongside color.

## Implementation outline

1. Introduce a Themes module with semantic roles for table, panels, text, dice, pips, selection, and disabled controls. Replace direct color references in screen and shared UI modules. Start with Classic and Midnight previews.
2. Add the Colors screen and persistent selection, preserving compatibility with existing saves.
3. Add score milestone evaluation, permanent unlocks, and results notifications. Keep unlock rules independent of rendering and leaderboard ranking.

## Acceptance and verification

- Changing schemes updates the entire game consistently without changing gameplay or scoring.
- Locked schemes cannot be equipped; unlocked schemes stay available across boards and restarts.
- Skipping name entry does not prevent earned unlocks.
- Existing saves load safely with Classic selected by default and eligible milestones credited.
- Cover selection, unlock boundaries, repeated completion, skipped name entry, and persistence through the existing lifecycle integration seam and focused domain checks.
- Visually verify text, dice faces, selected controls, and disabled controls in every scheme.

## Open decisions

- Resolved in [the score-based color unlocks PRD](../spec.md): Classic Table is immediate; Midnight unlocks at 200, Plum Velvet at 300, and Golden Hour at 400 completed-board points. Retain the four existing palettes.

## Out of scope

Gameplay bonuses, online accounts, paid cosmetics, and changes to scoring rules.

## Comments

- User approved keeping this as a future todo, not implementing it now.

- Implemented the selectable-theme proof of concept: all four schemes available,
  shared semantic color roles, live preview, saved selection, and safe fallback.
  Contrast checks and lifecycle coverage added. Score thresholds, permanent
  unlocks, and unlock notifications remain future work; this ticket stays open.

- Published [the implementation-ready PRD](../spec.md) from the scoring discussion.
  It defines inclusive milestones, permanent ownership, migration, results notices,
  and both lifecycle and dedicated unlock-rule tests. This request authorizes the
  specification only; gameplay implementation remains a separate task.

## Answer

Implemented on `feature/color-unlocks` after the user authorized implementation.
Completed boards permanently unlock Midnight at 200, Plum Velvet at 300, and Golden
Hour at 400. Ownership and pending results notices save at the final turn boundary;
Colors enforces ownership, and migration credits legacy scores and preserves the
previous selection. Dedicated unlock-rule and application lifecycle tests cover
boundaries, restart during payouts, skipped recording, notices, and migration.
All nine suites pass with `usagi run test.lua`. Physical gamepad and visual inspection
remain manual verification items.
