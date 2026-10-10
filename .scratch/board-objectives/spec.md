# Random board objectives

Status: resolved

Implement all six proposed objectives alongside Three Rows. Automatically deal
one of seven objectives before the first roll. Preserve its identity on resume;
older event saves without an identity retain Three Rows. Legacy boards without
events remain unchanged.

Rules and initial rewards are recorded in README.md. Track live placement and
tentative-placement progress, explain rules through the existing details panel,
and pay once at completion. Bonuses are additive and missing an objective has
no penalty. Full Collection matches four distinct ordinary rows/columns to its
requirements, accepting at least three equal dice for three of a kind.

## Validation

Dedicated event-rule coverage exercises each objective, failure boundaries,
distinct-line assignment, deterministic dealing, persistence, and compatibility.
Existing application and session seams cover progress display and payout lifecycle.
