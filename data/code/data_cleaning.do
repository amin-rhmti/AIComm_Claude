***************
* Environment *
***************

clear all
macro drop _all
//  set trace on
set varabbrev off
set scheme s1manual

global PATH "D:\Projects\Original\AIComm\data"
cd $PATH


global raw_csv "input/AICommunication_Sender_Survey_Zuerich_Insta_Experiment_June_2_2025.csv"
global gpt_dataset "input/SwissSurvey_Analysis_GPT_Measurements_Scores_Only.dta"
global pangram_dataset "input/SwissSurvey_Analysis_Pangram_Recoded.dta"
global dataset_final "output/SwissSurvey_Insta_Experiment_clean.dta"

cap program drop translate_codebook
program translate_codebook
	
	import delim using "$raw_csv", clear stringcols(_all) bindquote(strict) maxquotedrows(unlimited) case (preserve) varn(1)
	
	drop if _n <= 2
	keep if (Status != "Survey Preview") & (SurveyVersion != "01/29/2025 pilot7")
	
	**************************
	*****   Qualtrics    *****
	**************************
	
	* drop the extra string of (Strongly Prefer) and (Strongly Prefer Not) from the variable BotSocialMedia_* & BotSupport_*
	forvalues i = 1/3 {
		replace BotSocialMedia_`i' = substr(BotSocialMedia_`i', 1, 1)
		replace BotSupport_`i' = substr(BotSupport_`i', 1, 1)
	}
	
	
	include "code/temp/sender_survey_zuerich_insta_experiment/rename_code.do"
	include "code/temp/sender_survey_zuerich_insta_experiment/tostring_code.do"
	
	* Remove extra spaces
	foreach y of varlist   *  {  
		di "`y'"
		replace `y'= stritrim(`y') 
		replace `y'=rtrim(`y')
		}
	
	include "code/temp/sender_survey_zuerich_insta_experiment/sdecode_code.do"
	include "code/temp/sender_survey_zuerich_insta_experiment/replace_code.do"
	include "code/temp/sender_survey_zuerich_insta_experiment/destring_code.do"
	include "code/temp/sender_survey_zuerich_insta_experiment/label_code.do"
	include "code/temp/sender_survey_zuerich_insta_experiment/label_var_code.do"

	**************************
	***** 	  LLM	     *****
	**************************
	
	merge 1:1 ResponseId using "$gpt_dataset", ///
	keepusing(Post_typos_count Base_typos_count ///
	Post_personal_anecdote Base_personal_anecdote Post_emotional_appeal ///
	Base_emotional_appeal Post_scientific_argument Base_scientific_argument ///
	Post_meaningfulness Base_meaningfulness Post_moral_narratives ///
	Base_moral_narratives Post_causal_narratives Base_causal_narratives) ///
	nogen
	
	replace Post_meaningfulness = 0 if missing(Post_meaningfulness)
	replace Base_meaningfulness = 0 if missing(Base_meaningfulness)
	
	merge 1:1 ResponseId using "$pangram_dataset", ///
	keepusing (Post_pangram_headline Base_pangram_headline  Post_fraction_ai Base_fraction_ai /// 
	Base_fraction_ai_assisted Base_fraction_human Post_fraction_ai_assisted Post_fraction_human) ///
	nogen
	
	include "code/temp/gpt_pangram_measures/rename_code.do"
	include "code/temp/gpt_pangram_measures/tostring_code.do"
	include "code/temp/gpt_pangram_measures/sdecode_code.do"
	include "code/temp/gpt_pangram_measures/replace_code.do"
	include "code/temp/gpt_pangram_measures/destring_code.do"
	include "code/temp/gpt_pangram_measures/label_code.do"
	include "code/temp/gpt_pangram_measures/label_var_code.do"

	recode Post_pangram_headline (1 2 3 = 1) (4 = 0), generate(Post_AIness)
	label define ainess_lbl 0 "Fully Human Written" 1 "Not Fully Human Written"
	label values Post_AIness ainess_lbl
	label variable Post_AIness "Binary indicator for AI involvement"

	recode base_pangram_headline (1 2 3 = 1) (4 = 0), generate(base_AIness)
	label define ainess_lbl 0 "Fully Human Written" 1 "Not Fully Human Written"
	label values base_AIness ainess_lbl
	label variable base_AIness "Binary indicator for AI involvement"


end

cap program drop sample_defenition
program sample_defenition	

	* --- Base Samples (Whole Eligible Population) ---
	gen byte sample2  = 1 // Passed attention check and Consented (filtered previously)
	gen byte sample3  = Identify
	gen byte sample4  = !Identify
	gen byte sample5  = shared_handle
	gen byte sample6  = shared_handle & Identify 
	gen byte sample7  = shared_handle & !Identify
	gen byte sample8  = not_shared_handle
	gen byte sample9  = not_shared_handle & Identify
	gen byte sample10 = not_shared_handle & !Identify
	gen byte sample11 = AITreat
	gen byte sample12 = !AITreat

	* --- Instagram Subsamples (Sample X * 10) ---
	gen byte sample20  = Instagram_use
	gen byte sample30  = Instagram_use & Identify
	gen byte sample40  = Instagram_use & !Identify
	// 	gen byte sample50  = Instagram_use & shared_handle
	// 	gen byte sample60  = Instagram_use & shared_handle & Identify
	// 	gen byte sample70  = Instagram_use & shared_handle & !Identify
	gen byte sample80  = Instagram_use & not_shared_handle
	gen byte sample90  = Instagram_use & not_shared_handle & Identify
	gen byte sample100 = Instagram_use & not_shared_handle & !Identify
	gen byte sample110 = Instagram_use & AITreat
	gen byte sample120 = Instagram_use & !AITreat

end


cap program drop variables_refinement
program variables_refinement
	
	** Pre-Treatment **
	
	gen byte Grad_degree = 0
	replace Grad_degree = 1 if (Education == 2 | Education == 3 )
	label var Grad_degree "Master/PhD"
	
	gen byte Vote = 0
	replace Vote = 1 if (SwissPoliticalParty != "I did not vote in the last election") & !missing(SwissPoliticalParty)
	label var Vote "Voted in the last Swiss election"

	gen byte ETH = 0
	replace ETH = 1 if University == 1
		
	gen byte Female = 0
	replace Female = 1 if Gender == 2
	
	gen byte Switzerland = 0
	replace Switzerland = 1 if OriginCountry == "Switzerland"
	
	xtile half = Age, nq(2)
	gen AgeBinary_p50 = (half==2)
	drop half
	label var AgeBinary_p50 "Greater than Med(Age)"
	
	gen byte AgeBinary_adult = (Age >= 25) if !missing(Age)
	label var AgeBinary_adult "25 or older"
	label define adult_lbl 0 "18-24" 1 "25+"
	label values AgeBinary_adult adult_lbl

	gen BotKnowBinary = BotKnow == 5 & !missing(BotKnow)
	label variable BotKnowBinary "Very familiar with AI and frequent user"

	gen AIEffectiveBinary = InitialAIEffective >= 4 & !missing(InitialAIEffective)
	label variable AIEffectiveBinary "Perceives AI as very or extremely effective at persuasion"
	
	gen AIDiffBinary = BaseAIDiff >= 4 & !missing(BaseAIDiff)
	label variable AIDiffBinary "Perceives own writing as very or extremely different from AI"
	
	normalize_data, outcome(ClimateWorry ClimatePersonal) 	
	make_index, outcome(Climate) varset(ClimateWorry_N ClimatePersonal_N)
	
	xtile half = index_Climate, nq(2)
	gen index_ClimateBinary = (half==2)
	drop half
	label var index_ClimateBinary "Greater than Med(index_Climate)"
	
	* Since shared_handle is the opposite of privacy, adding it is similar to subtracting privacy.
	normalize_data, outcome(ImageConcern shared_handle)
	make_index, outcome(Image_minus_privacy) varset(ImageConcern_N shared_handle_N)
	
	xtile half = index_Image_minus_privacy, nq(2)
	gen Image_minus_privacyBinary = (half==2)
	drop half
	label var Image_minus_privacyBinary "Greater than Med(index_Image_minus_privacy)"
	
	
	* Traditional rule based robots are not interesting + Low variation in Humans -> Only use Gen-AI bots as control

	gen BotSupport_AIBinary = BotSupport_AI >= 4 if !missing(BotSupport_AI)
	label variable BotSupport_AIBinary "Prefer/Strongly Prefer AI in Customer Support"
	
	gen BotSocialMedia_AIBinary = BotSocialMedia_AI >= 3 if !missing(BotSocialMedia_AI)
	label variable BotSocialMedia_AIBinary "Indifferent/Prefer/Strongly Prefer AI bots in Social Media"
	
	gen ImageConcernBinary2 = ImageConcern >= 2 & !missing(ImageConcern)
	gen ImageConcernBinary3 = ImageConcern >= 3 & !missing(ImageConcern)
	gen ImageConcernBinary4 = ImageConcern >= 4 & !missing(ImageConcern)
	
	xtile half = ImageConcern, nq(2)
	gen ImageConcernBinary_p50 = (half==2)
	drop half
	label var ImageConcernBinary_p50 "Greater than Med(ImageConcern)"
	
	gen DonationBinary_pos = 0
	replace DonationBinary_pos = 1 if (Donation > 0) & !missing(Donation)
	label var DonationBinary_pos "Positive donation to Climate chgange"
	
	xtile half = Donation, nq(2)
	gen DonationBinary_p50 = (half==2)
	drop half
	label var DonationBinary_p50 "Greater than median =~ 10 donation to Climate chgange"
	
	* Calculate length excluding ALL whitespace (spaces, tabs, line-breaks)
	
	gen Base_TextLength = ustrlen(ustrregexra(Base, "\s", ""))
	gen Base_TextLength_log = log(1+Base_TextLength)
	
	gen Base_NumSentences = (ustrlen(Base) - ustrlen(usubinstr(Base, ".", "", .))) + ///
						(ustrlen(Base) - ustrlen(usubinstr(Base, "!", "", .))) + ///
						(ustrlen(Base) - ustrlen(usubinstr(Base, "?", "", .)))
	replace Base_NumSentences = 1 if Base_NumSentences == 0 & !missing(Base)
	replace Base_NumSentences = 0 if ustrlen(ustrregexra(Base, "\s", "")) < 4
	replace Base_NumSentences = 0 if missing(Base)
	gen Base_AvgSentLen = Base_TextLength / Base_NumSentences
	replace Base_AvgSentLen = 0 if missing(Base_AvgSentLen)
	
	* For the text effort index 
	
	generate Base_Avg_typos = (Base_typos_count / Base_AvgSentLen)
	label variable Base_Avg_typos "Average typos scaled by sentence length (Base)"
	
	generate aux_Base_Avg_typos = -Base_Avg_typos
	label variable aux_Base_Avg_typos "Negative average typos scaled back (Base)"
	
	normalize_data, outcome(Base_TextLength Base_AvgSentLen aux_Base_Avg_typos)
	make_index, outcome(Base_effort_index) varset(Base_TextLength_N Base_AvgSentLen_N aux_Base_Avg_typos_N)
	label variable Base_effort_index "Anderson index of Base_TextLength, Base_AvgSentLen, and -Base_Avg_typos"
	
	normalize_data, outcome(Base_personal_anecdote Base_emotional_appeal Base_scientific_argument Base_causal_narratives)
	make_index, outcome(Base_nlp_index) varset(Base_personal_anecdote_N Base_emotional_appeal_N Base_scientific_argument_N Base_causal_narratives_N)
	label variable Base_nlp_index "Anderson index of personal_anecdote, emotional_appeal, scientific_argument, and ausal_narratives (Base)"
	
	
	* Reaction Variables: React (Like/Dislike) vs. No React 
	
	gen byte ReadingReact1Binary = (ReadingReact1 != 3) if !missing(ReadingReact1)
	label var ReadingReact1Binary "Reacted (Like or Dislike) to first text"
	
	gen byte ReadingReact2Binary = (ReadingReact2 != 3) if !missing(ReadingReact2)
	label var ReadingReact2Binary "Reacted (Like or Dislike) to second text"
	
	gen byte PostReactBinary = (PostReact != 3) if !missing(PostReact)
	label var PostReactBinary "Reacted (Like or Dislike) to own post"

	label define react_lbl 0 "No Reaction" 1 "Reacted (Like/Dislike)"
	label values ReadingReact1Binary react_lbl
	label values ReadingReact2Binary react_lbl
	label values PostReactBinary react_lbl
	
	* Guess Variables: Perceived as Human vs. AI/Rule-Base Bot

	gen byte GuessHuman_asHuman = (GuessWriterHuman == 1) if !missing(GuessWriterHuman)
	label var GuessHuman_asHuman "Correctly identified Human writer as Human"
	
	gen byte GuessAI_asHuman = (GuessWriterAI == 1) if !missing(GuessWriterAI)
	label var GuessAI_asHuman "Mistakenly identified AI writer as Human"
	
	gen byte GuessAI_asAI = (GuessWriterAI == 3) if !missing(GuessWriterAI)
	label var GuessAI_asAI "Correctly identified AI writer as AI"
	
	label define human_lbl 0 "Perceived as AI/Bot" 1 "Perceived as Human"
	label values GuessHuman_asHuman human_lbl
	label values GuessAI_asHuman human_lbl
	
	
	generate aux_AIDiffBinary = -AIDiffBinary
	label variable aux_AIDiffBinary "Perceives own writing similar to AI"

	
	normalize_data, outcome(BotKnowBinary AIEffectiveBinary aux_AIDiffBinary)
	make_index, outcome(ai_trust_index) varset(BotKnowBinary_N AIEffectiveBinary_N AIDiffBinary_N aux_AIDiffBinary_N)
	label variable ai_trust_index "Anderson index of AI knowledge, perceived AI effectiveness, and perceives similar to AI"

	normalize_data, outcome(BotSupport_AIBinary BotSocialMedia_AIBinary)
	make_index, outcome(bot_support_index) varset(BotSupport_AIBinary_N BotSocialMedia_AIBinary_N)
	label variable bot_support_index "Anderson index of support for AI bots and AI on social media"

	normalize_data, outcome(ReadingReact1Binary ReadingReact2Binary PostReactBinary)
	make_index, outcome(react_index) varset(ReadingReact1Binary_N ReadingReact2Binary_N PostReactBinary_N)
	label variable react_index "Anderson index of reactions to readings and post reaction"

	normalize_data, outcome(GuessHuman_asHuman GuessAI_asHuman)
	make_index, outcome(guess_human_index) varset(GuessHuman_asHuman_N GuessAI_asHuman_N)
	label variable guess_human_index "Anderson index of guessing human authorship"
	
	xtile half = ai_trust_index, nq(2)
	gen ai_trust_indexBinary_p50 = (half==2)
	drop half
	label var ai_trust_indexBinary_p50 "Greater than Med(ai_trust_index)"

	xtile half = bot_support_index, nq(2)
	gen bot_support_indexBinary_p50 = (half==2)
	drop half
	label var bot_support_indexBinary_p50 "Greater than Med(bot_support_index)"

	xtile half = react_index, nq(2)
	gen react_indexBinary_p50 = (half==2)
	drop half
	label var react_indexBinary_p50 "Greater than Med(react_index)"

	xtile half = guess_human_index, nq(2)
	gen guess_human_indexBinary_p50 = (half==2)
	drop half
	label var guess_human_indexBinary_p50 "Greater than Med(guess_human_index)"
	
	** Post-Treatment **
	
	// gen byte wrote_nonempty_post = 0
	// replace wrote_nonempty_post = 1 if !missing(Post) & ustrlen(ustrtrim(Post)) >= 1
	// label var wrote_nonempty_post "Wrote climate task text (≥1 chars)"
	
	* Calculate length excluding ALL whitespace (spaces, tabs, line-breaks)

	gen Post_TextLength = ustrlen(ustrregexra(Post, "\s", ""))
	gen Post_TextLength_log = log(1+Post_TextLength)
	
	gen Post_NumSentences = (ustrlen(Post) - ustrlen(usubinstr(Post, ".", "", .))) + ///
						(ustrlen(Post) - ustrlen(usubinstr(Post, "!", "", .))) + ///
						(ustrlen(Post) - ustrlen(usubinstr(Post, "?", "", .)))
	replace Post_NumSentences = 1 if Post_NumSentences == 0 & !missing(Post)
	replace Post_NumSentences = 0 if ustrlen(ustrregexra(Post, "\s", "")) < 4
	replace Post_NumSentences = 0 if missing(Post)
	gen Post_AvgSentLen = Post_TextLength / Post_NumSentences
	replace Post_AvgSentLen = 0 if missing(Post_AvgSentLen)

	generate Post_Avg_typos = (Post_typos_count / Post_AvgSentLen)
	label variable Post_Avg_typos "Average typos scaled by sentence length (Post)"
	
	generate aux_Post_Avg_typos = -Post_Avg_typos
	label variable aux_Post_Avg_typos "Negative average typos scaled back (Post)"

	
	normalize_data, outcome(Post_TextLength Post_AvgSentLen aux_Post_Avg_typos)
	make_index, outcome(Post_effort_index) varset(Post_TextLength_N Post_AvgSentLen_N aux_Post_Avg_typos_N)
	label variable Post_effort_index "Anderson index of Post_TextLength, Post_AvgSentLen, and -Post_Avg_typos"
	
	normalize_data, outcome(Post_personal_anecdote Post_emotional_appeal Post_scientific_argument Post_causal_narratives)
	make_index, outcome(Post_nlp_index) varset(Post_personal_anecdote_N Post_emotional_appeal_N Post_scientific_argument_N Post_causal_narratives_N)
	label variable Post_nlp_index "Anderson index of personal_anecdote, emotional_appeal, scientific_argument, and ausal_narratives (Post)"
	
	normalize_data, outcome(Post_effort_index Post_nlp_index Post_AIness TimePost_W)
	make_index, outcome(Post_overall_index) varset(Post_effort_index_N Post_nlp_index_N Post_AIness_N TimePost_W_N)
	label variable Post_overall_index "Anderson index of effort_index, nlp_index, TimePost_W, and AIness (Post)"
	
	Post_effort_index Post_nlp_index Post_AIness
	
	
	gen WTPBinary_pos = 0
	replace WTPBinary_pos = 1 if (WTP>0) & !missing(WTP)
	
	xtile half = WTP, nq(2)
	gen WTPBinary_p50 = (half==2)
	drop half
	label var WTPBinary_p50 "Greater than Med(WTP)"


	* Convert 0 (Unsure) to .d (Don't Know)
	mvdecode GenAIEffective, mv(0=.d)
	* tab GenAIEffective, missing
	
	
	*Confriming the randomization for order of two reading tasks
	gen Chose1 = substr(Chose, 1, 1)
	destring Chose1, replace
	gen Chose2 = substr(Chose, 2, 1)
	destring Chose2, replace
	* tab Chose1 Chose2
	
	* Qualtrics exports the computer bid as a literal string (e.g. "3+2*0.25"). Parse and evaluate the a+b*c expression; bid is 0 if no expression present.
	gen double a = .
	gen double b = .
	gen double c = .
	replace a = real(regexs(1)) if regexm(computerBid, "^([0-9\.]+)\+([0-9\.]+)\*([0-9\.]+)")
	replace b = real(regexs(2)) if regexm(computerBid, "^([0-9\.]+)\+([0-9\.]+)\*([0-9\.]+)")
	replace c = real(regexs(3)) if regexm(computerBid, "^([0-9\.]+)\+([0-9\.]+)\*([0-9\.]+)")
	gen computerBid_num = .
	replace computerBid_num = a + b * c 
	replace computerBid_num = 0 if missing(computerBid_num)
	drop a b c
	
end

cap program drop normalize_data
program normalize_data

//Takes a list of numeric outcome variables and creates standardized versions (_N) using the mean and SD of the control groups
	syntax, outcome(varlist)
	foreach var in `outcome' {
		sum `var' // if Treatment_Group == 1 instead of TreatComp2 == 1
		gen `var'_N = (`var' - r(mean)) / r(sd)
		local label: variable label `var'
		label var `var'_N "`label'"
    }
	
end

cap program drop make_index
program make_index
	* Creates the indices based on Anderson (2008) utilizing the normalize_data program above. 
	* Positive direction muest always indicates a 'better' outcome.
	* outcomes in an index are weighted by inverted covariance matrix of all variables in the index 

	syntax, outcome(string) varset(varlist) 		
	local varset_`outcome' `varset'
	
	foreach vset in `outcome' { // Loop through all outcome families  	
		* Get number of variables
		local k: word count `varset_`vset''
		* display (`k')
		
		if (`k' > 0) {
			* Initiate covariance matrix
			matrix cov = J(`k', `k', .)

			* Get pairwise covariances
			local i = 1
			
			foreach var1 in `varset_`vset'' {
				local j = 1
				
				foreach var2 in `varset_`vset'' {
					corr `var1' `var2', covariance
					matrix cov[`i', `j'] = el(r(C), 1, 2)
					local j = `j' + 1
				}
				
				local i = `i' + 1
			}
			
			* Move matrix to Mata
			mata: cov = st_matrix("cov") 
			mata: cov
			
			* Get inverse covariance matrix
			mata: invcov = invsym(cov)
			mata: invcov
			
			* Get outcome weights
			mata: weights = rowsum(invcov) 
			mata: weights
			
			* Move outcome weights to Stata
			mata : st_matrix("weight", weights')
			matrix list weight
			svmat double weight, names(weight) 
			
			* Fill in outcome weights for all observations
			forvalues i = 1/`k' { 
				replace weight`i' = weight`i'[1] if weight`i' == . 
			}
		
					
			* Calculate outcome index 
			gen denom = 0
			gen num = 0
			
				local i = 1
				
				foreach v in `varset_`vset'' { // Missing outcomes are excluded
					cap gen `v' = . // Handling if outcome missing for everyone
					replace denom = denom + weight`i' if `v' != . 
					replace num = num + weight`i'*`v' if `v' != . 
					local i = `i' + 1
				}
				
				gen index_`vset' = num / denom
				drop num denom
		 
			* Clear
			drop weight*
			mata: mata clear  
			clear matrix 
		}
	}
	
end 

capture program drop social_media_platform_cleaning
program define social_media_platform_cleaning, rclass
    version 16.0

    local plats "YouTube Instagram LinkedIn Snapchat TikTok Facebook_excl_Messenger X_Twitter BlueSky Reddit"

    foreach v in `plats' Nothing Other No_SoMe Other_SoMe {
        capture drop `v'
    }

    gen byte Nothing = (strpos(SocialMediaPlatform, "I don't use social media")>0) if !missing(SocialMediaPlatform)
    replace Nothing = 0 if missing(Nothing)
    label var Nothing "I don't use social media"

    * Platforms (exact option text)
    gen byte YouTube  = (strpos(SocialMediaPlatform, "YouTube")>0) if !missing(SocialMediaPlatform)
    gen byte Instagram= (strpos(SocialMediaPlatform, "Instagram")>0) if !missing(SocialMediaPlatform)
    gen byte LinkedIn = (strpos(SocialMediaPlatform, "LinkedIn")>0) if !missing(SocialMediaPlatform)
    gen byte Snapchat = (strpos(SocialMediaPlatform, "Snapchat")>0) if !missing(SocialMediaPlatform)
    gen byte TikTok   = (strpos(SocialMediaPlatform, "TikTok")>0) if !missing(SocialMediaPlatform)
    gen byte BlueSky  = (strpos(SocialMediaPlatform, "BlueSky")>0) if !missing(SocialMediaPlatform)
    gen byte Reddit   = (strpos(SocialMediaPlatform, "Reddit")>0) if !missing(SocialMediaPlatform)
    gen byte Facebook_excl_Messenger = (strpos(SocialMediaPlatform, "Facebook (excluding Facebook Messenger)")>0) if !missing(SocialMediaPlatform)
    gen byte X_Twitter= (strpos(SocialMediaPlatform, "X / Twitter")>0) if !missing(SocialMediaPlatform)

    foreach v in `plats' {
        replace `v' = 0 if missing(`v')
    }

    label var Facebook_excl_Messenger "Facebook (excluding Facebook Messenger)"
    label var X_Twitter "X / Twitter"

    * Other: "Other" OR any leftover text besides known options
    gen byte Other = (strpos(SocialMediaPlatform, "Other")>0) if !missing(SocialMediaPlatform)
    replace Other = 0 if missing(Other)

    tempvar cleaned
    gen strL `cleaned' = SocialMediaPlatform

    foreach tok in ///
        "YouTube" "Instagram" "LinkedIn" "Snapchat" "TikTok" ///
        "Facebook (excluding Facebook Messenger)" "X / Twitter" "BlueSky" "Reddit" ///
        "I don't use social media" "Other" {
        replace `cleaned' = subinstr(`cleaned', "`tok'", "", .)
    }

    * remove common separators, then trim
    replace `cleaned' = subinstr(`cleaned', ",", " ", .)
    replace `cleaned' = subinstr(`cleaned' ,";", " ", .)
    replace `cleaned' = subinstr(`cleaned' ,":", " ", .)
    replace `cleaned' = itrim(trim(`cleaned'))

    replace Other = 1 if `cleaned' != "" & !missing(SocialMediaPlatform)
    replace Other = 0 if Nothing==1
    label var Other "Other Social Media (incl. typed-in/unknown text)"

    rename Nothing No_SoMe
    rename Other   Other_SoMe

    * ---- MODIFICATION to address two observations that Stata does not understand! ----*
    replace Other_SoMe = 1 if (YouTube==0 & Instagram==0 & LinkedIn==0 & Snapchat==0 & Other_SoMe==0 & No_SoMe==0)

    foreach v of local plats {
        local lbl_`v' : variable label `v'
    }

    preserve
        keep if No_SoMe==0
        collapse (sum) `plats'
        xpose, clear varname
        rename v1 count
        rename _varname platform
        gsort -count

        local top4 ""
        di as text "Top 4 platforms (count; excluding No_SoMe):"
        forvalues j=1/4 {
            local v = platform[`j']
            local c = count[`j']
            di as text "  `j'. ``lbl_`v'''  (" %9.0g `c' ")"
            local top4 "`top4' `v'"
        }
    restore

    return local top4_platforms "`top4'"
    * By using the following code right after this program, it shows: YouTube Instagram LinkedIn Snapchat
	* local top4 "`r(top4_platforms)'"
	* di "Top 4 (variable names): `r(top4_platforms)'"
	
end

cap program drop data_pre_process
program data_pre_process
	
	social_media_platform_cleaning
	

* ==============================================================================
*  Teatment armes ==> "Identify" & "AITreat"
* ==============================================================================

	gen byte AITreat = .
	replace AITreat = 0 if TreatComp2 == 1
	replace AITreat = 1 if TreatComp2 == 3
	tab AITreat Identify

* ==============================================================================
*  Eligible Filtering
* ==============================================================================

	* I) Keep those who Consented to participate
	keep if Participate==1 // 133+6 dropped
	drop if inlist(ResponseId,"R_2qmoGJOwTgiY2Fs","R_6AByUnOz648fX0t", "R_2j0EPFgn0QI0na9", "R_24N60g8iSv9xQox", "R_8c6m4A4WroPhuGY", "R_8Mfi4tcbAeDag1A", "R_8n7WCyuZQGbwQ8Z") // These participants wrote in the "Post" that they don't want to continue the survey because they shared their Instagram or requested to be dropped out.
	
	* II) Keep the Treated
	drop if missing(Identify) | missing(AITreat) //59 dropped

	* III) Keep those who passed the attention check
	gen AttnCheck_recode = regexm(AttnCheck, "read the instructions")
	replace AttnCheck_recode = 1 if regexm(AttnCheck, "read the instructioins")
	replace AttnCheck_recode = 1 if regexm(AttnCheck, "instruction")
	replace AttnCheck_recode = 1 if regexm(AttnCheck, "Instruction")
	replace AttnCheck_recode = 1 if regexm(AttnCheck, "intruction")
	replace AttnCheck_recode = 1 if regexm(AttnCheck, "insturction")
	replace AttnCheck_recode = 1 if regexm(AttnCheck, "instuction")
	replace AttnCheck_recode = 1 if regexm(AttnCheck, "habe die Anweisungen gelesen")
	keep if AttnCheck_recode // 95 dropped ==> n= 1075

	gen byte Treatment_Group = .
	label variable Treatment_Group "Treatment group (AI × Identified)"
	replace Treatment_Group = 1 if (AITreat==0 & Identify==0)
	replace Treatment_Group = 2 if (AITreat==1 & Identify==0)
	replace Treatment_Group = 3 if (AITreat==0 & Identify==1)
	replace Treatment_Group = 4 if (AITreat==1 & Identify==1)

	label define Treatment_Group_lbl ///
		1 "No AI, Anonymous" ///
		2 "AI, Anonymous" ///
		3 "No AI, Identified" ///
		4 "AI, Identified", replace
	label values Treatment_Group Treatment_Group_lbl
	
	gen NoAI_x_Anon = !AITreat * !Identify // : Treatment_Group == 1
	gen AI_x_Anon = AITreat * !Identify		// : Treatment_Group == 2
	gen NoAI_x_Iden = !AITreat * Identify  // : Treatment_Group == 3
	gen AI_x_Iden = AITreat * Identify 		// : Treatment_Group == 4
	

	gen byte Instagram_use = regexm(SocialMediaPlatform, "Instagram")
	gen byte no_Instagram_use = !Instagram_use
	gen byte shared_handle = !missing(InstaHandle) & InstaHandle != ""
	gen byte not_shared_handle = missing(InstaHandle) | InstaHandle == ""

	sample_defenition
	
	variables_refinement
	
	* Winsorize
	* centile TimePost TimeInstructionsPost TimeWTP TimeWTPExplain, centile(95 98 99 99.5 100)
	winsor2 TimePost TimeInstructionsPost TimeWTP TimeWTPExplain, suffix(_W) cuts(1 99)
	
	local winsor_vars TimePost TimeInstructionsPost TimeWTP TimeWTPExplain
	foreach v of local winsor_vars {
    	local orig_label : variable label `v'
		label variable `v'_W "`orig_label' (Winsorized at 1%)"
	}

end 



translate_codebook
data_pre_process


	
	
save "$dataset_final", replace
