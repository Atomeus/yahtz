# Alternator, Variety Show, and Double Feature

Status: resolved
Type: task

## Scope

The user authorized the three recommended ideas and requested future notes for
Outer Limits, Echo, Mirror Mirror, Last Word, and Fresh Start.

- Alternator: +5 for each adjacent odd/even transition in a completed row or
  column. Overlapping pairs and both directions count; maximum +20 per line.
- Variety Show: at completion, +10 for each distinct ordinary scoring category
  awarded across the ten rows/columns. Use the selected highest-value category;
  duplicates count once. Event multipliers do not alter categories. Up to +70.
- Double Feature: +20 for a confirmation that completes at least one new row and
  one new column. Pay once per qualifying turn, including the final turn. Old
  completed lines cannot qualify. Keep the initially proposed value for playtesting.

## Answer

Implemented on `feature/strategic-jokers`. The random three-choice draft draws from
all fifteen jokers. Bonuses participate in previews, payout events, deterministic
turn-boundary saves, results, leaderboard scores, and color milestones. Double
Feature uses persisted turn-bonus history and omits uncertain legacy attribution.
Variety Show is a board bonus and Alternator is a line bonus.

Recorded the other five candidates in [future ideas](../future-ideas.md), without
adding them to the playable roster. Existing event-screen work was preserved.

All eleven test suites pass with `usagi run test.lua`, including the fifteen-joker
application loop, worked bonus examples, category deduplication, simultaneous
completion, final-turn awards, repeat protection, restart behavior, event
integration, and card text bounds. Visual and physical gamepad checks remain manual.
