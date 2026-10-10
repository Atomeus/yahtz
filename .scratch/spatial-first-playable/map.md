# Spatial first playable

## Notes
Spec: [spec.md](spec.md). Integration branch: integration/spatial-first-playable.

## Decisions-so-far
The request to build confirms the agreed spec. Tickets: 01 scoring -> 02 session -> 03 playable.

[01 scoring](issues/01-scoring.md) resolved: pure scoring API and Lua 5.5 headless test runner.

## Fog
Confirmed test boundaries: pure scoring and game-session behavior. Runtime presentation checked separately.



[02 session](issues/02-session.md) resolved: pure session API owns deterministic RNG and committed turn-boundary snapshots; presentation resolves returned score events before adopting the prepared next turn.

- [03 playable presentation](issues/03-playable.md) resolved: full tabletop UI, generated sounds, accessible motion option, remappable actions and boundary persistence. Validated domain suite, complete-board adapter smoke and actual engine gameplay.
