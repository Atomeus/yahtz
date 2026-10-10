# Spatial first playable

Status: claimed

## Agreed scope

- Usagi and Lua; spatial play in the first version.
- One 5x5 board filled over five turns, followed by total score and replay.
- Five dice per turn; an initial roll and up to two rerolls, with individual holds.
- Explicit transition from rolling to placement permits stopping early.
- Distribute all five dice among empty cells. Rearrange the current turn's dice until confirmation; previous turns stay fixed.
- Preview scoring before confirmation.
- Complete rows and columns score once. A placement can complete both, scored in sequence.
- Each line uses its highest-value qualifying Yahtzee category, with Chance as fallback; overlapping categories do not add together.
- Chance and three/four of a kind: sum of all five faces. Full house: 25. Small straight: 30. Large straight: 40. Yahtzee: 50.
- Straights ignore spatial order. A small straight requires four distinct consecutive faces.
- Choose one of three persistent jokers before the board:
  - Pair Pay: +10 points per distinct face appearing at least twice in a completed line.
  - Short Run: any four distinct faces qualify as a small straight.
  - Thrifty: +5 points per unused roll when confirming a turn.
- Start with two single-use Adjustments, each changing one unplaced die by +1 or -1 within 1..6, after rolling. Held dice can be adjusted.
- Mouse and remappable keyboard/gamepad actions using Usagi input APIs.
- Simple retro pixel tabletop, chunky dice, short bouncy motion, dry dice clacks, rising score tones.
- Sequential line and joker scoring animations, a way to speed through scoring, and reduced motion.
- Multi-board runs, shops, and escalating targets are later exploration.

## Qualification and scoring

- Full house requires exactly three of one face and two of another. Five equal faces qualify as Yahtzee.
- Three/four of a kind require at least three/four matching faces.
- Select the qualifying category with the highest base points. Equal scores produce one base payout; category display priority is Yahtzee, large straight, small straight, full house, four of a kind, three of a kind, Chance. This display-only tie convention does not change payouts or joker triggers.
- Pair Pay counts each repeated face once, including triples, four of a kind, and Yahtzee.
- Short Run expands small-straight qualification; a natural large straight still earns 40.
- Thrifty awards its bonus once per confirmed turn, independent of completed lines.

## Placement and preview

- Choosing Place dice permanently ends rolling for the turn and fixes unused rolls.
- Current-turn placements and Adjustments are undoable before confirmation.
- Confirm requires all five dice placed. It commits placements, spends used consumables, and awards scores once.
- Preview each newly completed line's base score and joker bonus, the Thrifty bonus if applicable, and the resulting total. Incomplete lines earn no points yet.
- Old completed lines do not score again.

## Save and resume

- Save at turn boundaries using Usagi persistence. Preserve the board, score, scored lines, joker, consumables, turn number, and next turn's original dice and random state needed for its rerolls.
- Resume an unfinished turn from its original dice and original consumables; unconfirmed placements, rerolls, and adjustments are discarded.
- Reloading must not generate fresh random outcomes for the same actions.
- Resume a completed board at its results screen. Replay starts a fresh board and joker selection.

## Presentation

- 480x270 logical canvas; board on the left, dice, joker, and controls on the right.
- Show scores as points, with the selected category and each bonus visible during evaluation.
- Input is unavailable for gameplay changes during score resolution; speed-through remains available.
- Reduced motion preserves all scoring information with minimal movement.

## Completion boundary

The first playable is complete when a player can choose a joker, finish a five-turn board using all supported controls, inspect previews and scoring, resume at turn boundaries, and replay. No shop, escalating target, multi-board run, or conventional scorecard mode is required for this version.

Implementation authorized by the user; scoring and game-session test boundaries confirmed.

