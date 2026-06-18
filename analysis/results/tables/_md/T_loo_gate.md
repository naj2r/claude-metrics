# T_loo_gate — wine col-5 leave-one-out (the gate)

|   | FL AME (pp) | OLS coef (HC3) |
| --- | --- | --- |
| Full sample (N=25) | 0.437 (0.194) | 0.473 (0.307) |
| Drop Neuchatel (NE) | 0.443 (0.215) | 0.482 (0.596) |
| Drop Vaud (VD) | 0.497 (0.273) | 0.532 (0.536) |
| LOO range [min, max] | [0.321, 0.653] | [0.353, 0.697] |

_Note: Yes-vote share (vote \#68) on national wine revenue share, col-5 spec (+ French share + Absinthe trade share + Protestant share + log density). FL AME = fractional-logit average marginal effect, percentage points of yes-share per percentage point of wine share; OLS coef = HC3, on the 0-100 yes-share scale. Standard errors in parentheses. Each row re-estimates dropping the named canton(s). LOO range spans all 25 single-canton deletions (FL AME min at drop-ZH, max at drop-FR). The wine effect stays positive and similar in magnitude under every single-canton deletion, including drop-Vaud: it is not driven by any one canton._
