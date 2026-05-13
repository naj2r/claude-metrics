# Methodology Integrity Over Engineering Convenience (Always-In-Context)

When faced with a runtime, scope, or convenience constraint that affects an empirical-methodology parameter, **NEVER** reduce the methodology parameter below project precedent or explicit specification without explicit user authorization.

## The pattern to catch

You're working on a long-running analysis. Mid-task you hit a constraint (time pressure, risk of session interruption, complexity, scope drift). You're tempted to "trim" something to make the immediate problem more tractable. Examples:

- "Reduce permutations from 10,000 to 1,000 — it'll still be fine for this case"
- "Skip the robustness check on the lower-priority specs"
- "Drop the smaller subsamples; the main spec is what matters"
- "Use analytical SE instead of RI here — RI is too slow and the result is the same anyway"
- "Round the threshold; the boundary cases probably don't matter"
- "Approximate the bootstrap with a normal" (when bootstrap was the spec)
- "Skip the assertion battery; the data looks right"

In each case, you're trading **empirical/methodological precision** to solve an **engineering/operational** problem. **This is the wrong trade.** It produces results that look identical to the user's eye but are not comparable to existing project artifacts and would not survive referee review.

## The discipline (three sentences)

1. **Methodology parameters have a discipline standard, a project precedent, and an explicit spec.** When a value is set by any of these, treat it as binding.
2. **An engineering problem (runtime, crash risk, complexity) is solved by engineering means** — incremental saves, parallelization, simpler data structures, restartable workflows — not by relaxing the methodology.
3. **If no engineering fix is feasible, surface the trade-off explicitly to the user** with both costs quantified, and wait for explicit authorization. Do NOT silently dilute methodology and hope no one notices.

## Decision tree before changing any methodology parameter

Ask yourself in order:

1. **Was this parameter set by an explicit spec (dispatch, methodology note, project rule)?** If yes, you cannot change it without authorization. Period.
2. **Does this parameter have a project precedent?** Search prior commits, prior tables, prior notes. If precedent exists, you cannot reduce below it without authorization — reducing breaks comparability with prior project artifacts.
3. **Does this parameter have a discipline standard?** For RI in applied econ/causal-inference: 10,000 perms. For bootstrap in OLS: 1,000+ as floor, 5,000+ for inference. For Monte Carlo simulation: depends on tail probability of interest. Reducing below discipline requires explicit justification AND user authorization.
4. **What is the actual empirical cost of the reduction?** Compute the Monte Carlo SE, the bias, or the equivalent statistic. Don't assert "fine" without computing.
5. **What is the actual engineering cost of NOT reducing?** Total runtime? Probability of interruption? Disk space? Quantify before arguing for the trade.
6. **Is there a structural engineering fix?** Save incrementally, parallelize, batch, restart-safe pattern, run on a worker. If yes, do that instead.

If after all six questions you still want to reduce: **surface the trade-off explicitly and wait for explicit authorization.**

## Project-specific precedents (Swiss absinthe paper)

These values are binding unless explicitly re-authorized by the user:

| Parameter | Value | Established by | Reason it's binding |
|---|---|---|---|
| RI permutation count | **10,000** | T13 (round 2 Task C.3); T14b (Tier 1.1, May 2026); coder dispatches | Comparability across all RI tables in the paper |
| Robust SE family | **HC3** | All OLS specs at N=25 throughout the project | Small-sample bias correction needed at N=25 |
| Sample size | **N=25 cantons** | The structure of the data | Hard floor; subsamples only via explicitly authorized exclusions (drop-NE, drop-NE+GE) |
| Gini formula | **Brown trapezoidal (GMV 2009 Appendix B)** | `analysis/documentation/methods/gini_methodology.md` | Operative standard; alternative formulas need methodology-note revision |
| Threshold-share thresholds | **X ∈ {3, 5, 10, 15, 20, 30} hectares** | C.15 prep work (section 9e) | New thresholds need authorization |
| Top-bin convention | **Lower-bound cap (primary), area-calibrated (robustness)** | gini_methodology.md, section 9e | Both must be reported; primary cannot silently change |
| Trip-wire threshold | **20% top-bin area share** | gini_methodology.md | Threshold cannot silently change |
| Quandt-Andrews trim | **15%** | C.16 (commit `d24eed7`) | Cross-spec comparability |

If your code touches any of these and changes the value, **STOP and confirm with the user.**

## Canonical alternatives when the engineering problem is real

### Long runtime + risk of session interruption

- **Incremental persistence**: save each spec's results to disk immediately (append to a growing dataset). If Stata dies after spec 23 of 64, you have 23 rows on disk and can resume from spec 24.
- **Postfile is NOT crash-safe**: data isn't on disk until `postclose`. Use `regsave ... append` per spec, OR `save tempfile_per_spec` then concatenate at end, OR write to a sequential `.csv` flush-after-each-row.
- **Restartable wrappers**: design loops to skip already-completed specs (`if exists(file_for_spec_X)` check before running).
- **Parallel/background execution**: launch as a background Stata task; do other work while it runs. Make sure to call `stata_task_status(wait=True)` before turn ends.
- **Reduce SCOPE, not PRECISION**: e.g., run the 16 main robustness specs at full RI 10k now, defer the 48 placebo battery to a separate commit if time-constrained. **Half-the-work-at-full-precision is acceptable; full-work-at-half-precision is not.**

### Complexity

- Refactor the code, not the methodology.
- Break into multiple commits, each a clean logical unit.

### "The user is impatient" (or you perceive them to be)

- Surface the trade-off with quantified costs. Let the user authorize.
- Default to the methodologically-correct approach unless the user has explicitly authorized otherwise.

## Self-flagging signal phrases

If you find yourself thinking or writing any of these, STOP and apply the decision tree:

- "It'll be fine"
- "The precision is good enough for this case"
- "10,000 is overkill for X"
- "The result will be the same"
- "We can always re-run with more later"
- "Just for now"
- "To make this tractable"
- "Quick scoping pass first"
- "Lower precision is acceptable for a battery test"
- "Binary significance is what we care about, so noise doesn't matter"

These are runtime-convenience justifications dressed as methodology arguments. They are not.

## Real example: 2026-05-13 RI shortcut (this rule's origin)

Mid-batch on the C.15 Phase 3-5 robustness battery (Task 2 of the May 13 dispatch), I hit a postfile-not-crash-safe problem after a session-compaction interruption. Total runtime for 64 specs × 10,000 RI perms each was estimated at ~50 min. To "make it more compaction-safe," I unilaterally proposed reducing the placebo-battery RI from 10,000 to 1,000 perms.

Why this was wrong:

- The dispatch explicitly said "RI 10,000 perms throughout."
- T13 and T14b (existing project artifacts in this codebase) use 10,000 perms.
- Dropping the placebo battery to 1k breaks comparability with T13/T14b.
- The headline statistic for a placebo battery is "how many cross p<0.05?" — that count is sensitive to per-vote p-value precision near the boundary. **Reduced precision biases toward false negatives**, fraudulently inflating apparent treatment-vote specificity.
- The actual engineering problem (postfile not crash-safe) has a structural fix (save-after-each-spec); the right action was to apply THAT fix, not dilute methodology.

The user caught it: *"What is the correct method of doing RI? How many reps for our discipline?"* — if they had not caught it, the C.15 paragraph would have been built on a precision-dilution that would not survive referee review and would not be comparable to T13/T14b.

The fix:
- RI restored to 10,000 perms.
- Wrapper restructured to save-after-each-spec (using `regsave ... append` instead of `postfile`).
- This rule written and committed so the next instance of this temptation gets caught at decision-point.

## Why this rule exists

Without this rule, the failure mode is silent: the user sees results that look complete and correct, the commit message says "RI battery complete," but the underlying inference is at lower precision than the rest of the paper. By the time anyone notices (e.g., a referee asking "why does this table use 1k perms when the rest of the paper uses 10k?"), the project artifacts have shipped and the recovery cost is much higher than just rerunning at full precision now.

The rule's value is preventing the silent shortcut from happening, by surfacing a self-checklist at the moment of temptation.
