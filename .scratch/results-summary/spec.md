# Results summary: agreed design

Status: resolved

## Purpose and presentation

- Celebrate the completed board and offer a replay target; no grades, stars, or negative performance labels.
- Keep the completed board on the left and a compact summary on the right.
- Show the summary after existing payouts without another required animation. A brief finishing accent is acceptable; reduced motion stays static.
- Summary order: total score, Table best comparison, strongest line, joker contribution, and actions.
- Give the displayed strongest line a static outline on the board.

## Table best comparison

- Table best means the highest locally recorded board score across names and jokers.
- Compare against the record before this board is recorded.
- Distinguish first recorded board, new Table best, matched Table best, and points short of Table best.
- Preserve the original comparison when reopening results, after name entry, and after restart.
- For legacy completed saves without reliable previous-record data, omit uncertain comparison claims.

## Strongest line

- Rank all rows and columns by their total points including line-specific Pair Pay bonuses.
- Exclude Thrifty from line ranking because it rewards turns.
- Show the chosen line's five faces, category, and total.
- For tied winners, select consistently and label Joint strongest.

## Joker contribution

- Measure points added to this completed board, rather than predicting play without the joker.
- Pair Pay: sum line bonuses.
- Thrifty: sum turn bonuses.
- Short Run: sum the difference between each line's score with Short Run and its score under ordinary rules, using identical faces.
- Show genuine zero contributions honestly.
- Omit unavailable legacy contributions rather than guess, particularly Thrifty when turn history is missing.

## Navigation and name entry

- Show results before qualifying name entry.
- Save score is primary while an eligible score is pending. Saving returns to the summary.
- Otherwise, Play again is primary and returns to joker selection. Main menu is secondary.
- Score details opens the detailed scoring ledger with a clear return to the summary.
- Choosing Play again or Main menu with a pending qualifying score opens a prompt: Save score, Skip and continue, Back.
- Save score enters name entry and returns to the summary afterward.
- Skip and continue explicitly declines recording and proceeds to the originally selected destination.
- Back dismisses the prompt and leaves the score pending.
- Preserve existing qualification, tie ordering, optional names, and duplicate-record protection.

## Implementation boundary

- User authorized implementation; delivered in `a27fd5f` and merged into main.
- Later joker and event integrations preserve the original summary behavior.
- Preserve scoring, deterministic turn-boundary saves, reduced motion, and supported mouse and remappable keyboard/gamepad controls.
- Keep results behavior/rendering in a cohesive screen module and summary calculations separate from presentation where appropriate.
- Validate summary attribution, prior-record persistence, pending-score navigation, legacy fallbacks, and replay through existing domain and application test seams.

## Related documents

- Domain terms: ../../GLOSSARY.md
- Source proposals: ../game-feel/ideas.md
- Earlier placement experiment: ../game-feel/placement-scoring-direction.md

## Implementation review and conclusion

The accepted summary is implemented in `screens/results.lua` and
`game/results_summary.lua`, with application coordination/persistence in
`main.lua`. Domain tests cover comparisons, attribution, strongest-line ties,
and legacy omission. Application lifecycle tests cover summary-first name entry,
save/skip/back navigation, reopening results, persisted comparisons, score
qualification, and replay.

The summary now also supports all fifteen jokers, line-specific event bonuses,
a separate Events contribution, and unlocked-color notices. Strongest line
continues to mean a row or column; Crossroads joker diagonals contribute to joker
points but are excluded from strongest-line ranking. Unknown legacy turn bonuses
and prior-record comparisons are omitted instead of reconstructed.

No accepted summary requirement remains to implement. Manual readability,
reduced-motion presentation, and physical gamepad checks remain playtest tasks.
No new summary animation or feature is required to close this scope.
