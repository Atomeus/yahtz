# Joker ideas

Status: resolved

Accepted designs are implemented and merged into main. These notes preserve the
original nine-joker discussion; [the first implementation ticket](issues/01-jokers-and-three-choice-draft.md)
and [the strategic-joker ticket](issues/02-strategic-jokers.md) record delivery.

## Accepted direction

- Crossroads: score the two full corner-to-corner diagonals once each when filled, using ordinary combination scoring. Dice order does not affect combination qualification. The center participates in four scoring lines.
- Little Ones: +5 per actual 1 in each completed row or column, without changing its face value. Each placed 1 contributes +10 over a finished board.
- Bookends: +10 when the two end dice of a completed row or column match. User particularly likes this idea.
- Rainbow: +15 for a completed row or column with five distinct faces.
- Odd Todd: +15 for a completed row or column containing only odd faces.
- Even Steven: +15 for a completed row or column containing only even faces.
- Bookends pays regardless of the middle three dice, including five identical dice.
- All bonus values are initial playtest values.
- Step Up: +5 for each adjacent pair whose faces differ by exactly 1 within a completed row or column. Either ascending or descending pairs qualify; pairs overlap. A five-die ordered straight earns +20; a Yahtzee earns no bonus.
- Opposites: +5 for each adjacent pair whose faces total 7 within a completed row or column. Pairs overlap; `1 6 1 6 1` earns +20. A Yahtzee earns no bonus.
- Step Up and Opposites replace the matching-pair Neighbors proposal. Ordinary Yahtzee scoring remains available; these bonuses reward different arrangements.
- Agreed candidate roster for eventual playtesting: Crossroads, Little Ones, Odd Todd, Even Steven, Bookends, Rainbow, Step Up, and Opposites. Bonus values remain provisional.
- Step Up explicitly permits zigzags: `1 2 1 2 1` earns +20, just like `1 2 3 4 5`.
- Star: at board completion, +5 for each of the four cells directly above, below, left, or right of the board's center whose die matches the center die. Only the board's center is a hub; diagonal neighbors do not count. Award once per board, for a maximum of +20. User approved this ninth candidate.

## Deferred and rejected

- Matching-pair Neighbors was rejected because it compounds the existing incentive to pursue Yahtzee.
- Balance values require playtesting. All nine accepted candidates are implemented.

## Comments

User approved two full diagonals and an additive bonus for actual 1s, suggested Odd Todd / Even Steven, particularly liked Bookends, and expressed interest in Neighbors.

User subsequently accepted Step Up and Opposites as alternatives to matching-pair Neighbors. Interpreted "setup" as Step Up from the preceding proposal.

User confirmed the eight-candidate roster, bidirectional Step Up including zigzags, the +15 all-odd/all-even bonuses, and unconditional matching-end qualification for Bookends. Candidate design discussion is complete.

User then added and approved Star, expanding the roster to nine candidates. Star rewards a matching cluster around the single central hub at board completion.

## Current conclusion

The original Pair Pay, Short Run, and Thrifty plus these nine additions shipped
in `ca5bbd7`. Alternator, Variety Show, and Double Feature followed in `8d6f80d`.
All fifteen are on main and eligible for the random three-choice draft. Draft
randomness is separate from dice randomness, and the selected joker survives
Continue. Bonuses participate in previews, persistence, results, and unlock scores.

No accepted joker remains to implement. The five [future ideas](future-ideas.md)
are deliberately deferred; they are not missing release requirements. Echo and
Last Word need timing/history decisions, Mirror Mirror overlaps Bookends, and
all proposed payouts need review alongside event rewards.
