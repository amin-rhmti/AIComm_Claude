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
use input/SwissSurvey_Insta_Experiment_clean.dta, clear


* ════════════════════════════════════════════════════════════════
* Combined Tables A1, A2, A3
* ════════════════════════════════════════════════════════════════
global tableA_file "$output_folder/Table1.tex"

* ─────────────────────────────────────────────────────────────
* TABLE A1: Sample Demographics
* ─────────────────────────────────────────────────────────────
local tabA1_vars Age Female Switzerland Grad_degree Vote

label variable Age         "Age"
label variable Female      "Gender (Female)"
label variable Switzerland "Swiss"
label variable Grad_degree "Graduate Student"
label variable Vote        "Voted in Last Election"

eststo clear
estpost tabstat `tabA1_vars', statistics(mean) columns(statistics)
est store sample_col

preserve
replace Age         = 42.80
replace Female      = 0.50
replace Switzerland = 0.72
replace Grad_degree = 0.31
replace Vote        = 0.29
estpost tabstat `tabA1_vars', statistics(mean) columns(statistics)
est store swiss_col
restore

esttab sample_col swiss_col using "$tableA_file",                         ///
    mtitle("\shortstack{Analysis\\sample}" "\shortstack{Swiss\\adults}")  ///
    coeflabels(                                                            ///
        Age         "Age"                                                  ///
        Female      "Gender (Female)"                                      ///
        Switzerland "Swiss"                                                ///
        Grad_degree "Graduate Student"                                     ///
        Vote        "Voted in Last Election")                              ///
    collabels(none) nodepvars noobs replace                                ///
    cells(mean(fmt(%9.2fc)))                                               ///
    prehead("\documentclass{article}"                                      ///
            "\usepackage[margin=0.75in]{geometry}"                         ///
			"\usepackage{graphicx}"                                        ///
            "\usepackage{booktabs}"                                        ///
            "\usepackage{array}"                                           ///
            "\begin{document}"                                             ///
            "\setcounter{table}{0}"                                        ///
            "\renewcommand{\thetable}{A\arabic{table}}"                    ///
            "\begin{table}[htbp]"                                          ///
            "\centering"                                                    ///
            "\caption{Sample Demographics}"                                ///
            "\label{tab:TableA1}"                                          ///
            "\renewcommand{\arraystretch}{1.2}"                            ///
            "\begin{tabular}{l*{2}{c}}"                                    ///
            "\hline\hline")                                                ///
    postfoot("\hline\hline"                                                ///
             "\multicolumn{3}{p{0.4\textwidth}}{\footnotesize"             ///
             "\textit{Notes:} Column 1 presents average demographics"     ///
             "for the full eligible sample in this study."                ///
             "Column 2 presents average demographics of Swiss permanent"  ///
             "residents using data from the 2023 Swiss Federal"           ///
             "Statistical Office (FSO) STATPOP register, educational"     ///
             "attainment survey, and National Council election statistics.}" ///
             "\end{tabular}"                                               ///
             "\end{table}")

est clear

* ─────────────────────────────────────────────────────────────
* TABLE A2: Response Rates
* ─────────────────────────────────────────────────────────────
// label variable Finished "Completed Survey"
//
// eststo clear
// forvalues g = 1/4 {
//     eststo att_`g': quietly estpost summarize Finished if Treatment_Group == `g'
// }
//
// quietly reg Finished i.Treatment_Group
// local fval = Ftail(e(df_m), e(df_r), e(F))
// preserve
// replace Finished = `fval'
// quietly estpost summarize Finished
// est store att_ftest
// restore
//
// esttab att_1 att_2 att_3 att_4 att_ftest                                  ///
//     using "$tableA_file", append                                           ///
//     keep(Finished)                                                         ///
//     cells("mean(fmt(3))")                                                  ///
//     label collabels(none) nodepvars noobs nonumbers nomtitles nostar nolines ///
//     coeflabels(Finished "Completed Survey")                                ///
//     prehead("\begin{table}[htbp]"                                          ///
//             "\centering"                                                    ///
//             "\caption{Response Rates}"                                     ///
//             "\label{tab:TableA2}"                                          ///
//             "\renewcommand{\arraystretch}{1.2}"                            ///
//             "\begin{tabular}{l*{5}{c}}"                                    ///
//             "\hline\hline"                                                 ///
//             "& (1) & (2) & (3) & (4) & \\"                                ///
//             "& No AI, Anon. & AI, Anon. & No AI, Ident. & AI, Ident."    ///
//             "& \shortstack{F-test\\\textit{p}-value} \\"                   ///
//             "\midrule")                                                    ///
//     postfoot("\hline\hline"                                                ///
//              "\multicolumn{6}{p{0.85\textwidth}}{\footnotesize"           ///
//              "\textit{Notes:} This table presents response rates by"      ///
//              "treatment arm. The F-test \textit{p}-value tests for"       ///
//              "differences across all four treatment conditions.}"          ///
//              "\end{tabular}"                                               ///
//              "\end{table}")
//
// est clear

* ─────────────────────────────────────────────────────────────
* TABLE A3: Descriptive Statistics and Balance Tests
* ─────────────────────────────────────────────────────────────
local tabA3_vars Age Female Switzerland Grad_degree Vote ETH ///
    Donation Instagram_use ImageConcern shared_handle index_Climate ///
    BotKnow InitialAIEffective BaseAIDiff ///
    PostReact ReadingReact1 ReadingReact2 ///					
	GuessHuman_asHuman GuessAI_asHuman ///
    BotSupport_AI BotSocialMedia_AI

* ── Pre-compute N values ──
forvalues g = 1/4 {
    quietly count if Treatment_Group == `g'
    local n`g' = r(N)
}
local n12  = `n1' + `n2'
local n34  = `n3' + `n4'
local n13  = `n1' + `n3'
local n1234 = `n1' + `n2' + `n3' + `n4'

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

esttab group1 group2 group3 group4 diff1 diff2 diff3 diff4                ///
    using "$tableA_file", append                                           ///
    keep(`tabA3_vars')                                                     ///
    main(mean %9.3f) aux(sd %9.3f)                                        ///
    compress nogaps                                                        ///
    coeflabels(                                                            ///
        Age               "Age"                                            ///
        Female            "Gender (Female)"                                ///
        Switzerland       "Swiss"                                          ///
        Grad_degree       "Graduate Student"                               ///
        Vote              "Voted in Last Election"                         ///
        ETH               "ETH"                                            ///
        Donation          "Donation (CHF)"                                 ///
        Instagram_use     "Instagram User"                                 ///
        ImageConcern      "Image Concern (1-5)"                            ///
        shared_handle     "Exposure Risk"                                  ///
        index_Climate     "Climate Concern Index"                          ///
        BotKnow           "AI Familiarity (1-5)"                          ///
        InitialAIEffective "AI Persuasion (1-5)"                          ///
        BaseAIDiff        "Base AI Difference (1-5)"                      ///
        PostReact         "Reaction to (Human) Content"                    ///
        ReadingReact1     "Reaction to Human Content"                      ///
        ReadingReact2     "Reaction to Pool Content"                       ///
        GuessHuman_asHuman  "Guess Human Content as Human"                 ///
        GuessAI_asHuman     "Guess AI Content as Human"                    ///
        BotSupport_AI     "Customer Support Bot (1-5)"                     ///
        BotSocialMedia_AI "Social Media Bot (1-5)")                        ///
    collabels(none) nomtitles noobs nonumbers nostar nolines               ///
    prehead("\begin{table}[htbp]"                                          ///
            "\centering"                                                    ///
            "\caption{Descriptive Statistics and Balance Tests}"           ///
            "\label{tab:TableA3}"                                          ///
            "\small"                                                        ///
            "\renewcommand{\arraystretch}{1.2}"                            ///
            "\resizebox{\textwidth}{!}{"                                   ///
            "\begin{tabular}{l*{8}{c}}"                                    ///
            "\hline\hline"                                                 ///
            "& \multicolumn{4}{c}{Summary Statistics}"                    ///
            "& \multicolumn{4}{c}{\textit{p}-values} \\"                  ///
            "& (1) & (2) & (3) & (4)"                                     ///
            "& (1)--(2) & (3)--(4) & (1)--(3) & (1,2)--(3,4) \\"         ///
            "& No AI, Anon. & AI, Anon. & No AI, Ident. & AI, Ident."    ///
            "& & & & \\"                                                   ///
            "& Mean/SD & Mean/SD & Mean/SD & Mean/SD & & & & \\"          ///
            "\hline")                                                      ///
    postfoot("\midrule"                                                    ///
             "\textit{N} & `n1' & `n2' & `n3' & `n4'"                    ///
             "& `n12' & `n34' & `n13' & `n1234' \\"                       ///
             "\hline\hline"                                                ///
             "\end{tabular}}"                                              ///
             "\begin{minipage}{\textwidth}"                                ///
             "\footnotesize \medskip \textit{Notes:} Columns 1--4 report" ///
             "means with standard deviations in parentheses by treatment"  ///
             "arm: (1) No AI \& Anonymous, (2) AI \& Anonymous,"          ///
             "(3) No AI \& Identified, (4) AI \& Identified."             ///
             "Columns 5--8 report \textit{p}-values from"                 ///
             "unequal-variance \textit{t}-tests for each pairwise"        ///
             "comparison."                                                 ///
             "\end{minipage}"                                              ///
             "\end{table}"                                                 ///
             "\end{document}")

eststo clear