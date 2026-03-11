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

** Set your path here
global PATH "D:\Projects\Original\AIComm\analysis"
cd "$PATH"
quietly include code/sub_programs.do

global output_folder "output"
capture mkdir "$output_folder"

// capture log close
// capture mkdir "$output_folder/outcome_ciplot"
// cap log using "$output_folder/outcome_ciplot/outcome_ciplot.log", replace text

local ALL_SAMPLES "2 3 4 5 6 7 8 9 10 11 12 20 30 40 80 90 100 110 120"


use input/SwissSurvey_Insta_Experiment_clean.dta, clear

gen Post_AIness = .
replace Post_AIness = 0 if (Post_pangram_headline==2 | Post_pangram_headline==3 | Post_pangram_headline==4)
replace Post_AIness = 1 if (Post_pangram_headline==1)

gen Base_AIness = .
replace Base_AIness = 0 if (Base_pangram_headline==2 | Base_pangram_headline==3 | Base_pangram_headline==4)
replace Base_AIness = 1 if (Base_pangram_headline==1)

* ==============================================================================
* Horse Race
* ==============================================================================
// * No extrea control
// reg Finished i.AITreat##i.Identify##(i.not_shared_handle i.ImageConcernBinary_p50), vce(robust)
//
// reg Meaningful_post i.AITreat##i.Identify##(i.not_shared_handle i.ImageConcernBinary_p50), vce(robust)
// reg Meaningful_post i.AITreat##i.Identify##(i.not_shared_handle i.ImageConcernBinary_p50) if Finished==1, vce(robust)
//
//
// reg Finished i.AITreat##i.Identify##(i.not_shared_handle i.ImageConcernBinary_p50) if sample20==1, vce(robust)
//
// reg Meaningful_post i.AITreat##i.Identify##(i.not_shared_handle i.ImageConcernBinary_p50) if sample20==1, vce(robust)
// reg Meaningful_post i.AITreat##i.Identify##(i.not_shared_handle i.ImageConcernBinary_p50) if Finished==1 & sample20==1, vce(robust)



* ===================================================================================================
* POST CI plots by Treatment_Group, raw and residuals using Lasso selected controls
* Saved at: '\analysis\output\outcome_ciplot\raw_mean' & '\analysis\output\outcome_ciplot\residualized'
* ===================================================================================================

local RUN_SAMPLES "2 20"
foreach s of local RUN_SAMPLES {

	// Define the full label for xtitle
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
	
	foreach x in $OUTCOMES {
		
        di as txt "Running Sample=`s', Outcome=`x'"
		
		ciplot_4treat_pval_no_resid, outcome(`x') sample_number(`s') slabel("`slabel'") sname("`sname'")
		ciplot_4treat_pval_fwl_resid, outcome(`x') sample_number(`s') slabel("`slabel'") sname("`sname'")
		
		if "`x'" != "Finished" {
			ciplot_4treat_pval_no_resid, outcome(`x') sample_number(`s') slabel("`slabel'") sname("`sname'") if_condition("if Finished == 1")
			ciplot_4treat_pval_fwl_resid, outcome(`x') sample_number(`s') slabel("`slabel'") sname("`sname'") if_condition("if Finished == 1")
		}
    }
}





* ===================================================================================================
* Appendix Treatment Effect Tables: tbl_treat_eff_app
* 4 columns: No Controls / Focal Behavioral / All Behavioral / All Behavioral + Demographic
* Saved at: '\analysis\output\outcome_table'
* ===================================================================================================
local RUN_SAMPLES "2"

foreach s of local RUN_SAMPLES {

    local slabel "Sample `s'"
    if `s' == 2  local slabel "Full Eligible Sample"
    if `s' == 5  local slabel "Low Disclosure Concern Sample"
    if `s' == 8  local slabel "High Disclosure Concern Sample"
    if `s' == 20 local slabel "Instagram User Sample"
    if `s' == 80 local slabel "IG High Disclosure Concern Sample"

    local sname "S`s'"
    if `s' == 2  local sname "Full"
    if `s' == 5  local sname "LowDisclCon"
    if `s' == 8  local sname "HighDisclCon"
    if `s' == 20 local sname "IGUsers"
    if `s' == 80 local sname "HighDisclConIG"

    foreach x in $OUTCOMES {

        display as txt "tbl_treat_eff_app: Sample=`s' (`sname'), Outcome=`x'"

        tbl_treat_eff_app, outcome(`x') sample_number(`s') slabel("`slabel'") sname("`sname'")
		
        if "`x'" != "Finished" {
            tbl_treat_eff_app, outcome(`x') sample_number(`s') slabel("`slabel'") sname("`sname'") ///
                if_condition("if Finished == 1")
        }
    }
}


* ====================================================================================================
* Regression results: Treatment effect by dividing the samples and playing with focal controls 
* Saved at: '\analysis\output\outcome_table'
* ====================================================================================================

/*
local RUN_SAMPLES "2 5 8 20 80"

foreach s of local RUN_SAMPLES {

    local slabel "Sample `s'"
    if `s'==2  local slabel "Full Sample"
    if `s'==5  local slabel "Shared Handle"
    if `s'==8  local slabel "Not Shared Handle"
    if `s'==20 local slabel "Instagram Users"
    if `s'==80 local slabel "Instagram Users & Not Shared Handle"

    foreach x in $SELECTED_OUTCOMES {
       
        display "Running: Outcome `x' for `slabel'..."
		
        * Only run the conditional check if the variable is NOT "Finished"
        if "`x'" != "Finished" {
            outcome_img_prv_ins_tbl_Noctrl, sample_number(`s') outcome(`x') imageconcenrn(ImageConcern) if_condition("if Finished == 1") slabel("`slabel'")
            outcome_img_prv_ins_tbl_Lasso, sample_number(`s') outcome(`x') imageconcenrn(ImageConcern) if_condition("if Finished == 1") slabel("`slabel'") standardize(0)
            outcome_img_prv_ins_tbl_Lasso, sample_number(`s') outcome(`x') imageconcenrn(ImageConcern) if_condition("if Finished == 1") slabel("`slabel'") standardize(1)
        }
        * Run the unconditional version for every variable (including Finished)
        outcome_img_prv_ins_tbl_Noctrl, sample_number(`s') outcome(`x') imageconcenrn(ImageConcern) slabel("`slabel'")
        outcome_img_prv_ins_tbl_Lasso, sample_number(`s') outcome(`x') imageconcenrn(ImageConcern) slabel("`slabel'") standardize(0)
        outcome_img_prv_ins_tbl_Lasso, sample_number(`s') outcome(`x') imageconcenrn(ImageConcern) slabel("`slabel'") standardize(1)

    }
}



* Dividing by ImageConcern and not_shared_handle, controling for the Instagram_use
* We need to use a binary variable for the `imageconcenrn_binary' here.

foreach x in $SELECTED_OUTCOMES {
    

    if "`x'" != "Finished" {
        outcome_divby_img_prv_tbl_Noctrl, outcome(`x') imageconcenrn_binary(ImageConcernBinary_p50) if_condition("if Finished == 1")
		outcome_divby_img_prv_tbl_Lasso, outcome(`x') imageconcenrn_binary(ImageConcernBinary_p50) standardize(1) if_condition("if Finished == 1")
		outcome_divby_img_prv_tbl_Lasso, outcome(`x') imageconcenrn_binary(ImageConcernBinary_p50) standardize(0) if_condition("if Finished == 1")
    }
	
    outcome_divby_img_prv_tbl_Noctrl, outcome(`x') imageconcenrn_binary(ImageConcernBinary_p50)
    outcome_divby_img_prv_tbl_Lasso, outcome(`x') imageconcenrn_binary(ImageConcernBinary_p50) standardize(1)
    outcome_divby_img_prv_tbl_Lasso, outcome(`x') imageconcenrn_binary(ImageConcernBinary_p50) standardize(0)
}

*/



* ===================================================================================================
* HTE with interaction for appropriate moderators
* Saved at: '\analysis\output\hte\hte_table_with_interaction' 
* ===================================================================================================
local RUN_SAMPLES "2 20"
* Extra spaces is for safe searching
local NO_INSTA_SAMPLES " 20 30 40 80 90 100 "
local NO_HANDLE_SAMPLES " 5 6 7 8 9 10 80 90 100 "
local HANDLE_VARS "not_shared_handle index_Image_minus_privacy Image_minus_privacyBinary"

foreach s of local RUN_SAMPLES {
	
    local slabel "Sample `s'"
    if `s' == 2  local slabel "Full Eligible Sample"
    if `s' == 5  local slabel "Low Disclosure Concern Sample"
    if `s' == 8  local slabel "High Disclosure Concern Sample"
    if `s' == 20 local slabel "Instagram User Sample"
    if `s' == 80 local slabel "IG High Disclosure Concern Sample"

    local sname "S`s'"
    if `s' == 2  local sname "Full"
    if `s' == 5  local sname "LowDisclCon"
    if `s' == 8  local sname "HighDisclCon"
    if `s' == 20 local sname "IGUsers"
    if `s' == 80 local sname "HighDisclConIG"
    
    foreach x in $SELECTED_OUTCOMES {
        foreach m in $HTE_MODERATORS_TABLE {
        
            local skip = 0
            
            * Rule A: Instagram_use
            if "`m'" == "Instagram_use" {
                if strpos("`NO_INSTA_SAMPLES'", " `s' ") > 0 {
                    local skip = 1
                }
            }
            
            * Rule B: Privacy
            local is_handle_var : list m in HANDLE_VARS
            if `is_handle_var' {
                if strpos("`NO_HANDLE_SAMPLES'", " `s' ") > 0 {
                    local skip = 1
                }
            }
            
            if `skip' == 0 {
            
                hte_table_generator, outcome(`x') moderator(`m') sample_number(`s') slabel("`slabel'") sname("`sname'")
                
                * Skip if outcome is "Finished"
                if "`x'" != "Finished" {
                    hte_table_generator, outcome(`x') moderator(`m') ///
                        sample_number(`s') slabel("`slabel'") sname("`sname'") if_condition("if Finished == 1")
                }
                
            } 
            else {
               display "Skipping moderator `m' for sample `s' (No Variation)"
            }
        }
    }
}


* ===================================================================================================
* HTE without interaction for appropriate moderators
* Saved at: '\analysis\output\hte\hte_ciplot_no_interaction' 
* ===================================================================================================
local RUN_SAMPLES "2 20"
* Extra spaces are for safe searching
local NO_INSTA_SAMPLES " 20 30 40 80 90 100 "
local NO_HANDLE_SAMPLES " 5 6 7 8 9 10 80 90 100 "
local HANDLE_VARS "not_shared_handle index_Image_minus_privacy Image_minus_privacyBinary"

foreach s of local RUN_SAMPLES {

    if `s'==2  local slabel "Full Sample"
    if `s'==5  local slabel "Shared Handle"
    if `s'==8  local slabel "Not Shared Handle"
    if `s'==20 local slabel "Instagram Users"
    if `s'==80 local slabel "Instagram Users & Not Shared Handle"
    
    local sname "S`s'"
    if `s'==2  local sname "Full"
    if `s'==5  local sname "LowPriv"
    if `s'==8  local sname "HighPriv"
    if `s'==20 local sname "IGUsers"
    if `s'==80 local sname "HighPrivIG"
    
    foreach x in $SELECTED_OUTCOMES {
        foreach m in $HTE_MODERATORS_CIPLOT {
        
            local skip = 0
            
            * Rule A: Instagram_use
            if "`m'" == "Instagram_use" {
                if strpos("`NO_INSTA_SAMPLES'", " `s' ") > 0 {
                    local skip = 1
                }
            }
            
            * Rule B: Privacy
            local is_handle_var : list m in HANDLE_VARS
            if `is_handle_var' {
                if strpos("`NO_HANDLE_SAMPLES'", " `s' ") > 0 {
                    local skip = 1
                }
            }
            
            if `skip' == 0 {
            
                * 1. Run Standard Sample
                *hte_ciplot_NoCtrl, outcome(`x') moderator(`m') sample_number(`s') slabel("`slabel'") sname("`sname'")
				*hte_ciplot_raw, outcome(`x') moderator(`m') sample_number(`s') slabel("`slabel'") sname("`sname'")
                hte_ciplot_Lasso, outcome(`x') moderator(`m') sample_number(`s') slabel("`slabel'") sname("`sname'")
                
                * 2. Run "Finished == 1" Subset (if outcome is not Finished itself)
                if "`x'" != "Finished" {
                    *hte_ciplot_NoCtrl, outcome(`x') moderator(`m') sample_number(`s') slabel("`slabel'") sname("`sname'") if_condition("if Finished == 1")
					*hte_ciplot_raw, outcome(`x') moderator(`m') sample_number(`s') slabel("`slabel'") sname("`sname'") if_condition("if Finished == 1")
                    hte_ciplot_Lasso, outcome(`x') moderator(`m') sample_number(`s') slabel("`slabel'") sname("`sname'") if_condition("if Finished == 1")
                }
                
            } 
            else {
                display "Skipping moderator `m' for sample `s' (No Variation)"
            }
        }
    }
}
