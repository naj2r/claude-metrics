# Coder Update — Producer-variable disambiguation (apply in `c-metrics-absinthe1`)

**Date:** 2026-06-09
**From:** coordinator (Brainstorm-Absinthe / gallant-thompson worktree)
**Type:** Cleanup request — **your territory** (do-files, `codebook.md` source, repo docs). The coordinator is NOT editing analysis code; this hands the changes to you so two agents don't edit the same do-files.
**Relation to the feasibility dispatch:** same root cause, but this is the *permanent fix* to stop the names re-conflating. Independent of the feasibility run itself (which is already corrected to use `cohort_1908_workshop.dta` + `abs_producer`).

## The finding (root cause of the feasibility-dispatch popup)
Two different "producer" variables, in two different datasets, with colliding names:
- **`absinthe_dummy`** (`absinthe_analysis.dta`) = `(canton_code=="NE")` — **NE only** (siblings `_broad`=NE+VD, `_any`=NE+VD+GE). Investigation-stage robustness tiers (`02_clean.do:266`). The *name* reads like a generic "produces absinthe 0/1" but it encodes "is Neuchâtel."
- **`abs_producer`** (`cohort_1908_workshop.dta`) = `cov2_total_share > 0` — "any Milliet-listed absinthe purchase," **8 cantons (please confirm + record the set)**, the **headline** producer-coalition treatment behind `T_producer_cascade` **[FINAL]** (`09_canton_reg1*.do`, script 23).

The earlier dispatch had fused the first variable's *name* with the second's *definition*.

## Coordinator already did — no action from you
- Corrected the feasibility dispatch (`2026-06-09_feasibility-ipw-ebal-lewbel.md`): dataset → `cohort_1908_workshop.dta`, treatment → `abs_producer`, and added a "first command = `tab canton_code if abs_producer==1`" requirement.
- Logged the finding in the coordination research journal.
- **Reverted** a brief set of direct edits I had made to your `02_clean.do` / `09_*.do` labels + `CONTEXT.md`, and removed a note I'd dropped in `analysis/documentation/`. **All undone** — your tracked files are back to their prior state, so nothing of mine is sitting uncoordinated in your working tree (you have an active `_feasibility_*` run in flight; I did not want to collide with it).

## Requested of you — apply + own (suggested wording; rework freely)
1. **`abs_producer` label** — `09_canton_reg1.do:414` and `09_canton_reg1_workshop.do:412`. Make it self-distinguishing so the auto-generated `codebook.md` carries it on the next `_codebook_update`. Suggestion (≤80 chars): `label var abs_producer "Absinthe producer (Milliet any-purchase; headline)"`.
2. **Definition-site comment** — `02_clean.do`, just above the `absinthe_dummy*` block (~line 253): one or two comment lines noting these tiers are *investigation-stage robustness*, and the headline producer treatment is `abs_producer` in `cohort_1908_workshop.dta` (reported in `T_producer_cascade`). Mention the name trap: `absinthe_dummy` = `(canton_code=="NE")`, not a generic "produces absinthe."
3. **Canonical doc** — create `analysis/documentation/producer_variable_disambiguation.md` as the single source of truth (suggested content below).
4. **CONTEXT.md** — after the existing "Absinthe-canton tiering" bullet (~line 145): a one-line pointer that `abs_producer` (workshop cohort) is the headline producer treatment, `absinthe_dummy*` are robustness only, the names collide, and the canonical doc has details.
5. **Procedural guard going forward** — any producer spec/script prints `tab canton_code if abs_producer==1` (or the relevant treatment) so the realized treated set is on the record and never inferred from a variable name again.

## Suggested content for the canonical doc
```markdown
# Producer-treatment variables: canonical vs. investigation-stage

## TL;DR
- Headline producer-coalition treatment = `abs_producer` in `cohort_1908_workshop.dta`
  (`cov2_total_share > 0` = any Milliet-listed absinthe purchase; 8 cantons).
  Feeds T_producer_cascade [FINAL] and the deck / EEH manuscript.
- `absinthe_dummy` / `_broad` / `_any` in `absinthe_analysis.dta` are
  investigation-stage robustness tiers (NE / NE+VD / NE+VD+GE). NOT the headline.

| | abs_producer (CANONICAL) | absinthe_dummy* (robustness) |
|---|---|---|
| Dataset | cohort_1908_workshop.dta | absinthe_analysis.dta |
| Definition | cov2_total_share>0 (any Milliet purchase) | hardcoded canton lists |
| Breadth | 8 cantons | NE / +VD / +VD+GE (1–3) |
| Defined in | 09_canton_reg1*.do:411–413 | 02_clean.do:266–268 |
| Feeds | T_producer_cascade [FINAL], fr_x_producer, script 23 | t02 col7, t03 col3, t12 |
| Role | headline | robustness / superseded |

## Why the names mislead
`absinthe_dummy` sounds like "produces absinthe (0/1)" but is literally (canton_code=="NE").
The genuine "produces/handles at all" indicator is `abs_producer`, a different name in a
different file. Name matches one variable; definition matches the other → easy to fuse.

## Rules
1. Producer-coalition specs use abs_producer on cohort_1908_workshop.dta unless explicitly
   running the NE-tier robustness.
2. Any producer script prints `tab canton_code if abs_producer==1`.
3. absinthe_dummy* stays robustness-only; no promotion to headline without strategist sign-off.

## Secondary (possible paper footnote)
abs_producer is a handles/sells-per-excise definition (Milliet purchases), not strictly
"manufactures." The absinthe_dummy* NE-tiers are the manufacturing-heartland robustness
ladder if a referee presses on the definition.
```

## Standing rule
`abs_producer` (cohort_1908_workshop.dta) = headline producer-coalition treatment. `absinthe_dummy` / `_broad` / `_any` (absinthe_analysis.dta) = investigation-stage robustness only — do not promote to headline without strategist sign-off.
