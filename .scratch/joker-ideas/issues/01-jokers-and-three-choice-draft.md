# Nine new jokers and a random three-choice draft

Status: resolved
Type: task

## Scope

Implement the nine agreed candidates in [the design notes](../ideas.md), keeping
the original three jokers. At each new-board entry, deal three distinct random
jokers from all twelve and let the player choose one. Keep the offer stable while
choosing and preserve the selected joker on Continue. Draft randomness must not
consume the session dice generator.

## Answer

Implemented on `feature/joker-draft`. Added Crossroads, Little Ones, Bookends,
Rainbow, Odd Todd, Even Steven, Step Up, Opposites, and Star at the agreed provisional
values. Diagonals pay once when filled and persist their scored identities. Star
pays once on completion. All bonuses participate in previews, payout events,
results attribution, leaderboard scores, and color milestones. Strongest line
retains its glossary meaning of a row or column.

Selection cards show three distinct random offers with mouse and remappable action
support. Cards fit the engine's 16-pixel line height. The existing details dialog
explains every joker.

All ten suites pass with `usagi run test.lua`. Coverage includes worked bonuses,
full boards for all twelve jokers, diagonal completion before the final turn,
score-once and restart behavior, attribution, draft variety and uniqueness,
mouse/action selection, card text bounds, and reduced-motion feedback. Visual
inspection and physical gamepad verification remain manual checks.
