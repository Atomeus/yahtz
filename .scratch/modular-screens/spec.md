# Modular screen restructuring

Status: resolved

## Problem Statement

The audit found that the engine entry point combines menu and leaderboard rendering, name editing, joker selection, board presentation, input navigation, persistence, and scoring animation. This makes unrelated changes touch the same module and makes future work harder to understand. Name-appending rules and motion preference actions are also duplicated.

The scoring, session, and high-score modules already provide useful boundaries. The audit found no hard documented-standard violations or concrete spec failures; this work addresses maintainability.

## Solution

Restructure the existing game into cohesive screen modules, each keeping its behavior and rendering together. Keep engine coordination small, reuse shared controls and editing rules, and preserve the current player experience, rules, saves, and supported inputs.

## User Stories

1. As a maintainer, I want the main menu and leaderboard in one module, so that menu changes are easy to locate.
2. As a maintainer, I want name-entry behavior and rendering together, so that editing and submission remain consistent.
3. As a maintainer, I want joker selection in one module, so that choice presentation is easy to change.
4. As a maintainer, I want board presentation and scoring animation together, so that gameplay presentation has a clear owner.
5. As a maintainer, I want shared button activation and directional focus, so that every screen behaves consistently.
6. As a maintainer, I want explicit screen actions, so that dependencies are understandable without reading the whole application.
7. As a maintainer, I want a small engine entry point, so that lifecycle coordination is easy to inspect.
8. As a maintainer, I want scoring and session logic to retain their existing boundaries, so that presentation changes cannot silently change rules.
9. As a maintainer, I want a single name-length limit and append operation, so that every editing path follows the same rules.
10. As a maintainer, I want one motion preference action, so that changing the preference consistently persists it.
11. As a player, I want Play now, Continue, View results, and replay to retain their current behavior, so that navigation remains familiar.
12. As a player, I want the leaderboard and optional name entry preserved, so that completed boards remain recorded correctly.
13. As a player, I want mouse and remappable keyboard/gamepad controls preserved, so that I can keep using my preferred controls.
14. As a player, I want rolls, held dice, cell placement, Adjustments, and undo unchanged, so that the board plays the same way.
15. As a player, I want preview totals and sequential line and joker payouts preserved, so that scoring remains understandable.
16. As a player, I want speed-through and reduced motion preserved, so that presentation remains comfortable.
17. As a player, I want existing saves and deterministic turn-boundary resume preserved, so that restructuring does not lose progress.
18. As a maintainer, I want behavioral checks during each extraction, so that regressions are isolated to a small change.

## Implementation Decisions

- MainMenu owns menu and leaderboard rendering and menu-specific actions.
- NameEntry owns the entry buffer, append/delete behavior, and submission/skip interactions. HighScores remains responsible for ranking, qualification, normalization, capacity, and the canonical name-length limit.
- JokerSelection owns choice presentation and selection interactions.
- GameScreen owns board and dice presentation, previews, ledger presentation, and scoring animation timing. Session remains responsible for legal gameplay transitions, deterministic rolls, preview calculations, confirmation, and boundary snapshots.
- Shared Controls owns button registration, hit testing, activation, directional focus, and focus rendering. Preserve navigation geometry and enabled-control behavior.
- Engine coordination owns initialization, shared application state, screen transitions, save/load, and lifecycle dispatch. Screens receive relevant state and a small explicit set of actions, such as starting a board, changing screens, saving a score, and toggling motion.
- Do not pass an unrestricted service bag or introduce a general scene framework. Extract only responsibilities that already exist.
- Keep persistent state compatible with Usagi live reload. Rebuild transient controls and callbacks as needed; do not serialize callbacks or screen module objects.
- Centralize motion preference mutation and persistence. Reuse one name append operation and the canonical name-length limit across existing entry interactions.
- Preserve the current save shape, save timing, original dice on resume, leaderboard ordering, tie handling, blank-name fallback, and duplicate-submission protection.
- Plan step 1: establish the behavioral baseline and confirmed integration testing boundary against the current working tree, including the uncommitted high-score work.
- Plan step 2: extract shared Controls and MainMenu; verify menu navigation, Continue/View results, and leaderboard display.
- Plan step 3: extract NameEntry and JokerSelection; consolidate name editing and motion actions.
- Plan step 4: extract GameScreen and scoring animation; reduce the entry point to lifecycle coordination.
- Plan step 5: run regression checks, verify actual Usagi behavior, and document the final module ownership.
- Each step must preserve behavior before the next extraction begins. Do not mix rule changes or unrelated cleanup into the restructuring.

## Testing Decisions

- Test externally observable behavior and state transitions, not filenames, helper calls, callback ordering, or exact draw-call sequences.
- Keep the existing scoring, session, and high-score suites as prior art and the primary domain seams. Their stock Lua runtime runner already exercises deterministic resume, atomic confirmation, five-turn results, ranking, and name normalization.
- Additional seam approved with implementation: exercise application behavior through the Usagi lifecycle callbacks with simulated input, minimal drawing stubs, and in-memory persistence. Use one integration harness rather than a separate mock architecture for each screen.
- At that seam, cover menu-to-joker-to-board navigation, one completed board through score resolution, name submission and skip, prevention of duplicate records, saved preferences, and resume from an existing boundary.
- Cover shared controls through user-visible activation/navigation behavior, including disabled controls and screen transitions.
- Continue to check existing saved data compatibility and deterministic repeated actions through the session seam.
- Verify the 480x270 layout, dice and cell focus, leaderboard/name-entry readability, sound, scoring animation, speed-through, reduced motion, and pause menu in actual Usagi. A stubbed integration harness does not verify rendering or physical gamepad hardware.
- If physical gamepad hardware is unavailable, record that limitation rather than claiming it was tested.

## Out of Scope

- Physical keyboard typing for names, mobile keyboard support, Unicode/IME input, and other input features.
- Changes to scoring, jokers, rolls, Adjustments, board size, or turn count.
- UI redesign, new screens or gameplay features, online leaderboards, and save-schema migration.
- A generic scene framework, dependency injection framework, event bus, or wholesale state-management replacement.
- Splitting every helper into a separate module or rewriting the existing domain modules.

## Further Notes

The audit covered development history after the initial commit through the reviewed HEAD and the current uncommitted changes. It reported two heuristic maintainability findings: divergent responsibilities in the entry point and duplicated editing/preference logic. Existing scoring, session, and high-score suites passed; live engine and physical gamepad verification were not repeated during that audit.

Preserve existing uncommitted work. This spec authorizes a behavior-preserving restructuring plan; publishing it does not itself implement the refactor.

## Comments

- The user requested recording the audit recommendations and planning a modular restructuring, with MainMenu as an example.
- The user approved proceeding with implementation, including the proposed lifecycle integration check.

## Answer

Implemented the four screen modules, shared controls and drawing helpers, shared joker presentation data, centralized motion action, and canonical name-length limit. The engine entry point now coordinates lifecycle, persistence, and screen transitions. Existing uncommitted high-score and session changes were retained.

Validation: all four Lua suites pass through python tools/test.py, including lifecycle navigation, full boards, resume, preferences, name limits, blank-name fallback, skip, and duplicate prevention. git diff --check passes. Usagi 1.2.0 stayed running through a three-second startup check without reported runtime errors. Visual behavior, sound quality, and physical gamepad hardware were not manually verified.
