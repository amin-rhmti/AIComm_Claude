// ============================================================================
// main_replication.do  —  Replication package
// "Sharing Opinions in the Shadow of AI"
// Ash, Lou, and Song (2026)
//
// All outputs are written to:  output_replication/
//   ├── descriptives/    Figure 1
//   ├── ciplots/         Figures 2A–2B, 3, A1A–A1B, A2–A6
//   └── tables/          Tables A1, A2, A3
//
// Input datasets (relative to $PATH/input/):
//   SwissSurvey_Insta_Experiment_clean.dta      n = 1,075  (all eligible, called analysis sample)
//   SwissSurvey_Insta_Experiment_clean_ff.dta   n =   929  (finished suffix)
//
// Output file inventory
// ─────────────────────────────────────────────────────────────────────────────
//  descriptives/
//    GuessWriter2_Dist-Fig1.pdf
//
//  ciplots/
//    ciplot_Finished_Full_raw-Fig2A.pdf
//    ciplot_Post_meaningfulness_Full_raw-Fig2B.pdf
//    ciplot_Finished_hte_not_shared_handle_Full_raw-Fig3.pdf
//    ciplot_Post_TextLength_log_Full_raw-FigA1A.pdf
//    ciplot_TimePost_W_Full_raw-FigA1B.pdf
//    ciplot_Finished_hte_not_shared_handle_IGUsers_raw-FigA2.pdf
//    ciplot_Finished_hte_AgeBinary_adult_Full_raw-FigA3.pdf
//    ciplot_Finished_hte_Switzerland_Full_raw-FigA4.pdf
//    ciplot_Finished_hte_Female_Full_raw-FigA5.pdf
//    ciplot_WTP_Full_raw_finished-FigA6.pdf
//
//  tables/
//    TableA1-TableA1.tex
//    TableA2-TableA2.tex
//    table_te_Finished_Full-TableA3.tex
// ============================================================================

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

* ── SET YOUR PROJECT PATH ────────────────────────────────────────────────────
global PATH "D:\Projects\Original\AIComm\analysis"
cd "$PATH"
* ─────────────────────────────────────────────────────────────────────────────

quietly include code/sub_programs_replication.do

* Single output directory used by all sub-programs
global output_dir "output_replication"

* Create output directory and its three subfolders
capture mkdir "$output_dir"
capture mkdir "$output_dir/descriptives"
capture mkdir "$output_dir/ciplots"
capture mkdir "$output_dir/tables"


// ============================================================================
// TABLES A1 AND A2
//   Dataset : SwissSurvey_Insta_Experiment_clean.dta  (n=1,075)
//   Programs: estpost / esttab  (inline — no sub-program wrapper)
//
//   Outputs
//     output_replication/tables/TableA1-TableA1.tex
//     output_replication/tables/TableA2-TableA2.tex
// ============================================================================

use input/SwissSurvey_Insta_Experiment_clean.dta, clear
nice_name_as_label

local tabA2_vars Age Female Switzerland Grad_degree Vote ETH             ///
    Donation Instagram_use ImageConcern not_shared_handle index_Climate  ///
    BotKnow InitialAIEffective BaseAIDiff                                ///
    PostReactBinary ReadingReact1Binary ReadingReact2Binary              ///
    Guess1_asHuman Guess2_asHuman                                        ///
    BotSupport_AI BotSocialMedia_AI


// ── TABLE A1: Sample Demographics ──────────────────────────────────────────

local tabA1_vars Age Female Switzerland Grad_degree Vote

eststo clear
estpost tabstat `tabA1_vars', statistics(mean) columns(statistics)
est store sample_col

preserve
replace Age         = 50.01
replace Female      = 0.50
replace Switzerland = 0.72
replace Grad_degree = 0.15
replace Vote        = 0.36
estpost tabstat `tabA1_vars', statistics(mean) columns(statistics)
est store swiss_col
restore

esttab sample_col swiss_col                                               ///
    using "$output_dir/tables/TableA1-TableA1.tex",                       ///
    mtitle("\shortstack{Analysis\\sample}" "\shortstack{Swiss\\adults}")  ///
    collabels(none) nodepvars noobs replace label                         ///
    cells(mean(fmt(%9.2fc)))                                              ///
    prehead("\begin{tabular}{l*{2}{c}}"                                   ///
            "\hline\hline")                                               ///
    postfoot("\hline\hline"                                               ///
             "\end{tabular}")

est clear


// ── TABLE A2: Descriptive Statistics and Balance Tests ──────────────────────

* Group counts
forvalues g = 1/4 {
    quietly count if Treatment_Group == `g'
    local n`g' = r(N)
}
local n12   = `n1' + `n2'
local n34   = `n3' + `n4'
local n13   = `n1' + `n3'
local n1234 = `n1' + `n2' + `n3' + `n4'

* F-tests of joint significance — the table reports the F-statistic (not p-value)
* Col (1)–(2): AI treatment within anonymous condition
gen byte _treat12 = (Treatment_Group == 1) if inlist(Treatment_Group, 1, 2)
quietly regress _treat12 `tabA2_vars' if inlist(Treatment_Group, 1, 2), robust
local ftest_p1 = strtrim(string(e(F), "%9.2f"))
local ftest_n1 = e(N)
drop _treat12

* Col (3)–(4): AI treatment within identified condition
gen byte _treat34 = (Treatment_Group == 3) if inlist(Treatment_Group, 3, 4)
quietly regress _treat34 `tabA2_vars' if inlist(Treatment_Group, 3, 4), robust
local ftest_p2 = strtrim(string(e(F), "%9.2f"))
local ftest_n2 = e(N)
drop _treat34

* Col (1)–(3): identification effect, no-AI condition
gen byte _treat13 = (Treatment_Group == 1) if inlist(Treatment_Group, 1, 3)
quietly regress _treat13 `tabA2_vars' if inlist(Treatment_Group, 1, 3), robust
local ftest_p3 = strtrim(string(e(F), "%9.2f"))
local ftest_n3 = e(N)
drop _treat13

* Col (1,2)–(3,4): identification effect, pooled
quietly regress Identify `tabA2_vars', robust
local ftest_p4 = strtrim(string(e(F), "%9.2f"))
local ftest_n4 = e(N)

* Summary statistics and t-test p-values
eststo clear
forvalues g = 1/4 {
    eststo group`g': quietly estpost summarize `tabA2_vars' if Treatment_Group == `g'
}

quietly estpost ttest `tabA2_vars' if inlist(Treatment_Group,1,2), by(Treatment_Group) unequal
estadd matrix mean = e(p)
eststo diff1

quietly estpost ttest `tabA2_vars' if inlist(Treatment_Group,3,4), by(Treatment_Group) unequal
estadd matrix mean = e(p)
eststo diff2

quietly estpost ttest `tabA2_vars' if inlist(Treatment_Group,1,3), by(Treatment_Group) unequal
estadd matrix mean = e(p)
eststo diff3

quietly estpost ttest `tabA2_vars', by(Identify) unequal
estadd matrix mean = e(p)
eststo diff4

esttab group1 group2 group3 group4 diff1 diff2 diff3 diff4               ///
    using "$output_dir/tables/TableA2-TableA2.tex", replace label        ///
    keep(`tabA2_vars')                                                    ///
    main(mean %9.3f) aux(sd %9.3f)                                       ///
    compress nogaps                                                       ///
    collabels(none) nomtitles noobs nonumbers nostar nolines              ///
    prehead("\begin{tabular}{l*{8}{c}}"                                   ///
            "\hline\hline"                                                ///
            "& \multicolumn{4}{c}{Summary Statistics}"                   ///
            "& \multicolumn{4}{c}{\textit{p}-values} \\"                 ///
            "& (1) & (2) & (3) & (4)"                                    ///
            "& (1)--(2) & (3)--(4) & (1)--(3) & (1,2)--(3,4) \\"        ///
            "& No AI, Anon. & AI, Anon. & No AI, Ident. & AI, Ident."   ///
            "& & & & \\"                                                  ///
            "& Mean/SD & Mean/SD & Mean/SD & Mean/SD & & & & \\"         ///
            "\hline")                                                     ///
    postfoot("\textit{N} & `n1' & `n2' & `n3' & `n4'"                   ///
             "& `n12' & `n34' & `n13' & `n1234' \\"                      ///
             "\midrule"                                                   ///
             "F-test of joint significance (F-statistic)"                ///
             "& & & &"                                                    ///
             "& `ftest_p1' & `ftest_p2' & `ftest_p3' & `ftest_p4' \\"   ///
             "F-test, number of observations"                            ///
             "& & & &"                                                    ///
             "& `ftest_n1' & `ftest_n2' & `ftest_n3' & `ftest_n4' \\"   ///
             "\hline\hline"                                               ///
             "\end{tabular}")

eststo clear


// ============================================================================
// FIGURE 1  —  Reading task: guessing writer identity
//   Dataset : SwissSurvey_Insta_Experiment_clean.dta  (n=1,075), sample 2
//   Program : single_hist
//   Variable: GuessWriter2  (second reading task — AI-mixed pool)
//     Values: 1 = Human, 2 = Rule-based bot, 3 = Gen-AI bot
//   x-axis title : "Guess for Writer Identity"  (from nice_name_as_label)
//   y-axis title : "Fraction"
//   Output  : output_replication/descriptives/GuessWriter2_Dist-Fig1.pdf
// ============================================================================

use input/SwissSurvey_Insta_Experiment_clean.dta, clear

* Ensure all three values are labelled (data may already carry value 1 = Human)
label define GuessWriter2 1 "Human" 2 "Rule-based bot" 3 "Gen-AI bot", replace

single_hist, var(GuessWriter2) sample_number(2) xlabel(valuelabel labsize(small))


// ============================================================================
// FIGURES 2A, 2B, A1A, A1B  AND  TABLE A3
//   Dataset : SwissSurvey_Insta_Experiment_clean.dta  (n=1,075), sample 2
//             Outcomes imputed to 0 for non-completers (matching the paper)
//   Programs: nice_ciplot_4treat_pvalue  → figures
//             tbl_treat_eff_app          → Table A3
//
//  Figure 2A  ciplot_Finished_Full_raw-Fig2A.pdf
//    y-axis : "Survey Completion"
//    y-range: 0.60 – 1.00  (step 0.05)
//    x-title: "Treatment Group (Co-sender Composition × Disclosure) - Analysis Sample"
//
//  Figure 2B  ciplot_Post_meaningfulness_Full_raw-Fig2B.pdf
//    y-axis : "Wrote Meaningful Post"
//    y-range: 0.55 – 1.00  (step 0.05)
//    x-title: same as above
//
//  Figure A1A  ciplot_Post_TextLength_log_Full_raw-FigA1A.pdf
//    y-axis : "Ln (1+ Post-Task Character Count)"
//    y-range: 3.0 – 6.0  (step 0.5)
//
//  Figure A1B  ciplot_TimePost_W_Full_raw-FigA1B.pdf
//    y-axis : "Time on Post-Task (s)"
//    y-range: 0 – 700  (step 100)
//
//  Table A3  table_te_Finished_Full-TableA3.tex
//    Title  : "Treatment Effects on Finishing Study"
//    Columns: No Controls / Demographics / All Controls
// ============================================================================

use input/SwissSurvey_Insta_Experiment_clean.dta, clear
foreach v in Finished Post_meaningfulness Post_TextLength_log TimePost_W {
    replace `v' = 0 if missing(`v')
}

* Figure 2A
nice_ciplot_4treat_pvalue, outcome(Finished) sample_number(2) ///
    slabel("Analysis Sample") sname("Full")

* Figure 2B
nice_ciplot_4treat_pvalue, outcome(Post_meaningfulness) sample_number(2) ///
    slabel("Analysis Sample") sname("Full")

* Figure A1A
nice_ciplot_4treat_pvalue, outcome(Post_TextLength_log) sample_number(2) ///
    slabel("Analysis Sample") sname("Full")

* Figure A1B
nice_ciplot_4treat_pvalue, outcome(TimePost_W) sample_number(2) ///
    slabel("Analysis Sample") sname("Full")

* Table A3
tbl_treat_eff_app, outcome(Finished) sample_number(2) ///
    slabel("Analysis Sample") sname("Full")


// ============================================================================
// FIGURES 3, A2, A3, A4, A5  —  Heterogeneous treatment effects (HTE)
//   Dataset : SwissSurvey_Insta_Experiment_clean.dta  (n=1,075)
//             Finished imputed to 0 for non-completers
//   Program : hte_ciplot_raw
//
//  Figure 3   ciplot_Finished_hte_not_shared_handle_Full_raw-Fig3.pdf
//    Moderator : not_shared_handle  (0=low, 1=high exposure sensitivity)
//    Sample    : 2 (Analysis Sample, n=1,075)
//    y-axis    : "Survey Completion"
//    y-range   : 0.60 – 1.00  (step 0.05)
//    x-title   : "Treatment Group (Co-sender Composition × Disclosure) - Analysis Sample"
//    Legend    : Low Exposure Sensitivity  /  High Exposure Sensitivity
//
//  Figure A2  ciplot_Finished_hte_not_shared_handle_IGUsers_raw-FigA2.pdf
//    Moderator : not_shared_handle
//    Sample    : 20 (Instagram User Sample)
//    x-title   : "Treatment Group (Co-sender Composition × Disclosure) - Instagram User Sample"
//
//  Figure A3  ciplot_Finished_hte_AgeBinary_adult_Full_raw-FigA3.pdf
//    Moderator : AgeBinary_adult  (0=18–24, 1=25+)
//    Sample    : 2 (Analysis Sample)
//    Legend    : 18-24 Years  /  25+ Years
//
//  Figure A4  ciplot_Finished_hte_Switzerland_Full_raw-FigA4.pdf
//    Moderator : Switzerland  (0=Non-Swiss, 1=Swiss)
//    Sample    : 2 (Analysis Sample)
//    Legend    : Non-Swiss  /  Swiss
//
//  Figure A5  ciplot_Finished_hte_Female_Full_raw-FigA5.pdf
//    Moderator : Female  (0=Male, 1=Female)
//    Sample    : 2 (Analysis Sample)
//    Legend    : Male  /  Female
// ============================================================================

use input/SwissSurvey_Insta_Experiment_clean.dta, clear
replace Finished = 0 if missing(Finished)

* Figure 3
hte_ciplot_raw, outcome(Finished) moderator(not_shared_handle) ///
    sample_number(2) slabel("Analysis Sample") sname("Full")

* Figure A2
hte_ciplot_raw, outcome(Finished) moderator(not_shared_handle) ///
    sample_number(20) slabel("Instagram User Sample") sname("IGUsers")

* Figure A3
hte_ciplot_raw, outcome(Finished) moderator(AgeBinary_adult) ///
    sample_number(2) slabel("Analysis Sample") sname("Full")

* Figure A4
hte_ciplot_raw, outcome(Finished) moderator(Switzerland) ///
    sample_number(2) slabel("Analysis Sample") sname("Full")

* Figure A5
hte_ciplot_raw, outcome(Finished) moderator(Female) ///
    sample_number(2) slabel("Analysis Sample") sname("Full")


// ============================================================================
// FIGURE A6  —  Willingness to pay to remove post
//   Dataset : SwissSurvey_Insta_Experiment_clean_ff.dta  (n=929, finished only)
//             No imputation needed — all observations have completed the survey
//   Program : nice_ciplot_4treat_pvalue
//             The _ff.dta filename triggers finished_tag=1, so:
//               xtitle = "...Analysis Sample, Finished"  (auto-appended)
//               filetag = "ciplot_WTP_Full_raw_finished"
//   y-axis  : "WTP to Remove Post (CHF)"
//   y-range : -1.5 – 2.5  (step 0.5)
//   x-title : "Treatment Group (Co-sender Composition × Disclosure) - Analysis Sample, Finished"
//   Output  : output_replication/ciplots/ciplot_WTP_Full_raw_finished-FigA6.pdf
// ============================================================================

use input/SwissSurvey_Insta_Experiment_clean_ff.dta, clear

* slabel = "Analysis Sample" — the program auto-appends ", Finished" when _ff.dta is detected
nice_ciplot_4treat_pvalue, outcome(WTP) sample_number(2) ///
    slabel("Analysis Sample") sname("Full")


di as result "=== Replication complete. All outputs written to output_replication/ ==="
