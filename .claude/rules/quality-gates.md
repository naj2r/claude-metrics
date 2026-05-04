---
paths:
  - "**/*.do"
  - "**/*.R"
  - "**/*.tex"
  - "**/*.qmd"
description: Quality scoring thresholds (advisory only)
---

# Quality Gates (Advisory)

Inspired by Sant'Anna's 80/90/95 system. Scoring is informational — Claude reports a quality estimate, but no hook blocks based on the score. Advisory only.

## Scoring

| Issue type | Deduction | Why |
|---|---|---|
| Hard rule violation | -25 | Blocking; must be fixed |
| Soft rule violation (in strict) | -15 | Blocking; must be fixed in strict mode |
| Soft rule violation (in permissive) | -5 | Warning surfaced |
| Advisory rule violation | -2 | Warning surfaced |
| Missing post-credits block (in numbered script) | -10 | Codebook/inventory drift |
| Missing assert in tables/figures script | -5 | Reif submission checklist |
| Hardcoded value used in production | -3 | Prefer parameterization |
| Variable without label | -1 | Ouellet/Toffel §7 |
| Verification not performed | -10 | Risk that change is broken |

Start at 100. Subtract for each issue. Floor at 0.

## Thresholds

| Score | Status | Action |
|---|---|---|
| 95-100 | Excellent | Ready for publication-quality work |
| 90-94 | Good | Ready to PR; minor polish optional |
| 80-89 | Acceptable | Safe to commit; address advisories before PR |
| 60-79 | Risky | Soft rule violations or missing verification — fix before sharing |
| < 60 | Blocked | Hard rule violations or untested code — must fix |

## When to score

- Before reporting completion of a non-trivial task: estimate score and report it.
- During `/validate`: include a score in the output.
- Before a `/commit` (deferred command): block if score < 80.

## How to report

Just state the score and the deduction breakdown:

> Quality: 88/100
> Deductions: -10 (missing verification — pipeline not run end-to-end after change), -2 (script header missing Date)

Then offer to address the gaps.
