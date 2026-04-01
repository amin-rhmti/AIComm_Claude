********************************
****  Variables Structure    ****
********************************
cap program drop global_variables_defining
program global_variables_defining

	global DEMOG Age i.Grad_degree i.Vote i.ETH i.Female i.Switzerland
	global PRE_TREAT_CTRL i.Instagram_use i.ImageConcern i.not_shared_handle Donation index_Climate i.BotKnow i.InitialAIEffective i.BaseAIDiff i.ReadingReact1 i.ReadingReact2 i.GuessWriterHuman i.GuessWriterAI i.PostReact i.BotSupport_AI i.BotSocialMedia_AI
	global CONTROLS $DEMOG $PRE_TREAT_CTRL

	global OUTCOMES_BIN Finished Post_meaningfulness Post_AIness TaskQuizCorrect WTPBinary_pos WTPBinary_p50

end

global_variables_defining


cap program drop nice_name_as_label
program define nice_name_as_label

    * ** Post-Treatment **
    capture label variable Finished                    "Survey Completion"
    capture label variable Post_meaningfulness         "Wrote Meaningful Post"
    capture label variable Post_TextLength_log         "Ln (1+ Post-Task Character Count)"
    capture label variable Post_AIness                 "Post-Task Not Fully Human Written"
    capture label variable index_Post_effort           "Post-Task Effort Index"
    capture label variable index_Post_nlp              "Post-Task NLP Quality Index"
    capture label variable TimePost_W                  "Time on Post-Task (s)"
    capture label variable WTP                         "WTP to Remove Post (CHF)"
    capture label variable TimeWTP_W                   "Time Spent on WTP (s)"
    capture label variable TimeWTPExplain_W            "Time Spent on WTP Instruction (s)"
    capture label variable GenAIEffective              "AI Effectiveness to Attract Likes (1-3)"
    capture label variable PerceiveAI                  "Post-Task Likelihood to Perceived as AI (1-5)"
    capture label variable SignalValue                 "Post-Task Perceived Positively Importance (1-5)"
    capture label variable PerceiveEngaged             "Post-Task Perceived Engagement with Climate (1-5)"
    capture label variable index_Post_overall          "Post-Task Overall Quality Index"

    * ** Pre-Treatment **
    capture label variable Age                         "Age"
    capture label variable AgeBinary_p50               "Age Above Median (24+)"
    capture label variable AgeBinary_adult             "Age 25 Or Older"
    capture label variable Female                      "Gender (Female)"
    capture label variable Switzerland                 "Swiss"
    capture label variable Grad_degree                 "Graduate Student"
    capture label variable Vote                        "Voted in Last Election"
    capture label variable ETH                         "ETH"
    capture label variable Donation                    "Donation (CHF)"
    capture label variable DonationBinary_pos          "Donated"
    capture label variable DonationBinary_p50          "Donation Above Median"
    capture label variable Instagram_use               "Instagram User"
    capture label variable ImageConcern                "Image Concern (1-5)"
    capture label variable ImageConcernBinary2         "Image Concern Above 2 from 5"
    capture label variable ImageConcernBinary3         "Image Concern Above 3 from 5"
    capture label variable ImageConcernBinary4         "Image Concern Above 4 from 5"
    capture label variable ImageConcernBinary_p50      "Image Concern Above Median"
    capture label variable not_shared_handle           "Exposure Sensitivity"
    capture label variable index_Climate               "Climate Concern Index"
    capture label variable index_ClimateBinary         "Climate Concern Index Above Median"
    capture label variable BotKnow                     "AI Familiarity (1-5)"
    capture label variable BotKnowBinary               "Frequent AI User"
    capture label variable InitialAIEffective          "AI Persuasion (1-5)"
    capture label variable AIEffectiveBinary           "High AI Persuasion"
    capture label variable BaseAIDiff                  "Base-Task Perceived Difference from AI (1-5)"
    capture label variable AIDiffBinary                "Base-Task Perceived Distinct from AI"
    capture label variable PostReactBinary             "React to Example Post"
    capture label variable ReadingReact1Binary         "React to Post 1 in Reading Task"
    capture label variable ReadingReact2Binary         "React to Post 2 in Reading Task"
    capture label variable GuessWriter1                "Guess for Writer Identity"
    capture label variable Guess1_asHuman              "Guess Human Writer for Post 1"
    capture label variable GuessWriter2                "Guess for Writer Identity"
    capture label variable Guess2_asHuman              "Guess Human Writer for Post 2"
    capture label variable BotSupport_AI               "Customer Support Bot (1-5)"
    capture label variable BotSupport_AIBinary         "Prefer Customer Support Bot"
    capture label variable BotSocialMedia_AI           "Social Media Bot (1-5)"
    capture label variable BotSocialMedia_AIBinary     "Prefer AI On Social Media"

    * ** Index **
    capture label variable index_Image_minus_privacy       "(Image Concern - Exposure Sensitivity) Index"
    capture label variable index_Image_minus_privacyBinary "(Image Concern - Exposure Sensitivity) Index Above Median"
    capture label variable index_Base_effort               "Base-Task Effort Index"
    capture label variable index_Base_nlp                  "Base-Task NLP Quality Index"

    * ** Remaining **
    capture label variable Base_TextLength_log        "Ln(1+ Base-Task Character Count)"
    capture label variable Base_AIness                "Base-Task Not Fully Human Written"
    capture label variable Base_meaningfulness        "Wrote Meaningful Base-Task"

    capture label variable AITreat                    "AI Treatment"
    capture label variable Identify                   "Identified Treatment"
    capture label variable AIXIdentifyTreat           "AI × Identified"

end


cap program drop yaxis_range_raw
program define yaxis_range_raw
    syntax, outcome(varname)

    if "`outcome'" == "Finished" {
        c_local ylow  = 0.60
        c_local yhigh = 1.00
        c_local ystep = 0.05
        c_local yfmt    "%9.2f"
    }
    else if "`outcome'" == "Post_meaningfulness" {
        c_local ylow  = 0.55
        c_local yhigh = 1.00
        c_local ystep = 0.05
        c_local yfmt    "%9.2f"
    }
    else if "`outcome'" == "Post_TextLength_log" {
        c_local ylow  = 3.0
        c_local yhigh = 6.0
        c_local ystep = 0.5
        c_local yfmt    "%9.1f"
    }
    else if "`outcome'" == "Post_AIness" {
        c_local ylow  = -0.2
        c_local yhigh = 0.5
        c_local ystep = 0.1
        c_local yfmt    "%9.1f"
    }
    else if "`outcome'" == "index_Post_effort" {
        c_local ylow  = -0.8
        c_local yhigh = 0.6
        c_local ystep = 0.2
        c_local yfmt    "%9.1f"
    }
    else if "`outcome'" == "index_Post_nlp" {
        c_local ylow  = -0.75
        c_local yhigh = 0.50
        c_local ystep = 0.25
        c_local yfmt    "%9.2f"
    }
    else if "`outcome'" == "TimePost_W" {
        c_local ylow  = 0
        c_local yhigh = 700
        c_local ystep = 100
        c_local yfmt    "%9.0f"
    }
    else if "`outcome'" == "WTP" {
        c_local ylow  = -1.5
        c_local yhigh = 2.5
        c_local ystep = 0.5
        c_local yfmt    "%9.1f"
    }
    else if "`outcome'" == "TimeWTP_W" {
        c_local ylow  = 40
        c_local yhigh = 160
        c_local ystep = 20
        c_local yfmt    "%9.0f"
    }
    else if "`outcome'" == "TimeWTPExplain_W" {
        c_local ylow  = 0
        c_local yhigh = 120
        c_local ystep = 20
        c_local yfmt    "%9.0f"
    }
    else if "`outcome'" == "GenAIEffective" {
        c_local ylow  = 1.25
        c_local yhigh = 3.0
        c_local ystep = 0.25
        c_local yfmt    "%9.2f"
    }
    else if "`outcome'" == "PerceiveAI" {
        c_local ylow  = 0.5
        c_local yhigh = 3.0
        c_local ystep = 0.5
        c_local yfmt    "%9.1f"
    }
    else if "`outcome'" == "SignalValue" {
        c_local ylow  = 1.0
        c_local yhigh = 3.5
        c_local ystep = 0.5
        c_local yfmt    "%9.1f"
    }
    else if "`outcome'" == "PerceiveEngaged" {
        c_local ylow  = 2.0
        c_local yhigh = 4.5
        c_local ystep = 0.5
        c_local yfmt    "%9.1f"
    }
    else if "`outcome'" == "index_Post_overall" {
        c_local ylow  = -1.1
        c_local yhigh = 0.5
        c_local ystep = 0.2
        c_local yfmt    "%9.1f"
    }
    else {
        quietly summ `outcome'
        local _ylow  = r(min)
        local _yhigh = r(max)
        local _ystep = (`_yhigh' - `_ylow') / 5
        c_local ylow  = `_ylow'
        c_local yhigh = `_yhigh'
        c_local ystep = `_ystep'
        if      `_ystep' >= 1    c_local yfmt "%9.0f"
        else if `_ystep' >= 0.1  c_local yfmt "%9.1f"
        else                     c_local yfmt "%9.2f"
    }
end


// ============================================================================
// single_hist
//   Single-variable histogram. For the replication package this is used only
//   for Figure 1 (GuessWriter2).
//
//   Output: $output_dir/descriptives/<var>_Dist<figsuffix>.pdf
//
//   Parameters
//     var(name)          variable to plot
//     sample_number(#)   sample filter (sample# == 1)
//     figsuffix(string)  suffix appended before .pdf, e.g. "-Fig1"
//     [width(#)]         bin width for continuous vars (default 1)
//     [xlabel(string)]   additional xlabel options (e.g. valuelabel labsize(small))
//     [plow(#)]          lower percentile clip (default 1)
//     [phigh(#)]         upper percentile clip (default 99)
// ============================================================================
cap program drop single_hist
program define single_hist
    version 16.0
    syntax, var(name) sample_number(numlist) [figsuffix(string)] ///
        [width(numlist max=1)] [xlabel(string asis)]            ///
        [plow(numlist max=1)]  [phigh(numlist max=1)]

    if "`width'"  == "" local width  1
    if "`plow'"   == "" local plow   1
    if "`phigh'"  == "" local phigh  99

    preserve
        nice_name_as_label

        quietly keep if sample`sample_number' == 1
        quietly keep if !missing(`var')

        if _N == 0 {
            di as text "Note: No data for `var' in sample `sample_number'. Skipping."
            restore
            exit
        }

        local regopts "graphregion(color(white) margin(r+6)) plotregion(margin(small))"
        local yopts   `"ytitle("Fraction") ylabel(, grid angle(0))"'

        quietly summarize `var', meanonly
        local vmin = r(min)
        local vmax = r(max)

        local is_binary         = 0
        local is_small_discrete = 0
        if (`vmin'==0 & `vmax'==1) local is_binary = 1
        if (`vmin' >= 0 & `vmax' <= 10 & floor(`vmin')==`vmin' & floor(`vmax')==`vmax') ///
            local is_small_discrete = 1

        local clean_xlab = trim(`"`xlabel'"')
        if substr("`clean_xlab'",1,1) == "," local clean_xlab = trim(substr("`clean_xlab'",2,.))

        local xlabopt ""
        if (`is_binary' == 1) {
            local xlabopt "xlabel(0 1, angle(0)"
            if "`clean_xlab'" != "" local xlabopt "`xlabopt' `clean_xlab'"
            local xlabopt "`xlabopt')"
        }
        else if (`is_small_discrete' == 1) {
            local xlabopt "xlabel(`vmin'(1)`vmax', angle(0)"
            if "`clean_xlab'" != "" local xlabopt "`xlabopt' `clean_xlab'"
            local xlabopt "`xlabopt')"
        }
        else {
            if "`clean_xlab'" != "" local xlabopt "xlabel(`clean_xlab')"
        }

        capture mkdir "$output_dir/descriptives"

        if (`is_binary'==1) {
            histogram `var', fraction discrete start(-0.5) width(1) ///
                fcolor(navy%25) lcolor(navy%70)                      ///
                `regopts' `yopts' xscale(range(-0.5 1.5)) `xlabopt'
        }
        else if (`is_small_discrete'==1) {
            histogram `var', fraction discrete                              ///
                start(`= `vmin' - 0.5') width(1)                           ///
                fcolor(navy%25) lcolor(navy%70)                            ///
                `regopts' `yopts'                                           ///
                xscale(range(`= `vmin' - 0.5' `= `vmax' + 0.5')) `xlabopt'
        }
        else {
            quietly _pctile `var', p(`plow' `phigh')
            local lo = r(r1)
            local hi = r(r2)
            if (`hi' <= `lo') local hi = `lo' + 1
            histogram `var', fraction width(`width') ///
                fcolor(navy%25) lcolor(navy%70)       ///
                `regopts' `yopts' xscale(range(`lo' `hi')) `xlabopt'
        }

        graph export "$output_dir/descriptives/`var'_Dist`figsuffix'.pdf", replace
    restore
end


// ============================================================================
// nice_ciplot_4treat_pvalue
//   Four-treatment raw-mean CI plot with p-value annotation box.
//   Used for: Figures 2A, 2B, A1A, A1B (clean dataset) and Figure A6 (ff dataset).
//
//   Output: $output_dir/ciplots/<filetag><figsuffix>.pdf
//     filetag is constructed automatically from outcome, sname, and whether
//     the loaded dataset ends in _ff.dta.
//
//   Parameters
//     outcome(varname)   outcome variable
//     sample_number(#)   sample filter (sample# == 1)
//     slabel(string)     sample label used in x-axis title
//                        (when _ff.dta is loaded, ", Finished" is appended
//                        automatically — do NOT include it in slabel)
//     sname(string)      short tag for filename, e.g. "Full"
//     figsuffix(string)  suffix appended before .pdf, e.g. "-Fig2A"
// ============================================================================
cap program drop nice_ciplot_4treat_pvalue
program define nice_ciplot_4treat_pvalue
    version 17.0
    syntax, outcome(varname) sample_number(integer) ///
            slabel(string) sname(string) [figsuffix(string)]
    
    // 1. Finished-dataset detection (filename check only — no data access)
    local finished_tag = regexm(c(filename), "_ff\.dta")

    // 2. x-axis title and base filename stem
    //    When _ff.dta is used, ", Finished" is appended to slabel in xtitle
    //    and "_finished" is appended to the filename stem.
    if `finished_tag' {
        local xtitle  "Treatment Group (Co-sender Composition × Disclosure) - `slabel', Finished"
        local filetag "ciplot_`outcome'_`sname'_raw_finished"
    }
    else {
        local xtitle  "Treatment Group (Co-sender Composition × Disclosure) - `slabel'"
        local filetag "ciplot_`outcome'_`sname'_raw"
    }

    // 3. Output directory
    capture mkdir "$output_dir/ciplots"
    local outdir "$output_dir/ciplots"

    // 4. All data operations inside preserve/restore
    preserve

        keep if sample`sample_number' == 1 & !missing(`outcome')

        // y-axis settings (ylow, yhigh, ystep, yfmt) set via c_local
        yaxis_range_raw, outcome(`outcome')

        // y-axis title from standardised variable label
        nice_name_as_label
        local ytitle_final : variable label `outcome'
        if `"`ytitle_final'"' == "" local ytitle_final "`outcome'"

        // Arm counts for x-axis labels
        forvalues i = 1/4 {
            quietly count if Treatment_Group == `i'
            local n`i' = r(N)
        }

        // P-values: two-sided t-tests, unequal variance
        quietly ttest `outcome' if (Treatment_Group==1 | Treatment_Group==2), ///
            by(Treatment_Group) unequal
        local p12_str : di %6.3f r(p)

        quietly ttest `outcome' if (Treatment_Group==3 | Treatment_Group==4), ///
            by(Treatment_Group) unequal
        local p34_str : di %6.3f r(p)

        quietly ttest `outcome', by(Identify) unequal
        local p12_34_str : di %6.3f r(p)

        // True data bounds for CI capping
        quietly summ `outcome'
        local true_min = r(min)
        local true_max = r(max)

        // Collapse to cell means, SDs, and CIs
        collapse (count) n=`outcome' (mean) mean=`outcome' (sd) sd=`outcome', ///
            by(Treatment_Group)

        gen se       = sd / sqrt(n)
        gen tcrit    = invttail(n-1, 0.025)
        gen ci_lo    = mean - tcrit*se
        gen ci_hi    = mean + tcrit*se

        // Cap CIs at data bounds
        gen mean_plot  = mean
        gen ci_lo_plot = max(ci_lo, `true_min')
        gen ci_hi_plot = min(ci_hi, `true_max')

        // P-value box positioning
        local range_y = `yhigh' - `ylow'
        local gap     = `range_y' * 0.06
        local line2_y = `ylow' + (`range_y' * 0.15)   // maroon (middle row)
        local line1_y = `line2_y' + `gap'              // navy   (top row)
        local line3_y = `line2_y' - `gap'              // black  (bottom row)
        local box_x   = 0.7

        local c1 "navy"
        local c2 "maroon"
        local c3 "black"

        local txt1 "P-Value (No AI vs. AI | Anonymous) = `p12_str'"
        local txt2 "P-Value (No AI vs. AI | Identified) = `p34_str'"
        local txt3 "P-Value (Anonymous vs. Identified) = `p12_34_str'"

        twoway ///
            (rcap ci_hi_plot ci_lo_plot Treatment_Group if Treatment_Group <= 2, ///
                lcolor(`c1') lwidth(medthin)) ///
            (scatter mean_plot Treatment_Group if Treatment_Group <= 2, ///
                msymbol(Dh) msize(small) mcolor(none) mlcolor(`c1')) ///
            (rcap ci_hi_plot ci_lo_plot Treatment_Group if Treatment_Group > 2, ///
                lcolor(`c2') lwidth(medthin)) ///
            (scatter mean_plot Treatment_Group if Treatment_Group > 2, ///
                msymbol(Dh) msize(small) mcolor(none) mlcolor(`c2')) ///
            /* Dummy series for legend (never plotted) */ ///
            (scatter mean_plot Treatment_Group if 1==0, ///
                msymbol(Dh) msize(small) mcolor(none) mlcolor(black)) ///
            (rcap ci_hi_plot ci_lo_plot Treatment_Group if 1==0, ///
                lcolor(black) lwidth(medthin)), ///
            xlabel(1 `""No AI, Anonymous" "(n=`n1')""' ///
                   2 `""AI, Anonymous" "(n=`n2')""' ///
                   3 `""No AI, Identified" "(n=`n3')""' ///
                   4 `""AI, Identified" "(n=`n4')""', labsize(medsmall)) ///
            xtitle(`"`xtitle'"', size(small)) ///
            ytitle(`"`ytitle_final'"', size(small)) ///
            xscale(range(0.5 4.5)) ///
            yscale(range(`ylow' `yhigh')) ///
            ylabel(`ylow'(`ystep')`yhigh', format(`yfmt') labsize(medsmall)) ///
            /* Layer 1: white box background */ ///
            text(`line2_y' `box_x' "`txt1'" " " "`txt2'" " " "`txt3'", ///
                 place(e) box fcolor(white) lcolor(black) margin(vsmall) ///
                 size(small) justification(left) color(white)) ///
            /* Layer 2: navy text — top row */ ///
            text(`line1_y' `box_x' "`txt1'", ///
                 place(e) margin(small) size(small) justification(left) color(`c1')) ///
            /* Layer 3: maroon text — middle row */ ///
            text(`line2_y' `box_x' "`txt2'", ///
                 place(e) margin(small) size(small) justification(left) color(`c2')) ///
            /* Layer 4: black text — bottom row */ ///
            text(`line3_y' `box_x' "`txt3'", ///
                 place(e) margin(small) size(small) justification(left) color(`c3')) ///
            legend(off) ///
            plotregion(margin(zero)) ///
            name(Ci_4treat_nice, replace)

        graph display Ci_4treat_nice, xsize(10) ysize(7)
        graph export "`outdir'/`filetag'`figsuffix'.pdf", replace
        graph drop Ci_4treat_nice

    restore
end


// ============================================================================
// tbl_treat_eff_app
//   Three-column OLS regression table:
//     (1) No controls   (2) Demographics   (3) All pre-treatment controls
//   The table title matches the paper exactly for each outcome.
//
//   Output: $output_dir/tables/<fname><tabsuffix>.tex
//
//   Parameters
//     outcome(varname)   outcome variable
//     sample_number(#)   sample filter
//     slabel(string)     sample label (used in title unless overridden below)
//     sname(string)      short tag for filename, e.g. "Full"
//     tabsuffix(string)  suffix appended before .tex, e.g. "-TableA3"
// ============================================================================
capture program drop tbl_treat_eff_app
program define tbl_treat_eff_app

    syntax, outcome(varname) sample_number(integer) ///
            slabel(string) sname(string) [tabsuffix(string)]

    local col1_title "No Controls"
    local col2_title "Demographics"
    local col3_title "All Controls"

    // C2: Demographic controls (binarised to match HTE figures)
    local c2_controls "AgeBinary_adult Female Switzerland Grad_degree ETH Vote"

    // C3: Additional pre-treatment controls
    local c3_add_controls "Instagram_use not_shared_handle ImageConcernBinary_p50 DonationBinary_pos BotKnowBinary AIEffectiveBinary AIDiffBinary PostReactBinary ReadingReact1Binary ReadingReact2Binary Guess1_asHuman Guess2_asHuman BotSupport_AIBinary BotSocialMedia_AIBinary"

    preserve

    quietly keep if sample`sample_number' == 1 & !missing(`outcome')

    // Variable label for table title
    nice_name_as_label
    local ytitle : variable label `outcome'
    if "`ytitle'" == "" local ytitle "`outcome'"

    // Finished-dataset detection
    local finished_tag = regexm(c(filename), "_ff\.dta")

    // Filename stem
    if `finished_tag' {
        local fname "table_te_`outcome'_`sname'_finished"
    }
    else {
        local fname "table_te_`outcome'_`sname'"
    }

    // Table title — exactly as it appears in the paper
    // Table A3 paper title: "Treatment Effects on Finishing Study"
    if "`outcome'" == "Finished" {
        local tbl_title "Treatment Effects on Finishing Study"
    }
    else if `finished_tag' {
        local tbl_title "Treatment Effects on `ytitle' - `slabel', Finished"
    }
    else {
        local tbl_title "Treatment Effects on `ytitle' - `slabel'"
    }

    // Output directory
    capture mkdir "$output_dir/tables"
    local outdir "$output_dir/tables"

    // Forced base control for text-quality outcomes
    local forced_base ""
    if inlist("`outcome'", "Post_meaningfulness", "Post_TextLength_log", ///
              "Post_AIness", "index_Post_effort", "index_Post_nlp") {
        local forced_base = subinstr("`outcome'", "Post_", "Base_", 1)
    }

    // Three treatment indicators; base = NoAI × Anonymous = _cons
    local three_arms "Identify AITreat AIXIdentifyTreat"

    eststo clear
    local models_to_tab ""

    // Column 1: no controls
    capture quietly regress `outcome' `three_arms', vce(robust)
    if _rc == 0 {
        eststo model1
        local models_to_tab "`models_to_tab' model1"
    }

    // Column 2: demographic controls
    capture quietly regress `outcome' `three_arms' `c2_controls', vce(robust)
    if _rc == 0 {
        eststo model2
        local models_to_tab "`models_to_tab' model2"
    }

    // Column 3: demographics + forced base + full pre-treatment controls
    capture quietly regress `outcome' `three_arms' `c2_controls' ///
        `forced_base' `c3_add_controls', vce(robust)
    if _rc == 0 {
        eststo model3
        local models_to_tab "`models_to_tab' model3"
    }

    if "`models_to_tab'" != "" {
        esttab `models_to_tab' using "`outdir'/`fname'`tabsuffix'.tex", replace   ///
            main(b %9.3f) aux(se %9.3f)                                            ///
            starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001)                           ///
            label                                                                   ///
            keep(`three_arms' * _cons)                                              ///
            order(`three_arms')                                                     ///
            coeflabels(Identify         "Identified Treatment"                      ///
                       AITreat          "AI Treatment"                              ///
                       AIXIdentifyTreat "AI \$\times\$ Identified"                  ///
                       _cons            "Constant")                                 ///
            stats(r2_a N, fmt(%9.3f %9.0fc)                                        ///
                labels("Adj. \(R^2\)" "\(N\)"))                                    ///
            mtitles("`col1_title'" "`col2_title'" "`col3_title'")                  ///
            numbers                                                                  ///
            nonotes                                                                  ///
            booktabs compress width(\hsize)                                          ///
            prehead(`"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"'                  ///
                    `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                    `"\toprule"')                                                    ///
            postfoot(`"\bottomrule"'                                                 ///
                     `"\end{tabular*}"')
    }
    else {
        display as error "No models successfully estimated for `outcome' in sample `sample_number'."
    }

    restore
end


// ============================================================================
// hte_ciplot_raw
//   HTE CI plot: raw means split by a binary moderator (0 vs 1),
//   across four treatment groups.
//   Used for: Figures 3, A2, A3, A4, A5.
//
//   Output: $output_dir/ciplots/<filetag><figsuffix>.pdf
//     filetag is constructed automatically from outcome, moderator, sname,
//     and whether the loaded dataset ends in _ff.dta.
//
//   Parameters
//     outcome(varname)    outcome variable
//     moderator(varname)  binary moderator (0/1)
//     sample_number(#)    sample filter (sample# == 1)
//     slabel(string)      sample label used in x-axis title
//     sname(string)       short tag for filename, e.g. "Full" or "IGUsers"
//     figsuffix(string)   suffix appended before .pdf, e.g. "-Fig3"
// ============================================================================
cap program drop hte_ciplot_raw
program define hte_ciplot_raw
    version 17.0
    syntax, outcome(varname) moderator(varname) sample_number(integer) ///
            slabel(string) sname(string) [figsuffix(string)]

    // 1. Finished-dataset detection
    local finished_tag = regexm(c(filename), "_ff\.dta")

    // 2. x-axis title and base filename stem
    if `finished_tag' {
        local xtitle  "Treatment Group (Co-sender Composition × Disclosure) - `slabel', Finished"
        local filetag "ciplot_`outcome'_hte_`moderator'_`sname'_raw_finished"
    }
    else {
        local xtitle  "Treatment Group (Co-sender Composition × Disclosure) - `slabel'"
        local filetag "ciplot_`outcome'_hte_`moderator'_`sname'_raw"
    }

    // 3. Output directory
    capture mkdir "$output_dir/ciplots"
    local outdir "$output_dir/ciplots"

    // 4. All data operations inside preserve/restore
    preserve

        keep if sample`sample_number' == 1 & !missing(`outcome')

        // y-axis settings via c_local
        yaxis_range_raw, outcome(`outcome')

        // y-axis title
        nice_name_as_label
        local ytitle : variable label `outcome'
        if "`ytitle'" == "" local ytitle "`outcome'"

        // Moderator group labels (lab0 = moderator==0, lab1 = moderator==1)
        local moderator_lbl : variable label `moderator'
        if "`moderator_lbl'" == "" local moderator_lbl "`moderator'"
        local lab0 "Low `moderator_lbl'"
        local lab1 "High `moderator_lbl'"

        if "`moderator'" == "index_ClimateBinary" {
            local lab0 "Low Climate Concern"
            local lab1 "High Climate Concern"
        }
        else if "`moderator'" == "DonationBinary_pos" {
            local lab0 "Not Donated"
            local lab1 "Donated"
        }
        else if "`moderator'" == "AIDiffBinary" {
            local lab0 "Base-Task Perceived Similar to AI"
            local lab1 "Base-Task Perceived Distinct from AI"
        }
        else if "`moderator'" == "ImageConcernBinary_p50" {
            local lab0 "Low Image Concern"
            local lab1 "High Image Concern"
        }
        else if "`moderator'" == "not_shared_handle" {
            local lab0 "Low Exposure Sensitivity"
            local lab1 "High Exposure Sensitivity"
        }
        else if "`moderator'" == "BotKnowBinary" {
            local lab0 "Less Familiar with AI"
            local lab1 "Frequent AI User"
        }
        else if "`moderator'" == "AgeBinary_adult" {
            local lab0 "18-24 Years"
            local lab1 "25+ Years"
        }
        else if "`moderator'" == "Grad_degree" {
            local lab0 "Undergraduate Student"
            local lab1 "Graduate Student"
        }
        else if "`moderator'" == "Vote" {
            local lab0 "Did Not Vote in Last Election"
            local lab1 "Voted in Last Election"
        }
        else if "`moderator'" == "Switzerland" {
            local lab0 "Non-Swiss"
            local lab1 "Swiss"
        }
        else if "`moderator'" == "Female" {
            local lab0 "Male"
            local lab1 "Female"
        }
        else if "`moderator'" == "ETH" {
            local lab0 "Non-ETH"
            local lab1 "ETH"
        }
        else if "`moderator'" == "index_Base_effortBinary_p50" {
            local lab0 "Low Base-Task Effort"
            local lab1 "High Base-Task Effort"
        }
        else if "`moderator'" == "index_Base_nlpBinary_p50" {
            local lab0 "Low Base-Task NLP Quality"
            local lab1 "High Base-Task NLP Quality"
        }
        else if "`moderator'" == "Instagram_use" {
            local lab0 "Non-Instagram User"
            local lab1 "Instagram User"
        }
        else if "`moderator'" == "index_Image_minus_privacyBinary" {
            local lab0 "Low (Image - Exposure Sen.)"
            local lab1 "High (Image - Exposure Sen.)"
        }

        // Arm counts for x-axis labels
        forvalues i = 1/4 {
            quietly count if Treatment_Group == `i' & `moderator' == 0
            local n0`i' = r(N)
            quietly count if Treatment_Group == `i' & `moderator' == 1
            local n1`i' = r(N)
        }

        // P-values: No AI vs AI within Identified, by moderator group
        capture quietly ttest `outcome' if `moderator'==0 & ///
            (Treatment_Group==3 | Treatment_Group==4), by(Treatment_Group) unequal
        if _rc == 0  local p_lab0 : di %6.3f r(p)
        else         local p_lab0 "N/A"

        capture quietly ttest `outcome' if `moderator'==1 & ///
            (Treatment_Group==3 | Treatment_Group==4), by(Treatment_Group) unequal
        if _rc == 0  local p_lab1 : di %6.3f r(p)
        else         local p_lab1 "N/A"

        // P-value box text and vertical positioning
        local txt1 "P-Value (No AI vs. AI | Identified, `lab0') = `p_lab0'"
        local txt2 "P-Value (No AI vs. AI | Identified, `lab1') = `p_lab1'"

        local range_y = `yhigh' - `ylow'
        local gap     = `range_y' * 0.06
        local line2_y = `ylow' + (`range_y' * 0.12)   // maroon (bottom row)
        local line1_y = `line2_y' + `gap'              // navy   (top row)
        local box_y   = `line2_y' + (`gap' / 2)
        local box_x   = 0.7

        // Collapse separately for each moderator value, then append
        tempfile current_data
        quietly save `current_data'

        local c1 "navy"
        local c2 "maroon"

        // — moderator == 0 —
        keep if `moderator' == 0
        collapse (count) n=`outcome' (mean) beta=`outcome' (sd) sd=`outcome', ///
            by(Treatment_Group)
        gen se    = sd / sqrt(n)
        gen tcrit = invttail(n-1, 0.025)
        gen ci_lo = beta - tcrit*se
        gen ci_hi = beta + tcrit*se
        gen mod_group = 0
        tempfile mod0
        quietly save `mod0'

        // — moderator == 1 —
        use `current_data', clear
        keep if `moderator' == 1
        collapse (count) n=`outcome' (mean) beta=`outcome' (sd) sd=`outcome', ///
            by(Treatment_Group)
        gen se    = sd / sqrt(n)
        gen tcrit = invttail(n-1, 0.025)
        gen ci_lo = beta - tcrit*se
        gen ci_hi = beta + tcrit*se
        gen mod_group = 1

        append using `mod0'

        // Slight x-offset so both groups are distinguishable
        gen xpos = Treatment_Group - 0.15 if mod_group == 0
        replace xpos = Treatment_Group + 0.15 if mod_group == 1

        twoway ///
            (rcap ci_hi ci_lo xpos if mod_group==0, lcolor(`c1') lwidth(medthin)) ///
            (scatter beta xpos if mod_group==0, ///
                msymbol(Dh) msize(small) mcolor(none) mlcolor(`c1')) ///
            (rcap ci_hi ci_lo xpos if mod_group==1, lcolor(`c2') lwidth(medthin)) ///
            (scatter beta xpos if mod_group==1, ///
                msymbol(Dh) msize(small) mcolor(none) mlcolor(`c2')) ///
            , ///
            xlabel(1 `""No AI, Anonymous" "(n0=`n01') & (n1=`n11')""' ///
                   2 `""AI, Anonymous" "(n0=`n02') & (n1=`n12')""' ///
                   3 `""No AI, Identified" "(n0=`n03') & (n1=`n13')""' ///
                   4 `""AI, Identified" "(n0=`n04') & (n1=`n14')""', ///
                   labsize(small)) ///
            xscale(range(0.5 4.5)) ///
            yscale(range(`ylow' `yhigh')) ///
            ylabel(`ylow'(`ystep')`yhigh', format(`yfmt') labsize(medsmall)) ///
            xtitle("`xtitle'", size(small)) ///
            ytitle("`ytitle'", size(small)) ///
            /* Layer 1: white box background */ ///
            text(`box_y' `box_x' "`txt1'" " " "`txt2'", ///
                 place(e) box fcolor(white) lcolor(black) margin(small) ///
                 size(small) justification(left) color(white)) ///
            /* Layer 2: navy text — top row */ ///
            text(`line1_y' `box_x' "`txt1'", ///
                 place(e) margin(small) size(small) justification(left) color(`c1')) ///
            /* Layer 3: maroon text — bottom row */ ///
            text(`line2_y' `box_x' "`txt2'", ///
                 place(e) margin(small) size(small) justification(left) color(`c2')) ///
            legend(order(2 "`lab0'" 4 "`lab1'") pos(6) rows(1) ///
                size(small) region(lcolor(black) lwidth(thin))) ///
            plotregion(margin(zero)) ///
            name(g_raw_hte, replace)

        graph display g_raw_hte, xsize(10) ysize(7)
        graph export "`outdir'/`filetag'`figsuffix'.pdf", replace
        graph drop g_raw_hte

    restore
end
