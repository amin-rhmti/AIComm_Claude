
***************
* Environment *
***************

clear all
macro drop _all
set scheme s1manual
grstyle init
grstyle set plain, horizontal grid
set seed 2025

** Set the correct project path for your system
global PATH "D:\Projects\AIComm\analysis"
cd $PATH

adopath +  "."

global output_folder output/swiss_insta_experiment
capture mkdir $output_folder
capture mkdir "$output_folder/attrition_plots"


qui include code/sub_programs.do

forvalues i = 2/12 {
	capture mkdir $output_folder/sample`i'
	capture mkdir $output_folder/sample`i'_standardized
	capture mkdir $output_folder/sample`i'_standardized/post
	capture mkdir $output_folder/sample`i'/AI_bargraphs
}

* For i =11, 12, the /AI_bargraphs does not exist
forvalues i = 11/12 {
    capture rmdir "$output_folder/sample`i'/AI_bargraphs"
}

* specific subfolders for samples that get ciplots
capture mkdir $output_folder/sample2/post_ciplots
capture mkdir $output_folder/sample5/post_ciplots
capture mkdir $output_folder/sample8/post_ciplots // ADDED: for sample8

cap log using $output_folder/swiss_insta_experiment.log, replace



/**************************************************************************
  START: ATTRITION ANALYSIS PLOTS (CAPPED T-DISTRIBUTION)
  This section is self-contained. It loads and prepares the data specifically
  for the attrition plots, without filtering on survey completion (`Finished`),
  and then calls the custom plotting program.
**************************************************************************/

* --- Step 1: Load and prepare data for attrition analysis ---
use input/SwissSurvey_Insta_Experiment.dta, clear

* 1) Keep those who consented
local agree_text "I agree to participate, and I promise to read the questions carefully and answer honestly"
capture confirm numeric variable Participate
if (_rc==0) {
    keep if Participate==1
}
else {
    keep if Participate==`"`agree_text'"'
}

* 2) Require TreatIdentify and TreatComp2 present
drop if missing(TreatIdentify) | missing(TreatComp2)

* 3) Create numeric 'Identify' variable (Robustly handles both string and numeric types)
gen byte Identify = .
capture confirm string variable TreatIdentify
if (_rc==0) { // It's a string variable
    replace Identify = 0 if strpos(TreatIdentify,"Anonymous")
    replace Identify = 1 if strpos(TreatIdentify,"Identified")
}
else { // It's a numeric variable
    replace Identify = TreatIdentify if inlist(TreatIdentify,0,1)
}
drop if missing(Identify)


* 4) Create numeric 'TreatComp2' variable
destring TreatComp2, replace force
drop if !inlist(TreatComp2,1,3)

* 5) Create numeric 'Finished_num' variable (outcome) - ROBUSTLY
capture drop Finished_num
capture confirm numeric variable Finished
if (_rc==0) { // It's a numeric variable
    gen byte Finished_num = Finished
}
else { // It's a string variable
    gen byte Finished_num = .
    replace Finished_num = 1 if inlist(Finished,"1","True","TRUE","true")
    replace Finished_num = 0 if inlist(Finished,"0","False","FALSE","false")
}
* Note: We DO NOT drop if missing(Finished_num) here as requested.

* 6) Create Attention Check variable
gen AttnCheck_recode = regexm(AttnCheck, "read the instructions")
replace AttnCheck_recode = 1 if regexm(AttnCheck, "read the instructioins")
replace AttnCheck_recode = 1 if regexm(AttnCheck, "instruction")
replace AttnCheck_recode = 1 if regexm(AttnCheck, "Instruction")
replace AttnCheck_recode = 1 if regexm(AttnCheck, "intruction")
replace AttnCheck_recode = 1 if regexm(AttnCheck, "insturction")
replace AttnCheck_recode = 1 if regexm(AttnCheck, "instuction")
replace AttnCheck_recode = 1 if regexm(AttnCheck, "habe die Anweisungen gelesen")
tab AttnCheck_recode, m

* 7) Create the special Group4 variable with swapped categories for attrition plots
capture drop Group4_attrition
gen byte Group4_attrition = .
replace Group4_attrition = 1 if (TreatComp2==1 & Identify==0)   // No AI, Not identified
replace Group4_attrition = 2 if (TreatComp2==3 & Identify==0)   // AI, Not identified (SWAPPED)
replace Group4_attrition = 3 if (TreatComp2==1 & Identify==1)   // No AI, Identified (SWAPPED)
replace Group4_attrition = 4 if (TreatComp2==3 & Identify==1)   // AI, Identified
drop if missing(Group4_attrition)

label define Group4_attrition_lbl ///
    1 "No AI, Not identified" ///
    2 "AI, Not identified" ///
    3 "No AI, Identified" ///
    4 "AI, Identified", replace
label values Group4_attrition Group4_attrition_lbl

* 8) Create the writing dummy: 1 if wrote ≥1 chars; 0 otherwise (missing/empty = 0)

capture confirm variable wrote_nonempty_post
if _rc==0 drop wrote_nonempty_post
gen byte wrote_nonempty_post = 0
replace wrote_nonempty_post = 1 if !missing(Post) & ustrlen(ustrtrim(Post)) >= 1
label var wrote_nonempty_post "Wrote climate task text (≥1 chars)"

* --- Step 2: Create flags for subsamples to simplify program calls ---
gen byte shared_handle = !missing(InstaHandle) & InstaHandle != ""
gen byte not_shared_handle = missing(InstaHandle) | InstaHandle == "" // Defined here to support attrition logic

* Convenience locals
local cond_full      "AttnCheck_recode == 1"
local cond_shared    "AttnCheck_recode == 1 & shared_handle == 1"
local cond_notshared "AttnCheck_recode == 1 & not_shared_handle == 1" // This is the condition for sample8

local g12 "(Group4_attrition==1 | Group4_attrition==2)"
local g13 "(Group4_attrition==1 | Group4_attrition==3)"
local g24 "(Group4_attrition==2 | Group4_attrition==4)"
local g34 "(Group4_attrition==3 | Group4_attrition==4)"




* --- Step 3: Generate the three attrition plots, frequency tables, and p_values ---

// Plot 1: Full Sample (who passed attention check)

swiss_ciplot_attrition, ///
    if_condition("if (`cond_full')") ///
    xtitle("Treatment Group (Co-sender Composition × Image Concern)") ///
    filename_suffix("_Completion_rate_FullSample") /// ** tdist_capped
    graph_name_suffix("_FullComp")  ///
    outcome(Finished_num) ///
	ytitle("Completion rate (%)") ///
    ylow(70) yhigh(100)

	
swiss_ciplot_attrition, ///
    if_condition("if (`cond_full')") ///
    xtitle("Treatment Group (Co-sender Composition × Image Concern)") ///
    filename_suffix("_Wrote_nonempty_post_FullSample") /// ** tdist_capped
    graph_name_suffix("_FullWNP") ///
    outcome(wrote_nonempty_post) ///
    ytitle("Wrote non-empty post (%)") ///
    ylow(70) yhigh(100)

	
* p-values for Full Sample
* Note: We use same name for local representing tables

ttest Finished_num if (`cond_full') & `g12', by(Group4_attrition) unequal
local p12_full = r(p)
ttest Finished_num if (`cond_full') & `g34', by(Group4_attrition) unequal
local p34_full = r(p)
display as text "p-values (Full sample):"
display as result "  No AI, Not identified vs AI, Not identified : " %6.4f `p12_full'
display as result "  No AI, Identified     vs AI, Identified     : " %6.4f `p34_full'
display ""

ttest wrote_nonempty_post if (`cond_full') & `g12', by(Group4_attrition) unequal
local p12_full = r(p)
ttest wrote_nonempty_post if (`cond_full') & `g34', by(Group4_attrition) unequal
local p34_full = r(p)
display as text "p-values (Full sample):"
display as result "  No AI, Not identified vs AI, Not identified : " %6.4f `p12_full'
display as result "  No AI, Identified     vs AI, Identified     : " %6.4f `p34_full'
display ""


// Plot 2: Subsample that Shared Instagram Handle (and passed attention check)

swiss_ciplot_attrition, ///
    if_condition("if (`cond_shared')") ///
    xtitle("Subsample Treatment Group: Shared Instagram Handle") ///
    filename_suffix("_Completion_rate_SharedSample") /// ** tdist_capped
    graph_name_suffix("_SharedComp") ///
    outcome(Finished_num) ///
	ytitle("Completion rate (%)") ///
    ylow(70) yhigh(100)

	
swiss_ciplot_attrition, ///
    if_condition("if (`cond_shared')") ///
    xtitle("Subsample Treatment Group: Shared Instagram Handle") ///
    filename_suffix("_Wrote_nonempty_post_SharedSample") /// ** tdist_capped
    graph_name_suffix("_SharedWNP") ///
    outcome(wrote_nonempty_post) ///
    ytitle("Wrote non-empty post (%)") ///
    ylow(70) yhigh(100)
	


* p-values for Shared Handle

ttest Finished_num if (`cond_shared') & `g12', by(Group4_attrition) unequal
local p12_sh = r(p)
ttest Finished_num if (`cond_shared') & `g34', by(Group4_attrition) unequal
local p34_sh = r(p)
display as text "p-values (Shared handle):"
display as result "  No AI, Not identified vs AI, Not identified : " %6.4f `p12_sh'
display as result "  No AI, Identified     vs AI, Identified     : " %6.4f `p34_sh'
display ""

ttest wrote_nonempty_post if (`cond_shared') & `g12', by(Group4_attrition) unequal
local p12_sh = r(p)
ttest wrote_nonempty_post if (`cond_shared') & `g34', by(Group4_attrition) unequal
local p34_sh = r(p)
display as text "p-values (Shared handle):"
display as result "  No AI, Not identified vs AI, Not identified : " %6.4f `p12_sh'
display as result "  No AI, Identified     vs AI, Identified     : " %6.4f `p34_sh'
display ""


// Plot 3: Subsample that Did NOT Share Instagram Handle (and passed attention check) - This is sample8

	
swiss_ciplot_attrition, ///
    if_condition("if (`cond_notshared')") ///
    xtitle("Subsample Treatment Group: Not Shared Instagram Handle") ///
    filename_suffix("_Completion_rate_NotSharedSample") /// ** tdist_capped
    graph_name_suffix("_NotSharedComp") ///
    outcome(Finished_num) ///
	ytitle("Completion rate (%)") ///
    ylow(70) yhigh(100)

	
swiss_ciplot_attrition, ///
    if_condition("if (`cond_notshared')") ///
    xtitle("Subsample Treatment Group: Not Shared Instagram Handle") ///
    filename_suffix("_Wrote_nonempty_post_NotSharedSample") /// ** tdist_capped
    graph_name_suffix("_NotSharedWNP") ///
    outcome(wrote_nonempty_post) ///
    ytitle("Wrote non-empty post (%)") ///
    ylow(70) yhigh(100)

	
* p-values for Not Shared Handle

ttest Finished_num if (`cond_notshared') & `g12', by(Group4_attrition) unequal
local p12_nsh = r(p)

ttest Finished_num if (`cond_notshared') & `g34', by(Group4_attrition) unequal
local p34_nsh = r(p)

display as text "p-values (Not shared handle):"
display as result "  No AI, Not identified vs AI, Not identified : " %6.4f `p12_nsh'
display as result "  No AI, Identified     vs AI, Identified     : " %6.4f `p34_nsh'
display ""

ttest wrote_nonempty_post if (`cond_notshared') & `g12', by(Group4_attrition) unequal
local p12_nsh = r(p)
ttest wrote_nonempty_post if (`cond_notshared') & `g34', by(Group4_attrition) unequal
local p34_nsh = r(p)
display as text "p-values (Not shared handle):"
display as result "  No AI, Not identified vs AI, Not identified : " %6.4f `p12_nsh'
display as result "  No AI, Identified     vs AI, Identified     : " %6.4f `p34_nsh'
display ""

/**************************************************************************
  End: ATTRITION ANALYSIS PLOTS 
**************************************************************************/


/**************************************************************************
 Main Analysis for samplei, i=2,3,..,7
**************************************************************************/


cap program drop add_gpt_measures
program add_gpt_measures
	merge 1:1 ResponseId using gpt_annotations/Experiment_gpt_measures/Experiment_gpt_measures.dta
	foreach measure in "personal_anecdote" "emotional_appeal" "emotional_appeal_new" "scientific_argument" "progressive_score" "grammatical_mistakes" "moral_narratives" "causal_narratives" "sentiment" "collective_action" {
		rename Post_`measure' `measure'
		destring `measure', replace
		tab `measure', m
		rename ClimateLong_`measure' Base_`measure'
		destring Base_`measure', replace
		tab Base_`measure', m
	}
end


cap program drop label_variables
program label_variables
	label var personal_anecdote "GPT annotated use of personal anecdotes in Post"
	label var emotional_appeal "GPT annotated use of emotional appeal in Post"
	label var scientific_argument "GPT annotated use of scientific arguments in Post"
	label var progressive_score "GPT annotated left-wing score in Post"
	label var grammatical_mistakes "GPT annotated count of grammatical mistakes in Post"
	label var moral_narratives "GPT annotated use of moral narratives in Post"
	label var causal_narratives "GPT annotated use of causal narratives in Post"
	label var sentiment "GPT annotated sentiment in Post"
	label var collective_action "GPT annotated reference to collective action in Post"
end 


load_file


cap program drop conduct_lotteries
program conduct_lotteries

	load_file	
	
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



**************************
**** descriptive stuff ***
***************************

foreach sample_number in 2 3 4 5 6 7 8 9 10 {
	twoway_histogram, outcome(WTP) sample_number(`sample_number') width(0.5)
	twoway_histogram, outcome(TimePost) sample_number(`sample_number')  width(50)
	twoway_histogram, outcome(log1TextLength) sample_number(`sample_number')  width(0.1)
	twoway_histogram, outcome(TimePost) sample_number(`sample_number') width(0.1) standardize(yes)
	twoway_histogram, outcome(TaskQuizCorrect) sample_number(`sample_number') width(0.1) 

	foreach outcome in $GPT_OUTCOME_LIST {
	 	twoway_histogram, outcome(`outcome') sample_number(`sample_number') width(0.99)
	}
}


vennbar YouTube Instagram LinkedIn Snapchat TikTok Nothing, title("Top 5 platforms", size(medium)) 
graph export $output_folder/social_media_use.pdf, replace


* ClimateWorry ClimatePersonal ImageConcern DonationBinary BotKnow InitialAIEffective BaseAIDiff

foreach sample_number in 2 3 4 5 6 7 8 9 10 {

	hist ClimateWorry if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ytitle("") xtitle("") color(blue%30) title("Worry about Climate Change", size(medium)) xlabel(1 "Not at all worried" 5 "Extremely worried", labsize(small)) xscale(range(0 6))
	graph export $output_folder/sample`sample_number'/ClimateWorry_Dist.pdf, replace

	hist ClimatePersonal if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ytitle("") xtitle("") color(blue%30) title("Personal responsibility regarding Climate Change", size(medium)) xlabel(1 "Not at all responsible" 5 "Extremely responsible", labsize(small)) xscale(range(0 6))
	graph export $output_folder/sample`sample_number'/ClimatePersonal_Dist.pdf, replace

	hist ImageConcern if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ytitle("") xtitle("") color(blue%30) title("Important that other people perceive you positively", size(medium)) xlabel(1 "Not important at all" 5 "Extremely important", labsize(small)) xscale(range(0 6))
	graph export $output_folder/sample`sample_number'/ImageConcern_Dist.pdf, replace

	hist Donation if sample`sample_number'==1, frac width(2) ytitle("") xtitle("") color(blue%30) title("Donation to climate change org.", size(medium)) xscale(range(0 6))
	graph export $output_folder/sample`sample_number'/Donation_Dist.pdf, replace

	hist BotKnow if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ytitle("") xtitle("") color(blue%30) title("Familiarity with Gen AI", size(medium)) xlabel(5 "Familiar, Use frequently" 3 "Somewhat familiar, Use rarely" 1 "Not aware", labsize(small)) xscale(range(0 6))
	graph export $output_folder/sample`sample_number'/BotKnow_Dist.pdf, replace

	hist InitialAIEffective if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ytitle("") xtitle("") color(blue%30) title("Effectiveness of Gen AI at producing persuasive messages", size(small)) xlabel(1 "Not at all effective" 5 "Extremely effective", labsize(small)) xscale(range(0 6))
	graph export $output_folder/sample`sample_number'/InitialAIEffective_Dist.pdf, replace

	hist BaseAIDiff if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ytitle("") xtitle("") color(blue%30) title("How different does your writing feel compared to something generated by AI", size(small)) xlabel(1 "Not at all different" 5 "Extremely different", labsize(small)) xscale(range(0 6))
	graph export $output_folder/sample`sample_number'/BaseAIDiff_Dist.pdf, replace
}


bot_histograms


foreach x in $OUTCOMES $GPT_OUTCOME_LIST {

	preserve

	keep if sample2 
	make_ciplot_swiss, outcome(`x') by_var(TreatInteract) folder(sample2/post_ciplots) residualize(yes) subtitle("`: var label `x'' by Treatment (Residualized)")
	restore
}

foreach x in $OUTCOMES $GPT_OUTCOME_LIST {
	preserve
	keep if sample5
	make_ciplot_swiss, outcome(`x') by_var(TreatInteract) folder(sample5/post_ciplots) residualize(yes) subtitle("`: var label `x'' by Treatment (Residualized, Shared Handle)")
	restore
}

// ADDED: CI PLOTS FOR SAMPLE 8
foreach x in $OUTCOMES $GPT_OUTCOME_LIST {
	preserve
	keep if sample8
	make_ciplot_swiss, outcome(`x') by_var(TreatInteract) folder(sample8/post_ciplots) residualize(yes) subtitle("`: var label `x'' by Treatment (Residualized, Not Shared Handle)")
	restore
}


**********************
*** writing tasks ****
**********************


load_file

cap program drop table1
program define table1
	syntax, outcome(string) sample_number(numlist) [standardize(string)] basepostvars(varlist)

	preserve
	keep if sample`sample_number' == 1 


	if "`standardize'" == "yes"{
		local N "_N"
		local N_folder "_standardized"
		summ `outcome'`N'
	}


	eststo clear

	eststo: reghdfe `outcome'`N' $CONTROLS Identify, vce(r)
	estadd local basepostcontrols "No", replace

	eststo: reghdfe `outcome'`N' $CONTROLS AITreatXIden AITreatXAnon Identify , vce(r)
	estadd local basepostcontrols "No", replace

	eststo: reghdfe `outcome'`N' $CONTROLS `basepostvars' AITreatXIden AITreatXAnon Identify, vce(r)
	estadd local basepostcontrols "Yes", replace

	eststo: reghdfe `outcome'`N' $CONTROLS AITreatXIden AITreatXAnon Identify if !missing(ProvideHandle), vce(r)
	estadd local basepostcontrols "No", replace
	estadd local instasample "Yes", replace

	eststo: reghdfe `outcome'`N' $CONTROLS `basepostvars' AITreatXIden AITreatXAnon Identify if !missing(ProvideHandle), vce(r)
	estadd local basepostcontrols "Yes", replace
	estadd local instasample "Yes", replace

	eststo: reghdfe `outcome'`N' $CONTROLS AITreatXIden AITreatXAnon Identify AITreatXIdenXHandle ProvideHandle if !missing(ProvideHandle), vce(r)
	estadd local basepostcontrols "No", replace
	estadd local instasample "Yes", replace

	eststo: reghdfe `outcome'`N' $CONTROLS `basepostvars' AITreatXIden AITreatXAnon Identify AITreatXIdenXHandle ProvideHandle if !missing(ProvideHandle), vce(r)
	estadd local basepostcontrols "Yes", replace
	estadd local instasample "Yes", replace

	eststo: reghdfe `outcome'`N' $CONTROLS `basepostvars' AITreatXIden AITreatXAnon Identify if ProvideHandle, vce(r)
	estadd local basepostcontrols "Yes", replace
	estadd local instasample "Yes", replace
	estadd local handle "Yes", replace



	add_notes, outcome(`outcome')

	esttab using $output_folder/sample`sample_number'`N_folder'/post/`outcome'`N'_table.tex, ar2 se title("Regression") obslast prehead(`"\documentclass{article}"' `"\usepackage{booktabs}"' `"\usepackage[margin=0.1in]{geometry}"' `"\begin{document}"' `"\begin{table}[htbp]\centering"' `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"'  `"\caption{@title}"' `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@E}{c}}"' `"\toprule"') width(\hsize) nodep $stars addnotes("`r(ynote)'" "`r(xnote1)'" "`r(xnote2)'") scalar("instasample Use Instagram" "basepostcontrols ClimateLong controls" "handle Provide Insta Handle") page booktabs compress replace noisily

	restore

end




* table1, outcome(emotional_appeal) sample_number(2) basepostvars(BaseTextLength* Base_log1TextLength Base_emotional_appeal) standardize(yes)

** all outcomes 


// EXTENDED LOOP TO INCLUDE SAMPLES 8, 9, 10
foreach sample_number in 2 3 4 5 6 7 8 9 10 { // MODIFIED: was 2/7
	foreach outcome in $OUTCOMES {
		table1, outcome(`outcome') sample_number(`sample_number') basepostvars(BaseTextLength* Base_log1TextLength) standardize(yes)
	}

	foreach outcome in $GPT_OUTCOME_LIST {
		table1, outcome(`outcome') sample_number(`sample_number') basepostvars(BaseTextLength* Base_log1TextLength Base_`outcome') standardize(yes)
	}
}


cap program drop table2
program define table2
	syntax, outcome(string) sample_number(numlist) moderator(varlist) [standardize(string)] basepostvars(varlist) [extension(string)]

	preserve
	keep if sample`sample_number' == 1 


	if "`standardize'" == "yes"{
		local N "_N"
		local N_folder "_standardized"
		summ `outcome'`N'
	}

	eststo clear

	eststo: reghdfe `outcome'`N' $DEMOG $MODERATORS `basepostvars' AITreat , vce(r)
	estadd local basepostcontrols "Yes", replace

	eststo: reghdfe `outcome'`N' $DEMOG $MODERATORS AITreat , vce(r)


	foreach modvar of local moderator {

		eststo: reghdfe `outcome'`N' $DEMOG $MODERATORS `basepostvars' AITreat AITreatX`modvar' , vce(r)
		estadd local basepostcontrols "Yes", replace

	}

	add_notes, outcome(`outcome')
	local ynote = r(ynote)
	local xnote1 = r(xnote1)
	local xnote2 = r(xnote2)
	add_controlnotes

	esttab using $output_folder/sample`sample_number'`N_folder'/post/`outcome'`N'_table_heterogeneity`extension'.tex, r2 ar2 se ///
	title("`outcome' heterogeneity") obslast prehead(`"\documentclass{article}"' `"\usepackage{booktabs}"' `"\usepackage[margin=0.15in]{geometry}"' `"\begin{document}"' `""' `"\begin{table}[htbp]\centering"' `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' `"\caption{@title}"' `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@E}{c}}"' `"\toprule"') width(\hsize) ///
	nodep $stars addnotes("`ynote'" "`xnote1'" "`xnote2'" "`r(xnote3)'" "`r(xnote4)'" "`r(xnote5)'" "`r(xnote6)'" "`r(xnote7)'" "`r(xnote8)'" "`r(xnote9)'" "`r(xnote10)'" "`r(xnote11)'") page booktabs compress replace

	restore

end 

* table2, outcome(WTPBinary) sample_number(2) indepvars($DEMOG $MODERATORS) moderator($MODERATORS) standardize(yes)

* Note: table2 is designed to test for heterogeneous treatment effects. Running table2 on sample2 and sample5 would estimate the average heterogeneous effect across both of these conditions. This is misleading because it washes out or confounds the distinct effects happening in each group.

* Loop 1: Run the main heterogeneity analysis on all four key subgroups.
* This ensures that sample6 and sample7 get their primary output files in their own folders.
foreach sample_number in 3 4 6 7 9 10{
	foreach outcome in $OUTCOMES {
		table2, outcome(`outcome') sample_number(`sample_number') moderator($MODERATORS) basepostvars(BaseTextLength* Base_log1TextLength) standardize(yes)
	}
	*** Remove Base_`outcome` from this loop to match old script's output ***
	foreach outcome in $GPT_OUTCOME_LIST {
		table2, outcome(`outcome') sample_number(`sample_number') moderator($MODERATORS) basepostvars(BaseTextLength* Base_log1TextLength) standardize(yes)
	}
}

* Loop 2: Run the "_instagram_use" subset analysis ONLY on the full groups (3 and 4).
* This is where the subsetting is meaningful. It generates the results for the
* 'shared handle' groups (6 and 7) but places them within the sample3/sample4 folders for comparison.
foreach sample_number in 3 4 {
	foreach outcome in $OUTCOMES {
		preserve
		keep if !missing(ProvideHandle)
		table2, outcome(`outcome') sample_number(`sample_number') moderator($MODERATORS) basepostvars(BaseTextLength* Base_log1TextLength) standardize(yes) extension(_instagram_use)
		restore
	}
	* Note: The Base_`outcome` control IS included here, matching the old script's inconsistent but specific logic.
	foreach outcome in $GPT_OUTCOME_LIST {
		preserve
		keep if !missing(ProvideHandle)
		table2, outcome(`outcome') sample_number(`sample_number') moderator($MODERATORS) basepostvars(BaseTextLength* Base_log1TextLength Base_`outcome') standardize(yes) extension(_instagram_use)
		restore
	}
}



**********************************************************
****   writing tasks - HTE by interaction dummies  *****
**********************************************************
* HTE by interaction dummies on Full sample (sample2)
cap program drop table3
program define table3
	syntax, outcome(string) sample_number(numlist) [standardize(string)] basepostvars(varlist)

	preserve
	keep if sample`sample_number' == 1 


	if "`standardize'" == "yes"{
		local N "_N"
		local N_folder "_standardized"
		summ `outcome'`N'
	}

	eststo clear

	* WITH basepostvars
	* Specification: Treatment Dummies + ProvideHandle + All 3-way Interactions + Controls
	eststo: reghdfe `outcome'`N' $CONTROLS `basepostvars' AITreatXIden AITreatXAnon Identify ProvideHandle AITreatXIdenXHandle AITreatXAnonXHandle IdentifyXProvideHandle  , vce(r)
	estadd local basepostcontrols "Yes", replace
	estadd local HTE_model "Full Sample-Interaction", replace

	* WITHOUT basepostvars
	eststo: reghdfe `outcome'`N' $CONTROLS AITreatXIden AITreatXAnon Identify ProvideHandle AITreatXIdenXHandle AITreatXAnonXHandle IdentifyXProvideHandle  , vce(r)
	estadd local basepostcontrols "No", replace
	estadd local HTE_model "Full Sample-Interaction", replace


	add_notes, outcome(`outcome')
	local ynote = r(ynote)
	local xnote1 = r(xnote1)
	local xnote2 = r(xnote2)
	add_controlnotes

	esttab using $output_folder/sample`sample_number'`N_folder'/post/`outcome'`N'_table_HTE_pooled.tex, r2 ar2 se title("Regression (Pooled HTE by Shared Handle)") obslast prehead(`"\documentclass{article}"' `"\usepackage{booktabs}"' `"\usepackage[margin=0.1in]{geometry}"' `"\begin{document}"' `"\begin{table}[htbp]\centering"' `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"'  `"\caption{@title}"' `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@E}{c}}"' `"\toprule"') width(\hsize) nodep $stars addnotes("`ynote'" "`xnote1'" "`xnote2'" "`r(xnote3)'" "`r(xnote4)'" "`r(xnote5)'" "`r(xnote6)'" "`r(xnote7)'" "`r(xnote8)'" "`r(xnote9)'" "`r(xnote10)'" "`r(xnote11)'") scalar("HTE_model HTE Model Type" "basepostcontrols ClimateLong controls") page booktabs compress replace noisily

	restore
end

foreach outcome in $OUTCOMES {
	table3, outcome(`outcome') sample_number(2) basepostvars(BaseTextLength* Base_log1TextLength) standardize(yes)
}

* Execute for all GPT outcomes (including the Base_`outcome` control)
foreach outcome in $GPT_OUTCOME_LIST {
	table3, outcome(`outcome') sample_number(2) basepostvars(BaseTextLength* Base_log1TextLength Base_`outcome') standardize(yes)
}



* HTE by interaction dummies on sample3 and sample4 - AI vs. No AI in Identify and Not identified subsamples
cap program drop table4
program define table4
	syntax, outcome(string) sample_number(numlist) [standardize(string)] basepostvars(varlist)

	preserve
	keep if sample`sample_number' == 1 


	if "`standardize'" == "yes"{
		local N "_N"
		local N_folder "_standardized"
		summ `outcome'`N'
	}

	* --- The treatment dummy is AITreat, and the interaction is AITreatXProvideHandle ---
	
	eststo clear

	* Regression 1: HTE model (AI vs. Human) WITH basepostvars
	eststo: reghdfe `outcome'`N' $CONTROLS `basepostvars' AITreat ProvideHandle AITreatXProvideHandle, vce(r)
	estadd local basepostcontrols "Yes", replace
	estadd local HTE_model "Sub-HTE (AI vs Human)", replace

	* Regression 2: HTE model (AI vs. Human) WITHOUT basepostvars
	eststo: reghdfe `outcome'`N' $CONTROLS AITreat ProvideHandle AITreatXProvideHandle, vce(r)
	estadd local basepostcontrols "No", replace
	estadd local HTE_model "Sub-HTE (AI vs Human)", replace


	add_notes, outcome(`outcome')
	local ynote = r(ynote)
	local xnote1 = r(xnote1)
	local xnote2 = r(xnote2)
	add_controlnotes

	esttab using $output_folder/sample`sample_number'`N_folder'/post/`outcome'`N'_table_HTE_sub.tex, r2 ar2 se title("Regression (Sub-HTE by Shared Handle in Sample `sample_number')") obslast prehead(`"\documentclass{article}"' `"\usepackage{booktabs}"' `"\usepackage[margin=0.1in]{geometry}"' `"\begin{document}"' `"\begin{table}[htbp]\centering"' `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"'  `"\caption{@title}"' `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@E}{c}}"' `"\toprule"') width(\hsize) nodep $stars addnotes("`ynote'" "`xnote1'" "`xnote2'" "`r(xnote3)'" "`r(xnote4)'" "`r(xnote5)'" "`r(xnote6)'" "`r(xnote7)'" "`r(xnote8)'" "`r(xnote9)'" "`r(xnote10)'" "`r(xnote11)'") scalar("HTE_model HTE Model Type" "basepostcontrols ClimateLong controls") page booktabs compress replace noisily

	restore
end 


foreach sample_number in 3 4 {
	
	* Execute for all main outcomes
	foreach outcome in $OUTCOMES {
		table4, outcome(`outcome') sample_number(`sample_number') basepostvars(BaseTextLength* Base_log1TextLength) standardize(yes)
	}

	* Execute for all GPT outcomes (including the Base_`outcome` control)
	foreach outcome in $GPT_OUTCOME_LIST {
		table4, outcome(`outcome') sample_number(`sample_number') basepostvars(BaseTextLength* Base_log1TextLength Base_`outcome') standardize(yes)
	}
}


* HTE by interaction dummies on sample11 and sample12 - Identify vs. Anon  in AI and No AI subsamples
cap program drop table5
program define table5
	syntax, outcome(string) sample_number(numlist) [standardize(string)] basepostvars(varlist)

	preserve
	keep if sample`sample_number' == 1 


	if "`standardize'" == "yes"{
		local N "_N"
		local N_folder "_standardized"
		summ `outcome'`N'
	}

	* --- The treatment dummy is Identify, and the interaction is IdentifyXProvideHandle ---
	
	eststo clear

	* Regression 1: HTE model (Identify vs. Anonymous) WITH basepostvars
	* Model: Y = Identify + ProvideHandle + IdentifyXProvideHandle + Controls
	eststo: reghdfe `outcome'`N' $CONTROLS `basepostvars' Identify ProvideHandle IdentifyXProvideHandle, vce(r)
	estadd local basepostcontrols "Yes", replace
	estadd local HTE_model "Sub-HTE (Identify vs Anon)", replace

	* Regression 2: HTE model (Identify vs. Anonymous) WITHOUT basepostvars
	eststo: reghdfe `outcome'`N' $CONTROLS Identify ProvideHandle IdentifyXProvideHandle, vce(r)
	estadd local basepostcontrols "No", replace
	estadd local HTE_model "Sub-HTE (Identify vs Anon)", replace


	add_notes, outcome(`outcome')
	local ynote = r(ynote)
	local xnote1 = r(xnote1)
	local xnote2 = r(xnote2)
	add_controlnotes

	esttab using $output_folder/sample`sample_number'`N_folder'/post/`outcome'`N'_table_HTE_identify.tex, r2 ar2 se title("Regression (Sub-HTE by Shared Handle in Sample `sample_number')") obslast prehead(`"\documentclass{article}"' `"\usepackage{booktabs}"' `"\usepackage[margin=0.1in]{geometry}"' `"\begin{document}"' `"\begin{table}[htbp]\centering"' `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"'  `"\caption{@title}"' `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@E}{c}}"' `"\toprule"') width(\hsize) nodep $stars addnotes("`ynote'" "`xnote1'" "`xnote2'" "`r(xnote3)'" "`r(xnote4)'" "`r(xnote5)'" "`r(xnote6)'" "`r(xnote7)'" "`r(xnote8)'" "`r(xnote9)'" "`r(xnote10)'" "`r(xnote11)'") scalar("HTE_model HTE Model Type" "basepostcontrols ClimateLong controls") page booktabs compress replace noisily

	restore
end

foreach sample_number in 11 12 {
	
	* Execute for all main outcomes
	foreach outcome in $OUTCOMES {
		table5, outcome(`outcome') sample_number(`sample_number') basepostvars(BaseTextLength* Base_log1TextLength) standardize(yes)
	}

	* Execute for all GPT outcomes (including the Base_`outcome` control)
	foreach outcome in $GPT_OUTCOME_LIST {
		table5, outcome(`outcome') sample_number(`sample_number') basepostvars(BaseTextLength* Base_log1TextLength Base_`outcome') standardize(yes)
	}
}





*** Does the co-sender composition affect the AI-ness of a post? 

forvalues i = 1/2{

	preserve
	keep if Chose1 == `i' | Chose2 == `i'

	gen Guess = GuessWriterHuman if Chose1 == `i'
	replace Guess = GuessWriterAI if Chose2 == `i'

	gen GuessBot = Guess >= 2

	summ GuessBot

	gen React = ReadingReact1 if Chose1 == `i'
	replace React = ReadingReact2 if Chose2 == `i'

	cap drop SomeReact
	gen SomeReact = React != 3

	gen AILabelPost = Chose2 == `i'

	bysort AILabelPost: summ GuessBot
	bysort AILabelPost: summ SomeReact


	eststo clear
	eststo linear_model: reg GuessBot AILabelPost, r
	coefplot *, title("Effect of labelling the post's co-senders as AI (as opposed to human co-senders) on reader's guess that the writer is AI/bot" , size(vsmall)) $coefplot_options xlabel(-0.1(0.1)0.4)
	graph export $output_folder/GuessBot`i'_AILabel.pdf, replace

	eststo clear
	eststo linear_model: reg SomeReact AILabelPost, r
	coefplot *, title("Effect of labelling the post's co-senders as AI (as opposed to human co-senders) on reader's reaction to the post" , size(vsmall)) $coefplot_options xlabel(-0.1(0.1)0.4)
	graph export $output_folder/SomeReact`i'_AILabel.pdf, replace


	restore
}



forvalues i = 1/2{

	gen Guess`i' = 0 if Chose1 == `i' | Chose2 == `i'
	replace Guess`i' = GuessWriterHuman if Chose1 == `i'
	replace Guess`i' = GuessWriterAI if Chose2 == `i'
	gen GuessBot`i' = Guess`i' >= 2 if Chose1 == `i' | Chose2 == `i'
	tab Guess`i', m


	gen React`i' = 0 if Chose1 == `i' | Chose2 == `i'
	replace React`i' = ReadingReact1 if Chose1 == `i'
	replace React`i' = ReadingReact2 if Chose2 == `i'
	gen SomeReact`i' = React`i' != 3 if !missing(React`i')
	tab SomeReact`i', m

	gen AILabelPost`i' = Chose2 == `i' if Chose1 == `i' | Chose2 == `i'
	tab AILabelPost`i' GuessBot`i', m



}

* Reshape the data to long format
reshape long Guess GuessBot AILabelPost SomeReact, i(ResponseId) j(PostNumber)
keep Guess GuessBot SomeReact AILabelPost ResponseId PostNumber


* Create the bar graph
qui graph bar GuessBot, over(AILabelPost, relabel(1 "Human" 2 "AI")) over(PostNumber, relabel(1 "First post" 2 "Second post")) title("Average number of people who guess the writer as some kind of bot", size(small)) ytitle(, size(small)) ytitle("Guessed as bot", size(small))  ytitle("") bar(1, color(blue%20)) bar(2, color(red%20)) asyvars
graph export $output_folder/GuessBot_ALL.pdf, replace

* Create the bar graph
qui graph bar SomeReact, over(AILabelPost, relabel(1 "Human" 2 "AI")) over(PostNumber, relabel(1 "First post" 2 "Second post")) title("Reaction to Post by AI Label", size(medium))  ytitle("Reacted to post", size(small))  ytitle("") bar(1, color(blue%20)) bar(2, color(red%20)) asyvars
graph export $output_folder/SomeReact_ALL.pdf, replace




cap program drop save_file_for_gpt_measures
program save_file_for_gpt_measures

	load_file

	keep if sample1

	export delim ResponseId using gpt_annotations/Experiment_gpt_measures/Experiment_sample1_responseids.csv, replace

end

log close