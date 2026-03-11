***************
* Environment *
***************

clear all
macro drop _all
set scheme s1manual
grstyle init
grstyle set plain, horizontal grid
set seed 2025
set graphics off

** Set the correct project path for your system

global PATH "D:\Projects\Original\AIComm\analysis"
cd $PATH
adopath +  "."
qui include code/sub_programs.do

capture mkdir "output"
capture mkdir "output/outcome_ciplot"
global output_folder "output/outcome_ciplot/nice_version"
capture mkdir "$output_folder"


use input/SwissSurvey_Insta_Experiment_clean.dta, clear



// ==============================================================================
// VARIABLE-SPECIFIC PLOT SETTINGS
// Define ytitle, ylow, yhigh, ystep, and prct_var for each outcome here,
// ==============================================================================

// -- Finished --
local ytitle_Finished         "Completion Rate (%)"
local ylow_Finished           = 60
local yhigh_Finished          = 100
local ystep_Finished          = 5
local prct_Finished           = 1

// -- Post_meaningfulness --
local ytitle_Post_meaningfulness  "Meaningful Post-Task (%)"
local ylow_Post_meaningfulness    = 60
local yhigh_Post_meaningfulness   = 100
local ystep_Post_meaningfulness   = 5
local prct_Post_meaningfulness    = 1

// -- Post_TextLength_log --
local ytitle_Post_TextLength_log  "Ln (Post-Task Characters)"
local ylow_Post_TextLength_log    = 3.5
local yhigh_Post_TextLength_log   = 6
local ystep_Post_TextLength_log   = 0.5
local prct_Post_TextLength_log    = 0


// ==============================================================================
// EXECUTION LOOP
// ==============================================================================
local outcomes_list "Finished Post_meaningfulness Post_TextLength_log"

local RUN_SAMPLES "2 5 8 20 80"
foreach s of local RUN_SAMPLES {

    // Long label used in xtitle
    local slabel "Sample `s'"
    if `s' == 2  local slabel "Full Eligible Sample"
    if `s' == 5  local slabel "Low Disclosure Concern Sample"
    if `s' == 8  local slabel "High Disclosure Concern Sample"
    if `s' == 20 local slabel "Instagram User Sample"
    if `s' == 80 local slabel "IG High Disclosure Concern Sample"

    // Short tag used in filename
    local sname "S`s'"
    if `s' == 2  local sname "Full"
    if `s' == 5  local sname "LowDisclCon"
    if `s' == 8  local sname "HighDisclCon"
    if `s' == 20 local sname "IGUsers"
    if `s' == 80 local sname "HighDisclConIG"

    foreach x of local outcomes_list {

        di as txt "Running Sample=`s', Outcome=`x'"

        // Main plot (all respondents in sample)
        nice_ciplot_4treat_pvalue, outcome(`x') sample_number(`s') slabel("`slabel'") sname("`sname'") ///
            ytitle("`ytitle_`x''") ylow(`ylow_`x'') yhigh(`yhigh_`x'') ystep(`ystep_`x'') prct_var(`prct_`x'')

        // Finished-only plot (skip for Finished itself, which has no variation here)
        if "`x'" != "Finished" {
            nice_ciplot_4treat_pvalue, outcome(`x') sample_number(`s') slabel("`slabel'") sname("`sname'") ///
                ytitle("`ytitle_`x''") ylow(`ylow_`x'') yhigh(`yhigh_`x'') ystep(`ystep_`x'') prct_var(`prct_`x'') ///
                if_condition("if Finished == 1")
        }
    }
}



	
* ttest for sample 2 with more details

// ttest Finished if (`cond_full') & `g12', by(Treatment_Group) unequal
// local p12_full = r(p)
// ttest Finished if (`cond_full') & `g34', by(Treatment_Group) unequal
// local p34_full = r(p)
// display as text "p-values (Sample2):"
// display as result "  No AI, Not identified vs AI, Not identified : " %6.4f `p12_full'
// display as result "  No AI, Identified     vs AI, Identified     : " %6.4f `p34_full'
// display ""
//
// ttest Post_meaningfulness if (`cond_full') & `g12', by(Treatment_Group) unequal
// local p12_full = r(p)
// ttest Post_meaningfulness if (`cond_full') & `g34', by(Treatment_Group) unequal
// local p34_full = r(p)
// display as text "p-values (Sample2):"
// display as result "  No AI, Not identified vs AI, Not identified : " %6.4f `p12_full'
// display as result "  No AI, Identified     vs AI, Identified     : " %6.4f `p34_full'
// display ""
