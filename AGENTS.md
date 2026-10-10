## Agent skills

### Issue tracker

Issues and specs live in local Markdown under `.scratch/`.
See `docs/agents/issue-tracker.md`.

### Triage labels

Use the five default triage roles.
See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: root `GLOSSARY.md` and `docs/adr/`.
See `docs/agents/domain.md`.

## Code organization

When adding or changing features, keep modules cohesive:

- Keep each screen's behavior and rendering together in its screen module, such as the main menu or theme selection.
- Keep domain rules separate from presentation: scoring, game sessions, and high-score ranking belong in their own modules.
- Keep main.lua focused on engine lifecycle, application coordination, persistence, and screen transitions.
- Reuse shared controls, drawing helpers, and semantic theme colors. Pass explicit state and actions to screens; avoid hidden dependencies on global State.
- Extract when responsibilities change for different reasons or logic is duplicated. Keep closely related helpers together; avoid a file per function or a generic framework without a concrete need.
- Preserve existing behavior and save compatibility during restructuring, and verify behavior through existing domain and lifecycle test seams.
