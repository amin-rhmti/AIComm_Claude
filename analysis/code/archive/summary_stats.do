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

use input/SwissSurvey_Insta_Experiment_Clean.dta,clear



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
