*******
* _install_stata_packages.do
* Installs the default vendored package loadout into analysis/scripts/libraries/stata.
*
* Default loadout: realistic econ-research stack — beyond Reif's four — with
* dependency-aware install order. Each group is annotated with its purpose.
*
* USAGE:
*   1. Set $MyProject to the analysis/ folder path before running this script.
*   2. Run from Stata (not via run.do): `do "$MyProject/scripts/_install_stata_packages.do"`.
*   3. Verify each package installed via `which <command>`.
*
* IMPORTANT (per Reif's submission checklist): delete this script before
* publishing the replication package. The bundled libraries/stata folder is
* what should ship.
*******

* Stata version
version 15

* Create local install directory and route net installs there
cap mkdir "$MyProject/scripts/libraries"
cap mkdir "$MyProject/scripts/libraries/stata"
net set ado "$MyProject/scripts/libraries/stata"

* Initialize an error log for this install run
local errlog "$MyProject/scripts/libraries/stata/_install_errors.log"
cap erase "`errlog'"
tempname elog
file open `elog' using "`errlog'", write replace
file write `elog' "Install run: `c(current_date)' `c(current_time)'" _n
file close `elog'

* Helper: install from SSC (Boston College)
program define _install_ssc
    args pkg
    local ltr = substr("`pkg'", 1, 1)
    qui net from "http://fmwww.bc.edu/repec/bocode/`ltr'"
    cap net install `pkg', replace
    if _rc {
        di as error "FAILED: ssc install `pkg' (rc=`_rc')"
        tempname f
        file open `f' using "$MyProject/scripts/libraries/stata/_install_errors.log", write append
        file write `f' "FAILED ssc: `pkg' (rc=`_rc')" _n
        file close `f'
    }
    else {
        di as text "INSTALLED (ssc): `pkg'"
    }
end

* Helper: install from GitHub (Reif packages)
program define _install_gh
    args pkg user
    cap net install `pkg', from("https://raw.githubusercontent.com/`user'/`pkg'/master") replace
    if _rc {
        di as error "FAILED: gh install `pkg' from `user' (rc=`_rc')"
        tempname f
        file open `f' using "$MyProject/scripts/libraries/stata/_install_errors.log", write append
        file write `f' "FAILED gh: `pkg' from `user' (rc=`_rc')" _n
        file close `f'
    }
    else {
        di as text "INSTALLED (gh): `pkg' from `user'"
    }
end

************************************************************
* Group 1 — regression workhorses (with dependency order)
************************************************************
* ftools must come BEFORE reghdfe (Correia)
_install_ssc ftools
_install_ssc reghdfe

* ranktest, avar must come BEFORE ivreg2 and boottest
_install_ssc ranktest
_install_ssc avar
_install_ssc ivreg2
_install_ssc boottest

************************************************************
* Group 2 — Reif stack: output and cross-language
************************************************************
* Reif packages from GitHub (regsave bundles regsave_tbl)
_install_gh regsave reifjulian
_install_gh texsave reifjulian
_install_gh rscript reifjulian

* appendfile (used by texsave) — also from Reif's repo
_install_gh appendfile reifjulian

************************************************************
* Group 3 — large-dataset utilities
************************************************************
* gtools: fast collapse/egen/reshape/sort (Bravo)
_install_ssc gtools

************************************************************
* Group 4 — alternative output and presentation
************************************************************
* estout (provides esttab) — second output option alongside regsave/texsave
_install_ssc estout

* coefplot — coefficient plots, pairs with regsave
_install_ssc coefplot

************************************************************
* Group 5 — robustness and inference
************************************************************
* wyoung — multiple hypothesis correction (Reif/Jones/Molitor)
_install_gh wyoung reifjulian

************************************************************
* Group 6 — utilities
************************************************************
_install_ssc distinct
_install_ssc unique
_install_ssc fre
_install_ssc winsor2
_install_ssc labutil
_install_ssc ingap

************************************************************
* Group 7 — coefficient decomposition
************************************************************
* b1x2: Gelbach (2016) conditional decomposition of coefficient changes
* between base and full regression specifications. Used in 05_expansion.do
* to attribute the absinthe-vote vineyard sign-flip to language vs religion.
* See analysis/documentation/methods/gelbach_decomposition.md for the full
* methods reference + sources.
_install_ssc b1x2

************************************************************
* Group 8 — round-2 diagnostics + permutation inference (added 2026-05-01)
************************************************************
* coldiag2: Belsley-Kuh-Welsch condition number for multicollinearity
* diagnostics. Used in 05_expansion.do Task A (round-2) to defend the
* headline KEY-spec result against the obstinate-EEH-collinearity critique.
_install_ssc coldiag2

* lassopack: LASSO machinery (lasso2, cvlasso, rlasso, lassoutils, etc.).
* Must be installed BEFORE pdslasso because pdslasso depends on lassoutils.
_install_ssc lassopack

* pdslasso: post-double-selection LASSO (Belloni-Chernozhukov-Hansen 2014).
* Used in 05_expansion.do Task A for data-driven covariate selection on
* the headline yes_pct ~ vineyard_per_cap regression with a candidate
* control set including french/catholic/protestant/lang_italian/ln_pop/
* agland_1000ha/avg_parcel_area_1905/parcels_per_farm_1905/net_migration_per_cap.
_install_ssc pdslasso

* ritest: permutation inference (used in 03_regress.do for headline RI
* and in round-2 Tasks C.3 + C.6 for cross-vote and turnout-deviation RI).
* Already used implicitly in some round-1 paths; vendoring explicitly
* per round-2 STOP-and-vendor protocol.
_install_ssc ritest

************************************************************
* Verification
************************************************************
* Confirm each package's main command is reachable
local commands ftools reghdfe ranktest avar ivreg2 boottest ///
    regsave texsave rscript ///
    gtools estout esttab coefplot ///
    wyoung distinct unique fre winsor2 ingap ///
    b1x2 ///
    coldiag2 lassoutils pdslasso ritest

di _n as text "{hline 60}"
di as text "Verification — checking 'which' for each main command"
di as text "{hline 60}"
foreach c of local commands {
    cap which `c'
    if _rc di as error "MISSING: `c' (rc=`_rc')"
    else di as text "OK: `c'"
}
di as text "{hline 60}"

* Show error log if any failures
cap confirm file "`errlog'"
if !_rc {
    di _n as text "Install error log: `errlog'"
    type "`errlog'"
}

* Cleanup helper programs
cap program drop _install_ssc
cap program drop _install_gh

** EOF
