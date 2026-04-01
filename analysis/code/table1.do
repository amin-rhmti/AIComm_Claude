clear all
macro drop _all
set scheme s1manual
grstyle init
grstyle set plain, horizontal grid
set seed 2025
set graphics on

global PATH "D:\Projects\Original\AIComm\analysis"
cd "$PATH"
quietly include code/sub_programs.do
capture mkdir "output"
global output_folder "output/summary_stats"
capture mkdir "$output_folder"
use input/SwissSurvey_Insta_Experiment_clean.dta, clear
nice_name_as_label

local tabA3_vars Age Female Switzerland Grad_degree Vote ETH             ///
    Donation Instagram_use ImageConcern not_shared_handle index_Climate  ///
    BotKnow InitialAIEffective BaseAIDiff                                ///
    PostReactBinary ReadingReact1Binary ReadingReact2Binary              ///
    Guess1_asHuman Guess2_asHuman                                        ///
    BotSupport_AI BotSocialMedia_AI

misstable summarize `tabA3_vars'

gen byte _treat34 = (Treatment_Group == 3) if inlist(Treatment_Group, 3, 4)
regress _treat34 `tabA3_vars' if inlist(Treatment_Group, 3, 4), robust
*local ftest_p2 = strtrim(string(Ftail(e(df_m), e(df_r), e(F)), "%9.3f"))
local ftest_p2 = strtrim(string(e(F), "%9.3f"))
local ftest_n2 = e(N)
di "p-value: `ftest_p2' and n = `ftest_n2'"
drop _treat34

* ════════════════════════════════════════════════════════════════
* TABLE A1: Sample Demographics
* ════════════════════════════════════════════════════════════════
global tableA1_file "$output_folder/TableA1.tex"

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

esttab sample_col swiss_col using "$tableA1_file",                        ///
    mtitle("\shortstack{Analysis\\sample}" "\shortstack{Swiss\\adults}")  ///
    collabels(none) nodepvars noobs replace label                         ///
    cells(mean(fmt(%9.2fc)))                                              ///
    prehead("\documentclass{article}"                                     ///
            "\usepackage[margin=0.75in]{geometry}"                        ///
            "\usepackage{graphicx}"                                       ///
            "\usepackage{booktabs}"                                       ///
            "\usepackage{array}"                                          ///
            "\usepackage{caption}"                                        ///
            "\begin{document}"                                            ///
            "\begin{table}[htbp]"                                         ///
            "\centering"                                                   ///
            "\caption*{Sample Demographics}"                              ///
            "\label{tab:TableA1}"                                         ///
            "\renewcommand{\arraystretch}{1.2}"                           ///
            "\scalebox{1.2}{"                                             ///
            "\begin{tabular}{l*{2}{c}}"                                   ///
            "\hline\hline")                                               ///
    postfoot("\hline\hline"                                               ///
             "\end{tabular}}"                                             ///
             "\begin{minipage}{\textwidth}"                               ///
             "\footnotesize \medskip \textit{Notes:} Column 1 presents"  ///
             "average demographics for the full eligible sample in this"  ///
             "study. Column 2 presents average demographics of all"       ///
             "residents of Switzerland aged 18 or older using data from"  ///
             "the 2023 Swiss Federal Statistical Office (FSO) Population" ///
             "and Households Statistics (STATPOP), the FSO Structural"    ///
             "Survey and Swiss Labour Force Survey (for educational"       ///
             "attainment and migration status), and official 2023"        ///
             "National Council election statistics."                       ///
             "\end{minipage}"                                             ///
             "\end{table}"                                                ///
             "\end{document}")

est clear


* ════════════════════════════════════════════════════════════════
* TABLE A2: Descriptive Statistics and Balance Tests
* ════════════════════════════════════════════════════════════════
global tableA2_file "$output_folder/TableA2.tex"

local tabA3_vars Age Female Switzerland Grad_degree Vote ETH             ///
    Donation Instagram_use ImageConcern not_shared_handle index_Climate  ///
    BotKnow InitialAIEffective BaseAIDiff                                ///
    PostReactBinary ReadingReact1Binary ReadingReact2Binary              ///
    Guess1_asHuman Guess2_asHuman                                        ///
    BotSupport_AI BotSocialMedia_AI

* ── Pre-compute group N values ──
forvalues g = 1/4 {
    quietly count if Treatment_Group == `g'
    local n`g' = r(N)
}
local n12   = `n1' + `n2'
local n34   = `n3' + `n4'
local n13   = `n1' + `n3'
local n1234 = `n1' + `n2' + `n3' + `n4'

* ── F-tests of joint significance ──
* Col 5: Groups 1 vs 2  (AI treatment, anonymous)
gen byte _treat12 = (Treatment_Group == 1) if inlist(Treatment_Group, 1, 2)
quietly regress _treat12 `tabA3_vars' if inlist(Treatment_Group, 1, 2), robust
*p-value
*local ftest_p1 = strtrim(string(Ftail(e(df_m), e(df_r), e(F)), "%9.3f"))
* F-statistic
local ftest_p1 = strtrim(string(e(F), "%9.2f"))
local ftest_n1 = e(N)
drop _treat12

* Col 6: Groups 3 vs 4  (AI treatment, identified)
gen byte _treat34 = (Treatment_Group == 3) if inlist(Treatment_Group, 3, 4)
quietly regress _treat34 `tabA3_vars' if inlist(Treatment_Group, 3, 4), robust
*local ftest_p2 = strtrim(string(Ftail(e(df_m), e(df_r), e(F)), "%9.3f"))
local ftest_p2 = strtrim(string(e(F), "%9.2f"))
local ftest_n2 = e(N)
drop _treat34

* Col 7: Groups 1 vs 3  (identification effect, no AI)
gen byte _treat13 = (Treatment_Group == 1) if inlist(Treatment_Group, 1, 3)
quietly regress _treat13 `tabA3_vars' if inlist(Treatment_Group, 1, 3), robust
*local ftest_p3 = strtrim(string(Ftail(e(df_m), e(df_r), e(F)), "%9.3f"))
local ftest_p3 = strtrim(string(e(F), "%9.2f"))
local ftest_n3 = e(N)
drop _treat13

* Col 8: Groups 1,2 vs 3,4  (identification effect, pooled)
quietly regress Identify `tabA3_vars', robust
*local ftest_p4 = strtrim(string(Ftail(e(df_m), e(df_r), e(F)), "%9.3f"))
local ftest_p4 = strtrim(string(e(F), "%9.2f"))
local ftest_n4 = e(N)

* ── Summary statistics and t-test p-values ──
eststo clear
forvalues g = 1/4 {
    eststo group`g': quietly estpost summarize `tabA3_vars' if Treatment_Group == `g'
}

quietly estpost ttest `tabA3_vars' if inlist(Treatment_Group,1,2), by(Treatment_Group) unequal
estadd matrix mean = e(p)
eststo diff1

quietly estpost ttest `tabA3_vars' if inlist(Treatment_Group,3,4), by(Treatment_Group) unequal
estadd matrix mean = e(p)
eststo diff2

quietly estpost ttest `tabA3_vars' if inlist(Treatment_Group,1,3), by(Treatment_Group) unequal
estadd matrix mean = e(p)
eststo diff3

quietly estpost ttest `tabA3_vars', by(Identify) unequal
estadd matrix mean = e(p)
eststo diff4

esttab group1 group2 group3 group4 diff1 diff2 diff3 diff4               ///
    using "$tableA2_file", replace label                                  ///
    keep(`tabA3_vars')                                                    ///
    main(mean %9.3f) aux(sd %9.3f)                                       ///
    compress nogaps                                                       ///
    collabels(none) nomtitles noobs nonumbers nostar nolines              ///
    prehead("\documentclass{article}"                                     ///
            "\usepackage[margin=0.75in]{geometry}"                        ///
            "\usepackage{graphicx}"                                       ///
            "\usepackage{booktabs}"                                       ///
            "\usepackage{array}"                                          ///
            "\usepackage{caption}"                                        ///
            "\begin{document}"                                            ///
            "\begin{table}[htbp]"                                         ///
            "\centering"                                                   ///
            "\caption*{Descriptive Statistics and Balance Tests}"         ///
            "\label{tab:TableA2}"                                         ///
            "\small"                                                       ///
            "\renewcommand{\arraystretch}{1.2}"                           ///
            "\resizebox{\textwidth}{!}{"                                  ///
            "\begin{tabular}{l*{8}{c}}"                                   ///
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
             "F-test of joint significance (F-statistic)"	           ///
             "& & & &"                                                    ///
             "& `ftest_p1' & `ftest_p2' & `ftest_p3' & `ftest_p4' \\"   ///
             "F-test, number of observations"                            ///
             "& & & &"                                                    ///
             "& `ftest_n1' & `ftest_n2' & `ftest_n3' & `ftest_n4' \\"   ///
             "\hline\hline"                                               ///
             "\end{tabular}}"                                             ///
             "\begin{minipage}{\textwidth}"                               ///
             "\footnotesize \medskip \textit{Notes:} Columns 1--4 report" ///
             "means with standard deviations in parentheses by treatment"  ///
             "arm: (1) No AI \& Anonymous, (2) AI \& Anonymous,"         ///
             "(3) No AI \& Identified, (4) AI \& Identified."            ///
             "Columns 5--8 report \textit{p}-values from"                ///
             "unequal-variance \textit{t}-tests for each pairwise"       ///
             "comparison."           ///
             "\end{minipage}"                                             ///
             "\end{table}"                                                ///
             "\end{document}")

eststo clear