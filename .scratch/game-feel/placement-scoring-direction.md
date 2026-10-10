# Placement previews and scoring feedback: agreed direction

Status: needs-triage

## Product direction

Confirmed during the grilling conversation:

- Clever placements are the main reason to replay; satisfying payouts reinforce them.
- Keep a cozy tabletop atmosphere with bigger reactions for exceptional moments.
- A standalone five-turn board remains a complete experience.
- Completing a row and column on one confirmation deserves special emphasis, without adding extra points.
- Routine payouts stay quick; speed-through remains available.

## First experiment

Try placement previews and scoring feedback together on a dedicated experiment branch.

### Before placing

- With a selected die, hover/focus an eligible cell to highlight the affected row and column.
- Evaluate the prospective placement together with other dice already arranged this turn.
- When it would complete a line, show the category and points.
- Clarify consequences without suggesting a best move.
- Preview must not commit placements, spend an Adjustment, consume RNG, or change undo history.

### After confirming

- A completed row receives a horizontal sweep; a completed column receives a vertical sweep through its five cells.
- Points visibly travel from the completed line toward the total.
- If both directions complete, resolve them separately so each contribution is clear.
- Present line base points first, then its joker bonus; highlight the joker name during its contribution.
- Thrifty gets a separate turn-level treatment.
- Preserve existing category rules, payout order, score-once guarantees, and final totals.
- Reduced motion must communicate the same line, category, and points using static highlights and labels.

## Deferred options

- Quiet markers for nearly complete rows and columns: explicitly deferred, not part of this experiment.
- Additional factual results highlights on boards that miss the personal best: explicitly deferred.
- Results-screen changes are outside this first experiment. Earlier interest in strongest-line and personal-best summaries remains an option for a separate discussion.
- New scoring bonuses, progression, and longer runs are outside this experiment.

## Prototype evaluation

- Can the player identify which row/column a tentative placement affects?
- Can they understand the prospective points without mistaking them for committed points?
- Does confirming a row-and-column completion feel satisfying while keeping both payouts understandable?
- Are joker contributions attributable and routine payouts short enough to remain enjoyable?
- Verify mouse and remappable keyboard/gamepad paths, reduced motion, speed-through, and save/resume behavior through existing domain and lifecycle seams.
- Exact durations, sweep styling, and label placement are prototype tuning choices; they were not settled in the interview.

## Working agreement

Before implementing, create or switch to a dedicated feature/experiment branch and tell the user its name. Keep main and unrelated integration work untouched. These notes record shared direction; no gameplay changes were made during the interview.

## Comments

- The user confirmed the proposed first experiment after clarification that it concerns placement and scoring, with results work left for later.
- Source ideas: [idea bank](ideas.md); interview prompts: [question bank](questions.md).
