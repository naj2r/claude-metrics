/*==============================================================================
 [NN]_[description].do
 Purpose:  [What this script does]
 Input:    [What datasets/files it reads]
 Output:   [What datasets/files it creates]
 Author:   [Author name]
 Date:     [YYYY-MM-DD]
 Version:  1.0
==============================================================================*/

* Stata version control (set in _config.do; explicit here for standalone runs)
version 19

* Standalone-execution preamble (avoid the word "bootstrap" — reserved for
* econometric resampling here, not script init)
* When run via run.do, _config.do is already sourced; otherwise we source it here
if "${MyProject}" == "" {
    di as error "Error: \$MyProject must be set in run.do or your Stata profile"
    error 9
}
cap which _codebook_update
if _rc {
    run "$MyProject/scripts/programs/_config.do"
}


**# 0. Preamble
*------------------------------------------------------------------------------*
/* Use **# bookmark syntax for navigation. Each chapter heading appears as a
   bookmark in Stata's do-file editor (View > Bookmarks). Use chapter numbers:
   0., 1., 1.1, 1.2, 2., etc. — like a book outline.
   Wrap long code chunks in { ... } braces so they fold in the editor.
*/
{
    * Any setup specific to this script (above and beyond _config.do)
}


**# 1. Load data
*------------------------------------------------------------------------------*
{
    * use "$MyProject/processed/intermediate/auto_uncleaned.dta", clear
}


**# 1.1 Clean values
*------------------------------------------------------------------------------*
{
    * Examples of conventions to follow:
    *   - Use `$MyProject/...` for all paths (forward slashes only)
    *   - `set seed 100` if any random function is used
    *   - `isid <key>` before sorting on a non-unique key
    *   - Variable suffixes: _ln, _lnp1, _mz, _mm, _miss, _cat
    *   - Variable labels include units: label var price "Price (1978 dollars)"
    *   - Use `assert` for sanity checks on key reported numbers
}


**# 2. Analysis
*------------------------------------------------------------------------------*
{
    * [Your analysis code here]
}


**# 3. Save outputs
*------------------------------------------------------------------------------*
{
    * compress
    * save "$MyProject/processed/<dataset>.dta", replace
}


**# 4. Post-credits: codebook + inventory updates
*------------------------------------------------------------------------------*
{
    * Update codebook for the dataset this script saved (replace path as needed)
    * _codebook_update using "$MyProject/processed/<dataset>.dta", script("[NN]_[description].do")

    * Log to inventory
    * _inventory_append, sheet("datasets") row("created|processed/<dataset>.dta|`=c(N)'|`=c(k)'|.|[NN]_[description].do")
    * _inventory_append, sheet("scripts") row("[NN]_[description].do|.|<purpose>|.")
}

** EOF
