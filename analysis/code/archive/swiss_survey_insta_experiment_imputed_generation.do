/*******************************************************************************
  SELECTION BIAS CORRECTION: ATTRITION ANALYSIS (CORRECTED VERSION)
  
  Goal: Tease out effect of AI presence on SELECTION vs. EFFORT
  
  CRITICAL FIX: Use Attrited (survey non-completion) as outcome, 
                NOT AttritionFull (survey + writing combined)
  
  This matches the original analysis which treats:
  - Survey completion (Finished_num) as PRIMARY outcome
  - Writing behavior (wrote_nonempty_post) as SEPARATE outcome
     
*******************************************************************************/

clear all
macro drop _all
global PATH "D:\Projects\AIComm\analysis"
cd $PATH
use input/SwissSurvey_Insta_Experiment.dta, clear

/*******************************************************************************
  STEP 0: Data pre-process: Same as before
*******************************************************************************/


local agree_text "I agree to participate, and I promise to read the questions carefully and answer honestly"
capture confirm numeric variable Participate
if (_rc==0) {
    keep if Participate==1
}
else {
    keep if Participate==`"`agree_text'"'
}

drop if missing(TreatIdentify) | missing(TreatComp2)

gen byte Identify = .
capture confirm string variable TreatIdentify
if (_rc==0) {
    replace Identify = 0 if strpos(TreatIdentify,"Anonymous")
    replace Identify = 1 if strpos(TreatIdentify,"Identified")
}
else {
    replace Identify = TreatIdentify if inlist(TreatIdentify,0,1)
}
drop if missing(Identify)

destring TreatComp2, replace force
drop if !inlist(TreatComp2,1,3)
gen byte AITreat = (TreatComp2 == 3)

capture drop Finished_num
capture confirm numeric variable Finished
if (_rc==0) {
    gen byte Finished_num = Finished
}
else {
    gen byte Finished_num = .
    replace Finished_num = 1 if inlist(Finished,"1","True","TRUE","true")
    replace Finished_num = 0 if inlist(Finished,"0","False","FALSE","false")
}

gen AttnCheck_recode = regexm(AttnCheck, "read the instructions")
replace AttnCheck_recode = 1 if regexm(AttnCheck, "read the instructioins")
replace AttnCheck_recode = 1 if regexm(AttnCheck, "instruction")
replace AttnCheck_recode = 1 if regexm(AttnCheck, "Instruction")
replace AttnCheck_recode = 1 if regexm(AttnCheck, "intruction")
replace AttnCheck_recode = 1 if regexm(AttnCheck, "insturction")
replace AttnCheck_recode = 1 if regexm(AttnCheck, "instuction")
replace AttnCheck_recode = 1 if regexm(AttnCheck, "habe die Anweisungen gelesen")
tab AttnCheck_recode, m


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


capture confirm variable wrote_nonempty_post
if _rc==0 drop wrote_nonempty_post
gen byte wrote_nonempty_post = 0
replace wrote_nonempty_post = 1 if !missing(Post) & ustrlen(ustrtrim(Post)) >= 1
label var wrote_nonempty_post "Wrote climate task text (≥1 chars)"

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

add_gpt_measures
label_variables


gen byte shared_handle = !missing(InstaHandle) & InstaHandle != ""
gen byte not_shared_handle = missing(InstaHandle) | InstaHandle == ""

* Convenience locals
local cond_full      "AttnCheck_recode == 1"
local cond_shared    "AttnCheck_recode == 1 & shared_handle == 1"
local cond_notshared "AttnCheck_recode == 1 & not_shared_handle == 1"

local g12 "(Group4_attrition==1 | Group4_attrition==2)"
local g13 "(Group4_attrition==1 | Group4_attrition==3)"
local g24 "(Group4_attrition==2 | Group4_attrition==4)"
local g34 "(Group4_attrition==3 | Group4_attrition==4)"


/*******************************************************************************
  STEP 1: Covariates to predict attrition
*******************************************************************************/

* Attrited and NoPost are the opposite of Finished_num and wrote_nonempty_post

gen byte Attrited = (Finished_num == 0)
label var Attrited "Did not finish survey (Attrited)"

gen byte NoPost = (wrote_nonempty_post == 0)
label var NoPost "Did not write non-empty post (SECONDARY OUTCOME)"


* Combined attrition: Either didn't finish OR didn't write
* NOTE: This is NOT used in attrition modeling, only for reference
gen byte AttritionFull = (Attrited == 1 | NoPost == 1)
label var AttritionFull "Attrited or did not write post (REFERENCE ONLY)"


// * Display attrition rates
// display as text _n "Attrition rates by type:"
// qui count
// local total = r(N)
// qui count if Attrited == 1
// display as text "  Survey non-completion (Attrited): " as result r(N) as text " / " as result `total' as text " = " as result %5.2f (r(N)/`total'*100) "%"
// qui count if NoPost == 1
// display as text "  Did not write post (NoPost):     " as result r(N) as text " / " as result `total' as text " = " as result %5.2f (r(N)/`total'*100) "%"
// qui count if AttritionFull == 1
// display as text "  Combined (AttritionFull):        " as result r(N) as text " / " as result `total' as text " = " as result %5.2f (r(N)/`total'*100) "%"


keep if AttnCheck_recode ==1

* Age: c.Age
* University: i.University


* Base_personal_anecdote : Not so much variation
* c.Base_emotional_appeal
* i.Base_scientific_argument
* c.Base_progressive_score
* c.Base_grammatical_mistakes
* i.Base_moral_narratives_binary : Only one person with Base_moral_narratives = 2
* c.Base_causal_narratives
* c.Base_sentiment_symmetric =>-1,0,1 : Base_sentiment (0=negative, 1=neutral, 2=positive)
* i.Base_collective_action
* c.UseImageConcern (Range 0 to 4) instead of ImageConcern which starts from 1 to 5
* c.BotKnow_categorical, i.BotSupport_human_binary, i.BotSupport_genai_binary, i.BotSocialMedia_human_binary, i.BotSocialMedia_genai_binary
* i.PostReact
* c.BaseAIDiff
* c.InitialAIEffective
* i.ReadingReact1, i.GuessWriterHuman, i.ReadingReact2, i.GuessWriterAI



capture drop Female
capture confirm variable Gender
if (_rc == 0) {
    gen byte Female = (Gender == 2) if !missing(Gender)
}
else {
    gen byte Female = .
}


capture drop Switzerland
capture confirm variable OriginCountry
if (_rc == 0) {
    gen byte Switzerland = (OriginCountry == "Switzerland") if !missing(OriginCountry)
}
else {
    gen byte Switzerland = .
}

capture drop Graduated_degree
capture confirm variable Education
if (_rc == 0) {
    gen byte Graduated_degree = (Education == 2 | Education == 3 ) if !missing(Education)
}
else {
    gen byte Graduated_degree = .
}


capture drop Vote
capture confirm variable SwissPoliticalParty
if (_rc == 0) {
    gen byte Vote = (SwissPoliticalParty != "I did not vote in the last election") if !missing(SwissPoliticalParty)
}
else {
    gen byte Vote = .
}


// capture drop ClimateWorry_degree
// capture confirm variable ClimateWorry
// if (_rc == 0) {
//
//     gen byte ClimateWorry_degree = .
//
//     replace ClimateWorry_degree = 0 if inlist(ClimateWorry, ///
//         "Not at all worried", "Not very worried")
//
//     replace ClimateWorry_degree = 1 if ClimateWorry == "Moderately worried"
//     replace ClimateWorry_degree = 2 if ClimateWorry == "Very worried"
//     replace ClimateWorry_degree = 3 if ClimateWorry == "Extremely worried"
//
//     label define ClimateWorry_degree_lab ///
//         0 "Not/not very worried" ///
//         1 "Moderately worried" ///
//         2 "Very worried" ///
//         3 "Extremely worried"
// }

capture drop ClimateWorry_binary
capture confirm variable ClimateWorry
if (_rc == 0) {
    gen byte ClimateWorry_binary = .
    replace ClimateWorry_binary = 0 if inlist(ClimateWorry, 1, 2, 3)
    replace ClimateWorry_binary = 1 if inlist(ClimateWorry, 4, 5)
	}

capture drop ClimatePersonal_binary
capture confirm variable ClimatePersonal
if (_rc == 0) {
    gen byte ClimatePersonal_binary = .
    replace ClimatePersonal_binary = 0 if inlist(ClimatePersonal, 1, 2, 3)
    replace ClimatePersonal_binary = 1 if inlist(ClimatePersonal, 4, 5)
	}
		


// capture drop Base_grammatical_mistakes_3
// capture confirm variable Base_grammatical_mistakes
// if (_rc == 0) {
//     gen byte Base_grammatical_mistakes_3 = .
//     replace Base_grammatical_mistakes_3 = 0 if (Base_grammatical_mistakes == 0)
//     replace Base_grammatical_mistakes_3 = 1 if inlist(Base_grammatical_mistakes, 1, 2)
// 	replace Base_grammatical_mistakes_3 = 2 if inlist(Base_grammatical_mistakes, 3, 4, 5, 6, 7, 8, 9,10)
// 	}

capture drop Base_moral_narratives_binary
capture confirm variable Base_moral_narratives
if (_rc == 0) {
    gen byte Base_moral_narratives_binary = .
    replace Base_moral_narratives_binary = 0 if (Base_moral_narratives == 0)
    replace Base_moral_narratives_binary = 1 if inlist(Base_moral_narratives, 1, 2)
	}

capture drop Base_sentiment_symmetric
capture confirm variable Base_sentiment
if (_rc == 0) {
    gen byte Base_sentiment_symmetric = .
    replace Base_sentiment_symmetric = -1 if (Base_sentiment == 0)
    replace Base_sentiment_symmetric = 0 if (Base_sentiment == 1)
	replace Base_sentiment_symmetric = 1 if (Base_sentiment == 2)
	}


capture drop UseImageConcern
capture confirm variable ImageConcern
if (_rc == 0) {
    gen byte UseImageConcern = .
    replace UseImageConcern = (ImageConcern -1) if !missing(ImageConcern)
	}
	
capture drop BotKnow_categorical
capture confirm variable BotKnow
if (_rc == 0) {
    gen byte BotKnow_categorical = .
    replace BotKnow_categorical = -1 if inlist(BotKnow, 1, 2, 3)
	replace BotKnow_categorical = 0 if inlist(BotKnow, 4)
	replace BotKnow_categorical = 1 if inlist(BotKnow, 5)
	}



capture drop BotSupport_human_binary
capture confirm variable BotSupport_1
if (_rc == 0) {
    gen byte BotSupport_human_binary = 0
    replace BotSupport_human_binary = 1 if inlist(BotSupport_1, 5)
	}

capture drop BotSupport_genai_binary
capture confirm variable BotSupport_3
if (_rc == 0) {
    gen byte BotSupport_genai_binary = 0
    replace BotSupport_genai_binary = 1 if inlist(BotSupport_3, 4,5)
	}
	
capture drop BotSocialMedia_human_binary
capture confirm variable BotSocialMedia_1
if (_rc == 0) {
    gen byte BotSocialMedia_human_binary = 0
    replace BotSocialMedia_human_binary = 1 if inlist(BotSocialMedia_1, 4,5)
	}

capture drop BotSocialMedia_genai_binary
capture confirm variable BotSocialMedia_3
if (_rc == 0) {
    gen byte BotSocialMedia_genai_binary = 0
    replace BotSocialMedia_genai_binary = 1 if inlist(BotSocialMedia_3, 4,5)
	}

	
*** Logit/Probit *****	
/*

global ATTRIT_COVARS_POSSIBLE c.Age i.Female i.Switzerland i.Graduated_degree i.Vote ///
	c.UseImageConcern c.BotKnow_categorical ///
	i.BotSupport_human_binary i.BotSupport_genai_binary i.BotSocialMedia_human_binary i.BotSocialMedia_genai_binary ///
	i.PostReact c.BaseAIDiff c.InitialAIEffective ///
	i.ReadingReact1 i.GuessWriterHuman i.ReadingReact2 i.GuessWriterAI

* 1. LASSO logit on group 3 only (CV-selected lambda)
lasso logit Attrited $ATTRIT_COVARS_POSSIBLE if Group4_attrition == 3, selection(cv) grid(300) rseed(2025)

* (optional) inspect which variables lasso kept and their standardized coeffs
lassocoef, display(coef, standardized) sort(coef, standardized)

* (optional) store lasso coefficients **before** any other estimation
matrix b3_lasso = e(b)
matrix b3_lasso_std = e(b_standardized)

* 2. Get the selected variable list from lasso
local selvars3 `e(allvars_sel)'
display "Group 3 selected vars: `selvars3'"

* 3. Refit an ordinary logit on the selected vars, still in group 3
logit Attrited `selvars3' if Group4_attrition == 3

* 4. Predict attrition probabilities from that ordinary logit
*    p_attrit_g3 is the NEW VARIABLE containing the probabilities
*predict p_attrit_g3, pr

* candidate covariates defined earlier:
* global ATTRIT_COVARS_POSSIBLE ...

forvalues g = 3/4 {

    di "===== Group `g' ====="

    * 1. LASSO logit within group g
    lasso logit Attrited $ATTRIT_COVARS_POSSIBLE if Group4_attrition == `g', ///
        selection(cv) grid(300) rseed(2025)

    * (optional) see which vars were selected
    lassocoef, display(coef, standardized) sort(coef, standardized)

    * (optional) save lasso coefficient matrices
    matrix b_lasso_g`g'      = e(b)
    matrix b_lasso_std_g`g'  = e(b_standardized)

    * 2. grab selected variables into a local for this group
    local selvars`g' `e(allvars_sel)'
    di "Group `g' selected vars: `selvars`g''"

    * 3. refit ordinary logit on selected vars in group g
    logit Attrited `selvars`g'' if Group4_attrition == `g'

    * 4. predict probabilities for all obs under group-g model
    *    this creates p_attrit_g1, p_attrit_g2, p_attrit_g3, p_attrit_g4
    predict p_attrit_g`g', pr
}

	


*post-treatment stuff in the instrument is the WTP block and its follow-ups (WTP1, GenAIEffective, PerceiveHuman, SignalValue, PerceivedEngaged, WTPLongYes/No, StudyPurposeLong, etc.) which you are not including right now. Those definitely should not go into the attrition logit.


*Full:
// global ATTRIT_COVARS_Full c.Age i.Female i.Switzerland i.Graduated_degree i.Vote ///
// 	c.Base_emotional_appeal i.Base_scientific_argument c.Base_progressive_score c.Base_grammatical_mistakes ///
//     i.Base_moral_narratives_binary c.Base_causal_narratives c.Base_sentiment_symmetric ///
// 	i.Base_collective_action c.UseImageConcern c.BotKnow_categorical i.BotSupport_human_binary ///
// 	i.BotSupport_genai_binary i.BotSocialMedia_human_binary i.BotSocialMedia_genai_binary ///
// 	i.PostReact c.BaseAIDiff c.InitialAIEffective i.ReadingReact1 i.GuessWriterHuman i.ReadingReact2 i.GuessWriterAI

*/

*** Imputation ***


gen TextLength = strlen(Post) 
gen BaseTextLength = strlen(ClimateLong)
gen BaseTextLength2 = BaseTextLength^2 
gen BaseTextLength3 = BaseTextLength^3 	
gen Base_log1TextLength = log(1+BaseTextLength)
gen log1TextLength = log(1+TextLength)
gen WTPBinary = WTP>0
label var WTPBinary "WTP>0"
destring TimeSignaling2_PageSubmit, gen(TimePost)

/*
global OUTCOMES WTPBinary WTP GenAIEffective SignalValue PerceiveAI PerceiveEngaged log1TextLength TimePost TaskQuizCorrect

global GPT_OUTCOME_LIST personal_anecdote emotional_appeal emotional_appeal_new scientific_argument progressive_score grammatical_mistakes moral_narratives causal_narratives sentiment collective_action

global GPT_SCORE_OUTCOME_LIST personal_anecdote emotional_appeal scientific_argument progressive_score moral_narratives causal_narratives sentiment collective_action

global ATTRIT_COVARS_POSSIBLE c.Age i.Female i.Switzerland i.Graduated_degree i.Vote ///
	c.UseImageConcern c.BotKnow_categorical ///
	i.BotSupport_human_binary i.BotSupport_genai_binary i.BotSocialMedia_human_binary i.BotSocialMedia_genai_binary ///
	i.PostReact c.BaseAIDiff c.InitialAIEffective ///
	i.ReacodedingReact1 i.GuessWriterHuman i.ReadingReact2 i.GuessWriterAI

foreach outcome in $OUTCOMES {
	
	forvalues g = 1/4 {
		
		di "===== `outcome' in Group `g' ====="
	
		lasso logit outcome $ATTRIT_COVARS_POSSIBLE if (Group4_attrition == `g' & Attrited == 0), selection(cv) grid(300) rseed(2025)
	
		* (optional) see which vars were selected
		lassocoef, display(coef, standardized) sort(coef, standardized)
		
		* (optional) save lasso coefficient matrices
		matrix b_lasso_g`g'      = e(b)
		matrix b_lasso_std_g`g'  = e(b_standardized)
	
		* 2. grab selected variables into a local for this group
		local selvars`outcome'`g' `e(allvars_sel)'
		di "Group `g' selected vars: `selvars`outcome'`g''"
	
		* 3. refit ordinary logit on selected vars in group g
		logit outcome `selvars`outcome'`g'' if (Group4_attrition == `g' & Attrited == 0)
	
		* 4. predict probabilities for all obs under group-g model
		*    this creates p_attrit_g1, p_attrit_g2, p_attrit_g3, p_attrit_g4
		predict est_`outcome'_Group`g' if (Group4_attrition == `g' & Attrited == 1), pr
	}
*/

*------------------------------------------------------------
* OUTCOME VARIABLES
*------------------------------------------------------------

* Binary outcomes (0/1)
global OUT_BIN  WTPBinary TaskQuizCorrect

* Continuous / ordinal outcomes
* - WTP:       continuous bid [0,10]
* - GenAIEffective: 0–3 (Unsure, Less, Equal, More) – treat as numeric
* - SignalValue, PerceiveAI, PerceiveEngaged: 1–5 Likert – treat as numeric
* - log1TextLength, TimePost: continuous
global OUT_CONT WTP GenAIEffective SignalValue PerceiveAI PerceiveEngaged log1TextLength TimePost

*------------------------------------------------------------
* CANDIDATE PREDICTORS (all pre-treatment, observed for attriters)
*------------------------------------------------------------
global ATTRIT_COVARS_POSSIBLE ///
    c.Age i.Female i.Switzerland i.Graduated_degree i.Vote ///
    c.UseImageConcern c.BotKnow_categorical ///
    i.BotSupport_human_binary i.BotSupport_genai_binary ///
    i.BotSocialMedia_human_binary i.BotSocialMedia_genai_binary ///
    i.PostReact c.BaseAIDiff c.InitialAIEffective ///
    i.ReadingReact1 i.GuessWriterHuman i.ReadingReact2 i.GuessWriterAI


*============================================================
* BINARY OUTCOMES (WTPBinary, TaskQuizCorrect)
*============================================================

foreach y of global OUT_BIN {

    di "========== Imputing binary outcome `y' =========="

    * Start imputed variable as observed value, but blank out attriters
    capture drop `y'_imp
    gen double `y'_imp = `y'
    replace `y'_imp = . if Attrited == 1

    capture drop `y'_imp_flag
    gen byte `y'_imp_flag = 0

    * Loop over the 4 treatment groups
    forvalues g = 1/4 {

        di "----- Outcome `y', Group `g' -----"

        * Restrict to non-attriters with nonmissing outcome in this group
        quietly count if Group4_attrition == `g' & Attrited == 0 & !missing(`y')
        if r(N) == 0 {
            di as error "   No non-attriters with nonmissing `y' in group `g'; skipping."
            continue
        }

        * 1. LASSO LOGIT SELECTION on non-attriters in group g
        lasso logit `y' $ATTRIT_COVARS_POSSIBLE ///
            if Group4_attrition == `g' & Attrited == 0 & !missing(`y'), ///
            selection(cv) grid(300) rseed(2025)

        * Get selected covariates
        local selvars_`y'_g`g' `e(allvars_sel)'
        di "   Selected vars (group `g', `y'): `selvars_`y'_g`g''"

        * If nothing selected, fall back to group mean
        if "`selvars_`y'_g`g''" == "" {
            quietly summarize `y' if Group4_attrition == `g' & Attrited == 0 & !missing(`y')
            local mu = r(mean)
            di "   No vars selected; imputing group-`g' mean = `mu'"
            replace `y'_imp = `mu' if Attrited == 1 & Group4_attrition == `g'
            replace `y'_imp_flag = 1 if Attrited == 1 & Group4_attrition == `g'
            continue
        }

        * 2. REFIT ORDINARY LOGIT ON SELECTED COVARIATES (non-attriters only)
        logit `y' `selvars_`y'_g`g'' ///
            if Group4_attrition == `g' & Attrited == 0 & !missing(`y')

        * 3. PREDICT P(Y=1 | X) FOR EVERYONE IN GROUP g
        tempvar phat
        predict double `phat' if Group4_attrition == `g', pr

        * 4. IMPUTE FOR ATTRITERS IN GROUP g
        replace `y'_imp = `phat' if Attrited == 1 & Group4_attrition == `g' ///
            & !missing(`phat')
        replace `y'_imp_flag = 1 if Attrited == 1 & Group4_attrition == `g' ///
            & !missing(`phat')
    }
}


*============================================================
* CONTINUOUS / ORDINAL OUTCOMES
* (treated as numeric: WTP, GenAIEffective, SignalValue,
*  PerceiveAI, PerceiveEngaged, log1TextLength, TimePost)
*============================================================

foreach y of global OUT_CONT {

    di "========== Imputing continuous/ordinal outcome `y' =========="

    * Start imputed variable as observed value, but blank out attriters
    capture drop `y'_imp
    gen double `y'_imp = `y'
    replace `y'_imp = . if Attrited == 1

    capture drop `y'_imp_flag
    gen byte `y'_imp_flag = 0

    * Loop over the 4 treatment groups
    forvalues g = 1/4 {

        di "----- Outcome `y', Group `g' -----"

        * Restrict to non-attriters with nonmissing outcome in this group
        quietly count if Group4_attrition == `g' & Attrited == 0 & !missing(`y')
        if r(N) == 0 {
            di as error "   No non-attriters with nonmissing `y' in group `g'; skipping."
            continue
        }

        * 1. LASSO LINEAR SELECTION on non-attriters in group g
        lasso linear `y' $ATTRIT_COVARS_POSSIBLE ///
            if Group4_attrition == `g' & Attrited == 0 & !missing(`y'), ///
            selection(cv) grid(300) rseed(2025)

        * Get selected covariates
        local selvars_`y'_g`g' `e(allvars_sel)'
        di "   Selected vars (group `g', `y'): `selvars_`y'_g`g''"

        * If nothing selected, fall back to group mean
        if "`selvars_`y'_g`g''" == "" {
            quietly summarize `y' if Group4_attrition == `g' & Attrited == 0 & !missing(`y')
            local mu = r(mean)
            di "   No vars selected; imputing group-`g' mean = `mu'"
            replace `y'_imp = `mu' if Attrited == 1 & Group4_attrition == `g'
            replace `y'_imp_flag = 1 if Attrited == 1 & Group4_attrition == `g'
            continue
        }

        * 2. REFIT OLS ON SELECTED COVARIATES (non-attriters only)
        regress `y' `selvars_`y'_g`g'' ///
            if Group4_attrition == `g' & Attrited == 0 & !missing(`y')

        * 3. PREDICT E[Y | X] FOR EVERYONE IN GROUP g
        tempvar yhat
        predict double `yhat' if Group4_attrition == `g'

        * 4. IMPUTE FOR ATTRITERS IN GROUP g
        replace `y'_imp = `yhat' if Attrited == 1 & Group4_attrition == `g' ///
            & !missing(`yhat')
        replace `y'_imp_flag = 1 if Attrited == 1 & Group4_attrition == `g' ///
            & !missing(`yhat')
    }
}

save "input/SwissSurvey_Insta_Experiment_imputed.dta", replace