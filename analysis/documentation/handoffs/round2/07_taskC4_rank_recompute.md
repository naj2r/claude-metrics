# Round 2 — Task C.4: Recompute rank statistic with #65 reclassified

**Read first**: `00_MASTER.md`, `06_taskC3_RI_three_votes.md`
**Status**: PENDING
**Prereqs**: Tasks C.1, C.2, C.3 complete. The reframing of #65 as comparator (not placebo) was already done in round 1 commit `b9f2da3`; this task updates the rank statistic to reflect that.
**Estimated time**: 30 min
**Output**: Updated `f03_placebo_distribution.pdf` caption + CONTEXT.md update + assertion in `05_expansion.do`

---

## Purpose

Round 1 framing: "absinthe ranks #2 of 15" (out of all 1900-1910 votes). With #65 reclassified as a wine-rent-seeking comparator (not an independent placebo), the proper rank statistic should EXCLUDE both #65 and #68 from the placebo set:

- True placebo set: 13 votes (15 minus #65 minus #68)
- Absinthe rank: should be #1 of 14 (counting itself)
- Permutation-style p-value: rank / (true placebos + 1) = 1 / 14 ≈ 0.071

If absinthe is NOT #1 of 14 in this true-placebo subset, the framing is weakened — there's a confounding non-wine-related vote that also produced a positive vineyard coefficient. Investigate which vote and report.

## Implementation

In `05_expansion.do`, modify the existing assertion in section 11 (around line 1226 currently — was the line with `assert n_extreme <= 5` before round-2 changes; now after Task C.3 it may have shifted):

```stata
* Round-2 Task C.4: True-placebo rank with #65 reclassified
* "True placebos" = 13 votes (excludes #65 [comparator] and #68 [treatment])

qui sum coef if var == "vineyard_per_cap" & spec == "panel_anr68" & model == "ols"
local b_treat_v68 = r(mean)

qui count if var == "vineyard_per_cap" & strpos(spec, "panel_anr") ///
            & model == "ols" & coef >= `b_treat_v68' ///
            & spec != "panel_anr65" & spec != "panel_anr68"
local n_true_placebos_above = r(N)

* Total true-placebo votes
qui count if var == "vineyard_per_cap" & strpos(spec, "panel_anr") ///
            & model == "ols" & spec != "panel_anr65" & spec != "panel_anr68"
local n_true_placebos = r(N)

* True-placebo rank: 1 + (number of true placebos with coef >= absinthe coef)
local absinthe_true_rank = `n_true_placebos_above' + 1
local true_p = `absinthe_true_rank' / (`n_true_placebos' + 1)

di "True-placebo rank statistic (#65 reclassified, dropped from placebo set):"
di "  Absinthe coef:                " %7.2f `b_treat_v68'
di "  True placebos with coef >= absinthe: " `n_true_placebos_above' " of " `n_true_placebos'
di "  Absinthe rank in true-placebo set: #" `absinthe_true_rank' " of " `n_true_placebos' + 1 " (treatment + true placebos)"
di "  Permutation-style p (rank / (n+1)): " %5.3f `true_p'

* Assert: absinthe should be #1 in the true-placebo set (n_true_placebos_above == 0)
assert `n_true_placebos_above' == 0
```

If the assertion fails (some true placebo has a coef ≥ absinthe), `di` lists which one and INVESTIGATE before continuing — that's a substantive finding that needs flagging.

## CONTEXT.md update

Locate the existing paragraph about the 15-vote falsification (search for "absinthe ranks #2" or "15 votes 1900-1910"). Update to add:

> **True-placebo rank (round 2 update)**: with vote #65 (Lebensmittelgesetz) reclassified as a wine-industry-rent-seeking comparator (not an independent placebo), the proper falsification benchmark is the rank of absinthe among the 13 TRUE placebo votes. Absinthe ranks #1 of 14 (treatment plus 13 true placebos), permutation-style p = 1/14 ≈ 0.071. The original "rank #2 of 15" framing reflected vote #65 being one of the few non-treatment votes with a positive vineyard coefficient — but #65 is mechanism-related, not a clean placebo, so excluding it from the placebo set is the correct comparison.

## f03 caption update

In section 12.9 (figure builder), update the caption/note to reflect the reclassified rank:

```stata
note("Red vertical line: absinthe vote (#68) coefficient = " + string(`b_absinthe', "%9.1f") + ". Histogram: 13 TRUE placebo votes (1900-1910 excluding #68 absinthe AND #65 Lebensmittelgesetz, the latter reclassified as a wine-rent-seeking comparator per round-2 reframing).")
```

Also update the y-axis label from "Density (placebo votes, N=14)" to "Density (true placebo votes, N=13)".

## Acceptance criteria

- [ ] True-placebo rank computed and = 1 (absinthe is #1 of 14)
- [ ] Permutation-style p = 1/14 ≈ 0.071 reported
- [ ] CONTEXT.md updated with the round-2 framing
- [ ] f03 caption + y-axis updated
- [ ] New assertion passes
- [ ] Commit pushed

## Pitfalls

1. **The assertion `n_true_placebos_above == 0` is STRICT** — it says NO true placebo has a coef ≥ absinthe. If this fails, don't relax the assertion silently. Investigate which vote is the culprit. Possibilities:
   - Vote #57 or #58 (proportional representation, 1900) — round-1 work flagged these as elevated
   - Some other vote with a chance positive vineyard correlation
   
   If a true placebo has a positive coefficient, the framing should acknowledge it ("absinthe is one of 2 votes with..."), not pretend it doesn't exist.

2. **The rank statistic is informal** — it's not a formal hypothesis test (the RI in C.3 is the formal version). Treat it as a complementary visualization aid, not the inferential channel.

3. **CONTEXT.md edit must NOT break the existing flow**. Add the round-2 paragraph as an addendum, not by replacing the original "absinthe ranks #2 of 15" text (that's the round-1 result; both numbers are correct under their respective definitions).

## Commit message template

```
round2 Task C.4: Recompute rank statistic with #65 reclassified

With #65 (Lebensmittelgesetz) reclassified as a wine-industry comparator
(round 1 commit b9f2da3), the proper falsification rank should EXCLUDE
both #65 and #68 from the placebo set.

Result:
  Absinthe coef = <X>
  True placebos with coef >= absinthe: 0 of 13
  Absinthe rank in true-placebo set: #1 of 14 (treatment + 13 true placebos)
  Permutation-style p: 1/14 = 0.071

CONTEXT.md updated with round-2 framing addendum (original "rank #2 of 15"
also retained for the all-15-votes interpretation).

f03_placebo_distribution.pdf caption + y-axis label updated to reflect
N=13 true placebos.

1 new assert (absinthe is strict #1 in true-placebo set). Pipeline 37
assertions pass.
```

## Done when

- New assertion passes
- CONTEXT.md and f03 updated
- Commit pushed
- Move to `08_taskC5_cleavage_index.md`
