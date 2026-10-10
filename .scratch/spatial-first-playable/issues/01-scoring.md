# Line scoring
Status: resolved
Type: task
Blocked by: none

Implement category qualification, highest base payout with display ties, Pair Pay and Short Run from ../spec.md. Expose a pure scoring interface and verify known examples.


## Answer
Implemented pure `scoring.evaluate(faces, joker)` returning `category`, `base_score`, `joker_bonus`, and `total`. Category IDs and joker IDs use snake_case. Highest payout wins; display ties preserve the spec priority. Pair Pay counts distinct repeated faces; Short Run expands small straights; Thrifty is left to turn scoring.

Verified known examples, overlapping categories, ties, jokers, invalid lines, and input preservation using `python tools/test.py` (requires `python -m pip install lupa`). See [map](../map.md).
