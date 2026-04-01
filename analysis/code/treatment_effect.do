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

global PATH "D:\Projects\Original\AIComm\analysis"
global output_dir "output"


cd "$PATH"
quietly include code/sub_programs.do
capture mkdir "output"
capture mkdir "output/outcome_ciplot"
capture mkdir "output/outcome_ciplot/raw_mean"
capture mkdir "output/outcome_ciplot/residualized"
capture mkdir "output/outcome_ciplot/hte_raw"
capture mkdir "output/outcome_ciplot/hte_residualized"
capture mkdir "output/outcome_table"
capture mkdir "output/outcome_table/treatment_effect"

// -- Load dataset 

// Swap to SwissSurvey_Insta_Experiment_clean.dta for the non-finished version : treatment_effect_non_Finished.

use input/SwissSurvey_Insta_Experiment_clean_ff.dta, clear


local RUN_SAMPLES       "2 20"
local NO_INSTA_SAMPLES  " 20 30 40 80 90 100 "
local NO_HANDLE_SAMPLES " 5 6 7 8 9 10 80 90 100 "
local HANDLE_VARS "not_shared_handle index_Image_minus_privacy Image_minus_privacyBinary"


// ============================================================================
// EXECUTION LOOP
// ============================================================================

foreach s of local RUN_SAMPLES {

    // -- Long label for xtitle -----------------------------------------------
    local slabel "Sample `s'"
    if `s' == 2  local slabel "Analysis Sample"
    if `s' == 5  local slabel "Low Exposure Sensitivity Sample"
    if `s' == 8  local slabel "High Exposure Sensitivity Sample"
    if `s' == 20 local slabel "Instagram User Sample"
    if `s' == 80 local slabel "IG High Exposure Sensitivity Sample"

    // -- Short tag for filename -----------------------------------------------
    local sname "S`s'"
    if `s' == 2  local sname "Full"
    if `s' == 5  local sname "LowExposSen"
    if `s' == 8  local sname "HighExposSen"
    if `s' == 20 local sname "IGUsers"
    if `s' == 80 local sname "HighExposSenIG"

    // -------------------------------------------------------------------------
    // PART A: Raw-mean CI plots (4 treatment groups)
    // -------------------------------------------------------------------------
    foreach x in $OUTCOMES {
        di as txt "  [raw_mean] Sample=`s'  Outcome=`x'"
        nice_ciplot_4treat_pvalue, outcome(`x') sample_number(`s') slabel("`slabel'") sname("`sname'")
			
		di as txt "  [table: treatment_effect] Sample=`s'  Outcome=`x'"
		tbl_treat_eff_app, outcome(`x') sample_number(`s') slabel("`slabel'") sname("`sname'")
		
    }

    // -------------------------------------------------------------------------
    // PART B: HTE CI plots
    // -------------------------------------------------------------------------
    foreach x in $SELECTED_OUTCOMES {
        foreach m in $HTE_MODERATORS_CIPLOT {

            local skip = 0

            // skip Instagram_use for Instagram samples
            if "`m'" == "Instagram_use" {
                if strpos("`NO_INSTA_SAMPLES'", " `s' ") > 0 local skip = 1
            }

            // skip handle moderators for samples with no variation
            local is_handle_var : list m in HANDLE_VARS
            if `is_handle_var' {
                if strpos("`NO_HANDLE_SAMPLES'", " `s' ") > 0 local skip = 1
            }

            if `skip' == 0 {
                di as txt "  [hte_raw] Sample=`s'  Outcome=`x'  Moderator=`m'"
                hte_ciplot_raw, outcome(`x') moderator(`m') sample_number(`s') slabel("`slabel'") sname("`sname'")
            }
            else {
                di as txt "  [SKIP] Sample=`s'  Moderator=`m'  (no variation in this sample)"
            }

        }
    }
}