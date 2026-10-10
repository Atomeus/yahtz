# Yahtz

A spatial dice game built around familiar dice combinations, consumables, and persistent scoring modifiers.

## Language

**Board**:
The grid of cells that holds placed dice across turns.
_Avoid_: Scorecard

**Cell**:
A single board position that holds one die.

**Roll**:
A throw of the dice that are not held.

**Turn**:
A sequence of up to three rolls followed by arranging the five resulting dice on the board.

**Held die**:
A die the player keeps out of the next roll during a turn.
_Avoid_: Locked die

**Combination**:
A recognizable grouping of dice faces, such as a pair, three of a kind, straight, or full house.
_Avoid_: Poker hand

**Consumable**:
A single-use item that changes dice or board cells.

**Joker**:
A persistent modifier that changes combination rules or provides additional ways to score.

**Line**:
A complete row or column of five board cells, evaluated once when it fills.

**Chance**:
The fallback scoring category worth the sum of the faces in a line.

**Event**:
A temporary objective that rewards qualifying die placements or board arrangements.

**Board event**:
An event revealed at the start of a board that lasts for the whole board and is evaluated at board completion.

**Turn event**:
An event revealed at the start of a turn that is evaluated when that turn's placements are confirmed. It must involve at least one die placed during that turn.

**Adjustment**:
A consumable that changes one unplaced die by one face value, within one through six.
