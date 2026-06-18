# T_oster — Oster (2019) delta-bounds

| Oster (2019) quantity | Value |
| --- | --- |
| Uncontrolled coef (Y on wine only) | -0.196 |
| Uncontrolled R-squared | 0.016 |
| Controlled coef (full col-5) | 0.473 |
| Controlled R-squared | 0.623 |
| delta to zero coef (rmax = 1.3 x R2) | -1.353 |
| delta to zero coef (rmax = 1) | -0.746 |
| coef at delta = 1 (rmax = 1.3 x R2) | 0.821 |
| coef at delta = 1 (rmax = 1) | 1.248 |

_Note: Oster (2019) proportional-selection bounds (psacalc), full col-5 spec; rmax(1.3 x R2) = 0.810. Adding observables moves the wine coefficient AWAY from zero (Simpson flip -0.196 -> +0.469), so the delta that would drive it to zero is NEGATIVE -- unobservable selection would have to run OPPOSITE to the observable selection. Under equal selection (delta = 1) the bias-adjusted coefficient is LARGER (0.82 at rmax = 1.3 x R2), not smaller. Oster therefore CORROBORATES the wine result; a positive delta-to-zero is undefined here (the standard 'is delta > 1?' cutoff does not bind)._
