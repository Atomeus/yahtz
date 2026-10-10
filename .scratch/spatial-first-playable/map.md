# Spatial first playable

## Notes

Spec: [spec.md](spec.md). Integration branch: `integration/spatial-first-playable`.

## Decisions-so-far

The request to build confirms the agreed spec. All tickets are resolved:

- [01 scoring](issues/01-scoring.md): scoring API and Lua 5.5 headless tests.
- [02 session](issues/02-session.md): deterministic rolls, reversible placement, atomic scoring and turn-boundary snapshots.
- [03 playable presentation](issues/03-playable.md): complete tabletop, remappable actions, generated sounds, scoring previews, reduced motion, persistence and replay.

## Fog

Confirmed test boundaries: scoring and game-session behavior. Domain tests, full-board adapter smoke and actual Usagi gameplay pass. Physical gamepad hardware remains untested.
