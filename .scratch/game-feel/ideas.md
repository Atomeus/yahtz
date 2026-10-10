# Yahtz: ideas for making the table pop

Status: needs-triage

An idea bank for future PRDs and small experiments. These are proposals, not an implementation queue or an agreed roadmap. Created after selectable themes, score rocking, and in-game joker explanations landed.

## What to protect

The appealing core is a small table with chunky dice, a five-turn board, and the possibility that one placement completes both a row and a column. Make those moments clearer and more memorable before expanding the rules.

- Keep the board readable at 480x270. Put decoration around decisions, not over dice faces or controls.
- Preserve mouse and remappable keyboard/gamepad access.
- Every animated effect needs a reduced-motion equivalent that conveys the same information.
- Presentation randomness must never consume the session RNG.
- Keep the current quick board as a permanent mode, even if longer runs arrive.
- Unlock cosmetics for achievement; keep essential readability and controls available immediately.
- Reuse the existing screen, domain, and shared UI boundaries.

## First experiments worth trying

Effort labels describe relative scope, not delivery estimates.

| Priority | Idea | Player payoff | Smallest useful experiment | Scope |
| --- | --- | --- | --- | --- |
| 1 | Trace a completed line into the score | Immediately understand why the number rose | One outline sweep and one +points label per payout | Small |
| 2 | Give dice placement a satisfying landing | Every interaction feels deliberate | Short snap, soft shadow, distinct placement clack | Small |
| 3 | Make joker bonuses visibly belong to the joker | Feel the chosen strategy paying off | Highlight its name when its bonus resolves | Small |
| 4 | Celebrate the final turn as a board finale | Make the finish feel earned | Brief anticipation, readable line sequence, final tally | Medium |
| 5 | Show a personal-best comparison at results | Give the next board a concrete purpose | Total, previous best, and difference | Small |
| 6 | Add a replayable challenge seed | Give players a shared thing to talk about | Copyable local seed and same setup | Medium |

Try 1-3 together as a presentation pass before making a progression system. They improve the existing game without needing a balance redesign.

## A. Make the existing actions feel good

### 01. A completed line travels into the score

**Moment:** A row completes. Its cells gain a clear outline, the combination name appears nearby, and a small +points label moves toward the score. The score responds on arrival. A column payout uses the same grammar.

**First slice:** Outline the five cells and show a stationary +points label before adding travel.

**Watch for:** The flight should reinforce the ledger, not replace it. Never obscure the dice faces. Reduced motion uses the outline and stationary label. Existing payout order and score-once rules remain unchanged.

### 02. Dice have a landing, not just a new position

**Moment:** Selecting a die lifts it slightly; placing it gives a quick snap and a soft landing clack. Picking it back up has a lighter sound. Held dice settle into a visibly distinct tray position.

**First slice:** Small visual lift and a dedicated placement sound, with no simulated physics.

**Watch for:** Keep cell and button hit regions stable. Effects must not delay input or make a die look like it occupies a different cell. Reduced motion keeps the state distinction without the lift.

### 03. Joker activation is a little character moment

**Moment:** When Pair Pay contributes, its name briefly brightens and a +20 bonus appears beside it. Short Run highlights when its expanded qualification makes a difference; Thrifty celebrates saved rolls at confirmation.

**First slice:** Highlight the joker name during a relevant scoring event.

**Watch for:** Short Run changes qualification and may not emit a separate bonus event. Its activation needs correct domain attribution, not a decorative claim that it added points when it did not. Joker behavior must remain explainable through the existing details view.

### 04. Build a small musical vocabulary

**Moment:** Rolling, holding, placing, confirming, and scoring have related but distinguishable sounds. Bigger combinations receive a recognizable phrase rather than merely a louder beep.

**First slice:** Separate hold and placement sounds; keep the existing roll and payout sounds.

**Watch for:** Let the final turn resolve many payouts without turning into noise. Limit overlapping voices, cap pitch escalation, and respect the engine volume controls. Audio must supplement visual information.

### 05. The final turn gets a board finale

**Moment:** The last confirmation gets a short beat of anticipation, then each new line resolves clearly. The total settles into a final stamp: BOARD COMPLETE.

**First slice:** A special finish treatment after the normal scoring sequence.

**Watch for:** Six lines can complete on the final turn when filling rows. Make the chain legible rather than extending every animation. Speed-through remains available and must still land at the correct final total.

### 06. A restrained signature celebration for Yahtzee

**Moment:** Five matching faces receive a brief spotlight and a distinctive sound. A few particles stay around the relevant line rather than filling the screen.

**First slice:** Unique outline and sound for a Yahtzee payout.

**Watch for:** Avoid default screen shake or full-screen flashing. Keep large straight and full house recognizable too, so the rest of the game does not feel unacknowledged.

## B. Make strategic decisions easier to see

### 07. Show what a tentative placement changes

**Moment:** Focusing an empty cell with a selected die outlines the affected row and column. If placing there would complete a line, show its prospective category and points.

**First slice:** Highlight only the two affected lines. Add projected scoring after the visual treatment proves useful.

**Watch for:** A hypothetical preview must not mutate placements, consume an Adjustment, or change the RNG. Clearly distinguish a prospective result from the current confirmed preview.

### 08. Give near-complete lines quiet visual structure

**Moment:** A line with four occupied cells gets a subtle edge marker, helping players notice which placement might close it.

**First slice:** A small marker beside the row or column label.

**Watch for:** Do not equate fullness with strategic quality. This is a spatial cue, not a recommendation to complete every line as early as possible. Avoid covering the board with ten competing progress bars.

### 09. An inspectable line explains its arithmetic

**Moment:** Select a row or column label to see its faces, qualifying combination, base points, and joker contribution. Completed lines retain their recorded explanation.

**First slice:** Inspect already completed lines using information from the score history.

**Watch for:** A recorded payout is historical truth; reevaluating old lines using future modifiers could give a misleading explanation if longer runs are introduced.

### 10. Make Adjustments feel like a small strategic tool

**Moment:** Instead of only a count, show two clear consumable marks. Selecting +1 or -1 previews the changed face and the resulting score effect before committing.

**First slice:** Two marks that visibly become spent, keeping the current controls.

**Watch for:** Preserve undo and boundary-save behavior. Previewing an Adjustment must not spend it. Do not let decorative icons compete with the dice tray.

### 11. Teach through one playable opening

**Moment:** An optional first-board guide introduces a held die, early placement, a row completion, and the possibility of also completing a column.

**First slice:** A short practice board with fixed dice and one goal, separate from normal records.

**Watch for:** Keep ordinary play available immediately. Practice scores should not enter competitive records or unlock milestones accidentally. Prefer a concrete example over a wall of tutorial text.

## C. Give a completed board a story

### 12. A results screen with one memorable takeaway

**Moment:** Alongside the total, show the strongest line, joker contribution, and one factual observation: ?Your final turn earned 110 points.?

**First slice:** Total, biggest recorded line, and joker points.

**Watch for:** Be precise about ?line? versus ?turn,? and include bonuses consistently. Avoid generic praise detached from what actually happened.

### 13. Chase a personal best without punishing the player

**Moment:** Results compare the board with the previous best: ?18 points from your best? or ?New best: +24.?

**First slice:** Results-only comparison.

**Watch for:** Capture the previous best before recording the new score. Live best-chase indicators can wait; they may make a relaxed game feel pressured. A skipped name should not erase the meaning of the completed board.

### 14. Keep a tiny board scrapbook

**Moment:** Save a handful of completed boards as miniature grids with score, joker, and date. Open one to inspect why it worked.

**First slice:** The last five completed boards with a static miniature and total.

**Watch for:** Keep this distinct from the top-five leaderboard: recent history and best scores answer different questions. Version the record format if gameplay rules later change.

### 15. Optional end-of-board badges

**Moment:** Earn descriptive badges such as ?Two directions? for completing a row and column with one confirmation, or ?Frugal? for finishing without spending an Adjustment.

**First slice:** Two or three badges at results, without persistent progression.

**Watch for:** Define each condition precisely before implementation. They should recognize different approaches rather than all point toward one optimal strategy. No multiplier or scoring-rule change is needed.

## D. Give players reasons to return

### 16. Cosmetic mastery milestones

**Moment:** A completed board unlocks a theme, a dice finish, or a table ornament, with a preview and an option to equip it.

**First slice:** Build on the existing color-theme unlock ticket.

**Watch for:** All four themes are currently freely selectable. Decide explicitly whether future rewards are additional themes or whether existing availability changes; do not silently relock a player's choice. Essential high-contrast presentation stays free.

### 17. A small local challenge book

**Moment:** Optional goals encourage unfamiliar play: try Thrifty, finish a board without Adjustments, or score a Yahtzee. Each entry records completion.

**First slice:** A few handcrafted goals alongside normal quick play.

**Watch for:** Cosmetic completion is enough initially. Avoid turning every board into a checklist. Challenge bookkeeping must not couple leaderboard recording to whether the player enters a name.

### 18. Share a challenge seed

**Moment:** Two players use the same seed and joker to compare decisions. A completed board can show a compact challenge code.

**First slice:** Manual seed entry and a clear ?Challenge? mode, entirely local.

**Watch for:** A fair code needs rules/version identity and seed as well as joker. Current rerolls consume RNG depending on held dice, so identical seeds do not imply identical later dice after players take different actions. Describe this honestly; decide whether that is intended before promising tournament fairness.

### 19. A daily table without online infrastructure

**Moment:** Everyone playing the same dated challenge and rules version starts from a reproducible setup.

**First slice:** Deterministic date-to-seed setup and a separate local daily record.

**Watch for:** Define UTC versus local date, retries, and rules versions. A local clock is editable and local records are not cheat-proof. This can be a friendly ritual without claiming an authoritative global competition.

### 20. A shareable board postcard

**Moment:** Export or copy a compact summary: theme, joker, final score, and a small picture of the board.

**First slice:** A text summary; an actual image is a later platform capability check.

**Watch for:** Usagi export/sharing capabilities need investigation before committing to screenshot or clipboard behavior on every platform. Never promise OS-specific features solely from a desktop prototype.

## E. Larger design questions to park for future PRDs

These go beyond the first-playable scope. Prototype them separately and keep quick play intact.

### 21. A three-board evening

**Question:** Does carrying a modest choice across three boards create a satisfying arc without making a board feel disposable?

**Prototype:** Three boards with one choice between them; no shop at first. Try keeping or replacing a joker.

**Watch for:** Run duration, failure states, save boundaries, and whether scores remain comparable with quick play. Escalating targets need playtesting, not arbitrary numbers.

### 22. A draft of two synergistic jokers

**Question:** Can combinations create discovery while remaining understandable at a glance?

**Prototype:** A small curated set of pairs, with explicit bonus breakdowns.

**Watch for:** The existing game has one joker. Stacking changes domain rules, preview arithmetic, event ordering, balance, and saved state. Short Run plus Pair Pay may pull in different directions; conflicting incentives can be interesting if clearly explained.

### 23. Alternative consumables with distinct jobs

**Question:** Would one new tool add a real decision instead of more buttons?

**Candidates:** Swap two current-turn dice, reroll one unplaced die, or change a face to its opposite.

**Prototype:** Offer a single replacement for an Adjustment in a separate mode.

**Watch for:** Scope each tool precisely: current-turn versus fixed cells, phase restrictions, undo, RNG use, and preview behavior. Do not undermine the commitment that previous turns stay fixed without deliberately designing a new mode.

### 24. Tables with one unusual rule

**Question:** Can a board variation make spatial planning fresh without adding a complicated economy?

**Candidates:** One highlighted row with a disclosed bonus, a fixed starting cell, or a board that rewards completing both directions on one turn.

**Prototype:** One clearly labeled challenge board.

**Watch for:** Keep the standard board and its records separate. Any special bonus must appear in previews and the ledger. Avoid decorative cells whose scoring meaning is hidden.

### 25. A pocket-sized puzzle mode

**Question:** Does a fixed dice sequence and a target make an enjoyable daily puzzle, distinct from a high-score run?

**Prototype:** A handcrafted short scenario with limited placements and one objective.

**Watch for:** A smaller board changes line definitions and familiar combination lengths. Start with a partially filled standard board rather than generalizing the whole engine immediately.

## How to choose what becomes a PRD

Promote one idea at a time. A useful first PRD answers:

1. What exact player moment should improve?
2. What is the smallest version we can put in a player's hands?
3. Which current behavior, input access, and save guarantees must stay intact?
4. What would make the experiment a success, and what would make us cut it?
5. Does it change rules, or only how existing rules are presented?
6. Does it need a new mode, record category, or save version?
7. What do we need to hear or observe in a short playtest before expanding it?

For presentation experiments, ask a few players to explain a payout and identify the active die without prompting. Observe whether they notice joker contributions and use speed-through because a sequence drags. Treat these as qualitative playtest questions, not analytics already collected.

For progression experiments, ask whether a player wants another board and what they want to try differently. Reward clarity and curiosity before retention counters.

## Suggested order of exploration

1. Make one placement and one payout feel excellent: ideas 01-04.
2. Give the last turn and results an identity: ideas 05, 12, and 13.
3. Improve spatial understanding: ideas 07-09.
4. Add an optional reason to return: a challenge seed or cosmetic mastery.
5. Only then test longer runs, stacked jokers, and special boards.

Stop between stages and play. More particles, menus, and progression do not automatically make the table more fun.

## Experiment branches

Before implementing or prototyping these ideas, use a dedicated feature or experiment branch and tell the user its name. Keep main and unrelated integration work untouched. Planning notes may stay on the current branch.

## Related work

- [Questions for shaping future PRDs](questions.md)

- [Selectable themes and future unlocks](../color-schemes/issues/01-selectable-schemes-and-unlocks.md)
- [First-playable scope and rules](../spatial-first-playable/spec.md)
- [Modular restructuring](../modular-screens/spec.md)

## Comments

- User authorized autonomous ideation in the scratchpad for future PRDs and feature discussions.
- No gameplay implementation, balance commitment, new analytics, or external publishing is implied by this document.
