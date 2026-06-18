/*==============================================================================
 _phase9_extract.do  - Pull beta/SE/p for white vs red vs aggregate at col 5
==============================================================================*/

di _newline "===== Phase 9 HEADLINE: Cahannes white-wine substitution test ====="
di _newline "  Y1 (vote 68) at col 5 controls.  All N = 25."
di ""
di "  --- OLS HC3 ---"

estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/ols_white_5.ster"
local b_w  = _b[X3_white_share]
local se_w = _se[X3_white_share]
local p_w  = 2*ttail(e(df_r), abs(`b_w'/`se_w'))
di "    WHITE (X3_white_share):     beta=" %7.4f `b_w' ", SE=" %7.4f `se_w' ", p=" %5.3f `p_w'

estimates use "$MyProject/results/intermediate/estimates_workshop/ols_3_5.ster"
local b_a  = _b[X3_share]
local se_a = _se[X3_share]
local p_a  = 2*ttail(e(df_r), abs(`b_a'/`se_a'))
di "    AGGREGATE (X3_share):       beta=" %7.4f `b_a' ", SE=" %7.4f `se_a' ", p=" %5.3f `p_a'

estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/ols_red_5.ster"
local b_r  = _b[X3_red_share]
local se_r = _se[X3_red_share]
local p_r  = 2*ttail(e(df_r), abs(`b_r'/`se_r'))
di "    RED (X3_red_share):         beta=" %7.4f `b_r' ", SE=" %7.4f `se_r' ", p=" %5.3f `p_r'

di _newline "  --- FL AME x100 (headline-comparable scale) ---"

estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/fl_me_white_5.ster"
local b_w  = _b[X3_white_share]*100
local se_w = _se[X3_white_share]*100
local p_w  = 2*(1 - normal(abs(`b_w'/`se_w')))
di "    WHITE:                       AMEx100=" %7.4f `b_w' ", SE=" %7.4f `se_w' ", p=" %5.3f `p_w'

estimates use "$MyProject/results/intermediate/estimates_fraclogit_workshop/fl_me_3_5.ster"
local b_a  = _b[X3_share]*100
local se_a = _se[X3_share]*100
local p_a  = 2*(1 - normal(abs(`b_a'/`se_a')))
di "    AGGREGATE:                   AMEx100=" %7.4f `b_a' ", SE=" %7.4f `se_a' ", p=" %5.3f `p_a'

estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/fl_me_red_5.ster"
local b_r  = _b[X3_red_share]*100
local se_r = _se[X3_red_share]*100
local p_r  = 2*(1 - normal(abs(`b_r'/`se_r')))
di "    RED:                         AMEx100=" %7.4f `b_r' ", SE=" %7.4f `se_r' ", p=" %5.3f `p_r'

di _newline _newline "===== Petition Y at col 5 ====="
estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/ols_pet_white_5.ster"
local b  = _b[X3_white_share]
local se = _se[X3_white_share]
local p  = 2*ttail(e(df_r), abs(`b'/`se'))
di "    WHITE:      beta=" %7.4f `b' ", SE=" %7.4f `se' ", p=" %5.3f `p'

estimates use "$MyProject/results/intermediate/estimates_petition_workshop/ols_pet_3_5.ster"
local b  = _b[X3_share]
local se = _se[X3_share]
local p  = 2*ttail(e(df_r), abs(`b'/`se'))
di "    AGGREGATE:  beta=" %7.4f `b' ", SE=" %7.4f `se' ", p=" %5.3f `p'

estimates use "$MyProject/results/intermediate/estimates_winetype_workshop/ols_pet_red_5.ster"
local b  = _b[X3_red_share]
local se = _se[X3_red_share]
local p  = 2*ttail(e(df_r), abs(`b'/`se'))
di "    RED:        beta=" %7.4f `b' ", SE=" %7.4f `se' ", p=" %5.3f `p'

** EOF
