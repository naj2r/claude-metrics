# Project Context

> **Claude reads this file before any analytical reasoning.** If a field is empty, ask the user to fill it before proceeding. Do not invent project context.

This file is the project-level "what is this about" — distinct from `CLAUDE.md` (which is "how do we code here"). Fill all five fields when starting a new project. Run `/init-project` for an interactive walkthrough.

---

## 1. Dataset(s)

> _Name(s), source(s), sample period, N observations, refresh cadence._

**[ FILL IN ]**

Example:
> `auto.csv` — Stata's built-in 1978 automobile dataset, 74 observations, one-time snapshot, no refresh.

---

## 2. Unit of observation

> _What does one row in the analysis dataset represent?_

**[ FILL IN ]**

Example:
> Vehicle make-model in 1978. One row per (make, model) combination.

---

## 3. Outcome variable(s)

> _Name, transformation, units. Multiple outcomes OK._

**[ FILL IN ]**

Example:
> `price` — vehicle price in 1978 USD, untransformed. Secondary: `price_ln` — natural log of price.

---

## 4. Identification strategy

> _OLS / FE / DiD / IV / matching / RCT / RDD — one sentence on the source of variation._

**[ FILL IN ]**

Example:
> Cross-sectional OLS, comparing domestic vs. foreign vehicles. No causal claim — descriptive only.

---

## 5. Key globals

> _`$MyProject` and any other path globals; sample restrictions encoded as globals._

**[ FILL IN ]**

Example:
> - `$MyProject` — set in `run.do` before sourcing `_config.do`
> - Sample: all 74 observations; no restrictions
> - `$DisableR = 0` — set to 1 to skip R portion of analysis

---

## Notes

Any additional context useful to a coauthor or to future-you. Funder requirements, IRB constraints, deadlines, etc.

**[ OPTIONAL ]**
