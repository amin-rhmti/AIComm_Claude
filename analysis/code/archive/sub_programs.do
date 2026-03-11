global stars star(+ 0.10 * 0.05 ** 0.01 *** 0.001)
global coefplot_options xline(0, lpattern(dash) lcolor(gray) lwidth(thin)) msize(small) ylabel(, labsize(vsmall)) xlabel(, labsize(vsmall)) legend(symy(14) symx(14) textw(14) forces size(vsmall))


* Creates the indices based on Anderson (2008) - page 5
* outcomes in an index are weighted by inverted covariance matrix of all variables in the index 
cap program drop load_file
program load_file

	* load data
	use input/SwissSurvey_Insta_Experiment.dta, clear

	tab Participate, m
	tab SurveyVersion, m

	count

	*** check differential attrition 

	label define TreatComp2 1 "100% student-written posts" 3 "75% AI-generated and 25% student-written posts", replace
	label values TreatComp2 TreatComp2

	tab Progress if missing(Participate)

	count if missing(Participate) & Finished

	tab Participate Finished, m

	* remove 133 people of which 39 were not eligible and rest dropped out before participating 
	keep if Participate == 1

	tab TreatIdentify Finished, m

	tab Progress if missing(TreatIdentify) 

	reg Finished TreatIdentify, r

	tab TreatComp2 Finished, m

	reg Finished i.TreatComp2, r

	codebook TreatComp2 TreatIdentify

	reg Finished i.TreatComp2 TreatIdentify, r

	* remove 221 people that dropped out after participating 
	keep if Finished == 1

	add_gpt_measures

	* did the randomization of TreatComp2 happen properly?
	tab TreatComp2, m

	* did they provide a legitimate handle?
	replace ProvideHandle = 0 if missing(InstaHandle) 

	rename TreatIdentify Identify
	destring TreatComp2, replace
	tab TreatComp2, m

	gen HumanTreat = 0
	replace HumanTreat = 1 if TreatComp2 == 1
	gen AITreat = 0
	replace AITreat = 1 if TreatComp2 == 3
	tab AITreat

	label define AITreat 0 "Human treatment" 1 "AI treatment"
	label values AITreat AITreat

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
	gen AITreatXIdenXHandle = AITreatXIden * ProvideHandle if !missing(ProvideHandle)
	gen AITreatXAnonXHandle = AITreatXAnon * ProvideHandle if !missing(ProvideHandle)

	** cleaning for writing tasks

	gen WritePost = !missing(Post)
	tab WritePost, m
	gen TextLength = strlen(Post) 
	gen BaseTextLength = strlen(ClimateLong)
	gen BaseTextLength2 = BaseTextLength^2 
	gen BaseTextLength3 = BaseTextLength^3 

	* count single-character answers 
	gen NoWrite = (TextLength==1)
	tab NoWrite

	gen Base_log1TextLength = log(1+BaseTextLength)
	gen log1TextLength = log(1+TextLength)
	gen WTPBinary = WTP>0
	label var WTPBinary "WTP>0"

	destring TimeSignaling1_PageSubmit, gen(TimeInstructionsPost)	
	destring TimeSignaling2_PageSubmit, gen(TimePost)
	destring TimingWTP1_PageSubmit, gen(TimeWTP)
	destring TimingWTPExplain1_PageSubmit, gen(TimeWTPExplain)

	tab AttnCheck
	gen AttnCheck_recode = regexm(AttnCheck, "read the instructions")
	replace AttnCheck_recode = 1 if regexm(AttnCheck, "read the instructioins")
	replace AttnCheck_recode = 1 if regexm(AttnCheck, "instruction")
	replace AttnCheck_recode = 1 if regexm(AttnCheck, "Instruction")
	replace AttnCheck_recode = 1 if regexm(AttnCheck, "intruction")
	replace AttnCheck_recode = 1 if regexm(AttnCheck, "insturction")
	replace AttnCheck_recode = 1 if regexm(AttnCheck, "instuction")
	replace AttnCheck_recode = 1 if regexm(AttnCheck, "habe die Anweisungen gelesen")
	tab AttnCheck_recode, m

	gen sample1=1
	gen sample2=AttnCheck_recode
	gen sample3=sample2 & Identify
	gen sample4=sample2 & !Identify
	
	gen byte shared_handle = !missing(InstaHandle) & InstaHandle != ""
	gen sample5 = sample2 & shared_handle
	gen sample6 = sample2 & shared_handle & Identify 
	gen sample7 = sample2 & shared_handle & !Identify
	
    gen byte not_shared_handle = missing(InstaHandle) | InstaHandle == ""
    gen sample8 = sample2 & not_shared_handle
    gen sample9 = sample8 & Identify
    gen sample10 = sample8 & !Identify
	
	gen sample11 = sample2 & AITreat
	gen sample12 = sample2 & HumanTreat
	
	tab Chose
	gen Chose1 = substr(Chose, 1, 1)
	destring Chose1, replace
	gen Chose2 = substr(Chose, 2, 1)
	destring Chose2, replace

	summ Duration, d

	gen EducUG = Education == 1
	label var EducUG "Undergraduate"
	tab EducUG

	gen DidNotVote = regexm(SwissPoliticalParty, "did not vote")
	label var DidNotVote "Did not vote in last election"

	* ClimateWorry ClimatePersonal ImageConcern DonationBinary BotKnow InitialAIEffective BaseAIDiff 

	social_media_platform_cleaning

	gen DonationBinary = Donation > 0
	label var DonationBinary "Nonzero donation to clim chg"

	gen ImageConcernBinary = ImageConcern > 2 & !missing(ImageConcern)
	tab ImageConcern ImageConcernBinary, m
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

	global OUTCOMES WTPBinary WTP GenAIEffective SignalValue PerceiveAI PerceiveEngaged log1TextLength TimePost TaskQuizCorrect

	global GPT_OUTCOME_LIST personal_anecdote emotional_appeal emotional_appeal_new scientific_argument progressive_score grammatical_mistakes moral_narratives causal_narratives sentiment collective_action

	global GPT_SCORE_OUTCOME_LIST personal_anecdote emotional_appeal scientific_argument progressive_score moral_narratives causal_narratives sentiment collective_action


	label_variables

	qui foreach x in log1TextLength TimePost {

		tab `x'
		winsor2 `x', replace cuts(5 95)
		tab `x'

	}

	foreach x in $OUTCOMES $GPT_OUTCOME_LIST {

		normalize_data, outcome(`x')
		label var `x'_N "`:var label `x'': Standardized" 

	}



	foreach x in $MODERATORS {

		gen AITreatX`x' = AITreat * `x' == 1

	}

end 





cap program drop make_index
program make_index

	syntax, outcome(string) varset(varlist) 		
	local varset_`outcome' `varset'
	
	foreach vset in `outcome' { // Loop through all outcome families  	
		* Get number of variables
		local k: word count `varset_`vset''
		display (`k')
		
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






cap program drop make_ciplot_swiss
program make_ciplot_swiss

	syntax, outcome(varlist) by_var(varlist) folder(string) subtitle(string) [residualize(string)]

	capture mkdir $output_folder/`folder'/

	global swiss_ciplot_options `"xlabel(2 "Human Iden" 5 "AI Iden" 8 "Human Anon" 11 "AI Anon", labsize(small)) xtitle("") lcolor(blue) xtitle("Treatment Group (Co-sender Composition x Image Concern)", size(small)) ytitle("") mcolor(red%70) rcapopts(lcolor(navy))"'

	foreach x of local outcome {

		if "`residualize'" == ""{

			ciplot `x', by(`by_var') subtitle("`subtitle'", size(small)) $swiss_ciplot_options
			graph export $output_folder/`folder'/ciplot_`x'`by_var'.pdf, replace	

		}

		if "`residualize'" == "yes" {

			cap drop `x'Resid
			reg `x' $CONTROLS, r nocons
			predict `x'Resid, residuals
			noi bysort `by_var': summ `x'Resid, d		
			ciplot `x'Resid, by(`by_var') subtitle("`subtitle'", size(small)) $swiss_ciplot_options 
			graph export $output_folder/`folder'/ciplot_`x'Resid`by_var'.pdf,  replace	


		}

	}

end






cap program drop normalize_data
program normalize_data
	syntax, outcome(varlist)
	foreach var in `outcome' {
		sum `var' if TreatComp2 == 1
		gen `var'_N = (`var' - r(mean)) / r(sd)
		local label: variable label `var'
		label var `var'_N "`label'"
    }
	
end



cap program drop social_media_platform_cleaning
program social_media_platform_cleaning

	local platforms "Facebook Instagram Snapchat TikTok Twitter BlueSky LinkedIn Reddit YouTube"

	foreach platform of local platforms  {

		gen `platform' = regexm(SocialMediaPlatform, "`platform'")
		tab `platform'

	}
	gen Others = Facebook | TikTok | Twitter | BlueSky | Reddit
	gen Nothing = regexm(SocialMediaPlatform, "don't use social media")


end 





cap program drop twoway_histogram
program define twoway_histogram
	syntax, outcome(string) sample_number(numlist)  width(numlist) [i(numlist)] [standardize(string)] [subtitle(string)]

	if "`standardize'" == "yes"{
		local N "_N"
	}

	preserve 

	keep if sample`sample_number' == 1

	cap drop `outcome'_Human* `outcome'_AI*

	gen `outcome'_Human`i' = `outcome'`i'`N' if TreatComp2 == 1
	gen `outcome'_AI`i' = `outcome'`i'`N' if TreatComp2 == 3

	twoway (hist `outcome'_Human`i', color(blue%20) width(`width') frac) (hist `outcome'_AI`i', color(red%20) width(`width') frac), legend(label(1 "Human treatment") label(2 "AI treatment")) subtitle(`subtitle', size(small)) ytitle("")
	graph export $output_folder/sample`sample_number'/AI_bargraphs/`outcome'`i'`N'_Dist.pdf, replace

	restore

end 

cap program drop twoway_histogram_imputed
program define twoway_histogram_imputed
	syntax, outcome(string) sample_number(numlist)  width(numlist) [i(numlist)] [standardize(string)] [subtitle(string)]

	if "`standardize'" == "yes"{
		local N "_N"
	}

	preserve 

	keep if sample`sample_number' == 1

	cap drop `outcome'_Human* `outcome'_AI*

	gen `outcome'_Human`i' = `outcome'`i'`N' if TreatComp2 == 1
	gen `outcome'_AI`i' = `outcome'`i'`N' if TreatComp2 == 3

	twoway (hist `outcome'_Human`i', color(blue%20) width(`width') frac) (hist `outcome'_AI`i', color(red%20) width(`width') frac), legend(label(1 "Human treatment") label(2 "AI treatment")) subtitle(`subtitle', size(small)) ytitle("")
	graph export $output_folder/sample`sample_number'_imputed/AI_bargraphs/`outcome'`i'`N'_Dist.pdf, replace

	restore

end 

*twoway_histogram, outcome(WTP) sample_number(2) width(0.5)




cap program drop twoway_histogram_identify
program define twoway_histogram_identify
	syntax, outcome(string) sample_number(numlist) [i(numlist)] width(numlist) [standardize(string)] [subtitle(string)]

	if "`standardize'" == "yes"{
		local N "_N"
	}

	preserve 

	keep if sample`sample_number' == 1

	cap drop `outcome'_Anon* `outcome'_Iden*

	gen `outcome'_Anon`i' = `outcome'`i'`N' if Identify == 0
	gen `outcome'_Iden`i' = `outcome'`i'`N' if Identify == 1

	twoway (hist `outcome'_Anon`i', color(blue%20) width(`width') frac) (hist `outcome'_Iden`i', color(red%20) width(`width') frac), legend(label(1 "Anonymous") label(2 "Identified")) subtitle(`subtitle', size(small)) ytitle("")
	graph export $output_folder/sample`sample_number'/Identify_bargraphs/`outcome'`i'`N'_Dist_Identify.pdf, replace

	restore

end 



cap program drop bot_histograms
program bot_histograms

    preserve // --- THIS IS THE FIX ---

	replace BotSupport_1 = BotSupport_1 - 0.25 
	replace BotSupport_3 = BotSupport_3 + 0.25

	twoway (hist BotSupport_1, color(blue%20) discrete width(0.25) frac) (hist BotSupport_2, color(green%20) discrete width(0.25) frac) (hist BotSupport_3, color(red%20) discrete width(0.25) frac), legend(label(1 "Human") label(2 "Bot") label(3 "AI") cols(3)) subtitle("Interaction preference for customer service/support", size(medium)) xlabel(1 "Strongly Prefer Not" 5 "Strongly Prefer", labsize(small)) ytitle("")
	graph export $output_folder/BotSupport_Dist.pdf, replace

	replace BotSocialMedia_1 = BotSocialMedia_1 - 0.25 
	replace BotSocialMedia_3 = BotSocialMedia_3 + 0.25


	twoway (hist BotSocialMedia_1, color(blue%20) discrete width(0.25) frac) (hist BotSocialMedia_2, color(green%20) discrete width(0.25) frac) (hist BotSocialMedia_3, color(red%20) discrete width(0.25) frac), legend(label(1 "Human") label(2 "Bot") label(3 "AI") cols(3)) subtitle("Interaction preference on Social Media", size(medium)) xlabel(1 "Strongly Prefer Not" 5 "Strongly Prefer", labsize(small)) ytitle("")
	graph export $output_folder/BotSocialMedia_Dist.pdf, replace

    restore // --- THIS IS THE FIX ---

end 




cap program drop add_notes
program define add_notes, rclass

	syntax, outcome(varlist)

	* WTPBinary WTP GenAIEffective SignalValue PerceiveAI PerceiveEngaged log1TextLength TimePost TaskQuizCorrect

	local ynote `"`outcome' stands for `:var label `outcome''"'

    if "`outcome'" == "WTPBinary" {
        local ynote "WTPBinary is 1 if their WTP is greater than 0"
    }

    if "`outcome'" == "log1TextLength" {
        local ynote "log1TextLength is log(1+Textlength) and is winsorized at 5/95 percentile"
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


cap program drop add_controlnotes
program define add_controlnotes, rclass

    local i = 3
    foreach x in $CONTROLS {
    	local xnote`i' "`x' stands for `:var label `x''"
    	local ++i
    }

    local max_i `i'

    forvalues i = 3/`max_i' {
    	
    	return local xnote`i' "`xnote`i''"
    }

end


/**************************************************************************
  START: NEW PROGRAM FOR ATTRITION CIPLOTS
**************************************************************************/

cap program drop swiss_ciplot_attrition
program define swiss_ciplot_attrition
    version 17.0
    // Keep original option names and behavior; add OUTCOME() + optional y-axis controls
    syntax, if_condition(string) xtitle(string) filename_suffix(string) graph_name_suffix(string) ///
           OUTCOME(varname) [ YTITLE(string) YLOW(real 70) YHIGH(real 100) ]

    // Display the frequency table for the current sample
    display ""
    display "`xtitle'"
    display "--------------------------------------------------"
    tabulate Group4_attrition `if_condition'
    
    preserve
    
    // Keep only the relevant subsample for this plot
    keep `if_condition'
    
    // Calculate Mean + 95% t CI and cap the upper bound (binary outcome)
    collapse (count) n=`outcome' (mean) mean=`outcome' (sd) sd=`outcome', by(Group4_attrition)
    gen se        = sd/sqrt(n)
    gen tcrit     = invttail(n-1, 0.025)
    gen ci_lo     = mean - tcrit*se
    gen ci_hi     = mean + tcrit*se
    gen mean_pct  = 100*mean
    gen ci_lo_pct = 100*ci_lo
    gen ci_hi_pct = 100*ci_hi
    replace ci_hi_pct = 100 if ci_hi_pct > 100

    // Generate the plot (identical look/feel to original)
    // Default y-title = original "Completion rate (%)" unless overridden
    local ytitle_final = cond("`ytitle'"=="","Completion rate (%)","`ytitle'")
    twoway ///
        (rcap    ci_hi_pct ci_lo_pct Group4_attrition, lcolor(navy) lwidth(medthin)) ///
        (scatter mean_pct   Group4_attrition,   msymbol(Dh) msize(small) ///
                                     mcolor(none) mlcolor(red%70)), ///
        xlabel(1 "No AI, Not identified" 2 "AI, Not identified" ///
               3 "No AI, Identified"    4 "AI, Identified", labsize(medsmall)) ///
        xtitle("`xtitle'", size(small)) ///
        ytitle("`ytitle_final'", size(medsmall)) ///
        xscale(range(0.5 4.5)) ///
        yscale(range(`ylow' `yhigh')) ///
        ylabel(`ylow'(5)`yhigh', labsize(medsmall)) ///
        legend(order(2 1) label(1 "95% Confidence Interval") label(2 "Mean") ///
               cols(1) ring(0) pos(1) size(vsmall)) ///
        plotregion(margin(zero)) ///
        name(AttritionCI`graph_name_suffix', replace)

    // Display and export the graph
    capture mkdir "$output_folder/attrition_plots"
    graph display AttritionCI`graph_name_suffix', xsize(10) ysize(7)
    graph export "$output_folder/attrition_plots/ciplot_attrition`filename_suffix'.pdf", replace
    
    // Close the graph window after saving
    graph drop AttritionCI`graph_name_suffix'
    
    restore
end


/**************************************************************************
  END: NEW PROGRAM FOR ATTRITION CIPLOTS
**************************************************************************/