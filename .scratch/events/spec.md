# Events

Status: resolved

Implemented and merged into main (`7a69073`, `1d96d6a`, and `7f65f3f`).

## Starting idea

Events reward particular die placements or pip counts. Explore addition and multiplication events alongside the existing board, combination scoring, and persistent jokers.

## Design status

Initial design agreed and implemented at the user's request. Reward balance remains provisional for playtesting.

## Agreed rules

- Include arithmetic placement puzzles and reward modifiers as separate event types; user accepted the proposed arithmetic direction.
- One hard event lasts for the entire board (the user's "game").
- Easier events change each turn to influence dice and placement choices.
- Board event and turn event are the agreed names for the two durations.
- Reveal the board event before the first roll and each turn event before that turn's first roll.
- Turn events must involve at least one die placed during the current turn. Previously placed dice may help, but cannot satisfy a turn event by themselves.
- Board events examine the finished board.
- Each event pays once: turn events on placement confirmation; the board event at board completion. Rearrangements update previews without awarding points.
- Multiplier events target a specific completed row or column. Multiply its ordinary combination score; joker bonuses are added separately, and event multipliers do not multiply one another.
- Events are automatically dealt: one board event at board start and a fresh turn event each turn. No repeated turn-event condition on a board; changing its marked location does not permit a repeat.
- Easy events usually require two or three dice. Hard events require several coordinated lines or placements. Difficulty comes from planning rather than only larger numeric thresholds.
- Arithmetic placement events use distinct orthogonally adjacent cells, with order irrelevant. Turn objectives require at least one newly placed die. Multiple qualifying patterns still pay once.
- Initial playtest payouts: +10 for easy arithmetic events, x2 ordinary combination score for a marked-line event, and +50 for a hard board event. Board events are additive initially.
- Randomness may help or hinder. Marked-line events randomly target an unfinished row or column, with no further solvability filtering. Events may require unlikely dice or target a line with too many empty cells to finish that turn.
- The same exact objective does not repeat on a board, but different targets from the same family may appear (for example adjacent sum 7 and adjacent sum 9). For marked-line events, define identity by objective condition rather than location so a different marked line does not permit the same condition to repeat.

## Initial event set

Deal five turn events without replacement from these six objectives, one before each turn's first roll:

| Objective | Reward |
| --- | --- |
| Two orthogonally adjacent dice sum to 7 | +10 |
| Two orthogonally adjacent dice sum to 9 | +10 |
| Two orthogonally adjacent dice multiply to 6 | +10 |
| Two orthogonally adjacent dice multiply to 12 | +10 |
| Complete the marked row or column with exactly 15 pips | x2 that line's ordinary combination score |
| Complete the marked row or column with exactly 20 pips | x2 that line's ordinary combination score |

Each new board randomly receives one of seven board events. See
[the expansion spec](../board-objectives/spec.md) and the README rule table:
Three Rows (+50), Four Corners (+50), Crossroads (+75), Mirror, Mirror (+75),
Twin Diagonals (+75), Full Collection (+100), and Checkerboard (+100).
Progress includes tentative placements. Older event saves without a board-event
identity retain Three Rows; saves without events remain unchanged.

## Failure and presentation

- Unmet turn events expire for zero points. There is no penalty or event exchange action. An unmet board event likewise earns no bonus.
- Show the active board and turn objectives during play.
- Preview event payouts before confirmation, including the board-event payout on the final turn.
- List event contributions separately in results and make multiplier bonuses additive in the explanation: an ordinary 25-point line with x2 earns 25 line points plus 25 event points. Joker bonuses remain separate.
- Final-turn confirmation can earn both the turn-event payout and the board-event payout; neither multiplies the other.

## Deferred to playtesting

- Tune payouts and assess whether the three-row board objective is appropriately difficult.
- Assess the frequency of unachievable events under the agreed random-dealing policy.
- Further event types are optional future scope; the six accepted board-objective additions are implemented.

## Implementation and review

- `game/events.lua`: turn dealing, eligibility, additive event payouts.
- `game/board_objectives.lua`: seven board rules, progress, labels, and details.
- `game/session.lua`: reversible previews, once-only confirmation, persistence.
- `screens/game.lua` and `screens/event_details.lua`: progress and rule explanations.
- `game/results_summary.lua`: event contribution and line-specific event bonuses.
- `tests/events.lua` and `tests/application.lua`: qualification boundaries,
  distinct-line collection matching, random dealing, persistence, compatibility,
  final-turn combined rewards, and integration with every joker.

All accepted requirements are implemented. There is no required feature left
before playtesting. Reward tuning and manual visual/physical gamepad checks
remain validation work, not evidence that the rules are balanced.
