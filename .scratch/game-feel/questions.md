# Questions for shaping Yahtz

Status: needs-triage

A menu of questions for future conversations, not an interview to complete now. Pick two or three that matter to the idea being explored. Answers can become inputs to a PRD; unanswered questions are not implementation requirements.

## Identity and atmosphere

1. **When a board ends, what should the player most want to say: ?that felt good,? ?that was clever,? or ?one more try??** This helps choose between presentation polish, deeper planning, and progression.
2. **Should this feel like a cozy little table, a loud arcade cabinet, or a mysterious late-night dice game?** This directs sound, animation, language, and cosmetic design.
3. **What is the moment you would put in a five-second clip to make someone want to play?** A huge payout, a perfect last placement, or a joker interaction suggests different signature effects.
4. **Which parts of the current game already feel distinctly ours?** Protect those before borrowing features from other games.

## Pacing and presentation

5. **Should an ordinary payout be almost instant, with extra time reserved for rare combinations?** This defines how much celebration the player has to sit through.
6. **Would you rather see points physically travel from a line to the total, or have the whole table react briefly?** Both can communicate impact; the first emphasizes arithmetic, the second atmosphere.
7. **How much time should someone need for a satisfying session: one quick board or an evening of connected boards?** This is the gate before designing runs, shops, and escalating targets.
8. **What currently makes you hesitate because the next action is unclear?** That may be a better next feature than another reward or animation.

## Planning and randomness

9. **Do you want players to mostly improvise with their dice, or feel that they are constructing a plan across all five turns?** This informs previews, consumables, and new joker designs.
10. **Should the game help reveal promising placements, or mostly let players discover them?** We can highlight affected lines without automatically telling the player what to do.
11. **Would you enjoy a tool that rescues a bad roll, or one that rewards a risky plan?** These lead to different consumables and different emotional arcs.
12. **For a shared seed, should everyone get the same opportunities even after different hold decisions, or should choices change what comes next?** The current RNG makes those choices matter; a fair-challenge promise needs a deliberate decision.

## Jokers and personality

13. **Should jokers feel like understandable rules, collectible characters, or both?** Decide whether they need personality and collection systems beyond names and explanations.
14. **Do you want to master one chosen joker, or discover surprising pairs of jokers?** The latter is a substantial rules expansion; it should have its own prototype.
15. **What kind of joker would you immediately want to try even before knowing whether it is strong?** This can uncover a theme or interaction worth prototyping rather than inventing bonuses in the abstract.

## Rewards and reasons to return

16. **What would make you start another board: beating your best, trying a new strategy, finishing a challenge, or earning a cosmetic?** This helps choose one return hook instead of shipping four at once.
17. **Should rewards recognize a high total, unusual achievements, or repeated mastery of a joker?** A single score threshold may favor one strategy and miss other satisfying play.
18. **Since the current themes are freely selectable, should future unlocks be new themes, dice finishes, or table decorations?** Preserve current access unless we explicitly choose otherwise.
19. **Would an optional daily table feel inviting, or like homework?** We can offer a dated challenge without streak pressure or missed-day penalties.

## Results and sharing

20. **At results, what would you most want to understand: where your points came from, how you compare with your best, or what to try differently?** This gives the screen a purpose before adding more statistics.
21. **Would you want to keep beautiful completed boards even when their scores are mediocre?** That distinguishes a scrapbook from a leaderboard.
22. **Who would you share a challenge with, and what would you send them: a code, a board picture, or a score?** Build the smallest sharing path that matches an actual use.

## Choosing an experiment

23. **If we could change only one moment in the next version, which one would you choose?** Keep the next branch focused.
24. **What would make you say an experiment failed, even if it technically works?** Establish a reason to cut it before becoming attached.
25. **Which current behavior must feel exactly the same afterward?** Use the answer to set regression boundaries.
26. **Would you prefer a tiny playable experiment before a full PRD for this idea?** Presentation and game-loop questions often benefit from trying something small.

## Working agreement

Before implementing or prototyping any idea from this scratchpad, create or switch to a dedicated feature or experiment branch and state the branch name. Keep main and unrelated integration work untouched. Planning notes may stay on the current branch.

## Related notes

- [Game-feel and feature idea bank](ideas.md)

## Comments

- User welcomed questions as a valid form of ideation.
- User requested separate branches for future iterations so experiments do not contaminate main.
