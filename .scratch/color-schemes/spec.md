# Score-based color unlocks PRD

Status: ready-for-agent

## Problem Statement

All four color themes are currently available immediately. Players lack a lasting
cosmetic reward for improving their completed-board scores and a visible target
that encourages another board. The reward should recognize attainable progress
without requiring an exceptional all-Yahtzee board or leaderboard submission.

## Solution

Keep Classic Table available immediately. Permanently unlock the existing additional
themes when a single completed board reaches these inclusive milestones:

| Theme | Required completed-board score | Purpose |
| --- | ---: | --- |
| Classic Table | None | Readable starting theme |
| Midnight | 200 | Early reward |
| Plum Velvet | 300 | Reward for a strong board |
| Golden Hour | 400 | Longer-term target |

Scores include all line points and joker contributions. Milestones are shared across
names and jokers, and are independent of Table best and leaderboard qualification.
A 400-point board unlocks all three themes. Unlocks save automatically, never expire,
and never change the currently selected theme without the player's action.

The Colors screen shows every theme, its swatches, and explicit ownership or score
requirement. Results celebrate newly earned themes without adding a required
animation, modal, or step before saving a score or playing again.

## User Stories

1. As a new player, I want Classic Table immediately, so that I can play with a readable theme before earning rewards.
2. As a player, I want to see all available colors, so that I know what I can work toward.
3. As a player, I want locked colors to show their required score, so that I have a concrete replay target.
4. As a player, I want to see color swatches before unlocking a theme, so that I can decide which reward interests me.
5. As a player, I want Midnight at 200 points, so that early improvement earns a reward.
6. As a player, I want Plum Velvet at 300 points, so that a strong board earns another choice.
7. As a player, I want Golden Hour at 400 points, so that I have a longer-term challenge.
8. As a player, I want reaching the exact required score to count, so that the requirement behaves as written.
9. As a player, I want one strong board to unlock every milestone it reaches, so that I do not need to repeat lower targets.
10. As a player, I want each milestone to use one completed board, so that the challenge rewards board quality rather than accumulated playtime.
11. As a player, I want joker points to count, so that the displayed final score determines my reward.
12. As a player, I want any joker to earn the same rewards, so that I can choose my preferred strategy.
13. As a player, I want unlocks even when my score misses the leaderboard, so that cosmetic progress does not depend on previous records.
14. As a player, I want unlocks without entering a name, so that optional recording stays optional.
15. As a player, I want skipping score recording to preserve unlocks, so that leaving results does not discard earned rewards.
16. As a player, I want newly unlocked colors acknowledged in results, so that I notice my progress.
17. As a player using reduced motion, I want a static unlock announcement, so that I receive the same information comfortably.
18. As a player, I want unlocks saved at board completion, so that restarting during final payouts preserves rewards.
19. As a player, I want colors to remain unlocked after lower scores, so that earned progress is permanent.
20. As a player, I want my selected theme to remain equipped when another unlocks, so that rewards respect my preference.
21. As a player, I want unlocked colors to apply and save as they do today, so that personalization remains familiar.
22. As a player, I want locked themes clearly unavailable for selection, so that the interface communicates what I can use.
23. As a keyboard or gamepad player, I want unlock information and available selections accessible through remappable controls, so that I can use Colors without a mouse.
24. As a returning player, I want my saved high scores credited toward milestones, so that existing achievements count.
25. As a returning player, I want my previously selected valid theme preserved, so that this update does not take away the appearance I was using.
26. As a player, I want opening Colors during a turn to preserve my dice and unconfirmed actions, so that choosing colors never disrupts play.
27. As a player, I want reopening results to avoid repeated unlock celebrations, so that already acknowledged rewards do not become intrusive.
28. As a player, I want unknown saved theme identities to fall back safely, so that older saves remain playable.

## Implementation Decisions

- Build on the existing theme catalog, Colors screen, results summary, and application persistence. Preserve existing palettes and semantic drawing roles.
- Keep milestone evaluation in a small domain module independent of drawing, leaderboard ranking, and theme palette definitions. It accepts completed-board score evidence and existing ownership and returns cumulative ownership plus newly earned theme identities.
- Use stable theme identities for permanent ownership. Persist ownership separately from the selected theme and leaderboard entries. Include a progression schema version to distinguish existing all-themes-available saves from saves that already enforce unlocks.
- Evaluate milestones when the final turn commits its completed-board save boundary. Persist ownership and any unacknowledged unlock announcement in that same save. Do not require payout animation completion, name entry, or leaderboard recording.
- Only completed boards grant milestones. Intermediate scores, previews, and unconfirmed placements never grant rewards. Requirements are inclusive, use the final total, and are not cumulative across boards.
- Merge earned ownership monotonically. Repeating completion, reopening results, saving a name, changing themes, or loading the same save must not grant duplicate rewards or remove ownership.
- Results show all newly unlocked theme names in a compact static announcement, preserving the board, total, Table best comparison, strongest line, joker contribution, and existing actions. No automatic equipping or required celebration screen.
- Persist pending announcement identities so a restart during final payouts still exposes the reward on results. Keep the announcement while that results view is open; acknowledge and persist dismissal when leaving the summary for another screen, including name entry or score details. Reopening results after acknowledgement does not repeat it. Ownership is independent of announcement acknowledgement.
- The Colors screen replaces its current all-themes-available message with milestone guidance. Locked entries retain readable names, swatches, and a required-score label. Unlocked entries show availability; the selected theme remains visibly marked. The large preview continues to represent the equipped theme; locked entries do not apply or save a selection.
- Enforce ownership in the theme-selection action as well as the presentation. Mouse and remappable keyboard/gamepad controls can select only owned themes. Required-score information remains visible without focusing disabled controls.
- Migration credits the highest valid existing recorded score and any saved completed board, including an unrecorded completed board. Do not treat an unfinished board's current score as completed evidence.
- On migration from saves that predate progression, preserve a recognized non-default selected theme by granting ownership of that theme, even if recorded score evidence is insufficient. Do not grant all themes merely because the previous build offered them. Default and unknown selected identities resolve to Classic Table. Migration grants ownership silently rather than pretending a new board earned it.
- On saves already using progression, an unknown or unowned selected identity falls back to Classic Table. Preserve known owned identities and ignore unsupported ownership identities safely.
- Preserve deterministic turn-boundary saving, existing high-score qualification and ties, duplicate-record protection, motion preferences, and transient in-game state when opening Colors.
- Update the existing feature ticket to reference this PRD; this specification supplies its previously undecided milestones. Implementation must use a dedicated feature branch.

## Testing Decisions

- Test observable outcomes: ownership, displayed requirements, selection behavior, completion notifications, and saved/reloaded state. Avoid assertions about private helpers or the internal arrangement of tables.
- Use the existing application lifecycle integration seam as the primary end-to-end seam. It already drives engine callbacks, mouse and remappable actions, complete boards, theme selection, name entry, and persistence.
- Add dedicated unlock-rule domain tests, as requested by the user, alongside lifecycle coverage. Verify scores immediately below, at, and above 200, 300, and 400; multi-unlock awards; zero scores; repeated awards; monotonic ownership; and independence from leaderboard eligibility and player names.
- Through lifecycle tests, verify completion-time persistence before payouts finish, restart during final payouts, skipped name entry, save-and-return navigation, announcement acknowledgement, no duplicate celebrations, and unchanged equipped theme.
- Exercise fresh saves, legacy high-score evidence, legacy completed and unfinished boards, preservation of a previously selected theme, missing progression fields, unknown theme identities, and repeated migration/loading.
- Verify locked themes cannot be equipped with mouse or remappable actions, unlocked themes can be equipped and persist, and opening Colors preserves a live turn and its save boundary.
- Retain the existing theme contrast tests. Manually inspect locked labels, swatches, focus outlines, result announcements, and physical gamepad navigation on the 480 by 270 canvas, including reduced motion.

## Out of Scope

- Changes to scoring rules, joker balance, dice probabilities, or the results summary's score attribution.
- Gameplay bonuses, paid cosmetics, online accounts, cloud synchronization, or per-name ownership.
- Cumulative score currency, purchases, achievements, daily challenges, or rewards for partial boards.
- New palettes, a 450-point prestige color, or rewards at the theoretical maximum.
- Automatic theme selection, a new required animation, or a new mandatory results step.
- Recovering achievements from deleted saves or unrecorded historical boards without surviving evidence.
- Implementing this PRD as part of the current documentation request.

## Further Notes

The thresholds are initial product choices based on the scoring discussion, not measured
player percentiles. The theoretical maxima are 600 with Pair Pay, 550 with Thrifty,
and 500 with Short Run. Deliberately strong layouts mixing Yahtzees and large
straights can exceed 400, supporting a challenging reward below the theoretical ceiling.

Shared thresholds intentionally allow Pair Pay's larger contributions to help earn
colors. Revisit thresholds after representative play sessions; future increases
must preserve already earned ownership. Table best remains the highest locally
recorded board score and is not the unlock ledger, since unlocks also recognize
completed boards whose scores were never recorded.

Related tracker ticket: [Selectable color schemes and score-based unlocks](issues/01-selectable-schemes-and-unlocks.md).
