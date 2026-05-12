**********************
* OVERVIEW
*   This script generates tables and figures for the paper:
*       "Absinthe, Vineyards, and the 1908 Swiss Ban" (by Nicholas A Jensen)
*   Raw data are stored at $Absinthe1Data (external Dropbox)
*   All tables are outputted to /results/tables
*   All figures are outputted to /results/figures
*
* SOFTWARE REQUIREMENTS
*   Analyses run on Windows using Stata version 19
*
* TO PERFORM A CLEAN RUN, DELETE THE FOLLOWING TWO FOLDERS:
*   /processed
*   /results
**********************

* $Absinthe1 is set in the user's Stata profile (stata_profile.do)
global MyProject "$Absinthe1"
local ProjectDir "$MyProject"

* R is not used in this project
global DisableR = 1

* Confirm that the globals for the project root directory have been defined
cap assert !mi("`ProjectDir'")
if _rc {
	noi di as error "Error: need to define the global in run.do"
	error 9
}

* Record start time and initialize log
local datetime1 = clock("$S_DATE $S_TIME", "DMYhms")
clear
cap mkdir "`ProjectDir'/scripts/logs"
cap log close
local logdate : di %tcCCYY.NN.DD!_HH.MM.SS `datetime1'
local logfile "`ProjectDir'/scripts/logs/`logdate'.log.txt"
log using "`logfile'", text

* Configure Stata's library environment and record system parameters
run "`ProjectDir'/scripts/programs/_config.do"

* Inventory: log run start
local hostname : env HOSTNAME
if "`hostname'" == "" local hostname "unknown"
_inventory_append, sheet("runs") row("start|run.do|.|`c(stata_version)'|`c(os)'|`hostname'")

* R packages can be installed manually (see README) or installed automatically by uncommenting the following line
* if "$DisableR"!="1" rscript using "$MyProject/scripts/programs/_install_R_packages.R"

* R version control
if "$DisableR"!="1" rscript, rversion(3.6) require(tidyverse estimatr)

* Run project analysis
*   01-05: canton-level chain producing the headline tables/figures
*   06:    independent NATIONAL-LEVEL HSSO F-series archive (descriptive context
*          only; does not feed canton merge — placed last so a failure here
*          does not break the headline analysis)
do "`ProjectDir'/scripts/01_import.do"
do "`ProjectDir'/scripts/02_clean.do"
do "`ProjectDir'/scripts/03_regress.do"
do "`ProjectDir'/scripts/04_tables.do"
do "`ProjectDir'/scripts/05_expansion.do"
do "`ProjectDir'/scripts/06_national_descriptives.do"
do "`ProjectDir'/scripts/07_substrate_descriptives.do"

* Display runtime and end the script
local datetime2 = clock("$S_DATE $S_TIME", "DMYhms")
local duration_sec = (`datetime2' - `datetime1') / 1000
di "Runtime (hours): " %-12.2fc `duration_sec' / 3600

* Inventory: log run end
_inventory_append, sheet("runs") row("end|run.do|`=string(`duration_sec',"%9.2f")'|`c(stata_version)'|`c(os)'|`hostname'")

log close

** EOF
