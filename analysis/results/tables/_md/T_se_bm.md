# T_se_bm — wine cascade HC1/HC2/HC3 + Bell-McCaffrey dof

| Specification | OLS coef | HC1 SE | HC2 SE | HC3 SE | BM dof | BM p |
| --- | --- | --- | --- | --- | --- | --- |
| (1) wine only | -0.196 | 0.164 | 0.179 | 0.219 | 2.04 | 0.385 |
| (2) + French | 0.568 | 0.192 | 0.211 | 0.251 | 3.52 | 0.062* |
| (3) + Absinthe trade share | 0.415 | 0.169 | 0.201 | 0.271 | 3.31 | 0.122 |
| (4) + Protestant share | 0.547 | 0.188 | 0.213 | 0.277 | 3.95 | 0.063* |
| (5) + log density (full) | 0.473 | 0.221 | 0.241 | 0.307 | 4.30 | 0.116 |

_Note: OLS of yes-vote share (vote \#68) on national wine revenue share; cascade (1) wine only ... (5) + French + Absinthe trade + Protestant + log density. HC1 = vce(robust), HC2, HC3 heteroskedasticity-robust SEs. BM dof = Bell-McCaffrey / Imbens-Kolesar (2016) effective degrees of freedom, hand-implemented in Mata and validated against native HC2. BM p = two-sided p from a t-distribution with BM dof on the HC2 SE. Stars: * p<0.10, ** p<0.05, *** p<0.01. At N=25 the effective dof collapses to ~2-4 (not N-k=19), so the full-spec result is p~0.12 under the honest small-sample correction, not the ~0.06 a naive normal would give._
