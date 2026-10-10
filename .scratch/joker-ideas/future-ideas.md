# Future joker ideas

Status: needs-triage

Recorded at the user's request. These five ideas are deferred, not authorized for
implementation. Names, payouts, and detailed qualification rules are proposals
for a future design discussion and playtest.

| Joker | Proposed ability | Intended strategy |
| --- | --- | --- |
| Outer Limits | At completion, +3 per distinct face on each outer edge, up to +60 | Build a varied border; corners participate in two edges |
| Echo | +10 when a completed line's face sum matches an earlier completed line; pay once per line | Coordinate matching totals across the board |
| Mirror Mirror | +5 for matching first/fifth faces and +5 for matching second/fourth faces, up to +10 per line | Arrange symmetric lines; an alternative to Bookends |
| Last Word | +15 when the fifth die added to a line is a 6 | Prepare lines and choose their finishing die |
| Fresh Start | +10 per turn when all five newly placed dice have distinct faces | Pursue varied rolls and spread them strategically |

## Questions for later

- Echo: define whether lines completed in the same confirmation can match each
  other or require a matching total from a previous turn.
- Last Word: define the finishing die when several placements are confirmed
  together, how unplacing/replacing affects the order, and what history must save.
- Mirror Mirror overlaps Bookends; assess whether both warrant roster slots.
- Tune payouts with the existing joker roster and event rewards.

## Current selection

The user selected Alternator, Variety Show, and Double Feature for implementation
instead. They are implemented in `8d6f80d` and merged into main at the
initial proposed values. These deferred ideas are not included in random drafts.

The board objective Mirror, Mirror is now implemented, but is a separate
once-per-board objective; it does not implement the deferred per-line joker.
None of these five ideas is required to finish the accepted scope.
