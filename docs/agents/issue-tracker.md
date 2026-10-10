# Issue tracker: Local Markdown

Issues and specs live as Markdown files in `.scratch/`.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`.
- Specs: `.scratch/<feature-slug>/spec.md`.
- Tickets: `.scratch/<feature-slug>/issues/<NN>-<slug>.md`,
  numbered from 01, with one file per ticket.
- Record triage state in a `Status:` line near the top,
  using the roles in `triage-labels.md`.
- Append conversation under `## Comments`.

## Publishing and fetching

When a skill says to publish to the issue tracker, create
the appropriate file under `.scratch/<feature-slug>/`.

When fetching a ticket, read its referenced file.

## Wayfinding operations

- Map: `.scratch/<effort>/map.md`, containing Notes,
  Decisions-so-far, and Fog.
- Children: `.scratch/<effort>/issues/NN-<slug>.md`.
- Record ticket type with `Type:`: research, prototype,
  grilling, or task.
- Record workflow state with `Status: claimed` or
  `Status: resolved`.
- Record dependencies with `Blocked by: NN, NN`.
  A ticket is unblocked when every dependency is resolved.
- Frontier: select the first open, unblocked, unclaimed
  ticket by number.
- Claim: save `Status: claimed` before starting work.
- Resolve: append an `## Answer`, set `Status: resolved`,
  and add a summary and link to the map's Decisions-so-far.
