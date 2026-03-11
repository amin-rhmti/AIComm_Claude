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

global output_folder output/swiss_insta_experiment/imputed_version
capture mkdir $output_folder
capture mkdir "$output_folder/attrition_plots"



qui include code/sub_programs.do

forvalues i = 2/7 {
	capture mkdir $output_folder/sample`i'_imputed
	capture mkdir $output_folder/sample`i'_imputed_standardized
	capture mkdir $output_folder/sample`i'_imputed_standardized/post
	capture mkdir $output_folder/sample`i'_imputed/AI_bargraphs
}


* specific subfolders for samples that get ciplots
capture mkdir $output_folder/sample2_imputed/post_ciplots
capture mkdir $output_folder/sample5_imputed/post_ciplots


cap log using $output_folder/swiss_insta_experiment_imputed.log, replace
use input/SwissSurvey_Insta_Experiment_imputed.dta, clear

* Convenience locals
local cond_full      "AttnCheck_recode == 1"
local cond_shared    "AttnCheck_recode == 1 & shared_handle == 1"
local cond_notshared "AttnCheck_recode == 1 & not_shared_handle == 1"

local g12 "(Group4_attrition==1 | Group4_attrition==2)"
local g13 "(Group4_attrition==1 | Group4_attrition==3)"
local g24 "(Group4_attrition==2 | Group4_attrition==4)"
local g34 "(Group4_attrition==3 | Group4_attrition==4)"


* Data pre-process



label define TreatComp2 1 "100% student-written posts" 3 "75% AI-generated and 25% student-written posts", replace
label values TreatComp2 "TreatComp2"

capture drop HumanTreat
capture confirm variable TreatComp2
if (_rc == 0) {
    gen byte HumanTreat = 0
    replace HumanTreat = 1 if (TreatComp2 == 1)
	}

capture drop AITreat
capture confirm variable TreatComp2
if (_rc == 0) {
    gen byte AITreat = 0
    replace AITreat = 1 if (TreatComp2 == 3)
	}

label define AITreat 0 "Human treatment" 1 "AI treatment"
label values AITreat "AITreat"

gen HumanXAnon = (TreatComp2 == 1) * !Identify
gen HumanXIden = (TreatComp2 == 1) * Identify
gen AITreatXIden = AITreat * Identify
gen AITreatXAnon = AITreat * (Identify == 0)

gen TreatInteract = 0
replace TreatInteract = 1 if AITreatXIden
replace TreatInteract = 2 if HumanXAnon
replace TreatInteract = 3 if AITreatXAnon
tab TreatInteract, m

gen AITreatXProvideHandle = AITreat * ProvideHandle if !missing(ProvideHandle)
gen IdentifyXProvideHandle = Identify * ProvideHandle if !missing(ProvideHandle)
gen AITreatXIdenXHandle = AITreat * Identify * ProvideHandle if !missing(ProvideHandle)

gen WritePost = !missing(Post)
// gen TextLength = strlen(Post) 
gen NoWrite = (TextLength==1)
label var WTPBinary "WTP>0"

destring TimeSignaling1_PageSubmit, gen(TimeInstructionsPost)	
destring TimingWTP1_PageSubmit, gen(TimeWTP)
destring TimingWTPExplain1_PageSubmit, gen(TimeWTPExplain)

* Sample#
gen sample1=1
gen sample2=AttnCheck_recode
gen sample3=sample2 & Identify
gen sample4=sample2 & !Identify
gen sample6 = sample2 & shared_handle == 1 & Identify == 1
gen sample7 = sample2 & shared_handle == 1 & Identify == 0
gen sample5 = (sample6 == 1 | sample7 == 1)


gen Chose1 = substr(Chose, 1, 1)
destring Chose1, replace
gen Chose2 = substr(Chose, 2, 1)
destring Chose2, replace
gen EducUG = Education == 1 // EducUG = ~ Graduated_degree
label var EducUG "Undergraduate"
gen DidNotVote = regexm(SwissPoliticalParty, "did not vote") // DidNotVote = ~Vote
label var DidNotVote "Did not vote in last election"

social_media_platform_cleaning

gen DonationBinary = Donation > 0
label var DonationBinary "Nonzero donation to clim chg"
gen ImageConcernBinary = ImageConcern > 2 & !missing(ImageConcern)
gen BotKnowBinary = BotKnow == 5
gen AIEffectiveBinary = InitialAIEffective > 3
gen AIDiffBinary = BaseAIDiff >= 3

normalize_data, outcome(ClimateWorry ClimatePersonal)
make_index, outcome(Climate) varset(ClimateWorry_N ClimatePersonal_N)
summ index_Climate, d 
gen ClimateIndexBinary = index_Climate > r(p50)


global DEMOG EducUG DidNotVote

global BASELINE index_Climate ImageConcern DonationBinary BotKnow InitialAIEffective BaseAIDiff

global CONTROLS $DEMOG $BASELINE

global GPT_CONTROLS Base_*

global MODERATORS ClimateIndexBinary ImageConcernBinary DonationBinary BotKnowBinary AIEffectiveBinary AIDiffBinary

* This is the only change for output variables to imputed ones

global OUTCOMES_imp WTPBinary_imp WTP_imp GenAIEffective_imp SignalValue_imp PerceiveAI PerceiveEngaged_imp log1TextLength_imp TimePost_imp TaskQuizCorrect_imp

global GPT_OUTCOME_LIST personal_anecdote emotional_appeal emotional_appeal_new scientific_argument progressive_score grammatical_mistakes moral_narratives causal_narratives sentiment collective_action

global GPT_SCORE_OUTCOME_LIST personal_anecdote emotional_appeal scientific_argument progressive_score moral_narratives causal_narratives sentiment collective_action


* Normalization

qui foreach x in log1TextLength log1TextLength_imp TimePost_imp TimePost {

	tab `x'
	winsor2 `x', replace cuts(5 95)
	tab `x'

}



foreach x in $OUTCOMES_imp $GPT_OUTCOME_LIST {

	normalize_data, outcome(`x')
	label var `x'_N "`:var label `x'': Standardized" 

}

foreach x in $MODERATORS {

	gen AITreatX`x' = AITreat * `x' == 1

}



**************************
**** descriptive stuff ***
***************************

foreach sample_number in 2 3 4 5 6 7 {
	twoway_histogram_imputed, outcome(WTP_imp) sample_number(`sample_number') width(0.5)
	twoway_histogram_imputed, outcome(TimePost_imp) sample_number(`sample_number')  width(50)
	twoway_histogram_imputed, outcome(log1TextLength_imp) sample_number(`sample_number')  width(0.1)
	twoway_histogram_imputed, outcome(TimePost_imp) sample_number(`sample_number') width(0.1) standardize(yes)
	twoway_histogram_imputed, outcome(TaskQuizCorrect_imp) sample_number(`sample_number') width(0.1) 

}

foreach sample_number in 2 3 4 5 6 7 {

	hist ClimateWorry if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ytitle("") xtitle("") color(blue%30) title("Worry about Climate Change", size(medium)) xlabel(1 "Not at all worried" 5 "Extremely worried", labsize(small)) xscale(range(0 6))
	graph export $output_folder/sample`sample_number'_imputed/ClimateWorry_Dist.pdf, replace

	hist ClimatePersonal if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ytitle("") xtitle("") color(blue%30) title("Personal responsibility regarding Climate Change", size(medium)) xlabel(1 "Not at all responsible" 5 "Extremely responsible", labsize(small)) xscale(range(0 6))
	graph export $output_folder/sample`sample_number'_imputed/ClimatePersonal_Dist.pdf, replace

	hist ImageConcern if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ytitle("") xtitle("") color(blue%30) title("Important that other people perceive you positively", size(medium)) xlabel(1 "Not important at all" 5 "Extremely important", labsize(small)) xscale(range(0 6))
	graph export $output_folder/sample`sample_number'_imputed/ImageConcern_Dist.pdf, replace

	hist Donation if sample`sample_number'==1, frac width(2) ytitle("") xtitle("") color(blue%30) title("Donation to climate change org.", size(medium)) xscale(range(0 6))
	graph export $output_folder/sample`sample_number'_imputed/Donation_Dist.pdf, replace

	hist BotKnow if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ytitle("") xtitle("") color(blue%30) title("Familiarity with Gen AI", size(medium)) xlabel(5 "Familiar, Use frequently" 3 "Somewhat familiar, Use rarely" 1 "Not aware", labsize(small)) xscale(range(0 6))
	graph export $output_folder/sample`sample_number'_imputed/BotKnow_Dist.pdf, replace

	hist InitialAIEffective if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ytitle("") xtitle("") color(blue%30) title("Effectiveness of Gen AI at producing persuasive messages", size(small)) xlabel(1 "Not at all effective" 5 "Extremely effective", labsize(small)) xscale(range(0 6))
	graph export $output_folder/sample`sample_number'_imputed/InitialAIEffective_Dist.pdf, replace

	hist BaseAIDiff if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ytitle("") xtitle("") color(blue%30) title("How different does your writing feel compared to something generated by AI", size(small)) xlabel(1 "Not at all different" 5 "Extremely different", labsize(small)) xscale(range(0 6))
	graph export $output_folder/sample`sample_number'_imputed/BaseAIDiff_Dist.pdf, replace
}


bot_histograms

********************************************************************************
* START: ADDED DESCRIPTIVE PLOTS TO MATCH ORIGINAL ANALYSIS
********************************************************************************


*** 1) Venn Diagram for Social Media Use ***
vennbar YouTube Instagram LinkedIn Snapchat TikTok Nothing, title("Top 5 platforms", size(medium))
graph export $output_folder/social_media_use.pdf, replace


*** 2) CI Plots for Imputed Outcomes (Residualized) ***

* For sample 2 (all who passed attention check)
foreach x in $OUTCOMES_imp {

	preserve

	keep if sample2
	make_ciplot_swiss, outcome(`x') by_var(TreatInteract) folder(sample2_imputed/post_ciplots) residualize(yes) subtitle("`: var label `x'' by Treatment (Residualized)")
	restore
}

* For sample 5 (all who passed attention check AND shared handle)
foreach x in $OUTCOMES_imp {
	preserve
	keep if sample5
	make_ciplot_swiss, outcome(`x') by_var(TreatInteract) folder(sample5_imputed/post_ciplots) residualize(yes) subtitle("`: var label `x'' by Treatment (Residualized, Shared Handle)")
	restore
}

********************************************************************************
* END: ADDED DESCRIPTIVE PLOTS
********************************************************************************

**********************
*** writing tasks ****
**********************


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

	esttab using $output_folder/sample`sample_number'_imputed`N_folder'/post/`outcome'`N'_table.tex, ar2 se title("Regression") obslast prehead(`"\documentclass{article}"' `"\usepackage{booktabs}"' `"\usepackage[margin=0.1in]{geometry}"' `"\begin{document}"' `"\begin{table}[htbp]\centering"' `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"'  `"\caption{@title}"' `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@E}{c}}"' `"\toprule"') width(\hsize) nodep $stars addnotes("`r(ynote)'" "`r(xnote1)'" "`r(xnote2)'") scalar("instasample Use Instagram" "basepostcontrols ClimateLong controls" "handle Provide Insta Handle") page booktabs compress replace noisily

	restore

end 


* table1, outcome(emotional_appeal) sample_number(2) basepostvars(BaseTextLength* Base_log1TextLength Base_emotional_appeal) standardize(yes)

** all outcomes 


foreach sample_number in 2 3 4 5 6 7 {
	foreach outcome in $OUTCOMES_imp {
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

	esttab using $output_folder/sample`sample_number'_imputed`N_folder'/post/`outcome'`N'_table_heterogeneity`extension'.tex, r2 ar2 se ///
	title("`outcome' heterogeneity") obslast prehead(`"\documentclass{article}"' `"\usepackage{booktabs}"' `"\usepackage[margin=0.15in]{geometry}"' `"\begin{document}"' `""' `"\begin{table}[htbp]\centering"' `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' `"\caption{@title}"' `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@E}{c}}"' `"\toprule"') width(\hsize) ///
	nodep $stars addnotes("`ynote'" "`xnote1'" "`xnote2'" "`r(xnote3)'" "`r(xnote4)'" "`r(xnote5)'" "`r(xnote6)'" "`r(xnote7)'" "`r(xnote8)'" "`r(xnote9)'" "`r(xnote10)'" "`r(xnote11)'") page booktabs compress replace

	restore

end 



* table2, outcome(WTPBinary_imp) sample_number(2) indepvars($DEMOG $MODERATORS) moderator($MODERATORS) standardize(yes)

* Note: table2 is designed to test for heterogeneous treatment effects. Running table2 on sample2 and sample5 would estimate the average heterogeneous effect across both of these conditions. This is misleading because it washes out or confounds the distinct effects happening in each group.

* Loop 1: Run the main heterogeneity analysis on all four key subgroups.
* This ensures that sample6 and sample7 get their primary output files in their own folders.
foreach sample_number in 3 4 6 7 {
	foreach outcome in $OUTCOMES_imp {
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
	foreach outcome in $OUTCOMES_imp {
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