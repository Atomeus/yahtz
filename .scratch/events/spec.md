# Events

Status: resolved

Implemented on `feature/events` in the dedicated `.worktrees/events` worktree.

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
- Events are automatically dealt: one board event at board start and a fresh turn event each turn. No repeated turn event on a board; exact repeat identity remains to define.
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

The initial board event is: finish at least three rows with exactly 20 pips each, for +50 at board completion. Columns do not count toward this objective. Start with this single hard objective; expand variety after playtesting.

## Failure and presentation

- Unmet turn events expire for zero points. There is no penalty or event exchange action. An unmet board event likewise earns no bonus.
- Show the active board and turn objectives during play.
- Preview event payouts before confirmation, including the board-event payout on the final turn.
- List event contributions separately in results and make multiplier bonuses additive in the explanation: an ordinary 25-point line with x2 earns 25 line points plus 25 event points. Joker bonuses remain separate.
- Final-turn confirmation can earn both the turn-event payout and the board-event payout; neither multiplies the other.

## Deferred to playtesting

- Tune payouts and assess whether the three-row board objective is appropriately difficult.
- Assess the frequency of unachievable events under the agreed random-dealing policy.
- Additional event types and hard board objectives are outside this initial set.

## Integration

- Base commit: `a27fd5f` (before the concurrent joker implementation).
- Event rules live in `game/events.lua`; `game/session.lua` invokes them for new turns, previews, and confirmation.
- Persistence adds an optional `objectives` field to session snapshots. Legacy boards lacking it continue without events. No changes to application persistence or the save envelope are needed.
- Event evaluation consumes ordinary completed rows/columns and does not define joker rules. Multipliers explicitly evaluate faces without a joker so joker rule improvements are not multiplied.
- `game/results_summary.lua` includes recorded event line bonuses in strongest-line selection and reports event contribution separately.
- Expect integration overlaps with joker work in session lifecycle, game rendering, results attribution, glossary, and test-suite registration. Preserve both features rather than replacing either path.
- Domain and application lifecycle tests cover event payouts, previews/undo, RNG independence, boundary reload, old saves, visibility, and results attribution.

## Validation

All ten suites pass with `usagi run test.lua` on Usagi 1.3.3, including the event suite and application lifecycle checks. The same suites also pass under the installed Lupa Lua runtime. Objective bounds are checked against the 480x270 canvas and engine text measurements; manual visual playtesting and reward balance remain outstanding.

## Primary worktree experiment

Integrated onto `experiment/events` from joker-enabled `main` at `ca5bbd7`, without advancing main. Preserved the twelve-joker draft, diagonal lines, Star attribution, and event contributions. Added a regression covering event multipliers with every joker. The combined runner includes eleven suites.
