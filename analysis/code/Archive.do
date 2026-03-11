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
*cap log using "$output_folder/ciplots_and_tables.log", replace

local ALL_SAMPLES "2 3 4 5 6 7 8 9 10 11 12 20 30 40 80 90 100 110 120"
local RUN_SAMPLES "2 5 20 80"

use input/SwissSurvey_Insta_Experiment.dta, clear
data_pre_process

******* Table1 - My format *****
/*
clear all
macro drop _all
set scheme s1manual
grstyle init
grstyle set plain, horizontal grid
set seed 2025
set graphics on

** Set your path here
global PATH "D:\Projects\Original\AIComm\analysis"
cd "$PATH"
quietly include code/sub_programs.do


capture mkdir "output"
global output_folder "output/summary_stats"
capture mkdir "$output_folder"

use input/SwissSurvey_Insta_Experiment.dta,clear
data_pre_process
// replace Donation = Donation / 10


label variable Age "Age"
label variable Female "Gender"
label variable Switzerland "Swiss"
label variable Donation "Donation (CHF)"
label variable Instagram_use "Instagram User"
label variable shared_handle "Shared handle"

local vars_1dec "Age"
local vars_3dec "Female Switzerland Donation Instagram_use shared_handle"
local all_vars "`vars_1dec' `vars_3dec'"

// label variable index_Climate "Climate Attitude"
// label variable Grad_degree "Master/PhD"


* ========================================================
* Table 1 : Panel A & Panel B in one file
* ========================================================
global output_file "$output_folder/Table1_2Panel.tex"

eststo clear
forvalues g = 1/4 {
    eststo group`g': quietly estpost summarize `all_vars' if Treatment_Group == `g'
}

* Calculate Differences for Panel B
eststo diff1: quietly estpost ttest `all_vars' if inlist(Treatment_Group, 1, 2), by(Treatment_Group) unequal
eststo diff2: quietly estpost ttest `all_vars' if inlist(Treatment_Group, 3, 4), by(Treatment_Group) unequal
eststo diff3: quietly estpost ttest `all_vars' if inlist(Treatment_Group, 1, 3), by(Treatment_Group) unequal
eststo diff4: quietly estpost ttest `all_vars', by(Identify) unequal



* --------------------------------------------------------
* PANEL A TOP: Headers + 1-Decimal Vars
* --------------------------------------------------------
esttab group1 group2 group3 group4 using "$output_file", replace ///
    keep(`vars_1dec') ///
    cells("mean(fmt(1)) sd(fmt(1))") ///
    label ///
    collabels("Mean" "SD") ///
    mtitles("(1)" "(2)" "(3)" "(4)") ///
    mgroups("No AI, Anon." "AI, Anon." "No AI, Ident." "AI, Ident.", ///
        pattern(1 1 1 1) span prefix(\multicolumn{@span}{c}{) suffix(})) ///
    refcat(Age "\textbf{Panel A: Summary Statistics (Means)}", nolabel) ///
    noobs nonumbers nolines ///
    prehead( ///
        "\documentclass{article}" ///
        "\usepackage[margin=0.5in]{geometry}" ///
        "\usepackage{booktabs}" ///
        "\begin{document}" ///
        "\begin{table}[h!]" ///
        "\centering" ///
        "\caption{Descriptive Statistics and Balance Tests}" ///
        "\small" ///
        "\renewcommand{\arraystretch}{1.25}" ///
        "\begin{tabular}{l*{8}{c}}" ///  <-- 8 Columns (4 groups * 2 stats)
        "\toprule" ///
    ) ///
    posthead("\midrule") ///
    postfoot("") 

* --------------------------------------------------------
* PANEL A BOTTOM: 3-Decimal Vars + N Statistics
* --------------------------------------------------------
esttab group1 group2 group3 group4 using "$output_file", append ///
    keep(`vars_3dec') ///
    cells("mean(fmt(3)) sd(fmt(3))") ///
    label ///
    collabels(none) ///
    nomtitles ///
    nonumbers nolines ///
    stats(N, labels("\midrule \textit{N}") fmt(0)) /// <-- Adds Line + Italic N
    prehead("") ///
    postfoot("") 

* --------------------------------------------------------
* PANEL B TOP: Headers + 1-Decimal Vars
* --------------------------------------------------------
esttab diff1 diff2 diff3 diff4 using "$output_file", append ///
    keep(`vars_1dec') ///
    cells("b(fmt(1)) p(fmt(3))") ///
    label ///
    collabels("Diff." "\textit{p}-val") ///
    nomtitles ///
    noobs nonumbers nostar nolines ///
    refcat(Age "\textbf{Panel B: Balance Tests (Differences)}", nolabel) ///
    prehead( ///
        "\midrule" ///
        " & \multicolumn{2}{c}{(1) - (2)} & \multicolumn{2}{c}{(3) - (4)} & \multicolumn{2}{c}{(1) - (3)} & \multicolumn{2}{c}{(1, 2) - (3, 4)} \\") ///
    posthead("") ///
    postfoot("") 

* --------------------------------------------------------
* PANEL B BOTTOM: 3-Decimal Vars + Footer
* --------------------------------------------------------
esttab diff1 diff2 diff3 diff4 using "$output_file", append ///
    keep(`vars_3dec') ///
    cells("b(fmt(3)) p(fmt(3))") ///
    label ///
    collabels(none) ///
    nomtitles ///
    nonumbers nostar nolines ///
    stats(N, labels("\midrule \textit{N}") fmt(0)) /// <-- Adds Line + Italic N for Panel B
    prehead("") ///
    postfoot( ///
        "\bottomrule" ///
        "\end{tabular}" ///
        "\begin{minipage}{0.8\textwidth}" ///
        "\footnotesize \medskip \textit{Notes:} Panel A reports means and standard deviations. Panel B reports differences. \textit{p}-values are from unequal variance t-tests." ///
        "\end{minipage}" ///
        "\end{table}" ///
        "\end{document}" ///
    )

	
* ========================================================
* Table 1 : Panel A & Panel B in seperate files
* ========================================================
* --------------------------------------------------------
* Table 1: Panel A
* --------------------------------------------------------
eststo clear
forvalues g = 1/4 {
    eststo group`g': quietly estpost summarize ///
        `vars_1dec' `vars_3dec' ///
        if Treatment_Group == `g'
}

* Part A: The Top Half (1 Decimal)
esttab group1 group2 group3 group4 using "$output_folder/Table1_PanelA.tex", replace ///
    keep(`vars_1dec') ///
    main(mean %9.1f) aux(sd %9.1f) ///
    cells("mean(fmt(1)) sd(fmt(1))") ///
    label ///
    collabels("Mean" "Std. Dev.") ///
    mgroups("No AI, Anonymous" "AI, Anonymous" "No AI, Identified" "AI, Identified", ///
        pattern(1 1 1 1) span prefix(\multicolumn{@span}{c}{) suffix(})) ///
    mtitles("(1)" "(2)" "(3)" "(4)") ///
    nonumbers ///
    noobs ///
    nolines ///
    prehead( ///
        "\documentclass{article}" ///
        "\usepackage[margin=1in]{geometry}" /// 
        "\usepackage{booktabs}" ///
        "\begin{document}" ///
        "\begin{table}[h!]" ///
        "\centering" ///
        "\small" ///
		"\renewcommand{\arraystretch}{1.25}" ///
        "\begin{tabular}{l*{8}{c}}" ///
        "\toprule" ///
    ) ///
    posthead("\midrule") ///
    postfoot("")

* Part B: The Bottom Half (3 Decimals)
esttab group1 group2 group3 group4 using "$output_folder/Table1_PanelA.tex", append ///
    keep(`vars_3dec') ///
    main(mean %9.3f) aux(sd %9.3f) ///
    cells("mean(fmt(3)) sd(fmt(3))") ///
    label ///
    collabels(none) ///
    nomtitles ///
    nonumbers ///
    nolines ///
    stats(N, labels("\midrule \textit{N}") fmt(0)) ///
    prehead("") ///
    postfoot( ///
        "\bottomrule" ///
        "\end{tabular}" ///
        "\end{table}" ///
        "\end{document}" ///
    )


* --------------------------------------------------------
* Table 1: Panel B
* --------------------------------------------------------
eststo clear

* --- Column 1: (1) - (2) ---
* Compares Group 1 vs Group 2. 
* ttest calculates (Mean_Low - Mean_High), so (1) - (2).
eststo diff1: quietly estpost ttest `all_vars' ///
    if inlist(Treatment_Group, 1, 2), by(Treatment_Group) unequal

* --- Column 2: (3) - (4) ---
* Compares Group 3 vs Group 4.
eststo diff2: quietly estpost ttest `all_vars' ///
    if inlist(Treatment_Group, 3, 4), by(Treatment_Group) unequal

* --- Column 3: (1) - (3) ---
* Compares Group 1 vs Group 3.
eststo diff3: quietly estpost ttest `all_vars' ///
    if inlist(Treatment_Group, 1, 3), by(Treatment_Group) unequal

* --- Column 4: ((1),(2)) - ((3),(4)) ---
* Compares Pooled 1 vs Pooled 2.
eststo diff4: quietly estpost ttest `all_vars', by(Identify) unequal

* Output Part A: Top Half (1 Decimal Vars)
esttab diff1 diff2 diff3 diff4 using "$output_folder/Table1_PanelB.tex", replace ///
    keep(`vars_1dec') ///
    cells("b(fmt(1)) p(fmt(3))") ///
    label ///
    collabels("Difference" "$ p$-value") ///
    mgroups("(1) -- (2)" "(3) -- (4)" "(1) -- (3)" "((1),(2)) -- ((3),(4))", ///
        pattern(1 1 1 1) span prefix(\multicolumn{@span}{c}{) suffix(})) ///
    nomtitles ///
    nonumbers ///
    noobs ///
    nostar /// 
    nolines ///
    prehead( ///
        "\documentclass{article}" ///
        "\usepackage[margin=0.5in]{geometry}" ///
        "\usepackage{booktabs}" ///
        "\begin{document}" ///
        "\begin{table}[h!]" ///
		"\caption{Balance Tests of Control Variables}" ///
        "\centering" ///
        "\small" ///
        "\renewcommand{\arraystretch}{1.25}" ///
        "\begin{tabular}{l*{8}{c}}" ///
        "\toprule" ///
    ) ///
    posthead("\midrule") ///
    postfoot("") 

* Output Part B: Bottom Half (3 Decimal Vars) & Footer
esttab diff1 diff2 diff3 diff4 using "$output_folder/Table1_PanelB.tex", append ///
    keep(`vars_3dec') ///
    cells("b(fmt(3)) p(fmt(3))") ///
    label ///
    collabels(none) ///
    nomtitles ///
    nonumbers ///
    nostar ///
    nolines ///
    stats(N, labels("\midrule \textit{N}") fmt(0)) /// 
    prehead("") ///
    postfoot( ///
        "\bottomrule" ///
        "\end{tabular}" ///
        "\end{table}" ///
        "\end{document}" ///
    )

*/


capture program drop hte_cont_binary
program define hte_cont_binary

    syntax, outcome(varname) moderator(varname) sample_number(integer) sample_label(string) [if_condition(string)]
    
    preserve
    quietly keep if sample`sample_number' == 1 & !missing(`outcome')
    if "`if_condition'" != "" {
        keep `if_condition'
    }
    
    local tbl_title "HTE: `outcome' by `moderator' (`sample_label')"
    local fname "`outcome'_hte_by_`moderator'"
	
    if "`if_condition'" == "if Finished == 1" {
        local tbl_title "HTE: `outcome' by `moderator' (`sample_label') $|$ Finished = 1"
		** ff: Finished ==1 Filtering
		local fname "`outcome'_hte_by_`moderator'_finised"

    }	
	
	capture mkdir "$output_folder/hte_table"
    capture mkdir "$output_folder/hte_table/hte_with_interactions"
    local outdir "$output_folder/hte_table/hte_with_interactions/sample`sample_number'"
    capture mkdir "`outdir'"
    
    *******************************************************
    * 1. Dynamic Variable Removal (Avoid Collinearity)    *
    *******************************************************
	eststo clear

    local VARS_TO_REMOVE ""

    if strpos("`moderator'", "Instagram_use") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Instagram_use"
    }

    * Logic from your example program for ImageConcern variants
    if strpos("`moderator'", "ImageConcern") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern i.ImageConcern ImageConcernBinary_p50 i.ImageConcernBinary_p50 ImageConcernBinary2 i.ImageConcernBinary2 ImageConcernBinary3 i.ImageConcernBinary3 ImageConcernBinary4 i.ImageConcernBinary4 index_Image_minus_privacy Image_minus_privacyBinary i.Image_minus_privacyBinary"
    }

    if strpos("`moderator'", "not_shared_handle") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' not_shared_handle i.not_shared_handle index_Image_minus_privacy Image_minus_privacyBinary i.Image_minus_privacyBinary"
    }

    if strpos("`moderator'", "Image_minus_privacy") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern i.ImageConcern ImageConcernBinary_p50 i.ImageConcernBinary_p50 ImageConcernBinary2 i.ImageConcernBinary2 ImageConcernBinary3 i.ImageConcernBinary3 ImageConcernBinary4 i.ImageConcernBinary4 not_shared_handle i.not_shared_handle index_Image_minus_privacy Image_minus_privacyBinary i.Image_minus_privacyBinary"
    }

    if strpos("`moderator'", "Donation") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Donation DonationBinary_p50 i.DonationBinary_p50 DonationBinary_pos i.DonationBinary_pos"
    }

    if strpos("`moderator'", "BotKnow") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotKnow BotKnowBinary i.BotKnow i.BotKnowBinary"
    }

    if strpos("`moderator'", "AIEffective") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' InitialAIEffective i.InitialAIEffective AIEffectiveBinary i.AIEffectiveBinary"
    }
	
    if strpos("`moderator'", "AIDiff") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BaseAIDiff AIDiffBinary i.BaseAIDiff i.AIDiffBinary "
    }
    
    if strpos("`moderator'", "Grad_degree") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Grad_degree i.Grad_degree"
    }
    
    if strpos("`moderator'", "Vote") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Vote i.Vote"
    }
    
    if strpos("`moderator'", "Switzerland") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Switzerland i.Switzerland"
    }
    
    if strpos("`moderator'", "Female") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Female i.Female"
    }

    if strpos("`moderator'", "ETH") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ETH i.ETH"
    }

    if strpos("`moderator'", "Age") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Age"
    }

    if strpos("`moderator'", "BaseTextLength") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BaseTextLength BaseTextLength_log"
    }

    if strpos("`moderator'", "Base_grammatical_mistakes") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Base_grammatical_mistakes"
    }
    
    * Also remove the moderator itself if it appears in any lists
    local VARS_TO_REMOVE "`VARS_TO_REMOVE' `moderator'"

    
    *******************************************************
    * 2. Define Control Sets                              *
    *******************************************************
    
    * -- Set A: Base Controls (ImageConcern, Handle, Insta) --
    local base_vars "i.ImageConcern not_shared_handle Instagram_use"
    * Remove forbidden vars
    if "`VARS_TO_REMOVE'" != "" {
        local base_vars : list base_vars - VARS_TO_REMOVE
    }

    * -- Set B: Base + Demographics --
    local col3_controls "i.ImageConcern not_shared_handle Instagram_use $DEMOG"
    * Remove forbidden vars from Demog (just in case)
    if "`VARS_TO_REMOVE'" != "" {
        local col3_controls : list col3_controls - VARS_TO_REMOVE
    }
 
    * -- Set C: Lasso Selection --
    local lasso_cands "$LASSO_CANDIDATES"
    
    * 1. Remove forbidden variables from candidates BEFORE Lasso
    if "`VARS_TO_REMOVE'" != "" {
        local lasso_cands : list lasso_cands - VARS_TO_REMOVE
    }
    
    * 2. Run Lasso
    local controls_lasso_sel ""
    
    * Check if outcome is binary (in global OUTCOMES_BIN) or continuous
    if (strpos("$OUTCOMES_BIN", "`outcome'") > 0) {
        capture quietly lasso logit `outcome' `lasso_cands', selection("cv")
        if _rc == 0 {
            local controls_lasso_sel "`e(allvars_sel)'"
        }
    }
    else {
        capture quietly lasso linear `outcome' `lasso_cands', selection("cv")
        if _rc == 0 {
            local controls_lasso_sel "`e(allvars_sel)'"
        }
    }

    * 3. Construct Final Lasso Control List (Lasso Result + Forced Base Vars)

    local raw_base_to_remove "ImageConcern i.ImageConcern not_shared_handle Instagram_use"
    local controls_lasso_sel : list controls_lasso_sel - raw_base_to_remove
    local col4_controls "`controls_lasso_sel' `base_vars'"
    local col4_controls : list col4_controls - VARS_TO_REMOVE


    *******************************************************
    * 3. Run Regressions (With Safety Checks)             *
    *******************************************************

    * Init list of models to tabulate and dynamic titles
    local models_to_tab ""
    local dynamic_mtitles ""

    * Define Interaction Terms for keeping in table
    local keep_terms "_cons 1.AITreat 1.Identify `moderator' 1.AITreat#1.Identify 1.AITreat#c.`moderator' 1.Identify#c.`moderator' 1.AITreat#1.Identify#c.`moderator'"
    
    * -- Model 1: No Controls --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator', vce(robust)
    if _rc == 0 {
        eststo model1
        local models_to_tab "`models_to_tab' model1"
        local dynamic_mtitles "`dynamic_mtitles' "HTE""
    }
    
    * -- Model 2: Base Controls --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator' `base_vars', vce(robust)
    if _rc == 0 {
        eststo model2
        local models_to_tab "`models_to_tab' model2"
        local dynamic_mtitles "`dynamic_mtitles' "HTE + Base""
    }
    
    * -- Model 3: Base + Demog --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator' `col3_controls', vce(robust)
    if _rc == 0 {
        eststo model3
        local models_to_tab "`models_to_tab' model3"
        local dynamic_mtitles "`dynamic_mtitles' "HTE + Base + Demog""
    }
    
    * -- Model 4: Lasso + Base --
    * Note: Checking N to ensure Lasso didn't fail or drop everything due to small sample
    if e(N) > 10 {
        capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator' `col4_controls', vce(robust)
        if _rc == 0 {
            eststo model4
            local models_to_tab "`models_to_tab' model4"
            local dynamic_mtitles "`dynamic_mtitles' "HTE + Lasso""
        }
    }

	*******************************************************
    * 4. Export Table                                     *
    *******************************************************

    if "`models_to_tab'" != "" {
        esttab `models_to_tab' using "`outdir'/`fname'.tex", replace ///
            main(b %9.3f) aux(se %9.3f) ///
            starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
            nobase noomit ///
            order(_cons 1.AITreat 1.Identify `moderator' ///
                  1.AITreat#1.Identify ///
                  1.AITreat#c.`moderator' ///
                  1.Identify#c.`moderator' ///
                  1.AITreat#1.Identify#c.`moderator') ///
            coeflabels(_cons "Intercept" ///
                       1.AITreat "AI Treat" ///
                       1.Identify "Identified Treat" ///
                       `moderator' "`moderator'" ///
                       1.AITreat#1.Identify "AI $\times$ Identified" ///
                       1.AITreat#c.`moderator' "AI $\times$ `moderator'" ///
                       1.Identify#c.`moderator' "Identified $\times$ `moderator'" ///
                       1.AITreat#1.Identify#c.`moderator' "AI $\times$ Identified $\times$ `moderator'") ///
            stats(r2_a N, fmt(%9.3f %9.0fc) labels("Adj. \(R^2\)" "\(N\)")) ///
            mtitles(`dynamic_mtitles') ///
            title("`tbl_title'") nonotes /// 
            booktabs compress width(\hsize) ///
            prehead(`"\documentclass{article}"' ///
                    `"\usepackage{booktabs}"' ///
                    `"\usepackage[paperheight=18in, paperwidth=8in, margin=0.5in]{geometry}"' ///
                    `"\begin{document}"' ///
                    `"\begin{table}[htbp]\centering"' ///
                    `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
                    `"\caption{@title}"' ///
                    `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                    `"\toprule"') ///
            postfoot(`"\bottomrule"' ///
                     `"\end{tabular*}"' ///
                     `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"' ///
                     `"Standard errors in parentheses. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$."' ///
                     `"\\ Base Controls: Image Concern, Shared Handle, Instagram Use."' ///
                     `"\\ Demographics: Grad degree, Vote, Age, ETH, Switzerland, Female."' ///
                     `"\\ Lasso includes Base Controls forced in."' ///
                     `"\end{minipage}"' ///
                     `"\end{table}"' ///
                     `"\end{document}"')
    }
    else {
        display "No models were successfully estimated for `outcome' by `moderator' in sample `sample_number'."
    }
	
    restore

end

capture program drop hte_cont_binary_std
program define hte_cont_binary_std

    syntax, outcome(varname) moderator(varname) sample_number(integer) sample_label(string) [if_condition(string)]
    
    preserve
    quietly keep if sample`sample_number' == 1 & !missing(`outcome')
    if "`if_condition'" != "" {
        keep `if_condition'
    }
    

    local tbl_title "HTE: `outcome' by `moderator (standardized controls)' (`sample_label')"
    local fname "`outcome'_hte_by_`moderator'_standardized"
	
    if "`if_condition'" == "if Finished == 1" {
        local tbl_title "HTE: `outcome' by `moderator (standardized controls)' (`sample_label') $|$ Finished = 1"
		** ff: Finished ==1 Filtering
		local fname "`outcome'_hte_by_`moderator'_standardized_finished"
    }	
	
	capture mkdir "$output_folder/hte_table"
    capture mkdir "$output_folder/hte_table/hte_with_interactions"
    local outdir "$output_folder/hte_table/hte_with_interactions/sample`sample_number'"
    capture mkdir "`outdir'"
    
    *******************************************************
    * 1. Dynamic Variable Removal (Avoid Collinearity)    *
    *******************************************************
	eststo clear
	
    local VARS_TO_REMOVE ""

    if strpos("`moderator'", "Instagram_use") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Instagram_use"
    }

    if strpos("`moderator'", "ImageConcern") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern i.ImageConcern ImageConcernBinary_p50 i.ImageConcernBinary_p50 ImageConcernBinary2 i.ImageConcernBinary2 ImageConcernBinary3 i.ImageConcernBinary3 ImageConcernBinary4 i.ImageConcernBinary4 index_Image_minus_privacy Image_minus_privacyBinary i.Image_minus_privacyBinary"
    }

    if strpos("`moderator'", "not_shared_handle") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' not_shared_handle i.not_shared_handle index_Image_minus_privacy Image_minus_privacyBinary i.Image_minus_privacyBinary"
    }

    if strpos("`moderator'", "Image_minus_privacy") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern i.ImageConcern ImageConcernBinary_p50 i.ImageConcernBinary_p50 ImageConcernBinary2 i.ImageConcernBinary2 ImageConcernBinary3 i.ImageConcernBinary3 ImageConcernBinary4 i.ImageConcernBinary4 not_shared_handle i.not_shared_handle index_Image_minus_privacy Image_minus_privacyBinary i.Image_minus_privacyBinary"
    }

    if strpos("`moderator'", "Donation") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Donation DonationBinary_p50 i.DonationBinary_p50 DonationBinary_pos i.DonationBinary_pos"
    }
    
    if strpos("`moderator'", "Grad_degree") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Grad_degree i.Grad_degree"
    }
    
    if strpos("`moderator'", "Vote") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Vote i.Vote"
    }
    
    if strpos("`moderator'", "Switzerland") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Switzerland i.Switzerland"
    }
    
    if strpos("`moderator'", "Female") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Female i.Female"
    }

    if strpos("`moderator'", "ETH") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ETH i.ETH"
    }

    if strpos("`moderator'", "Age") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Age"
    }

    if strpos("`moderator'", "BotKnow") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotKnow BotKnowBinary i.BotKnow i.BotKnowBinary"
    }

    if strpos("`moderator'", "AIEffective") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' InitialAIEffective i.InitialAIEffective AIEffectiveBinary i.AIEffectiveBinary"
    }
	
    if strpos("`moderator'", "AIDiff") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BaseAIDiff AIDiffBinary i.BaseAIDiff i.AIDiffBinary "
    }
    
    if strpos("`moderator'", "BaseTextLength") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BaseTextLength BaseTextLength_log"
    }

    if strpos("`moderator'", "Base_grammatical_mistakes") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Base_grammatical_mistakes i.Base_grammatical_mistakes"
    }
    
    * Also remove the moderator itself
    local VARS_TO_REMOVE "`VARS_TO_REMOVE' `moderator'"

    
    *******************************************************
    * 2. Standardization & List Creation                  *
    *******************************************************
    
    * --- A. Prepare Lasso Candidates (Standardized) ---
    local lasso_cands_std ""
    
    * 1. Continuous Candidates: Standardize if not removed
    foreach v of varlist $CONTROLS_CONT_NOFACTOR {
        local skip 0
        if strpos(" `VARS_TO_REMOVE' ", " `v' ") > 0 local skip 1
        
        if `skip' == 0 {
            capture drop `v'_N
            quietly sum `v'
            if r(sd) > 0 & r(sd) < . {
                gen `v'_N = (`v' - r(mean)) / r(sd)
                local lasso_cands_std "`lasso_cands_std' `v'_N"
            }
        }
    }
    
    * 2. Categorical Candidates: Add 'i.' prefix (No normalization) if not removed
    foreach v of varlist $CONTROLS_CAT_NOFACTOR_EX3 {
        local skip 0
        if strpos(" `VARS_TO_REMOVE' ", " `v' ") > 0 local skip 1
        
        if `skip' == 0 {
            local lasso_cands_std "`lasso_cands_std' i.`v'"
        }
    }

    * --- B. Define Base Controls (Standardized) ---
    * Logic: ImageConcern (Categorical) + Handle (Std) + Insta (Std)
    local base_vars_std ""

    * ImageConcern (Cat)
    if strpos(" `VARS_TO_REMOVE' ", " ImageConcern ") == 0 {
        local base_vars_std "`base_vars_std' i.ImageConcern"
    }
    
    * not_shared_handle (Binary -> Treat as continuous for normalization per instructions)
    if strpos(" `VARS_TO_REMOVE' ", " not_shared_handle ") == 0 {
        capture drop not_shared_handle_N
        quietly sum not_shared_handle
        if r(sd) > 0 & r(sd) < . {
            gen not_shared_handle_N = (not_shared_handle - r(mean)) / r(sd)
            local base_vars_std "`base_vars_std' not_shared_handle_N"
        }
    }
    
    * Instagram_use (Binary -> Treat as continuous for normalization)
    if strpos(" `VARS_TO_REMOVE' ", " Instagram_use ") == 0 {
        capture drop Instagram_use_N
        quietly sum Instagram_use
        if r(sd) > 0 & r(sd) < . {
            gen Instagram_use_N = (Instagram_use - r(mean)) / r(sd)
            local base_vars_std "`base_vars_std' Instagram_use_N"
        }
    }
    
    local col2_controls "`base_vars_std'"

    * --- C. Define Col 3 (Base Std + Demog Std) ---
    local demog_std ""
    foreach v of global DEMOG {
        local skip 0
        
        * Strip prefix (i. or c.) to get pure variable name for checking/generating
        local pure_v = regexr("`v'", "^[ic]\.", "")
        
        if strpos(" `VARS_TO_REMOVE' ", " `pure_v' ") > 0 local skip 1
        
        if `skip' == 0 {
            * Check if a standardized version was created in Step A (variable name will be pure_v_N)
            capture confirm variable `pure_v'_N
            if _rc == 0 {
                * It exists (was in EX3_CONT), so use the standardized version with original prefix
                * If original was c.Age, we use c.Age_N (or just Age_N, c. is implied for continuous)
                local demog_std "`demog_std' c.`pure_v'_N"
            }
            else {
                * If not standardized in Step A, check if it is categorical (in EX3_CAT)
                local is_cat 0
                foreach c of global LASSO_CANDIDATES_EX3_CAT {
                    if "`pure_v'" == "`c'" local is_cat 1
                }
                
                if `is_cat' {
                    * It is categorical, use original with i. prefix
                    local demog_std "`demog_std' i.`pure_v'"
                }
                else {
                    * If not in CAT list and not standardized yet, force standardization now
                    * (This handles continuous demographics not in the main lasso list)
                    capture drop `pure_v'_N
                    quietly sum `pure_v'
                    if r(sd) > 0 & r(sd) < . {
                        gen `pure_v'_N = (`pure_v' - r(mean)) / r(sd)
                        local demog_std "`demog_std' c.`pure_v'_N"
                    }
                }
            }
        }
    }
    local col3_controls "`base_vars_std' `demog_std'"

    * --- D. Define Col 4 (Lasso Std) ---
    * 1. Run Lasso using the standardized candidates
    local controls_lasso_sel ""
    if (strpos("$OUTCOMES_BIN", "`outcome'") > 0) {
        capture quietly lasso logit `outcome' `lasso_cands_std', selection(cv) rseed(2025)
        if _rc == 0 {
            local controls_lasso_sel "`e(allvars_sel)'"
        }
    }
    else {
        capture quietly lasso linear `outcome' `lasso_cands_std', selection(cv) rseed(2025)
        if _rc == 0 {
            local controls_lasso_sel "`e(allvars_sel)'"
        }
    }

    * 2. Force Base Vars back in
    * Remove the standardized base variable names from the Lasso result to avoid duplicates
    * We construct the "standardized names to remove" list dynamically based on what we created in Base
    local base_std_names_to_remove ""
    foreach b in `base_vars_std' {
        * Remove "i." for string matching if necessary, but list removal usually handles exact strings
        local base_std_names_to_remove "`base_std_names_to_remove' `b'"
    }
    
    local controls_lasso_sel : list controls_lasso_sel - base_std_names_to_remove
    
    local col4_controls "`controls_lasso_sel' `base_vars_std'"
    
    * Final safety: Remove any vars related to moderator (though they shouldn't exist due to pre-checks)
    if "`VARS_TO_REMOVE'" != "" {
        local col4_controls : list col4_controls - VARS_TO_REMOVE
    }


    *******************************************************
    * 3. Run Regressions (With Safety Checks)             *
    *******************************************************

    local models_to_tab ""
    local dynamic_mtitles ""
    local keep_terms "_cons 1.AITreat 1.Identify `moderator' 1.AITreat#1.Identify 1.AITreat#c.`moderator' 1.Identify#c.`moderator' 1.AITreat#1.Identify#c.`moderator'"
    
    * -- Model 1: No Controls --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator', vce(robust)
    if _rc == 0 {
        eststo model1
        local models_to_tab "`models_to_tab' model1"
        local dynamic_mtitles "`dynamic_mtitles' "HTE""
    }
    
    * -- Model 2: Base Controls (Std) --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator' `col2_controls', vce(robust)
    if _rc == 0 {
        eststo model2
        local models_to_tab "`models_to_tab' model2"
        local dynamic_mtitles "`dynamic_mtitles' "HTE + Base""
    }
    
    * -- Model 3: Base + Demog (Std) --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator' `col3_controls', vce(robust)
    if _rc == 0 {
        eststo model3
        local models_to_tab "`models_to_tab' model3"
        local dynamic_mtitles "`dynamic_mtitles' "HTE + Base + Demog""
    }
    
    * -- Model 4: Lasso (Std) + Base --
    if e(N) > 10 {
        capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator' `col4_controls', vce(robust)
        if _rc == 0 {
            eststo model4
            local models_to_tab "`models_to_tab' model4"
            local dynamic_mtitles "`dynamic_mtitles' "HTE + Lasso""
        }
    }

    *******************************************************
    * 4. Export Table                                     *
    *******************************************************

    if "`models_to_tab'" != "" {
        esttab `models_to_tab' using "`outdir'/`fname'.tex", replace ///
            main(b %9.3f) aux(se %9.3f) ///
            starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
            nobase noomit ///
            order(_cons 1.AITreat 1.Identify `moderator' ///
                  1.AITreat#1.Identify ///
                  1.AITreat#c.`moderator' ///
                  1.Identify#c.`moderator' ///
                  1.AITreat#1.Identify#c.`moderator') ///
            coeflabels(_cons "Intercept" ///
                       1.AITreat "AI Treat" ///
                       1.Identify "Identified Treat" ///
                       `moderator' "`moderator'" ///
                       1.AITreat#1.Identify "AI $\times$ Identified" ///
                       1.AITreat#c.`moderator' "AI $\times$ `moderator'" ///
                       1.Identify#c.`moderator' "Identified $\times$ `moderator'" ///
                       1.AITreat#1.Identify#c.`moderator' "AI $\times$ Identified $\times$ `moderator'") ///
            stats(r2_a N, fmt(%9.3f %9.0fc) labels("Adj. \(R^2\)" "\(N\)")) ///
            mtitles(`dynamic_mtitles') ///
            title("`tbl_title'") nonotes ///
            booktabs compress width(\hsize) ///
            prehead(`"\documentclass{article}"' ///
                    `"\usepackage{booktabs}"' ///
                    `"\usepackage[paperheight=18in, paperwidth=8in, margin=0.5in]{geometry}"' ///
                    `"\begin{document}"' ///
                    `"\begin{table}[htbp]\centering"' ///
                    `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
                    `"\caption{@title}"' ///
                    `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                    `"\toprule"') ///
            postfoot(`"\bottomrule"' ///
                     `"\end{tabular*}"' ///
                     `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"' ///
                     `"Standard errors in parentheses. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$."' ///
                     `"\\ Controls are standardized (z-score) where applicable."' ///
                     `"\\ Base Controls: Image Concern (Categorical), Shared Handle (Standardized), Instagram Use (Standardized)."' ///
                     `"\\ Lasso includes Base Controls forced in."' ///
                     `"\end{minipage}"' ///
                     `"\end{table}"' ///
                     `"\end{document}"')
    }
    else {
        display "No models were successfully estimated for `outcome' by `moderator' in sample `sample_number'."
    }
    
    restore

end




********************************
**** 	Usefull Stuff 		****
********************************

/*
* ------------------------------------------------------------------------------
* ciplot_interactions_binary :: https://aistudio.google.com/app/prompts?state=%7B%22ids%22:%5B%221auZlPRPfAO9kI4w_PdcM0MRbL2c8dmla%22%5D,%22action%22:%22open%22,%22userId%22:%22117042941950604748131%22,%22resourceKeys%22:%7B%7D%7D&usp=sharing
* ------------------------------------------------------------------------------
capture program drop ciplot_interactions_binary
program define ciplot_interactions_binary
    syntax, outcome(varname) sample(numlist) moderator(varname) controls(varlist) lasso_cands(varlist)

    preserve
    keep if sample`sample' == 1
    
    * Define 8 Groups
    gen byte Group8 = .
    replace Group8 = 1 if Treatment_Group==1 & `moderator'==0
    replace Group8 = 2 if Treatment_Group==1 & `moderator'==1
    replace Group8 = 3 if Treatment_Group==2 & `moderator'==0
    replace Group8 = 4 if Treatment_Group==2 & `moderator'==1
    replace Group8 = 5 if Treatment_Group==3 & `moderator'==0
    replace Group8 = 6 if Treatment_Group==3 & `moderator'==1
    replace Group8 = 7 if Treatment_Group==4 & `moderator'==0
    replace Group8 = 8 if Treatment_Group==4 & `moderator'==1
    
    drop if missing(Group8)

    * Lasso Selection (Using Sanitized Candidates)
    qui inspect `outcome'
    if r(N_unique) == 2 {
        capture lasso logit `outcome' `lasso_cands', selection(cv) rseed(2025)
    }
    else {
        capture lasso linear `outcome' `lasso_cands', selection(cv) rseed(2025)
    }

    * Residualize
    if _rc == 0 {
        local selected_vars `e(allvars_sel)'
        if "`selected_vars'" != "" {
            quietly reg `outcome' `selected_vars'
            predict double `outcome'_resid, residuals
        }
        else {
            gen double `outcome'_resid = `outcome'
        }
    }
    else {
        gen double `outcome'_resid = `outcome'
    }

    * Statsby
    statsby mean=r(mean) ub=r(ub) lb=r(lb) N=r(N), by(Group8) clear: ci means `outcome'_resid

    * Plotting
    local c1 "navy"     
    local c2 "maroon"   
    
    twoway ///
        (rcap ub lb Group8 if mod(Group8, 2) != 0, lcolor(`c1') lwidth(medthin)) ///
        (scatter mean Group8 if mod(Group8, 2) != 0, msymbol(O) msize(small) mcolor(`c1')) ///
        (rcap ub lb Group8 if mod(Group8, 2) == 0, lcolor(`c2') lwidth(medthin)) ///
        (scatter mean Group8 if mod(Group8, 2) == 0, msymbol(D) msize(small) mcolor(`c2')), ///
        xlabel(1.5 "No AI, Not Iden" 3.5 "AI, Not Iden" 5.5 "No AI, Iden" 7.5 "AI, Iden", noticks labsize(small)) ///
        xtitle("") ytitle("Residuals (`outcome')", size(small)) ///
        legend(order(2 "Mod=0" 4 "Mod=1") rows(1) position(6)) ///
        title("Heterogeneity by `moderator'", size(medium)) ///
        subtitle("Sample `sample' (Lasso Residualized)", size(small)) ///
        yline(0, lcolor(gs12) lpattern(dash)) ///
        graphregion(color(white)) name(g_`outcome'_`sample', replace)


	capture mkdir "$output_folder/hte_with_interactions"
	capture mkdir "$output_folder/hte_with_interactions/sample`sample'"
	capture mkdir "$output_folder/hte_with_interactions/sample`sample'/ciplots_binary"	
	graph export"$output_folder/hte_with_interactions/sample`sample'/ciplots_binary/CI_8Arm_`outcome'_by_`moderator'.pdf", replace		
    
    restore
end

foreach s of local RUN_SAMPLES {
    
    display "Processing ciplot_interactions_binary for Sample `s'..."
    local ALL_OUTCOMES "$OUTCOMES $GPT_OUTCOMES" "Finished"
    
    foreach y of local ALL_OUTCOMES {
        
        * Only running Binary HTE Plots as requested
        foreach mod of global HTE_MODERATORS_BINARY {
            
            capture confirm variable `mod'
            if _rc == 0 {
                
                * --- CONTROLS SANITIZER ---
                local CURRENT_CONTROLS "$CONTROLS"
                local CURRENT_LASSO    "$LASSO_CANDIDATES"
                local VARS_TO_REMOVE   ""

                * Logic A: Image Concern Related
                if strpos("`mod'", "ImageConcern") > 0 {
                    local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern"
                }

                * Logic B: Donation Related
                if strpos("`mod'", "Donation") > 0 {
                    local VARS_TO_REMOVE "`VARS_TO_REMOVE' Donation"
                }

                * Logic C: Privacy / Index Related (Image - Privacy)
                if strpos("`mod'", "Image_minus_privacy") > 0 {
                    local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern not_shared_handle index_Image_minus_privacy"
                }

                * Logic D: Shared Handle
                if "`mod'" == "not_shared_handle" {
                    local VARS_TO_REMOVE "`VARS_TO_REMOVE' not_shared_handle index_Image_minus_privacy"
                }

                * Logic E: Climate Index
                if "`mod'" == "index_Climate" {
                     local VARS_TO_REMOVE "`VARS_TO_REMOVE' index_Climate"
                }
                
                * APPLY REMOVAL
                if "`VARS_TO_REMOVE'" != "" {
                    local CURRENT_CONTROLS : list CURRENT_CONTROLS - VARS_TO_REMOVE
                    local CURRENT_LASSO    : list CURRENT_LASSO    - VARS_TO_REMOVE
                }

                * Run only the binary CI Plot program
                ciplot_interactions_binary, outcome(`y') sample(`s') moderator(`mod') controls(`CURRENT_CONTROLS') lasso_cands(`CURRENT_LASSO')
            }
        }
    }
}
*/


/*
* ====================================================================================================
* HTE with interaction binary moderators: Manually defined
* ====================================================================================================

* table_hte_interactions_binary1: samples 2 and 20 using unstandardized base and Lasso-selected controls.
* table_hte_interactions_binary2: samples 2 and 20 using standardized (z-score) base and Lasso-selected controls.
* table_hte_interactions_binary3: samples 5, 8, and 80 using unstandardized base and Lasso-selected controls.
* table_hte_interactions_binary4: samples 5, 8, and 80 using standardized (z-score) base and Lasso-selected controls.

foreach y in $OUTCOMES $GPT_OUTCOMES {
    foreach moderator in $HTE_MODERATORS_BINARY {
        table_hte_interactions_binary1, outcome(`y') moderator(`moderator') imgconcern(ImageConcernBinary_p50)
		table_hte_interactions_binary2, outcome(`y') moderator(`moderator') imgconcern(ImageConcernBinary_p50)
        table_hte_interactions_binary3, outcome(`y') moderator(`moderator') imgconcern(ImageConcernBinary_p50)
		table_hte_interactions_binary4, outcome(`y') moderator(`moderator') imgconcern(ImageConcernBinary_p50)
    }
}


capture program drop table_hte_interactions_binary1
program define table_hte_interactions_binary1
    syntax, outcome(varname) moderator(varname) imgconcern(varname)

    local models_to_tab ""
    local ordered_vars "NoAI_x_NotIden_D0 NoAI_x_NotIden_D1 AI_x_NotIden_D0 AI_x_NotIden_D1 NoAI_x_Iden_D0 NoAI_x_Iden_D1 AI_x_Iden_D0 AI_x_Iden_D1"

    foreach samp in sample2 sample20 {
        preserve
        keep if `samp' == 1
        keep if !missing(`outcome')
        
        if "`samp'" == "sample2" {
            local instasample_lab "No"
        }
        else {
            local instasample_lab "Yes"
        }

        * Generate Interactions
        gen byte NoAI_x_NotIden_D0 = (NoAI_x_NotIden==1 & `moderator'==0)
        gen byte NoAI_x_NotIden_D1 = (NoAI_x_NotIden==1 & `moderator'==1)
        gen byte AI_x_NotIden_D0   = (AI_x_NotIden==1   & `moderator'==0)
        gen byte AI_x_NotIden_D1   = (AI_x_NotIden==1   & `moderator'==1)
        gen byte NoAI_x_Iden_D0    = (NoAI_x_Iden==1    & `moderator'==0)
        gen byte NoAI_x_Iden_D1    = (NoAI_x_Iden==1    & `moderator'==1)
        gen byte AI_x_Iden_D0      = (AI_x_Iden==1      & `moderator'==0)
        gen byte AI_x_Iden_D1      = (AI_x_Iden==1      & `moderator'==1)
        
        local eight_arms "AI_x_Iden_D1 AI_x_Iden_D0 NoAI_x_Iden_D1 NoAI_x_Iden_D0 AI_x_NotIden_D1 AI_x_NotIden_D0 NoAI_x_NotIden_D1 NoAI_x_NotIden_D0"

        * --- DEFINE VARIABLES TO REMOVE ---
        local VARS_TO_REMOVE ""

        if strpos("`moderator'", "Instagram_use") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' Instagram_use"
        }

        * Updated logic with all binary versions and factor syntax
        if strpos("`moderator'", "ImageConcern") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern i.ImageConcern ImageConcernBinary_p50 i.ImageConcernBinary_p50 ImageConcernBinary2 i.ImageConcernBinary2 ImageConcernBinary3 i.ImageConcernBinary3 ImageConcernBinary4 i.ImageConcernBinary4 index_Image_minus_privacy Image_minus_privacyBinary i.Image_minus_privacyBinary"
        }

        if strpos("`moderator'", "not_shared_handle") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' not_shared_handle index_Image_minus_privacy Image_minus_privacyBinary i.Image_minus_privacyBinary"
        }

        if strpos("`moderator'", "Image_minus_privacy") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern i.ImageConcern ImageConcernBinary_p50 i.ImageConcernBinary_p50 ImageConcernBinary2 i.ImageConcernBinary2 ImageConcernBinary3 i.ImageConcernBinary3 ImageConcernBinary4 i.ImageConcernBinary4 not_shared_handle index_Image_minus_privacy Image_minus_privacyBinary i.Image_minus_privacyBinary"
        }

        if strpos("`moderator'", "Donation") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' Donation DonationBinary_p50 i.DonationBinary_p50 DonationBinary_pos i.DonationBinary_pos"
        }

        quietly count
        local N_obs = r(N)
        local nice_N : display %9.0fc `N_obs'

        * --- REGRESSION 1: No Controls ---
        capture eststo est1_`samp': reghdfe `outcome' `eight_arms', vce(robust) nocons
        if _rc == 0 {
            estadd local instasample "`instasample_lab'"
            estadd local samplesize "`nice_N'"
            local models_to_tab "`models_to_tab' est1_`samp'"
        }

        * --- REGRESSION 2: Base Controls ---
        local base_controls "i.`imgconcern' not_shared_handle Instagram_use"
        if "`VARS_TO_REMOVE'" != "" {
            local base_controls : list base_controls - VARS_TO_REMOVE
        }   
        
        capture eststo est2_`samp': reghdfe `outcome' `eight_arms' `base_controls', vce(robust) nocons
        if _rc == 0 {
            estadd local instasample "`instasample_lab'"
            estadd local samplesize "`nice_N'"
            local models_to_tab "`models_to_tab' est2_`samp'"
        }

        * --- REGRESSION 3: Lasso Selection ---
        local lasso_cands "$LASSO_CANDIDATES"
        
        * FIX: Remove forbidden variables from candidates BEFORE Lasso
        * This ensures Lasso never selects '2.ImageConcern' if 'ImageConcern' is forbidden
        if "`VARS_TO_REMOVE'" != "" {
            local lasso_cands : list lasso_cands - VARS_TO_REMOVE
        }

        local controls_lasso_sel ""

        * Run Lasso (Logit or Linear)
        if (strpos("$OUTCOMES_BIN", "`outcome'") > 0) {
            capture quietly lasso logit `outcome' `lasso_cands', selection("cv")
            if _rc == 0 {
                local controls_lasso_sel "`e(allvars_sel)'"
            }
        }
        else {
            capture quietly lasso linear `outcome' `lasso_cands', selection("cv")
            if _rc == 0 {
                local controls_lasso_sel "`e(allvars_sel)'"
            }
        }
        
        * FIX: Smart logic for Forced Variables
        local vars_to_force "i.ImageConcern ImageConcern not_shared_handle Instagram_use"
        
        * 1. Remove forced vars from the Lasso result (to avoid duplicates)
        local controls_lasso_sel : list controls_lasso_sel - vars_to_force
        
        * 2. Remove forbidden vars from the forced list (so we don't add back what we don't want)
        if "`VARS_TO_REMOVE'" != "" {
            local vars_to_force : list vars_to_force - VARS_TO_REMOVE
        }

        * 3. Combine Lasso result with remaining forced variables
        local controls_lasso_sel "`controls_lasso_sel' `vars_to_force'"
        
        if `N_obs' > 10 {
            capture eststo est3_`samp': reghdfe `outcome' `eight_arms' `controls_lasso_sel', vce(robust) nocons
            if _rc == 0 {
                estadd local instasample "`instasample_lab'"
                estadd local samplesize "`nice_N'"
                estadd local controls "Lasso Controls", replace
                local models_to_tab "`models_to_tab' est3_`samp'"
            }
        }
        else {
            display "Not enough variation in the `outcome' under `samp'"
        }
        
        restore
    }

    * --- EXPORT TABLE ---
    capture mkdir "$output_folder/hte_with_interactions"
    capture mkdir "$output_folder/hte_with_interactions/sample2_20"
    
    if "`models_to_tab'" != "" {
        esttab `models_to_tab' using "$output_folder/hte_with_interactions/sample2_20/`outcome'_hte_by_`moderator'.tex", ///
            replace ///
            main(b %9.3f) aux(se %9.3f) ///
            starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
            keep(`ordered_vars' *) ///
            order(`ordered_vars') ///
            stats(r2_a instasample samplesize, labels("Adj. \(R^2\)" "Only Instagram Sample" "\(N\)")) ///
            nomtitles title("Regression of `outcome': HTE by `moderator'") nonotes ///
            booktabs compress width(\hsize) ///
            prehead(`"\documentclass{article}"' ///
                    `"\usepackage{booktabs}"' ///
                    `"\usepackage[paperheight=16in, paperwidth=9in, margin=0.5in]{geometry}"' ///
                    `"\begin{document}"' ///
                    `"\begin{table}[htbp]\centering"' ///
                    `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
                    `"\caption{@title}"' ///
                    `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                    `"\toprule"') ///
            postfoot(`"\bottomrule"' ///
                     `"\end{tabular*}"' ///
                     `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"' ///
                     `"Standard errors in parentheses. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$. \\ Reference group acts as the control group: NoAI x NotIden."' ///
                     `"\\ D0 indicates when the `moderator'==0 \\ D1 indicates when the `moderator'==1"' ///
                     `"\end{minipage}"' ///
                     `"\end{table}"' ///
                     `"\end{document}"')
    }
    else {
        display "No models were successfully estimated for `outcome' by `moderator'."
    }
    
    eststo clear
end

capture program drop table_hte_interactions_binary2
program define table_hte_interactions_binary2
    syntax, outcome(varname) moderator(varname) imgconcern(varname)

    * Initialize list to keep track of successful models
    local models_to_tab ""
    
    * Define the specific order for the table rows
    local ordered_vars "NoAI_x_NotIden_D0 NoAI_x_NotIden_D1 AI_x_NotIden_D0 AI_x_NotIden_D1 NoAI_x_Iden_D0 NoAI_x_Iden_D1 AI_x_Iden_D0 AI_x_Iden_D1"

    * Loop over the two samples
    foreach samp in sample2 sample20 {
        
        preserve
        
        keep if `samp' == 1
        keep if !missing(`outcome')
        
        * Define Instasample Label
        if "`samp'" == "sample2" {
            local instasample_lab "No"
        }
        else {
            local instasample_lab "Yes"
        }

        * Generate Interactions (D0/D1) - These are NOT standardized
        gen byte NoAI_x_NotIden_D0 = (NoAI_x_NotIden==1 & `moderator'==0)
        gen byte NoAI_x_NotIden_D1 = (NoAI_x_NotIden==1 & `moderator'==1)
        gen byte AI_x_NotIden_D0   = (AI_x_NotIden==1   & `moderator'==0)
        gen byte AI_x_NotIden_D1   = (AI_x_NotIden==1   & `moderator'==1)
        gen byte NoAI_x_Iden_D0    = (NoAI_x_Iden==1    & `moderator'==0)
        gen byte NoAI_x_Iden_D1    = (NoAI_x_Iden==1    & `moderator'==1)
        gen byte AI_x_Iden_D0      = (AI_x_Iden==1      & `moderator'==0)
        gen byte AI_x_Iden_D1      = (AI_x_Iden==1      & `moderator'==1)
        
        local eight_arms "AI_x_Iden_D1 AI_x_Iden_D0 NoAI_x_Iden_D1 NoAI_x_Iden_D0 AI_x_NotIden_D1 AI_x_NotIden_D0 NoAI_x_NotIden_D1 NoAI_x_NotIden_D0"

        * --- STANDARDIZATION LOOP ---
        * We build the lasso_cands list dynamically here based on what exists and has variation
        local lasso_cands_std "" 
        
        * We iterate over the NO_FACTOR list plus the specific base controls
        foreach v of varlist $LASSO_CANDIDATES_NO_FACTOR Instagram_use ImageConcern not_shared_handle index_Image_minus_privacy {
            capture drop `v'_N
            quietly summarize `v'
            * Create standardized version if SD is valid
            if r(sd) > 0 & r(sd) < . {
                gen `v'_N = (`v' - r(mean)) / r(sd)
                local lasso_cands_std "`lasso_cands_std' `v'_N"
            }
        }

        * --- DEFINE VARIABLES TO REMOVE (Standardized Versions) ---
        local VARS_TO_REMOVE ""

        if strpos("`moderator'", "Instagram_use") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' Instagram_use_N"
        }

        if strpos("`moderator'", "ImageConcern") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern_N index_Image_minus_privacy_N"
        }

        if strpos("`moderator'", "not_shared_handle") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' not_shared_handle_N index_Image_minus_privacy_N"
        }

        if strpos("`moderator'", "Image_minus_privacy") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern_N not_shared_handle_N index_Image_minus_privacy_N"
        }

        if strpos("`moderator'", "Donation") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' Donation_N"
        }

        quietly count
        local N_obs = r(N)
        local nice_N : display %9.0fc `N_obs'

        * --- REGRESSION 1: No Controls (Unchanged) ---
        capture eststo est1_`samp': reghdfe `outcome' `eight_arms', vce(robust) nocons
        if _rc == 0 {
            estadd local instasample "`instasample_lab'"
            estadd local samplesize "`nice_N'"
            local models_to_tab "`models_to_tab' est1_`samp'"
        }

        * --- REGRESSION 2: Base Controls (Standardized) ---
        * Note: We do NOT use 'i.' here because they are standardized continuous variables now
        local base_controls "ImageConcern_N not_shared_handle_N Instagram_use_N"
        
        if "`VARS_TO_REMOVE'" != "" {
            local base_controls : list base_controls - VARS_TO_REMOVE
        }   
        
        capture eststo est2_`samp': reghdfe `outcome' `eight_arms' `base_controls', vce(robust) nocons
        if _rc == 0 {
            estadd local instasample "`instasample_lab'"
            estadd local samplesize "`nice_N'"
            local models_to_tab "`models_to_tab' est2_`samp'"
        }

        * --- REGRESSION 3: Lasso Selection (Standardized) ---
        
        * 1. Start with the dynamically built list of standardized vars
        local current_lasso_cands "`lasso_cands_std'"

        * 2. Remove Forbidden variables BEFORE Lasso
        if "`VARS_TO_REMOVE'" != "" {
            local current_lasso_cands : list current_lasso_cands - VARS_TO_REMOVE
        }

        local controls_lasso_sel ""

        * Run Lasso 
        if (strpos("$OUTCOMES_BIN", "`outcome'") > 0) {
            capture quietly lasso logit `outcome' `current_lasso_cands', selection("cv")
            if _rc == 0 {
                local controls_lasso_sel "`e(allvars_sel)'"
            }
        }
        else {
            capture quietly lasso linear `outcome' `current_lasso_cands', selection("cv")
            if _rc == 0 {
                local controls_lasso_sel "`e(allvars_sel)'"
            }
        }
        
        * --- Force Inclusion Logic (Standardized) ---
        local vars_to_force "ImageConcern_N not_shared_handle_N Instagram_use_N"
        
        * Remove duplicates (forced vars that Lasso already picked)
        local controls_lasso_sel : list controls_lasso_sel - vars_to_force
        
        * Remove forbidden vars from the forced list
        if "`VARS_TO_REMOVE'" != "" {
            local vars_to_force : list vars_to_force - VARS_TO_REMOVE
        }

        * Combine
        local controls_lasso_sel "`controls_lasso_sel' `vars_to_force'"

        if `N_obs' > 10 {
            capture eststo est3_`samp': reghdfe `outcome' `eight_arms' `controls_lasso_sel', vce(robust) nocons
            if _rc == 0 {
                estadd local instasample "`instasample_lab'"
                estadd local samplesize "`nice_N'"
                estadd local controls "Lasso Controls (Std)", replace
                local models_to_tab "`models_to_tab' est3_`samp'"
            }
        }
        else {
            display "Not enough variation in the `outcome' under `samp'"
        }
        
        restore
    }

    * --- EXPORT TABLE ---
    capture mkdir "$output_folder/hte_with_interactions"
    capture mkdir "$output_folder/hte_with_interactions/sample2_20"
    
    if "`models_to_tab'" != "" {
        * Updated filename to include _standardized
        esttab `models_to_tab' using "$output_folder/hte_with_interactions/sample2_20/`outcome'_hte_by_`moderator'_standardized.tex", ///
            replace ///
            main(b %9.3f) aux(se %9.3f) ///
            starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
            keep(`ordered_vars' *) ///
            order(`ordered_vars') ///
            stats(r2_a instasample samplesize, labels("Adj. \(R^2\)" "Only Instagram Sample" "\(N\)")) ///
            nomtitles title("Regression of `outcome' (Standardized Controls): HTE by `moderator'") nonotes ///
            booktabs compress width(\hsize) ///
            prehead(`"\documentclass{article}"' ///
                    `"\usepackage{booktabs}"' ///
                    `"\usepackage[paperheight=16in, paperwidth=9in, margin=0.5in]{geometry}"' ///
                    `"\begin{document}"' ///
                    `"\begin{table}[htbp]\centering"' ///
                    `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
                    `"\caption{@title}"' ///
                    `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                    `"\toprule"') ///
            postfoot(`"\bottomrule"' ///
                     `"\end{tabular*}"' ///
                     `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"' ///
                     `"Standard errors in parentheses. All control variables are standardized. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$. \\ Reference group acts as the control group: NoAI x NotIden."' ///
                     `"\\ D0 indicates when the `moderator'==0 \\ D1 indicates when the `moderator'==1"' ///
                     `"\end{minipage}"' ///
                     `"\end{table}"' ///
                     `"\end{document}"')
    }
    else {
        display "No models were successfully estimated for `outcome' by `moderator'."
    }
    
    eststo clear
end

capture program drop table_hte_interactions_binary3
program define table_hte_interactions_binary3
    syntax, outcome(varname) moderator(varname) imgconcern(varname)

    * Initialize list to keep track of successful models
    local models_to_tab ""
    
    * Define the specific order for the table rows
    local ordered_vars "NoAI_x_NotIden_D0 NoAI_x_NotIden_D1 AI_x_NotIden_D0 AI_x_NotIden_D1 NoAI_x_Iden_D0 NoAI_x_Iden_D1 AI_x_Iden_D0 AI_x_Iden_D1"

    * Loop over the three samples: sample5, sample8, sample80
    foreach samp in sample5 sample8 sample80 {
        
        preserve
        
        keep if `samp' == 1
        keep if !missing(`outcome')
        
        * Define Sample Label for the table footer
        if "`samp'" == "sample5" {
            local sample_lab "Sample 5"
        }
        else if "`samp'" == "sample8" {
            local sample_lab "Sample 8"
        }
        else {
            local sample_lab "Sample 80"
        }

        * Generate Interactions (D0/D1)
        gen byte NoAI_x_NotIden_D0 = (NoAI_x_NotIden==1 & `moderator'==0)
        gen byte NoAI_x_NotIden_D1 = (NoAI_x_NotIden==1 & `moderator'==1)
        gen byte AI_x_NotIden_D0   = (AI_x_NotIden==1   & `moderator'==0)
        gen byte AI_x_NotIden_D1   = (AI_x_NotIden==1   & `moderator'==1)
        gen byte NoAI_x_Iden_D0    = (NoAI_x_Iden==1    & `moderator'==0)
        gen byte NoAI_x_Iden_D1    = (NoAI_x_Iden==1    & `moderator'==1)
        gen byte AI_x_Iden_D0      = (AI_x_Iden==1      & `moderator'==0)
        gen byte AI_x_Iden_D1      = (AI_x_Iden==1      & `moderator'==1)
        
        local eight_arms "AI_x_Iden_D1 AI_x_Iden_D0 NoAI_x_Iden_D1 NoAI_x_Iden_D0 AI_x_NotIden_D1 AI_x_NotIden_D0 NoAI_x_NotIden_D1 NoAI_x_NotIden_D0"

        * --- DEFINE VARIABLES TO REMOVE (Unstandardized Logic) ---
        local VARS_TO_REMOVE ""

        if strpos("`moderator'", "Instagram_use") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' Instagram_use"
        }

        * Logic with all binary versions and factor syntax
        if strpos("`moderator'", "ImageConcern") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern i.ImageConcern ImageConcernBinary_p50 i.ImageConcernBinary_p50 ImageConcernBinary2 i.ImageConcernBinary2 ImageConcernBinary3 i.ImageConcernBinary3 ImageConcernBinary4 i.ImageConcernBinary4 index_Image_minus_privacy Image_minus_privacyBinary i.Image_minus_privacyBinary"
        }

        if strpos("`moderator'", "not_shared_handle") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' not_shared_handle index_Image_minus_privacy Image_minus_privacyBinary i.Image_minus_privacyBinary"
        }

        if strpos("`moderator'", "Image_minus_privacy") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern i.ImageConcern ImageConcernBinary_p50 i.ImageConcernBinary_p50 ImageConcernBinary2 i.ImageConcernBinary2 ImageConcernBinary3 i.ImageConcernBinary3 ImageConcernBinary4 i.ImageConcernBinary4 not_shared_handle index_Image_minus_privacy Image_minus_privacyBinary i.Image_minus_privacyBinary"
        }

        if strpos("`moderator'", "Donation") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' Donation DonationBinary_p50 i.DonationBinary_p50 DonationBinary_pos i.DonationBinary_pos"
        }

        quietly count
        local N_obs = r(N)
        local nice_N : display %9.0fc `N_obs'

        * --- REGRESSION 1: No Controls ---
        capture eststo est1_`samp': reghdfe `outcome' `eight_arms', vce(robust) nocons
        if _rc == 0 {
            estadd local sample_label "`sample_lab'"
            estadd local samplesize "`nice_N'"
            local models_to_tab "`models_to_tab' est1_`samp'"
        }

        * --- REGRESSION 2: Base Controls (Unstandardized) ---
        local base_controls "i.`imgconcern' not_shared_handle Instagram_use"
        
        if "`VARS_TO_REMOVE'" != "" {
            local base_controls : list base_controls - VARS_TO_REMOVE
        }   
        
        capture eststo est2_`samp': reghdfe `outcome' `eight_arms' `base_controls', vce(robust) nocons
        if _rc == 0 {
            estadd local sample_label "`sample_lab'"
            estadd local samplesize "`nice_N'"
            local models_to_tab "`models_to_tab' est2_`samp'"
        }

        * --- REGRESSION 3: Lasso Selection (Unstandardized) ---
        local lasso_cands "$LASSO_CANDIDATES"
        
        * FIX: Remove forbidden variables from candidates BEFORE Lasso
        if "`VARS_TO_REMOVE'" != "" {
            local lasso_cands : list lasso_cands - VARS_TO_REMOVE
        }

        local controls_lasso_sel ""

        * Run Lasso (Logit or Linear)
        if (strpos("$OUTCOMES_BIN", "`outcome'") > 0) {
            capture quietly lasso logit `outcome' `lasso_cands', selection("cv")
            if _rc == 0 {
                local controls_lasso_sel "`e(allvars_sel)'"
            }
        }
        else {
            capture quietly lasso linear `outcome' `lasso_cands', selection("cv")
            if _rc == 0 {
                local controls_lasso_sel "`e(allvars_sel)'"
            }
        }
        
        * FIX: Smart logic for Forced Variables
        local vars_to_force "i.ImageConcern ImageConcern not_shared_handle Instagram_use"
        
        * 1. Remove forced vars from the Lasso result (to avoid duplicates)
        local controls_lasso_sel : list controls_lasso_sel - vars_to_force
        
        * 2. Remove forbidden vars from the forced list (so we don't add back what we don't want)
        if "`VARS_TO_REMOVE'" != "" {
            local vars_to_force : list vars_to_force - VARS_TO_REMOVE
        }

        * 3. Combine Lasso result with remaining forced variables
        local controls_lasso_sel "`controls_lasso_sel' `vars_to_force'"
        
        if `N_obs' > 10 {
            capture eststo est3_`samp': reghdfe `outcome' `eight_arms' `controls_lasso_sel', vce(robust) nocons
            if _rc == 0 {
                estadd local sample_label "`sample_lab'"
                estadd local samplesize "`nice_N'"
                estadd local controls "Lasso Controls", replace
                local models_to_tab "`models_to_tab' est3_`samp'"
            }
        }
        else {
            display "Not enough variation in the `outcome' under `samp'"
        }
        
        restore
    }

    * --- EXPORT TABLE ---
    capture mkdir "$output_folder/hte_with_interactions"
    capture mkdir "$output_folder/hte_with_interactions/sample5_8_80"
    
    if "`models_to_tab'" != "" {
        esttab `models_to_tab' using "$output_folder/hte_with_interactions/sample5_8_80/`outcome'_hte_by_`moderator'.tex", ///
            replace ///
            main(b %9.3f) aux(se %9.3f) ///
            starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
            keep(`ordered_vars' *) ///
            order(`ordered_vars') ///
            stats(r2_a sample_label samplesize, labels("Adj. \(R^2\)" "Sample" "\(N\)")) ///
            nomtitles title("Regression of `outcome': HTE by `moderator'") nonotes ///
            booktabs compress width(\hsize) ///
            prehead(`"\documentclass{article}"' ///
                    `"\usepackage{booktabs}"' ///
                    `"\usepackage[paperheight=16in, paperwidth=12in, margin=0.5in]{geometry}"' ///
                    `"\begin{document}"' ///
                    `"\begin{table}[htbp]\centering"' ///
                    `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
                    `"\caption{@title}"' ///
                    `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                    `"\toprule"') ///
            postfoot(`"\bottomrule"' ///
                     `"\end{tabular*}"' ///
                     `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"' ///
                     `"Standard errors in parentheses. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$. \\ Reference group acts as the control group: NoAI x NotIden."' ///
                     `"\\ D0 indicates when the `moderator'==0 \\ D1 indicates when the `moderator'==1"' ///
                     `"\end{minipage}"' ///
                     `"\end{table}"' ///
                     `"\end{document}"')
    }
    else {
        display "No models were successfully estimated for `outcome' by `moderator'."
    }
    
    eststo clear
end

capture program drop table_hte_interactions_binary4
program define table_hte_interactions_binary4
    syntax, outcome(varname) moderator(varname) imgconcern(varname)

    * Initialize list to keep track of successful models
    local models_to_tab ""
    
    * Define the specific order for the table rows
    local ordered_vars "NoAI_x_NotIden_D0 NoAI_x_NotIden_D1 AI_x_NotIden_D0 AI_x_NotIden_D1 NoAI_x_Iden_D0 NoAI_x_Iden_D1 AI_x_Iden_D0 AI_x_Iden_D1"

    * Loop over the three samples: sample5, sample8, sample80
    foreach samp in sample5 sample8 sample80 {
        
        preserve
        
        keep if `samp' == 1
        keep if !missing(`outcome')
        
        * Define Sample Label for the table footer
        if "`samp'" == "sample5" {
            local sample_lab "Sample 5"
        }
        else if "`samp'" == "sample8" {
            local sample_lab "Sample 8"
        }
        else {
            local sample_lab "Sample 80"
        }

        * Generate Interactions (D0/D1)
        gen byte NoAI_x_NotIden_D0 = (NoAI_x_NotIden==1 & `moderator'==0)
        gen byte NoAI_x_NotIden_D1 = (NoAI_x_NotIden==1 & `moderator'==1)
        gen byte AI_x_NotIden_D0   = (AI_x_NotIden==1   & `moderator'==0)
        gen byte AI_x_NotIden_D1   = (AI_x_NotIden==1   & `moderator'==1)
        gen byte NoAI_x_Iden_D0    = (NoAI_x_Iden==1    & `moderator'==0)
        gen byte NoAI_x_Iden_D1    = (NoAI_x_Iden==1    & `moderator'==1)
        gen byte AI_x_Iden_D0      = (AI_x_Iden==1      & `moderator'==0)
        gen byte AI_x_Iden_D1      = (AI_x_Iden==1      & `moderator'==1)
        
        local eight_arms "AI_x_Iden_D1 AI_x_Iden_D0 NoAI_x_Iden_D1 NoAI_x_Iden_D0 AI_x_NotIden_D1 AI_x_NotIden_D0 NoAI_x_NotIden_D1 NoAI_x_NotIden_D0"

        * --- STANDARDIZATION LOOP ---
        local lasso_cands_std "" 
        
        foreach v of varlist $LASSO_CANDIDATES_NO_FACTOR Instagram_use ImageConcern not_shared_handle index_Image_minus_privacy {
            capture drop `v'_N
            quietly summarize `v'
            if r(sd) > 0 & r(sd) < . {
                gen `v'_N = (`v' - r(mean)) / r(sd)
                local lasso_cands_std "`lasso_cands_std' `v'_N"
            }
        }

        * --- DEFINE VARIABLES TO REMOVE (Standardized Versions) ---
        local VARS_TO_REMOVE ""

        if strpos("`moderator'", "Instagram_use") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' Instagram_use_N"
        }

        if strpos("`moderator'", "ImageConcern") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern_N index_Image_minus_privacy_N"
        }

        if strpos("`moderator'", "not_shared_handle") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' not_shared_handle_N index_Image_minus_privacy_N"
        }

        if strpos("`moderator'", "Image_minus_privacy") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern_N not_shared_handle_N index_Image_minus_privacy_N"
        }

        if strpos("`moderator'", "Donation") > 0 {
            local VARS_TO_REMOVE "`VARS_TO_REMOVE' Donation_N"
        }

        quietly count
        local N_obs = r(N)
        local nice_N : display %9.0fc `N_obs'

        * --- REGRESSION 1: No Controls ---
        capture eststo est1_`samp': reghdfe `outcome' `eight_arms', vce(robust) nocons
        if _rc == 0 {
            estadd local sample_label "`sample_lab'"
            estadd local samplesize "`nice_N'"
            local models_to_tab "`models_to_tab' est1_`samp'"
        }

        * --- REGRESSION 2: Base Controls (Standardized) ---
        local base_controls "ImageConcern_N not_shared_handle_N Instagram_use_N"
        
        if "`VARS_TO_REMOVE'" != "" {
            local base_controls : list base_controls - VARS_TO_REMOVE
        }   
        
        capture eststo est2_`samp': reghdfe `outcome' `eight_arms' `base_controls', vce(robust) nocons
        if _rc == 0 {
            estadd local sample_label "`sample_lab'"
            estadd local samplesize "`nice_N'"
            local models_to_tab "`models_to_tab' est2_`samp'"
        }

        * --- REGRESSION 3: Lasso Selection (Standardized) ---
        local current_lasso_cands "`lasso_cands_std'"

        if "`VARS_TO_REMOVE'" != "" {
            local current_lasso_cands : list current_lasso_cands - VARS_TO_REMOVE
        }

        local controls_lasso_sel ""

        if (strpos("$OUTCOMES_BIN", "`outcome'") > 0) {
            capture quietly lasso logit `outcome' `current_lasso_cands', selection("cv")
            if _rc == 0 {
                local controls_lasso_sel "`e(allvars_sel)'"
            }
        }
        else {
            capture quietly lasso linear `outcome' `current_lasso_cands', selection("cv")
            if _rc == 0 {
                local controls_lasso_sel "`e(allvars_sel)'"
            }
        }
        
        * --- Force Inclusion Logic (Standardized) ---
        local vars_to_force "ImageConcern_N not_shared_handle_N Instagram_use_N"
        
        local controls_lasso_sel : list controls_lasso_sel - vars_to_force
        
        if "`VARS_TO_REMOVE'" != "" {
            local vars_to_force : list vars_to_force - VARS_TO_REMOVE
        }

        local controls_lasso_sel "`controls_lasso_sel' `vars_to_force'"

        if `N_obs' > 10 {
            capture eststo est3_`samp': reghdfe `outcome' `eight_arms' `controls_lasso_sel', vce(robust) nocons
            if _rc == 0 {
                estadd local sample_label "`sample_lab'"
                estadd local samplesize "`nice_N'"
                estadd local controls "Lasso Controls (Std)", replace
                local models_to_tab "`models_to_tab' est3_`samp'"
            }
        }
        else {
            display "Not enough variation in the `outcome' under `samp'"
        }
        
        restore
    }

    * --- EXPORT TABLE ---
    capture mkdir "$output_folder/hte_with_interactions"
    capture mkdir "$output_folder/hte_with_interactions/sample5_8_80"
    
    if "`models_to_tab'" != "" {
        esttab `models_to_tab' using "$output_folder/hte_with_interactions/sample5_8_80/`outcome'_hte_by_`moderator'_standardized.tex", ///
            replace ///
            main(b %9.3f) aux(se %9.3f) ///
            starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
            keep(`ordered_vars' *) ///
            order(`ordered_vars') ///
            stats(r2_a sample_label samplesize, labels("Adj. \(R^2\)" "Sample" "\(N\)")) ///
            nomtitles title("Regression of `outcome' (Standardized Controls): HTE by `moderator'") nonotes ///
            booktabs compress width(\hsize) ///
            prehead(`"\documentclass{article}"' ///
                    `"\usepackage{booktabs}"' ///
                    `"\usepackage[paperheight=16in, paperwidth=12in, margin=0.5in]{geometry}"' ///
                    `"\begin{document}"' ///
                    `"\begin{table}[htbp]\centering"' ///
                    `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
                    `"\caption{@title}"' ///
                    `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                    `"\toprule"') ///
            postfoot(`"\bottomrule"' ///
                     `"\end{tabular*}"' ///
                     `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"' ///
                     `"Standard errors in parentheses. All control variables are standardized. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$. \\ Reference group acts as the control group: NoAI x NotIden."' ///
                     `"\\ D0 indicates when the `moderator'==0 \\ D1 indicates when the `moderator'==1"' ///
                     `"\end{minipage}"' ///
                     `"\end{table}"' ///
                     `"\end{document}"')
    }
    else {
        display "No models were successfully estimated for `outcome' by `moderator'."
    }
    
    eststo clear
end
*/

/*
* ====================================================================================================
* HTE with interaction binary moderators
* ====================================================================================================

** Divide the sample by the moderator, 2 sets of regressions.
* 1)
* 2)
* 3)
* 4)
* ====================================================================================================
foreach x in $HTE_MODERATORS_BINARY $HTE_MODERATORS_CONTINUOUS {
    capture confirm variable `x'
    if _rc == 0 {
        local newname "AITreat_x_`x'"
        if strlen("`newname'") > 32 {
            local newname = substr("`newname'", 1, 32)
        }
        capture drop `newname' 
        gen `newname' = AITreat * `x'
    }
    else {
        display as error "Warning: Moderator `x' not found in dataset."
    }
}


capture program drop table_interactions_continuous
program define table_interactions_continuous
    syntax, outcome(varname) sample(numlist) moderator(varname) controls(varlist) lasso_cands(varlist)

    preserve
    keep if sample`sample' == 1
    
    * Define Intercepts & Slopes
    gen byte Int_NoAI_NotIden = NoAI_x_NotIden
    gen byte Int_AI_NotIden   = AI_x_NotIden
    gen byte Int_NoAI_Iden    = NoAI_x_Iden
    gen byte Int_AI_Iden      = AI_x_Iden
    
    gen float Slope_NoAI_NotIden = NoAI_x_NotIden * `moderator'
    gen float Slope_AI_NotIden   = AI_x_NotIden   * `moderator'
    gen float Slope_NoAI_Iden    = NoAI_x_Iden    * `moderator'
    gen float Slope_AI_Iden      = AI_x_Iden      * `moderator'
    
    local model_vars "Int_* Slope_*"

    eststo clear
    
    * Col 1
    eststo: reghdfe `outcome' `model_vars', vce(robust) nocons
    estadd local controls "None"

    * Col 2 (Using Sanitized Controls)
    eststo: reghdfe `outcome' `model_vars' `controls', vce(robust) nocons
    estadd local controls "All Controls"

    * Col 3 (Using Sanitized Lasso Candidates)
    qui inspect `outcome'
    local lasso_cmd "lasso linear"
    if r(N_unique) == 2 local lasso_cmd "lasso logit"
    
    capture `lasso_cmd' `outcome' `lasso_cands', selection(cv) rseed(2025)
    if _rc == 0 {
        local selected `e(allvars_sel)'
        eststo: reghdfe `outcome' `model_vars' `selected', vce(robust) nocons
        estadd local controls "Lasso"
    }
    else {
        eststo: reghdfe `outcome' `model_vars', vce(robust) nocons
        estadd local controls "Lasso Failed"
    }

    capture mkdir "$output_folder\hte_with_interactions"
    capture mkdir "$output_folder\hte_with_interactions\sample`sample'"
    capture mkdir "$output_folder\hte_with_interactions\sample`sample'\tables"
	
    esttab using "$output_folder/hte_with_interactions/sample`sample'/tables/hte_continuous_`outcome'_by_`moderator'.tex", ///
        replace booktabs compress label title("HTE Continuous: `outcome' by `moderator'") ///
        scalars("controls Controls") star(* 0.10 ** 0.05 *** 0.01)

    restore
end





* ------------------------------------------------------------------------------
* OLD EXECUTION LOOP
* ------------------------------------------------------------------------------
foreach s of local RUN_SAMPLES {
    
    display "Processing Sample `s'..."
    local ALL_OUTCOMES "$OUTCOMES $GPT_OUTCOMES"
    
    foreach y of local ALL_OUTCOMES {
        
        * 1. Binary HTEs
        foreach mod of global HTE_MODERATORS_BINARY {
            
            capture confirm variable `mod'
            if _rc == 0 {
                
                * --- CONTROLS SANITIZER ---
                local CURRENT_CONTROLS "$CONTROLS"
                local CURRENT_LASSO    "$LASSO_CANDIDATES"
                local VARS_TO_REMOVE   ""

                * Logic A: Image Concern Related
                if strpos("`mod'", "ImageConcern") > 0 {
                    local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern"
                }

                * Logic B: Donation Related
                if strpos("`mod'", "Donation") > 0 {
                    local VARS_TO_REMOVE "`VARS_TO_REMOVE' Donation"
                }

                * Logic C: Privacy / Index Related (Image - Privacy)
                if strpos("`mod'", "Image_minus_privacy") > 0 {
                    local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern not_shared_handle index_Image_minus_privacy"
                }

                * Logic D: Shared Handle
                if "`mod'" == "not_shared_handle" {
                    local VARS_TO_REMOVE "`VARS_TO_REMOVE' not_shared_handle index_Image_minus_privacy"
                }

                * Logic E: Climate Index
                if "`mod'" == "index_Climate" {
                     local VARS_TO_REMOVE "`VARS_TO_REMOVE' index_Climate"
                }
                
                * APPLY REMOVAL
                if "`VARS_TO_REMOVE'" != "" {
                    local CURRENT_CONTROLS : list CURRENT_CONTROLS - VARS_TO_REMOVE
                    local CURRENT_LASSO    : list CURRENT_LASSO    - VARS_TO_REMOVE
                }

                ciplot_interactions_binary, outcome(`y') sample(`s') moderator(`mod') controls(`CURRENT_CONTROLS') lasso_cands(`CURRENT_LASSO')
                table_interactions_binary, outcome(`y') sample(`s') moderator(`mod') controls(`CURRENT_CONTROLS') lasso_cands(`CURRENT_LASSO')
            }
        }
        
        * 2. Continuous HTEs
        foreach mod of global HTE_MODERATORS_CONTINUOUS {
            
            capture confirm variable `mod'
            if _rc == 0 {
                
                * --- CONTROLS SANITIZER (Repeat Logic) ---
                local CURRENT_CONTROLS "$CONTROLS"
                local CURRENT_LASSO    "$LASSO_CANDIDATES"
                local VARS_TO_REMOVE   ""

                if strpos("`mod'", "ImageConcern") > 0 {
                    local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern"
                }
                if strpos("`mod'", "Donation") > 0 {
                    local VARS_TO_REMOVE "`VARS_TO_REMOVE' Donation"
                }
                if strpos("`mod'", "Image_minus_privacy") > 0 {
                    local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern not_shared_handle index_Image_minus_privacy"
                }
                if "`mod'" == "not_shared_handle" {
                    local VARS_TO_REMOVE "`VARS_TO_REMOVE' not_shared_handle index_Image_minus_privacy"
                }
                if "`mod'" == "index_Climate" {
                     local VARS_TO_REMOVE "`VARS_TO_REMOVE' index_Climate"
                }

                * APPLY REMOVAL
                if "`VARS_TO_REMOVE'" != "" {
                    local CURRENT_CONTROLS : list CURRENT_CONTROLS - VARS_TO_REMOVE
                    local CURRENT_LASSO    : list CURRENT_LASSO    - VARS_TO_REMOVE
                }

                table_interactions_continuous, outcome(`y') sample(`s') moderator(`mod') controls(`CURRENT_CONTROLS') lasso_cands(`CURRENT_LASSO')
            }
        }
    }
}
*/

********************************
**** 		Archive	 		****
********************************
/*
cap program drop ciplot_4treat_pvalue_coeff0
program define ciplot_4treat_pvalue_coeff0
    version 17.0

    syntax, outcome(varname) sample_number(integer) ///
        [ if_condition(string) ///
          filetag(string) ///
          title(string) ///
          xtitle(string) ///
          ytitle(string) ///
          lasso_select(string) ///
          vce(string) ]

    // -----------------------------
    // 1) Defaults
    // -----------------------------
    local cond "`if_condition'"
    if "`cond'" == "" local cond "if `outcome' < ."

    // Make a clean condition (strip leading "if ")
    local cond_clean "`cond'"
    local cond_clean : subinstr local cond_clean "if " "", all

    if "`filetag'" == "" local filetag "`outcome'_coef_ciplot"
    if "`title'"   == "" local title ""
    if "`xtitle'"  == "" local xtitle "Treatment Group (Co-sender Composition × AI Presence)"
    if "`ytitle'"  == "" local ytitle "Coefficients"
    if "`lasso_select'" == "" local lasso_select "plugin"
    if "`vce'" == "" local vce "robust"

    // Output directory
    capture mkdir "$output_folder/post_ciplots"
    local outdir "$output_folder/post_ciplots/sample`sample_number'"
    capture mkdir "`outdir'"


    // -----------------------------
    // 2) Sample sizes per arm
    // -----------------------------
    forvalues i = 1/4 {
        quietly count if Treatment_Group==`i' & `cond_clean'
        local n`i' = r(N)
    }

    // -----------------------------
    // 3) Determine outcome type
    // -----------------------------
    local is_bin  = 0
    local is_cont = 0
    if strpos(" $OUTCOMES_BIN ",  " `outcome' ") > 0 local is_bin  = 1
    if strpos(" $OUTCOMES_CONT ", " `outcome' ") > 0 local is_cont = 1

    if (`is_bin'==0 & `is_cont'==0) {
        // Default to continuous if unknown
        local is_cont = 1
    }

    // -----------------------------
    // 4) Lasso to select controls
    // -----------------------------
    local cand "$LASSO_CANDIDATES"
    local controls_sel ""

    if trim("`cand'") != "" {
        quietly count if `cond_clean'
        if r(N) >= 10 {
            if `is_bin' {
                quietly tab `outcome' if `cond_clean', missing
                if r(r) >= 2 {
                    capture noisily lasso logit `outcome' `cand' if `cond_clean', selection(`lasso_select')
                    if !_rc local controls_sel "`e(allvars_sel)'"
                }
            }
            else {
                capture noisily lasso linear `outcome' `cand' if `cond_clean', selection(`lasso_select')
                if !_rc local controls_sel "`e(allvars_sel)'"
            }
        }
    }

    // -----------------------------
    // 5) Final regression
    // -----------------------------
    quietly regress `outcome' ///
        NoAI_x_NotIden AI_x_NotIden NoAI_x_Iden AI_x_Iden ///
        `controls_sel' ///
        if `cond_clean', nocons vce(`vce')

    quietly test AI_x_NotIden = NoAI_x_NotIden
    local p12_str : di %6.3f r(p)

    quietly test AI_x_Iden = NoAI_x_Iden
    local p34_str : di %6.3f r(p)

    // -----------------------------
    // 6) Build plotting dataset
    // -----------------------------
    preserve
        clear
        set obs 4
        gen Treatment_Group = _n
        gen beta = .
        gen se   = .

        local arms "NoAI_x_NotIden AI_x_NotIden NoAI_x_Iden AI_x_Iden"
        forvalues i=1/4 {
            local a : word `i' of `arms'
            replace beta = _b[`a'] in `i'
            replace se   = _se[`a'] in `i'
        }

        gen ci_lo = beta - 1.96*se
        gen ci_hi = beta + 1.96*se

        quietly summ ci_hi, meanonly
        local max_val = r(max)
        quietly summ ci_lo, meanonly
        local min_val = r(min)
        local range = `max_val' - `min_val'
        if `range' == 0 local range = 1

        local ybottom = `min_val' - (`range' * 0.25)
        local ytop    = `max_val' + (`range' * 0.25)
        local box_y   = `ybottom' + (`range' * 0.10)
        local box_x   = 0.7
        local c1 "navy"
        local c2 "maroon"

        twoway ///
            (rcap ci_hi ci_lo Treatment_Group if Treatment_Group<=2, lcolor(`c1') lwidth(medthin)) ///
            (scatter beta Treatment_Group if Treatment_Group<=2, msymbol(Dh) msize(small) mcolor(none) mlcolor(`c1')) ///
            (rcap ci_hi ci_lo Treatment_Group if Treatment_Group> 2, lcolor(`c2') lwidth(medthin)) ///
            (scatter beta Treatment_Group if Treatment_Group> 2, msymbol(Dh) msize(small) mcolor(none) mlcolor(`c2')) ///
            (scatter beta Treatment_Group if 1==0, msymbol(Dh) msize(small) mcolor(none) mlcolor(black)) ///
            (rcap ci_hi ci_lo Treatment_Group if 1==0, lcolor(black) lwidth(medthin)), ///
            xlabel(1 `""No AI, Not identified" "(n=`n1')""' ///
                   2 `""AI, Not identified" "(n=`n2')""' ///
                   3 `""No AI, Identified" "(n=`n3')""' ///
                   4 `""AI, Identified" "(n=`n4')""', labsize(medsmall)) ///
            xscale(range(0.5 4.5)) ///
            yscale(range(`ybottom' `ytop')) ///
            xtitle("`xtitle'", size(small)) ///
            ytitle("`ytitle'", size(medsmall)) ///
            title("`title'", size(medsmall)) ///
            text(`box_y' `box_x' "P-Value (No AI vs AI | Not Identified) = `p12_str'" " " " ", ///
                 place(ne) margin(small) size(vsmall) justification(left) color(`c1')) ///
            text(`box_y' `box_x' " " " " "P-Value (No AI vs AI | Identified) = `p34_str'", ///
                 place(ne) margin(small) size(vsmall) justification(left) color(`c2')) ///
            legend(order(5 6) label(6 "95% Confidence Interval") label(5 "Mean") ///
                   cols(1) ring(0) pos(1) size(vsmall)) ///
            graphregion(color(white) margin(medium)) ///
            plotregion(margin(zero)) ///
            name(ci_4treat_coef, replace)

        graph export "`outdir'/`filetag'.pdf", replace
        graph drop ci_4treat_coef
    restore
end

cap program drop ciplot_4treat_pval_fwl_resid0
program define ciplot_4treat_pval_fwl_resid0
    version 17.0

    syntax, outcome(varname) sample_number(integer) ///
        [ if_condition(string) ///
          filetag(string) ///
          title(string) ///
          xtitle(string) ///
          ytitle(string) ///
          lasso_select(string) ///
          vce(string) ]

    // -----------------------------
    // 0) Defaults
    // -----------------------------
    local cond "`if_condition'"
    if "`cond'" == "" local cond "if `outcome' < ."

    // Clean condition
    local cond_clean "`cond'"
    local cond_clean : subinstr local cond_clean "if " "", all

    if "`filetag'" == "" local filetag "`outcome'_fwl_plot"
    if "`title'"   == "" local title ""
    if "`xtitle'"  == "" local xtitle "Treatment Group (Co-sender Composition × AI Presence)"
    if "`ytitle'"  == "" local ytitle "FWL Residualized Estimates"
    if "`lasso_select'" == "" local lasso_select "plugin"
    if "`vce'" == "" local vce "robust"

    // Output directory
    capture mkdir "$output_folder/post_ciplots_residualized"
    local outdir "$output_folder/post_ciplots_residualized/sample`sample_number'"
    capture mkdir "`outdir'"

    // -----------------------------
    // 1) Get Sample Sizes (for X-axis labels)
    // -----------------------------
    forvalues i = 1/4 {
        quietly count if Treatment_Group==`i' & `cond_clean'
        local n`i' = r(N)
    }

    // -----------------------------
    // 2) Lasso Control Selection
    // -----------------------------
    local is_bin  = 0
    if strpos(" $OUTCOMES_BIN ",  " `outcome' ") > 0 local is_bin  = 1
    
    local cand "$$CONTROLS $GPT_CONTROLS"
    local controls_sel ""

    if trim("`cand'") != "" {
        quietly count if `cond_clean'
        if r(N) >= 10 {
            if `is_bin' {
                quietly tab `outcome' if `cond_clean' & !missing(`outcome')
                if r(r) == 2 {
                    capture noisily lasso logit `outcome' `cand' if `cond_clean' & !missing(`outcome'), selection(`lasso_select')
                    if !_rc local controls_sel "`e(allvars_sel)'"
                }
            }
            else {
                capture noisily lasso linear `outcome' `cand' if `cond_clean', selection(`lasso_select')
                if !_rc local controls_sel "`e(allvars_sel)'"
            }
        }
    }

    // -----------------------------
    // 3) FRISCH-WAUGH-LOVELL (FWL) PROCEDURE
    // -----------------------------
    // We explicitly calculate residuals to demonstrate the math.
    
    tempvar r_outcome r_t1 r_t2 r_t3 r_t4
    
    if "`controls_sel'" != "" {
        // A. Residualize Outcome: Regress Y on Controls -> Get Residuals
        quietly regress `outcome' `controls_sel' if `cond_clean'
        quietly predict double `r_outcome' if e(sample), resid
        
        // B. Residualize Treatments: Regress each Dummy on Controls -> Get Residuals
        // Note: We process the 4 exhaustive dummies
        local treatments "NoAI_x_NotIden AI_x_NotIden NoAI_x_Iden AI_x_Iden"
        local i = 1
        foreach t of local treatments {
            quietly regress `t' `controls_sel' if `cond_clean'
            quietly predict double `r_t`i'' if e(sample), resid
            local i = `i' + 1
        }
        
        // C. FWL Regression: Regress Y-Resids on Treatment-Resids
        // We use nocons because residuals represent deviations from means
        quietly regress `r_outcome' `r_t1' `r_t2' `r_t3' `r_t4' ///
            if `cond_clean', nocons vce(`vce')
            
    }
    else {
        // If no controls selected, FWL is just the original regression
        quietly regress `outcome' ///
            NoAI_x_NotIden AI_x_NotIden NoAI_x_Iden AI_x_Iden ///
            if `cond_clean', nocons vce(`vce')
    }

    // -----------------------------
    // 4) P-Values
    // -----------------------------
    // Note: The variable names in the regression are now temps or originals depending on loop.
    // We access them by position or name. If we used temps, we refer to them.
    
    if "`controls_sel'" != "" {
        // Test 1: NoAI (1) vs AI (2) -> r_t1 vs r_t2
        quietly test `r_t2' = `r_t1'
        local p12_str : di %6.3f r(p)

        // Test 2: NoAI (3) vs AI (4) -> r_t3 vs r_t4
        quietly test `r_t4' = `r_t3'
        local p34_str : di %6.3f r(p)
    }
    else {
        quietly test AI_x_NotIden = NoAI_x_NotIden
        local p12_str : di %6.3f r(p)

        quietly test AI_x_Iden = NoAI_x_Iden
        local p34_str : di %6.3f r(p)
    }

    // -----------------------------
    // 5) Build Plotting Data
    // -----------------------------
    preserve
        clear
        set obs 4
        gen Treatment_Group = _n
        gen beta = .
        gen se   = .

        if "`controls_sel'" != "" {
            // Pull from the FWL tempvars
            replace beta = _b[`r_t1'] in 1
            replace se   = _se[`r_t1'] in 1
            replace beta = _b[`r_t2'] in 2
            replace se   = _se[`r_t2'] in 2
            replace beta = _b[`r_t3'] in 3
            replace se   = _se[`r_t3'] in 3
            replace beta = _b[`r_t4'] in 4
            replace se   = _se[`r_t4'] in 4
        }
        else {
            // Pull from original names
            replace beta = _b[NoAI_x_NotIden] in 1
            replace se   = _se[NoAI_x_NotIden] in 1
            replace beta = _b[AI_x_NotIden]   in 2
            replace se   = _se[AI_x_NotIden]   in 2
            replace beta = _b[NoAI_x_Iden]    in 3
            replace se   = _se[NoAI_x_Iden]    in 3
            replace beta = _b[AI_x_Iden]      in 4
            replace se   = _se[AI_x_Iden]      in 4
        }

        gen ci_lo = beta - 1.96*se
        gen ci_hi = beta + 1.96*se

        // Dynamic Scaling
        quietly summ ci_hi, meanonly
        local max_val = r(max)
        quietly summ ci_lo, meanonly
        local min_val = r(min)
        local range = `max_val' - `min_val'
        if `range' == 0 local range = 1

        local ybottom = `min_val' - (`range' * 0.25)
        local ytop    = `max_val' + (`range' * 0.30)
        local box_y   = `ybottom' + (`range' * 0.05)
        local box_x   = 0.7
        local c1 "navy"
        local c2 "maroon"

        twoway ///
            (rcap ci_hi ci_lo Treatment_Group if Treatment_Group<=2, lcolor(`c1') lwidth(medthin)) ///
            (scatter beta Treatment_Group if Treatment_Group<=2, msymbol(Dh) msize(small) mcolor(none) mlcolor(`c1')) ///
            (rcap ci_hi ci_lo Treatment_Group if Treatment_Group> 2, lcolor(`c2') lwidth(medthin)) ///
            (scatter beta Treatment_Group if Treatment_Group> 2, msymbol(Dh) msize(small) mcolor(none) mlcolor(`c2')) ///
            (scatter beta Treatment_Group if 1==0, msymbol(Dh) msize(small) mcolor(none) mlcolor(black)) ///
            (rcap ci_hi ci_lo Treatment_Group if 1==0, lcolor(black) lwidth(medthin)), ///
            xlabel(1 `""No AI, Not identified" "(n=`n1')""' ///
                   2 `""AI, Not identified" "(n=`n2')""' ///
                   3 `""No AI, Identified" "(n=`n3')""' ///
                   4 `""AI, Identified" "(n=`n4')""', labsize(small)) ///
            xscale(range(0.5 4.5)) ///
            yscale(range(`ybottom' `ytop')) ///
            xtitle("`xtitle'", size(small)) ///
            ytitle("`ytitle'", size(medsmall)) ///
            title("`title'", size(small)) ///
            text(`box_y' `box_x' "									   " " " " ", ///
                 place(ne) box fcolor(white) lcolor(black) margin(small) size(vsmall) justification(left) color(white)) ///
            text(`box_y' `box_x' "P-Value (No AI vs AI | Not Identified) = `p12_str'" " " " ", ///
                 place(ne) margin(small) size(vsmall) justification(left) color(`c1')) ///
            text(`box_y' `box_x' " " " " "P-Value (No AI vs AI | Identified) = `p34_str'", ///
                 place(ne) margin(small) size(vsmall) justification(left) color(`c2')) ///
            legend(order(5 6) label(6 "95% Confidence Interval") label(5 "Mean") ///
                   cols(1) ring(0) pos(1) size(vsmall)) ///
            graphregion(color(white) margin(medium)) ///
            plotregion(margin(zero)) ///
            name(fwl_plot_final, replace)

        graph export "`outdir'/`filetag'.pdf", replace
        graph drop fwl_plot_final
    restore
end

cap program drop outcome_img_prv_ins_tbl_Lasso0
program define outcome_img_prv_ins_tbl_Lasso0
    syntax, sample_number(integer) outcome(varname) imageconcern(varname) slabel(string) standardize(integer)
    
    preserve
    quietly keep if sample`sample_number' == 1 & !missing(`outcome')
    

    local four_arms AI_x_NotIden NoAI_x_Iden AI_x_Iden NoAI_x_NotIden
    local lasso_cands ""
    
    * Setup pointers to the 3 main structural variables
    * (Default: use the raw names)
    local c_img  "`imageconcern'"
    local c_prv  "not_shared_handle"
    local c_inst "Instagram_use"

    if `standardize' == 1 {
        
        foreach v of varlist $LASSO_CANDIDATES_NOT3 {
            capture drop `v'_N
            quietly summarize `v'
            if r(sd) > 0 & r(sd) < . {
                gen `v'_N = (`v' - r(mean)) / r(sd)
                local lasso_cands "`lasso_cands' `v'_N"
            }
        }
        
        capture drop `imageconcern'_N
        quietly summarize `imageconcern'
        if r(sd) > 0 & r(sd) < . {
            gen `imageconcern'_N = (`imageconcern' - r(mean)) / r(sd)
            local c_img "`imageconcern'_N" 
        }

        capture drop not_shared_handle_N
        quietly summarize not_shared_handle
        if r(sd) > 0 & r(sd) < . {
            gen not_shared_handle_N = (not_shared_handle - r(mean)) / r(sd)
            local c_prv "not_shared_handle_N"
        }

        capture drop Instagram_use_N
        quietly summarize Instagram_use
        if r(sd) > 0 & r(sd) < . {
            gen Instagram_use_N = (Instagram_use - r(mean)) / r(sd)
            local c_inst "Instagram_use_N"
        }
    }
    else {
        * If not standardizing, use raw candidates
        local lasso_cands "$LASSO_CANDIDATES_NOT3"
    }

    
    local controls_lasso_sel ""
    local is_binary = (strpos("$OUTCOMES_BIN", "`outcome'") > 0)
    local is_cont   = (strpos("$OUTCOMES_CONT", "`outcome'") > 0)
    
    if `is_binary' {
        capture quietly lasso logit `outcome' `lasso_cands', selection("cv")
        if _rc == 0 {
            local controls_lasso_sel "`e(allvars_sel)'"
        }
    }
    else {
        * Default to linear if continuous or not specified in binary list
        capture quietly lasso linear `outcome' `lasso_cands', selection("cv")
        if _rc == 0 {
            local controls_lasso_sel "`e(allvars_sel)'"
        }
    }

    if `standardize' {
        local fname "`outcome'_Lasso_standardized"
    }
    if !`standardize' {
        local fname "`outcome'_Lasso"
    }
	
    local tbl_title "Regression of `outcome' (Lasso Controls) using `slabel'"
    local models_to_tab ""
    
    eststo clear
    quietly count
    local N_obs = r(N)
    
    if `N_obs' > 10 {
        
        forvalues i = 1/8 {
            
            local current_main_controls ""
            local lbl_img "No"
            local lbl_prv "No"
            local lbl_insta "No"
            
            * --- BLOCK 1: NO INSTAGRAM CONTROL (Columns 1-4) ---
            
            if `i' == 1 {
                local current_main_controls ""
                local lbl_img "No"
                local lbl_prv "No"
            }
            if `i' == 2 {
                local current_main_controls `c_img'
                local lbl_img "Yes"
                local lbl_prv "No"
            }
            if `i' == 3 {
                local current_main_controls `c_img' `c_prv'
                local lbl_img "Yes"
                local lbl_prv "Yes"
            }
            if `i' == 4 {
                local current_main_controls `c_prv'
                local lbl_img "No"
                local lbl_prv "Yes"
            }
            
            * --- BLOCK 2: YES INSTAGRAM CONTROL (Columns 5-8) ---
            
            if `i' >= 5 {
                local lbl_insta "Yes"
            }
            
            if `i' == 5 {
                local current_main_controls `c_inst'
                local lbl_img "No"
                local lbl_prv "No"
            }
            if `i' == 6 {
                local current_main_controls `c_img' `c_inst'
                local lbl_img "Yes"
                local lbl_prv "No"
            }
            if `i' == 7 {
                local current_main_controls `c_img' `c_prv' `c_inst'
                local lbl_img "Yes"
                local lbl_prv "Yes"
            }
            if `i' == 8 {
                local current_main_controls `c_prv' `c_inst'
                local lbl_img "No"
                local lbl_prv "Yes"
            }

            * --- COMBINE CONTROLS AND RUN ---
            * We combine: [Structural Controls] + [Lasso Selected Controls] + [Treatment Arms]
            
            capture eststo model_`i': reghdfe `outcome' `current_main_controls' `controls_lasso_sel' `four_arms', vce(robust) nocons
            
            if _rc == 0 {
                quietly estadd local imgconcern "`lbl_img'"
                quietly estadd local privacy "`lbl_prv'"
                quietly estadd local insta "`lbl_insta'"
                quietly estadd scalar samplesize = e(N)
                local models_to_tab "`models_to_tab' model_`i'"
            }
        }
    }
    else {
        display as error "Not enough observations for Sample `sample_number'"
    }

    
    if "`models_to_tab'" != "" {
        
        capture mkdir "$output_folder/outcome_tables"
        capture mkdir "$output_folder/outcome_tables/sample`sample_number'"

        esttab `models_to_tab' using "$output_folder/outcome_tables/sample`sample_number'/`fname'.tex", replace ///
            main(b %9.3f) aux(se %9.3f) ///
            starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
            order(NoAI_x_NotIden AI_x_NotIden NoAI_x_Iden AI_x_Iden) ///
            keep(NoAI_x_NotIden AI_x_NotIden NoAI_x_Iden AI_x_Iden *) ///
            stats(r2_a imgconcern privacy insta samplesize, ///
                fmt(%9.3f 0 0 0 %9.0fc) ///
                labels("Adj. \(R^2\)" "Control: Image Concern" "Control: Privacy" "Control: Instagram Usage" "\(N\)")) ///
            nomtitles ///
            title("`tbl_title'") nonotes ///
            booktabs compress width(\hsize) ///
            prehead(`"\documentclass{article}"' ///
                    `"\usepackage{booktabs}"' ///
                    `"\usepackage[paperheight=12in, paperwidth=10in, margin=0.5in]{geometry}"' ///
                    `"\begin{document}"' ///
                    `"\begin{table}[htbp]\centering"' ///
                    `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
                    `"\caption{@title}"' ///
                    `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                    `"\toprule"') ///
            postfoot(`"\bottomrule"' ///
                     `"\end{tabular*}"' ///
                     `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"' ///
                     `"\textbf{Note:} Standard errors in parentheses. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$. \\ Reference group acts as the control group: NoAI x NotIden."' ///
                     `"\end{minipage}"' ///
                     `"\end{table}"' ///
                     `"\end{document}"')
    }
    else {
        display as error "No models converged for table generation."
    }

    restore
end

cap program drop outcome_divby_img_prv_tbl_Lasso0
program define outcome_divby_img_prv_tbl_Lasso0
    syntax, outcome(varname) imageconcenrn_binary(varname) standardize(integer)
    
    preserve
    keep if !missing(`outcome')
    
    * Put the one arm that you want to be dropped at the end.
    local four_arms AI_x_NotIden NoAI_x_Iden AI_x_Iden NoAI_x_NotIden

    * Prepare Controls
    local tbl_title "Regression of '`outcome'' using double Lasso control variables"
    local lasso_cands ""
	
	capture drop Instagram_use_N
	quietly summarize Instagram_use
	gen Instagram_use_N = (Instagram_use - r(mean)) / r(sd)
	
    if `standardize' {
        foreach v of varlist $LASSO_CANDIDATES_NOT3 {
            capture drop `v'_N
            quietly summarize `v'
            if r(sd) > 0 & r(sd) < . {
                gen `v'_N = (`v' - r(mean)) / r(sd)
                local lasso_cands "`lasso_cands' `v'_N"
			}
		}
	}

    if !`standardize' {
        local lasso_cands "$LASSO_CANDIDATES_NOT3"
    }
    

    local controls_lasso_sel ""
    local is_binary = (strpos("$OUTCOMES_BIN", "`outcome'") > 0)
    local is_cont   = (strpos("$OUTCOMES_CONT", "`outcome'") > 0)
    
    * Lasso selection on FULL sample

    if `is_binary' {
        capture quietly lasso logit `outcome' `lasso_cands', selection("cv")
        if _rc == 0 {
            local controls_lasso_sel "`e(allvars_sel)'"
        }

    }
    else if `is_cont' {
        capture quietly lasso linear `outcome' `lasso_cands', selection("cv")
        if _rc == 0 {
            local controls_lasso_sel "`e(allvars_sel)'"
        }
    }
	
    * --- Debugging Display ---
    display _newline(2)
    display as text "--------------------------------------------------"
    display as text "Outcome: " as result "`outcome'"
    display as text "Lasso Selected Controls: " as result "`controls_lasso_sel'"
    display as text "--------------------------------------------------"
    display _newline
    * -------------------------

	local models_to_tab ""
	
	* -----------------------------------------------------
    * LOOP 1: With Instagram Control (1-4)
    * -----------------------------------------------------
	
    local cond1 "`imageconcenrn_binary' == 0 & not_shared_handle == 1"
    local labs1 "Low Low Yes"
    
    local cond2 "`imageconcenrn_binary' == 1 & not_shared_handle == 1"
    local labs2 "High Low Yes"
    
    local cond3 "`imageconcenrn_binary' == 1 & not_shared_handle == 0"
    local labs3 "High High Yes"
    
    local cond4 "`imageconcenrn_binary' == 0 & not_shared_handle == 0"
    local labs4 "Low High Yes"
	

    forvalues i = 1/4 {

        quietly count if `cond`i''
        local N_obs = r(N)
        
        tokenize `"`labs`i''"'
        local lbl_img "`1'"
        local lbl_prv  "`2'"
        local lbl_insta  "`3'"
        local nice_N : display %9.0fc `N_obs'

        if `N_obs' > 10 {
            * 1. Run the regression
            if `standardize' {
                capture eststo est`i': reghdfe `outcome' `four_arms' Instagram_use_N `controls_lasso_sel' if `cond`i'', vce(robust) nocons
            }
            if !`standardize' {
                capture eststo est`i': reghdfe `outcome' `four_arms' Instagram_use `controls_lasso_sel' if `cond`i'', vce(robust) nocons
            }

            * 2. Check if it worked (error code 0 means success)
            if _rc == 0 {
                * Add locals to the CURRENT model (est`i')
                estadd local imgconcern "`lbl_img'", replace
                estadd local privacy "`lbl_prv'", replace
                estadd local insta "`lbl_insta'", replace
                estadd local samplesize "`nice_N'", replace
                
                * Add this model to the list for the final table
                local models_to_tab "`models_to_tab' est`i'"
            }
            else {
                display as error "Regression `i' failed to converge or encountered an error."
            }
        }
        else {
            display "Not enough variation in the `outcome' under `cond`i''"
        }
    }	
	
	
	* -----------------------------------------------------
    * LOOP 2: Without Instagram Control (5-8)
    * -----------------------------------------------------
	
    local cond5 "`imageconcenrn_binary' == 0 & not_shared_handle == 1"
    local labs5 "Low Low No"
    
    local cond6 "`imageconcenrn_binary' == 1 & not_shared_handle == 1"
    local labs6 "High Low No"
    
    local cond7 "`imageconcenrn_binary' == 1 & not_shared_handle == 0"
    local labs7 "High High No"
    
    local cond8 "`imageconcenrn_binary' == 0 & not_shared_handle == 0"
    local labs8 "Low High No"


    forvalues i = 5/8 {

        quietly count if `cond`i''
        local N_obs = r(N)
        tokenize `"`labs`i''"'
        local lbl_img "`1'"
        local lbl_prv  "`2'"
        local lbl_insta  "`3'"
        local nice_N : display %9.0fc `N_obs'

        if `N_obs' > 10 {
            capture eststo est`i': reghdfe `outcome' `four_arms' `controls_lasso_sel' if `cond`i'', vce(robust) nocons
            
            if _rc == 0 {
                estadd local imgconcern "`lbl_img'", replace
                estadd local privacy "`lbl_prv'", replace
                estadd local insta "`lbl_insta'", replace
                estadd local samplesize "`nice_N'", replace
                
                local models_to_tab "`models_to_tab' est`i'"
            }
            else {
                 display as error "Regression `i' failed to converge or encountered an error."
            }
        }
        else {
            display "Not enough variation in the `outcome' under `cond`i''"
        }
    }

    * Generate Table
	capture mkdir "$output_folder/outcome_tables"
	capture mkdir "$output_folder/outcome_tables/div_by_img_prv_insta_control"
	
	
    if `standardize' {
        local fname "`outcome'_Lasso_standardized"
    }
    if !`standardize' {
        local fname "`outcome'_Lasso"
    }

	esttab `models_to_tab' using "$output_folder/outcome_tables/div_by_img_prv_insta_control/`fname'.tex", replace ///
        main(b %9.3f) aux(se %9.3f) ///
        starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
        order(NoAI_x_NotIden AI_x_NotIden NoAI_x_Iden AI_x_Iden) ///
        keep(NoAI_x_NotIden AI_x_NotIden NoAI_x_Iden AI_x_Iden *) ///
        stats(r2_a imgconcern privacy insta samplesize, ///
            labels("Adj. \(R^2\)" "Image Concern" "Privacy" "Inst Use Control" "\(N\)")) ///
        nomtitles ///
        title("`tbl_title'") nonotes ///
        booktabs compress width(\hsize) ///
        prehead(`"\documentclass{article}"' ///
                `"\usepackage{booktabs}"' ///
                `"\usepackage[paperheight=13in, paperwidth=9in, margin=0.5in]{geometry}"' ///
                `"\begin{document}"' ///
                `"\begin{table}[htbp]\centering"' ///
                `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
                `"\caption{@title}"' ///
                `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                `"\toprule"') ///
        postfoot(`"\bottomrule"' ///
                 `"\end{tabular*}"' ///
                 `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"' ///
                 `"Standard errors in parentheses. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$. \\ Reference group acts as the control group: NoAI x NotIden."' ///
                 `"\end{minipage}"' ///
                 `"\end{table}"' ///
                 `"\end{document}"')

    restore
end

cap program drop outcome_img_prv_ins_tbl_Noctrl0
program define outcome_img_prv_ins_tbl_Noctrl0
    syntax, sample_number(integer) outcome(varname) imageconcern(varname) slabel(string) [if_condition(string)]
    
    preserve
    * Filter based on the sample number dummy
    quietly keep if sample`sample_number' == 1 & !missing(`outcome')
	
    if "`if_condition'" != "" {
        keep `if_condition'
    }
    * Define the main arms
    local four_arms AI_x_NotIden NoAI_x_Iden AI_x_Iden NoAI_x_NotIden
    
    * Define Control Variables
    local c_img  "`imageconcern'"
    local c_prv  "not_shared_handle"
    local c_inst "Instagram_use"
    
    * Filename only needs the outcome, as the folder structure now indicates the sample
    local fname "`outcome'_NoControl"
    local tbl_title "Regression of `outcome' (No Controls) using `slabel'"
    
    local models_to_tab ""
    eststo clear
    
    quietly count
    local N_obs = r(N)
    
    if `N_obs' > 10 {
        forvalues i = 1/8 {
            local current_controls ""
            local lbl_img "No"
            local lbl_prv "No"
            local lbl_insta "No"
            
            if `i' == 2 {
                local current_controls `c_img'
                local lbl_img "Yes"
            }
            if `i' == 3 {
                local current_controls `c_img' `c_prv'
				local lbl_img "Yes"
                local lbl_prv "Yes"
            }
            if `i' == 4 {
                local current_controls `c_prv'
				local lbl_prv "Yes"
            }
            if `i' == 5 {
                local current_controls `c_inst'
				local lbl_insta "Yes"

            }
            if `i' == 6 {
                local current_controls `c_inst' `c_img'
				local lbl_insta "Yes"
				local lbl_img "Yes"

            }
            if `i' == 7 {
                local current_controls `c_inst' `c_img' `c_prv'
				local lbl_insta "Yes"
				local lbl_img "Yes"
				local lbl_prv "Yes"
				
            }
            if `i' == 8 {
                local current_controls `c_inst' `c_prv'
				local lbl_insta "Yes"
				local lbl_prv "Yes"
            }
            
            capture eststo model_`i': reghdfe `outcome' `current_controls' `four_arms', vce(robust) nocons
            
            if _rc == 0 {
                quietly estadd local imgconcern "`lbl_img'"
                quietly estadd local privacy "`lbl_prv'"
                quietly estadd local insta "`lbl_insta'"
                quietly estadd scalar samplesize = e(N)
                local models_to_tab "`models_to_tab' model_`i'"
            }
        }
    }
    else {
        display as error "Not enough observations for Sample `sample_number'"
    }

    * --- GENERATE TABLE ---
    if "`models_to_tab'" != "" {
        
        * 1. Create main table folder
        capture mkdir "$output_folder/outcome_tables"
        
        * 2. Create specific sample folder
        capture mkdir "$output_folder/outcome_tables/sample`sample_number'"

        * 3. Save file into that specific folder
        esttab `models_to_tab' using "$output_folder/outcome_tables/sample`sample_number'/`fname'.tex", replace ///
            main(b %9.3f) aux(se %9.3f) ///
            starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
            order(NoAI_x_NotIden AI_x_NotIden NoAI_x_Iden AI_x_Iden) ///
            keep(NoAI_x_NotIden AI_x_NotIden NoAI_x_Iden AI_x_Iden *) ///
            stats(r2_a imgconcern privacy insta samplesize, fmt(%9.3f 0 0 0 %9.0fc) ///
                labels("Adj. \(R^2\)" "Control: Image Concern" "Control: Privacy" "Control: Instagram Usage" "\(N\)")) ///
            nomtitles ///
            title("`tbl_title'") nonotes ///
            booktabs compress width(\hsize) ///
            prehead(`"\documentclass{article}"' ///
                    `"\usepackage{booktabs}"' ///
                    `"\usepackage[paperheight=8in, paperwidth=9in, margin=0.5in]{geometry}"' ///
                    `"\begin{document}"' ///
                    `"\begin{table}[htbp]\centering"' ///
                    `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
                    `"\caption{@title}"' ///
                    `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                    `"\toprule"') ///
            postfoot(`"\bottomrule"' ///
                     `"\end{tabular*}"' ///
                     `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"' ///
                     `"\textbf{Note:} Standard errors in parentheses. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$. \\ Reference group acts as the control group: NoAI x NotIden."' ///
                     `"\end{minipage}"' ///
                     `"\end{table}"' ///
                     `"\end{document}"')
    }
    else {
        display as error "No models converged for table generation."
    }

    restore
end

cap program drop outcome_divby_img_prv_tbl_Noctrl0
program define outcome_divby_img_prv_tbl_Noctrl0
    syntax, outcome(varname) imageconcenrn_binary(varname) [if_condition(string)]
    
    preserve
    keep if !missing(`outcome')
	
    if "`if_condition'" != "" {
        keep `if_condition'
    }
    
    * Put the one arm that you want to be dropped at the end.
    local four_arms AI_x_NotIden NoAI_x_Iden AI_x_Iden NoAI_x_NotIden

	local fname "`outcome'_NoControl"
    local tbl_title "Regression of '`outcome'' (No Controls)"
    local models_to_tab ""
    
    * --- Debugging Display ---
    display _newline(2)
    display as text "--------------------------------------------------"
    display as text "Outcome: " as result "`outcome'"
    display as text "Model: No Controls (Basic Treatment Arms)"
    display as text "--------------------------------------------------"
    display _newline

    * -----------------------------------------------------
    * LOOP 1: With Instagram Control (1-4)
    * -----------------------------------------------------
    * We control for 'Instagram_use' (raw) here.
    
    local cond1 "`imageconcenrn_binary' == 0 & not_shared_handle == 1"
    local labs1 "Low Low Yes"
    
    local cond2 "`imageconcenrn_binary' == 1 & not_shared_handle == 1"
    local labs2 "High Low Yes"
    
    local cond3 "`imageconcenrn_binary' == 1 & not_shared_handle == 0"
    local labs3 "High High Yes"
    
    local cond4 "`imageconcenrn_binary' == 0 & not_shared_handle == 0"
    local labs4 "Low High Yes"
    

    forvalues i = 1/4 {

        quietly count if `cond`i''
        local N_obs = r(N)
        
        tokenize `"`labs`i''"'
        local lbl_img "`1'"
        local lbl_prv  "`2'"
        local lbl_insta  "`3'"
        local nice_N : display %9.0fc `N_obs'

        if `N_obs' > 10 {
            * Run the regression: Treatment Arms + Instagram_use
            capture eststo est`i': reghdfe `outcome' `four_arms' Instagram_use if `cond`i'', vce(robust) nocons

            if _rc == 0 {
                estadd local imgconcern "`lbl_img'", replace
                estadd local privacy "`lbl_prv'", replace
                estadd local insta "`lbl_insta'", replace
                estadd local samplesize "`nice_N'", replace
                
                local models_to_tab "`models_to_tab' est`i'"
            }
            else {
                display as error "Regression `i' failed to converge or encountered an error."
            }
        }
        else {
            display "Not enough variation in the `outcome' under `cond`i''"
        }
    }   
    
    
    * -----------------------------------------------------
    * LOOP 2: Without Instagram Control (5-8)
    * -----------------------------------------------------
    * No controls at all here, just treatment arms.
    
    local cond5 "`imageconcenrn_binary' == 0 & not_shared_handle == 1"
    local labs5 "Low Low No"
    
    local cond6 "`imageconcenrn_binary' == 1 & not_shared_handle == 1"
    local labs6 "High Low No"
    
    local cond7 "`imageconcenrn_binary' == 1 & not_shared_handle == 0"
    local labs7 "High High No"
    
    local cond8 "`imageconcenrn_binary' == 0 & not_shared_handle == 0"
    local labs8 "Low High No"


    forvalues i = 5/8 {

        quietly count if `cond`i''
        local N_obs = r(N)
        tokenize `"`labs`i''"'
        local lbl_img "`1'"
        local lbl_prv  "`2'"
        local lbl_insta  "`3'"
        local nice_N : display %9.0fc `N_obs'

        if `N_obs' > 10 {
            * Run regression: Treatment Arms ONLY
            capture eststo est`i': reghdfe `outcome' `four_arms' if `cond`i'', vce(robust) nocons
            
            if _rc == 0 {
                estadd local imgconcern "`lbl_img'", replace
                estadd local privacy "`lbl_prv'", replace
                estadd local insta "`lbl_insta'", replace
                estadd local samplesize "`nice_N'", replace
                
                local models_to_tab "`models_to_tab' est`i'"
            }
            else {
                 display as error "Regression `i' failed to converge or encountered an error."
            }
        }
        else {
            display "Not enough variation in the `outcome' under `cond`i''"
        }
    }

    * Generate Table 
	capture mkdir "$output_folder/outcome_tables"
	capture mkdir "$output_folder/outcome_tables/div_by_img_prv_insta_control"

    esttab `models_to_tab' using "$output_folder/outcome_tables/div_by_img_prv_insta_control/`fname'.tex", replace ///
        main(b %9.3f) aux(se %9.3f) ///
        starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
        order(NoAI_x_NotIden AI_x_NotIden NoAI_x_Iden AI_x_Iden) ///
        keep(NoAI_x_NotIden AI_x_NotIden NoAI_x_Iden AI_x_Iden *) ///
        stats(r2_a imgconcern privacy insta samplesize, ///
            labels("Adj. \(R^2\)" "Image Concern" "Privacy" "Inst Use Control" "\(N\)")) ///
        nomtitles ///
        title("`tbl_title'") nonotes ///
        booktabs compress width(\hsize) ///
        prehead(`"\documentclass{article}"' ///
                `"\usepackage{booktabs}"' ///
                `"\usepackage[paperheight=8in, paperwidth=9in, margin=0.5in]{geometry}"' ///
                `"\begin{document}"' ///
                `"\begin{table}[htbp]\centering"' ///
                `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
                `"\caption{@title}"' ///
                `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                `"\toprule"') ///
        postfoot(`"\bottomrule"' ///
                 `"\end{tabular*}"' ///
                 `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"' ///
                 `"Standard errors in parentheses. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$. \\ Reference group acts as the control group: NoAI x NotIden."' ///
                 `"\end{minipage}"' ///
                 `"\end{table}"' ///
                 `"\end{document}"')

    restore
end

capture program drop hte_reghdfe
program define hte_reghdfe
    version 15.1
    // depvar is the first positional argument
    syntax varname(numeric) [if] [in], D(varname) ///
        [ ARMS(varlist) CONTROLS(varlist fv) VCE(passthru) ABSORB(passthru) * ]

    // Default to your globals if not provided
    if "`arms'"==""     local arms     "$TREAT_ARM"
    if "`controls'"=="" local controls "$CONTROLS"

    // 1) Remove D from controls (handles D, c.D, i.D)
    local controls_clean
    foreach tok of local controls {
        if inlist("`tok'","`d'","c.`d'","i.`d'") continue
        local controls_clean `controls_clean' `tok'
    }

    // 2) Build the "PUZZLE" = interactions arm*D (4 terms)
    local inters
    local j = 1
    foreach a of local arms {
        tempvar int`j'
        gen double `int`j'' = `a' * `d' `if' `in'
        local inters `inters' `int`j''
        local ++j
    }

    // 3) Run model: 4 arms + 4 interactions, no constant
    reghdfe `varlist' `controls_clean' `arms' `inters' `if' `in', ///
        nocons `vce' `absorb' `options'
end

*/

********************************
**** 	Sahil Archive 		****
********************************
/*
cap program drop swiss_ciplot_residualized
program define swiss_ciplot_residualized
    version 17.0
    syntax, if_condition(string) xtitle(string) filename_suffix(string) graph_name_suffix(string) ///
           OUTCOME(varname) [ YTITLE(string) ]

    // ---------------------------------------------------------
    // 1. CALCULATIONS (T-Tests on Residuals)
    // ---------------------------------------------------------
    local cond_clean : subinstr local if_condition "if " ""
    
    // Sample Sizes
    forvalues i = 1/4 {
        quietly count if Treatment_Group == `i' & `cond_clean'
        local n`i' = r(N)
    }

    // T-tests (Two-sided)
    // 1 vs 2 (Anon): No AI vs AI
    quietly ttest `outcome' if `cond_clean' & (Treatment_Group==1 | Treatment_Group==2), by(Treatment_Group) unequal
    local p12_str : di %6.3f r(p)
    
    // 3 vs 4 (Iden): No AI vs AI
    quietly ttest `outcome' if `cond_clean' & (Treatment_Group==3 | Treatment_Group==4), by(Treatment_Group) unequal
    local p34_str : di %6.3f r(p)

    // ---------------------------------------------------------
    // 2. DATA PREP
    // ---------------------------------------------------------
    preserve
    keep `if_condition'
    collapse (count) n=`outcome' (mean) mean=`outcome' (sd) sd=`outcome', by(Treatment_Group)
    
    gen se    = sd/sqrt(n)
    gen tcrit = invttail(n-1, 0.025)
    gen ci_lo = mean - 1.96*se
    gen ci_hi = mean + 1.96*se
    
    // Note: Residuals are NOT multiplied by 100. They are raw units.
    
    // ---------------------------------------------------------
    // 3. DYNAMIC SCALING (To place the P-value box correctly)
    // ---------------------------------------------------------
    summ ci_hi, d
    local max_val = r(max)
    summ ci_lo, d
    local min_val = r(min)
    
    // Add 15% padding to top for the box
    local range = `max_val' - `min_val'
    if `range' == 0 local range = 1
    local ytop    = `max_val' + (`range' * 0.25)
    local ybottom = `min_val' - (`range' * 0.05)
    
    local box_y   = `max_val' + (`range' * 0.15)
    local box_x   = 0.5 // Left-aligned in the treatment 1-2 area usually, or centered? 
                        // swiss_ciplot uses 0.7 (near left). Let's stick to that.
    
    // ---------------------------------------------------------
    // 4. PLOTTING
    // ---------------------------------------------------------
    local ytitle_final = cond("`ytitle'"=="","Residuals","`ytitle'")
    
    local c1 "navy"
    local c2 "maroon"

    twoway ///
        (rcap ci_hi ci_lo Treatment_Group if Treatment_Group <= 2, lcolor(`c1') lwidth(medthin)) ///
        (scatter mean Treatment_Group if Treatment_Group <= 2, msymbol(Dh) msize(small) mcolor(none) mlcolor(`c1')) ///
        (rcap ci_hi ci_lo Treatment_Group if Treatment_Group > 2, lcolor(`c2') lwidth(medthin)) ///
        (scatter mean Treatment_Group if Treatment_Group > 2, msymbol(Dh) msize(small) mcolor(none) mlcolor(`c2')) ///
        /* Legend Dummies */ ///
        (scatter mean Treatment_Group if 1==0, msymbol(Dh) msize(small) mcolor(none) mlcolor(black)) ///
        (rcap ci_hi ci_lo Treatment_Group if 1==0, lcolor(black) lwidth(medthin)), ///
        xlabel(1 `""No AI, Not identified" "(n=`n1')""' ///
               2 `""AI, Not identified" "(n=`n2')""' ///
               3 `""No AI, Identified" "(n=`n3')""' ///
               4 `""AI, Identified" "(n=`n4')""', labsize(vsmall)) ///
        xtitle("`xtitle'", size(small)) ///
        ytitle("`ytitle_final'", size(medsmall)) ///
        xscale(range(0.5 4.5)) ///
        /* P-Value Box (Top Left/Center) */ ///
        text(`box_y' 0.6 "									   " " " " ", ///
             place(ne) box fcolor(white) lcolor(black) margin(small) size(vsmall) justification(left)) ///
        text(`box_y' 0.6 "P-Value (No AI vs AI | Not Identified) = `p12_str'" " " " ", ///
             place(ne) margin(small) size(vsmall) justification(left) color(`c1')) ///
        text(`box_y' 0.6 " " " " "P-Value (No AI vs AI | Identified) = `p34_str'", ///
             place(ne) margin(small) size(vsmall) justification(left) color(`c2')) ///
        legend(order(5 6) label(6 "95% Confidence Interval") label(5 "Mean Residual") ///
               cols(1) ring(0) pos(1) size(vsmall)) ///
        graphregion(color(white) margin(medium)) ///
        name(Ci_Resid`graph_name_suffix', replace)

    graph export "$output_folder/`filename_suffix'.pdf", replace
    graph drop Ci_Resid`graph_name_suffix'
    
    restore
end

cap program drop make_ciplot_swiss
program make_ciplot_swiss

    syntax, outcome(varlist) by_var(varlist) folder(string) subtitle(string) [residualize(string)]

    capture mkdir $output_folder/`folder'/

    foreach x of local outcome {

        * Logic for Non-Residualized (Use original CI plot logic or customized if needed)
        * (Assuming you only run Residualized for this part as per prompt)
        
        * Logic for Residualized
        if "`residualize'" == "yes" {
            cap drop `x'Resid
            quietly reg `x' $CONTROLS, r nocons
            predict `x'Resid, residuals
            
            * --- Call the NEW customized program ---
            * Note: filename_suffix now excludes "ciplot_" prefix
            swiss_ciplot_residualized, ///
                if_condition("if `x'Resid != .") ///
                outcome(`x'Resid) ///
                xtitle("Treatment Group") ///
                ytitle("Residuals (`x')") ///
                filename_suffix("`folder'/`x'Resid_`by_var'") ///
                graph_name_suffix("_`x'")
        }
    }

end

cap program drop make_ciplot_swiss0
program make_ciplot_swiss0

    syntax, outcome(varlist) by_var(varlist) folder(string) subtitle(string) [residualize(string)]

    capture mkdir $output_folder/`folder'/

    global swiss_ciplot_options `"xlabel(2 "No AI, Not identified" 5 "AI, Not identified" 8 "No AI, Identified" 11 "AI, Identified", labsize(small)) xtitle("") lcolor(blue) xtitle("Treatment Group (Co-sender Composition x AI Presence)", size(small)) ytitle("") mcolor(red%70) rcapopts(lcolor(navy))"'

    foreach x of local outcome {

        * Logic for Non-Residualized (e.g., Finished)
        if "`residualize'" == ""{
            ciplot `x', by(`by_var') subtitle("`subtitle'", size(small)) $swiss_ciplot_options
            graph export $output_folder/`folder'/ciplot_`x'_`by_var'.pdf, replace    
        }

        * Logic for Residualized (e.g., Continuous outcomes)
        if "`residualize'" == "yes" {
            cap drop `x'Resid
            quietly reg `x' $CONTROLS, r nocons
            predict `x'Resid, residuals
            noi bysort `by_var': summ `x'Resid, d      
            ciplot `x'Resid, by(`by_var') subtitle("`subtitle'", size(small)) $swiss_ciplot_options 
            graph export $output_folder/`folder'/ciplot_`x'Resid_`by_var'.pdf,  replace 
        }

    }

end


* These programs generate notes for the control variables (xnote3 to xnote11).
* It handles factor variables (e.g., i.University) by stripping the prefix.

cap program drop add_controlnotes
program define add_controlnotes, rclass

    * Start at 3 because xnote1 and xnote2 are defined in add_notes
    local i = 3
    
    foreach var of global CONTROLS {
        
        * 1. Default: assume the variable name is just the string
        local clean_var "`var'"
        
        * 2. Check if it is a factor variable (contains a dot, e.g., i.University)
        if strpos("`var'", ".") > 0 {
            * Use Stata's internal parser to extract the base variable name
            capture _ms_parse_parts `var'
            if _rc == 0 {
                local clean_var "`r(name)'"
            }
        }
        
        * 3. Get the variable label using the clean name
        capture local lbl : var label `clean_var'
        
        * 4. If a label exists, create the note
        if "`lbl'" != "" {
            * Optional: Truncate label if too long to fit in table footer
            if length("`lbl'") > 80 local lbl = substr("`lbl'", 1, 77) + "..."
            
            return local xnote`i' "`clean_var' stands for `lbl'"
            local i = `i' + 1
        }
        
        * Stop if we exceed the number of notes esttab is expecting (xnote11)
        if `i' > 11 continue, break
    }
    
    * Fill remaining slots with empty strings to prevent errors if fewer controls exist
    forvalues j = `i'/11 {
        return local xnote`j' ""
    }

end

cap program drop add_notes
program define add_notes, rclass

	syntax, outcome(varlist)

	* WTPBinary WTP GenAIEffective SignalValue PerceiveAI PerceiveEngaged PostTextLength_log1 TimePost TaskQuizCorrect

	local ynote `"`outcome' stands for `:var label `outcome''"'

    if "`outcome'" == "WTPBinary" {
        local ynote "WTPBinary is 1 if their WTP is greater than 0"
    }

    if "`outcome'" == "PostTextLength_log1" {
        local ynote "PostTextLength_log1 is log(1+Textlength) and is winsorized at 5/95 percentile"
    }

    if "`outcome'" == "TimePost" {
        local ynote "TimePost is time spent writing the post and is winsorized at 5/95 percentile"
    }

    local xnote1 "Identify is 1 if the respondent's first name and instagram handle (if available) will be shown"
    local xnote2 "AITreat is 1 if respondent is assigned to AI treatment"


    forvalues i = 1/2 {
   	
    	return local xnote`i' "`xnote`i''"

    }

    return local ynote "`ynote'"

end

cap program drop conduct_lotteries
program conduct_lotteries

	use input/SwissSurvey_Insta_Experiment.dta, clear // n = 1368

	data_pre_process

	normalize_data, outcome(ClimateWorry ClimatePersonal) 

	make_index, outcome(Climate) varset(ClimateWorry_N ClimatePersonal_N) 
	gen ClimateIndexBinary = index_Climate > r(p50)

	social_media_platform_cleaning 

	global_variables_defining	
	
	set seed 2025
	gen p = 0.001

	**** donation lottery ***

	gen draw1 = runiform()
	gen success1 = 1 if draw1 < p
	tab success1, m
	sort draw1
	br ResponseId paymentCode draw1 Donation OrganizationChoice if success1 == 1

	*** instagram lottery ***

	gen draw2 = runiform() if ProvideHandle
	gen success2 = 1 if draw2 < p	
	tab success2, m
	sort draw2
	br ResponseId paymentCode draw2 if success2 == 1


	*** test expected value of method ***

	local drawsum = 0 

	forvalues i = 1/1000 {
		count if runiform() < 0.001
		local drawsum = `drawsum' + `r(N)'
	}

	local drawsum = `drawsum'/1000
	di "`drawsum'"

end 
*/





