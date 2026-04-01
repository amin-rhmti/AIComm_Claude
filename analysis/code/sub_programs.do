********************************
****  Variables Structure	****
********************************
cap program drop global_variables_defining
program global_variables_defining

	********************************
	**** 		Controls 		****
	********************************
	
	global DEMOG Age i.Grad_degree i.Vote i.ETH i.Female i.Switzerland
	global PRE_TREAT_CTRL i.Instagram_use i.ImageConcern i.not_shared_handle Donation index_Climate i.BotKnow i.InitialAIEffective i.BaseAIDiff i.ReadingReact1 i.ReadingReact2 i.GuessWriterHuman i.GuessWriterAI i.PostReact i.BotSupport_AI i.BotSocialMedia_AI
	
	global BASE_TEXT_CONTROLS Base_meaningfulness index_Base_effort index_Base_nlp Base_AIness
	
	global CONTROLS $DEMOG $PRE_TREAT_CTRL
	
	
	global CONTROLS_TABEL i.AgeBinary_adult i.Grad_degree i.Vote i.ETH i.Female i.Switzerland ///
	i.Instagram_use i.ImageConcernBinary_p50 i.not_shared_handle i.index_ClimateBinary ///
	i.DonationBinary_pos i.BotKnowBinary i.AIEffectiveBinary i.AIDiffBinary i.ReadingReact1Binary i.ReadingReact2Binary i.GuessHuman_asHuman i.GuessAI_asHuman i.PostReactBinary i.BotSupport_AIBinary i.BotSocialMedia_AIBinary
	
	* Lasso Helpers
	global CONTROLS_CONT_NOFACTOR Age Donation index_Climate
	
	global CONTROLS_CAT_NOFACTOR Grad_degree Vote ETH Female Switzerland Instagram_use ImageConcern not_shared_handle BotKnow InitialAIEffective BaseAIDiff ReadingReact1 ReadingReact2 GuessWriterHuman GuessWriterAI PostReact BotSupport_AI BotSocialMedia_AI
	
	
	********************************
	**** 		Outcomes 		****
	********************************
	
    global OUTCOMES Post_meaningfulness Post_TextLength_log ///
	Post_AIness index_Post_effort index_Post_nlp  ///
	TimePost_W WTP TimeWTP_W TimeWTPExplain_W ///
	GenAIEffective PerceiveAI SignalValue PerceiveEngaged
	
	global SELECTED_OUTCOMES Post_meaningfulness index_Post_effort index_Post_nlp
		
	global EXTRA_OUTCOMES TaskQuizCorrect WTPBinary_pos WTPBinary_p50 TimeInstructionsPost_W

	* We treat ordinal variables (like your 0/1/2 scores) as continuous in Lasso regression
		
	global OUTCOMES_CONT TimePost_W index_Post_effort index_Post_nlp WTP TimeWTP_W TimeWTPExplain_W TimeInstructionsPost_W GenAIEffective PerceiveAI SignalValue PerceiveEngaged
	global OUTCOMES_BIN Finished Post_meaningfulness Post_AIness TaskQuizCorrect WTPBinary_pos WTPBinary_p50 
	
	********************************
	**** 	HTE MODERATORS		****
	********************************
	
    global HTE_MODERATORS index_Climate index_ClimateBinary ClimateWorry ClimatePersonal ///
	Donation DonationBinary_p50 DonationBinary_pos ///
	BaseAIDiff AIDiffBinary ///
	ImageConcern ImageConcernBinary_p50 ImageConcernBinary2 ImageConcernBinary3 ImageConcernBinary4 ///
	not_shared_handle ///
	Instagram_use ///
	Age AgeBinary_p50 AgeBinary_adult Grad_degree Vote Switzerland Female ETH ///
	index_Image_minus_privacy index_Image_minus_privacyBinary ///
	BotKnow BotKnowBinary InitialAIEffective AIEffectiveBinary ///
	BotSupport_AI BotSupport_AIBinary BotSocialMedia_AI BotSocialMedia_AIBinary ///
	ReadingReact1Binary ReadingReact2Binary GuessHuman_asHuman GuessAI_asHuman PostReactBinary ///
	ReadingReact1 ReadingReact2 GuessWriterHuman GuessWriterAI PostReact
	
	* Ordinal variables
	global HTE_MODERATORS_TABLE index_Climate ///
	Donation ///
	BaseAIDiff ///
	ImageConcern ///
	not_shared_handle ///
	Instagram_use ///
	Age Grad_degree Vote Switzerland Female ETH ///
	index_Image_minus_privacy ///
	BotKnow InitialAIEffective ///
	BotSupport_AI BotSocialMedia_AI ///
	ReadingReact1Binary ReadingReact2Binary GuessHuman_asHuman GuessAI_asHuman PostReactBinary
	
	
	* PAP ordered, last row is extra
	
	global HTE_MODERATORS_CIPLOT index_ClimateBinary DonationBinary_pos AIDiffBinary ///
	ImageConcernBinary_p50 not_shared_handle BotKnowBinary ///
	AgeBinary_adult Grad_degree Vote Switzerland Female ETH ///
	index_Base_effortBinary_p50 index_Base_nlpBinary_p50 ///
	Instagram_use index_Image_minus_privacyBinary
	
end

global_variables_defining
	

cap program drop nice_name_as_label
program define nice_name_as_label

    * This program assigns nice labels to variables for use in graph axis titles.

    * ** Post-Treatment **
    capture label variable Finished                   	"Survey Completion"
    capture label variable Post_meaningfulness        	"Wrote Meaningful Post"
    capture label variable Post_TextLength_log        	"Ln (1+ Post-Task Character Count)"
    capture label variable Post_AIness                	"Post-Task Not Fully Human Written"
	capture label variable index_Post_effort          	"Post-Task Effort Index"
	capture label variable index_Post_nlp             	"Post-Task NLP Quality Index"
    capture label variable TimePost_W                 	"Time on Post-Task (s)"
    capture label variable WTP                        	"WTP to Remove Post (CHF)"
    capture label variable TimeWTP_W                  	"Time Spent on WTP (s)"
    capture label variable TimeWTPExplain_W           	"Time Spent on WTP Instruction (s)"
    capture label variable GenAIEffective             	"AI Effectiveness to Attract Likes (1-3)"
    capture label variable PerceiveAI                 	"Post-Task Likelihood to Perceived as AI (1-5)"
    capture label variable SignalValue                	"Post-Task Perceived Positively Importance (1-5)"
    capture label variable PerceiveEngaged            	"Post-Task Perceived Engagement with Climate (1-5)"
		
	capture label variable index_Post_overall         	"Post-Task Overall Quality Index"
		
    * ** Pre-Treatment **	
    capture label variable Age                        		"Age"
    capture label variable AgeBinary_p50              		"Age Above Median (24+)"
    capture label variable AgeBinary_adult            		"Age 25 Or Older"
    capture label variable Female                     		"Gender (Female)"
    capture label variable Switzerland                		"Swiss"
    capture label variable Grad_degree                		"Graduate Student"
    capture label variable Vote                       		"Voted in Last Election"
    capture label variable ETH                        		"ETH"
    capture label variable Donation                   		"Donation (CHF)"
    capture label variable DonationBinary_pos         		"Donated"
    capture label variable DonationBinary_p50         		"Donation Above Median"
    capture label variable Instagram_use              		"Instagram User"
    capture label variable ImageConcern               		"Image Concern (1-5)"
    capture label variable ImageConcernBinary2        		"Image Concern Above 2 from 5"
    capture label variable ImageConcernBinary3        		"Image Concern Above 3 from 5"
    capture label variable ImageConcernBinary4        		"Image Concern Above 4 from 5"
    capture label variable ImageConcernBinary_p50     		"Image Concern Above Median"
    capture label variable not_shared_handle          		"Exposure Sensitivity"
    capture label variable index_Climate              		"Climate Concern Index"
    capture label variable index_ClimateBinary        		"Climate Concern Index Above Median"
    capture label variable BotKnow                    		"AI Familiarity (1-5)"
    capture label variable BotKnowBinary              		"Frequent AI User"
    capture label variable InitialAIEffective         		"AI Persuasion (1-5)"
    capture label variable AIEffectiveBinary          		"High AI Persuasion"
    capture label variable BaseAIDiff                 		"Base-Task Perceived Difference from AI (1-5)"
    capture label variable AIDiffBinary               		"Base-Task Perceived Distinct from AI"
    capture label variable PostReactBinary            		"React to Example Post"
    capture label variable ReadingReact1Binary        		"React to Post 1 in Reading Task"
    capture label variable ReadingReact2Binary        		"React to Post 2 in Reading Task"
	capture label variable GuessWriter1         	  		"Guess for Writer Identity"
    capture label variable Guess1_asHuman         	  		"Guess Human Writer for Post 1"
	capture label variable GuessWriter2         	  		"Guess for Writer Identity"
    capture label variable Guess2_asHuman             		"Guess Human Writer for Post 2"
    capture label variable BotSupport_AI              		"Customer Support Bot (1-5)"
    capture label variable BotSupport_AIBinary        		"Prefer Customer Support Bot"
    capture label variable BotSocialMedia_AI          		"Social Media Bot (1-5)"
    capture label variable BotSocialMedia_AIBinary    		"Prefer AI On Social Media"

    * ** Index **
    capture label variable index_Image_minus_privacy    	"(Image Concern - Exposure Sensitivity) Index"
	capture label variable index_Image_minus_privacyBinary  "(Image Concern - Exposure Sensitivity) Index Above Median"
	capture label variable index_Base_effort           		"Base-Task Effort Index"
	capture label variable index_Base_nlp              		"Base-Task NLP Quality Index"
	
	capture label variable index_ai_trust              		"AI Familiarity and Trust (Anderson Index)"
	capture label variable index_ai_trustBinary_p50    		"AI Familiarity and Trust Index — Above Median"
	capture label variable index_bot_support           		"Support for AI Bots (Anderson Index)"
	capture label variable index_bot_supportBinary_p50 		"Support for AI Bots Index — Above Median"
	capture label variable index_react                 		"Reaction (Anderson Index)"
	capture label variable index_reactBinary_p50       		"Reaction Index — Above Median"
	capture label variable index_guess_human           		"Perceived Human Authorship (Anderson Index)"
	capture label variable index_guess_humanBinary_p50 		"Perceived Human Authorship Index — Above Median"

	
    * ** Remaining **
	capture label variable Base_TextLength_log        "Ln(1+ Base-Task Character Count)"
	capture label variable Base_AIness                "Base-Task Not Fully Human Written"
	capture label variable Base_meaningfulness        "Wrote Meaningful Base-Task"
	capture label variable TimeInstructionsPost_W     "Time on Post Instructions (s)"
	
    capture label variable Post_TextLength            "Post-Task Character Count"
    capture label variable Base_TextLength            "Base-Task Character Count"
    capture label variable Post_AvgSentLen            "Post-Task Average Sentence Length"
    capture label variable Base_AvgSentLen            "Base-Task Average Sentence Length"
    capture label variable Post_typos_count           "Post-Task Typo Count"
    capture label variable Base_typos_count           "Base-Task Typo Count"
    capture label variable Post_personal_anecdote     "Post Personal Anecdote"
	capture label variable Base_personal_anecdote     "Base Personal Anecdote"
    capture label variable Post_emotional_appeal	  "Post Emotional Appeal"
	capture label variable Base_emotional_appeal      "Base Emotional Appeal"
    capture label variable Post_scientific_argument   "Post Scientific Argument"
	capture label variable Base_scientific_argument   "Base Scientific Argument"
    capture label variable Post_moral_narratives      "Post Moral Narratives"
	capture label variable Base_moral_narratives      "Base Moral Narratives"
    capture label variable Post_causal_narratives     "Post Causal Narratives"    
    capture label variable Base_causal_narratives     "Base Causal Narratives"
    capture label variable TaskQuizCorrect            "Treatment Composition Correct"
    capture label variable TimePost                   "Time on Post, Raw(s)"
    capture label variable TimeInstructionsPost       "Time on Post Instructions, Raw (s)"
    capture label variable TimeWTP                    "Time on WTP, Raw (s)"
    capture label variable TimeWTPExplain             "Time on WTP Instruction, Raw (s)"
    capture label variable WTPBinary_pos              "Positive WTP"
    capture label variable WTPBinary_p50              "WTP Above Median"
	capture label variable ClimatePersonal            "Personal Climate Responsibility"
	capture label variable ClimateWorry               "Worried about Climate"
	capture label variable AITreat               	  "AI Treatment"
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


********************************
**** 	Data Analysis 		****
********************************

* --- descriptive_histograms ---

cap program drop ciplot_corr_binary_by_category
program define ciplot_corr_binary_by_category
    version 16.0
    syntax [if] [in], ///
        sample(integer) ///
        outcome(varname numeric) ///
		ytitle_arg(string) ///
        xvar(varname numeric) ///
		xtitle_arg(string) ///
        xlow(real) ///
        xhigh(real) ///
        xvallabel(name) ///
        [sample_label(string asis) ylow(real 0) yhigh(real 1) ystep(real 0.1)]

    preserve
        * Apply caller restriction
        keep `if' `in'

        * Clean sample label (prevents stray quotes in subtitle)
        //local slabel_clean `"`sample_label'"'
        //local slabel_clean : subinstr local slabel_clean `"""' "", all

        * Collapse to group mean (Pr(outcome==1)) and count
        collapse (mean) mean=`outcome' (count) n=`outcome', by(`xvar')
        drop if missing(`xvar')
        drop if !inrange(`xvar', `xlow', `xhigh')
        drop if missing(n) | n==0
        sort `xvar'

        * Re-attach value labels for xvar (tick labels)
        label values `xvar' `xvallabel'

        * Standard error + 95% CI for Bernoulli mean
        gen se    = sqrt(mean * (1 - mean) / n)
        gen ci_lo = mean - 1.96 * se
        gen ci_hi = mean + 1.96 * se

        * Cap CI to [0,1]
        replace ci_lo = 0 if ci_lo < 0
        replace ci_hi = 1 if ci_hi > 1

        * Compute xscale range
        local xmin = `xlow'  - 0.2
        local xmax = `xhigh' + 0.3

        * Ensure output folder exists
        capture mkdir "$output_folder/sample`sample'"

        * Plotting: Add the following after xtitle for title (and slabel below it )
		 //title("Conditional mean of `outcome' by `xvar'", size(medsmall))   subtitle("(`slabel_clean')", size(small)) ///
        twoway ///
            (rcap ci_hi ci_lo `xvar', lcolor(navy) lwidth(medthin)) ///
            (scatter mean `xvar', msymbol(Dh) msize(medlarge) mcolor(none) mlcolor(maroon)), ///
            ytitle("`ytitle_arg'", size(medsmall)) ///
            xtitle("`xtitle_arg'", size(medsmall)) ///
            graphregion(color(white) margin(medium)) ///
            plotregion(margin(l=medium r=large t=medium b=0)) ///
            xlabel(, valuelabel angle(0) labsize(small)) ///
            xscale(range(`xmin' `xmax')) ///
            yscale(range(`ylow' `yhigh')) ///
            ylabel(`ylow'(`ystep')`yhigh', grid angle(0)) ///
            legend(order(2 "Mean" 1 "95% Confidence Interval") pos(6) rows(1) size(small)) ///
            name(CI_Plot_s`sample', replace)

        graph export ///
            "$output_folder/sample`sample'/ci_conditional_mean_`outcome'_by_`xvar'.pdf", replace
    restore
end

cap program drop twoway_histogram_AI
program define twoway_histogram_AI
    version 16.0
    syntax, outcome(string) sample_number(numlist) width(numlist) [i(numlist)] [standardize(string)] [subtitle(string asis)] [plow(numlist max=1)] [phigh(numlist max=1)]

	* In both twoway_histogram_AI and twoway_histogram_Identify, the subtitle comes from the subtitle() option in every twoway command. There are 4 twoway commands in each program (discrete with/without desc, continuous with/without desc). Add this to get it bask: subtitle(`subtitle', size(small))
	
    if "`plow'"  == "" local plow  1
    if "`phigh'" == "" local phigh 99
	* We actually do not clip the x-axis to p1-p99, but everything is already set for this code to do so if you want by modifying the two last 'twoway':
	* 1) Change the two last 'twoway' to: "twoway (hist `var' if AITreat==0 & inrange(`var', `lo', `hi'), width(`width') frac ...)"
	* 2) Add this to the two last 'note': "X-axis clipped to p`plow'–p`phigh'."
	
    local N ""
    if "`standardize'" == "yes" local N "_N"

    local ii ""
    if "`i'" != "" local ii "`i'"
    local var "`outcome'`ii'`N'"

    preserve
        quietly keep if sample`sample_number' == 1
        quietly keep if inlist(AITreat,0,1)

        capture confirm variable `var'
        if _rc {
            di as error "Variable not found: `var'"
            restore
            exit 111
        }
        quietly keep if !missing(`var')
		
		* Nice Names
		nice_name_as_label
		local nice_label : variable label `var'
		if `"`nice_label'"' == "" local nice_label "`var'"
		
        * --- LOGIC TO CHOOSE DESCRIPTION OR PROMPT ---
        local base = "`var'"
        local base : subinstr local base "_N" "", all
        
        * 1. Try to find a 'description' char (For OUTCOMES)
        local desc : char `var'[description]
        local label_prefix "Description: "

        * 2. If no description, look for 'prompt' (For GPT_OUTCOMES)
        if "`desc'" == "" {
            local desc : char `var'[prompt]
            local label_prefix "Prompt: "
        }
        
        * 3. Repeat checks for base variable if specialized one is empty
        if "`desc'" == "" {
            local desc : char `base'[description] 
            local label_prefix "Description: "
        }
        if "`desc'" == "" {
            local desc : char `base'[prompt]
            local label_prefix "Prompt: "
        }

        * --- SMART WORD WRAP LOGIC (3 LINES) ---
        local line1 ""
        local line2 ""
        local line3 ""
        
        if `"`desc'"' != "" {
            local full_text = "`label_prefix'" + `"`desc'"'
            local max_len = 90
            
            * --- Line 1 Calculation ---
            if strlen(`"`full_text'"') <= `max_len' {
                local line1 `"`full_text'"'
            }
            else {
                local chunk = substr(`"`full_text'"', 1, `max_len')
                local split_pos = strrpos(`"`chunk'"', " ")
                if `split_pos' == 0 local split_pos = `max_len'
                
                local line1 = substr(`"`full_text'"', 1, `split_pos')
                local remainder = substr(`"`full_text'"', `split_pos' + 1, .)
                
                * --- Line 2 Calculation ---
                if strlen(`"`remainder'"') <= `max_len' {
                    local line2 `"`remainder'"'
                }
                else {
                    local chunk = substr(`"`remainder'"', 1, `max_len')
                    local split_pos = strrpos(`"`chunk'"', " ")
                    if `split_pos' == 0 local split_pos = `max_len'
                    
                    local line2 = substr(`"`remainder'"', 1, `split_pos')
                    local line3 = substr(`"`remainder'"', `split_pos' + 1, .)
                }
            }
        }
        * ----------------------------------------------

        local legopts `"legend(label(1 "No AI") label(2 "AI") ring(1) pos(11) cols(1) size(vsmall) region(lcolor(none)))"'
        local regopts "graphregion(color(white) margin(r+8)) plotregion(margin(small))"
        local yopts   `"ytitle("Fraction") ylabel(, grid angle(0))"'

        quietly summarize `var', meanonly
        local vmin = r(min)
        local vmax = r(max)

        local discrete = 0
        if (`vmin' >= 0 & `vmax' <= 10) {
            if (floor(`vmin')==`vmin' & floor(`vmax')==`vmax') local discrete = 1
        }

        cap mkdir "$output_folder/sample`sample_number'"
        cap mkdir "$output_folder/sample`sample_number'/AI_bargraphs"

        * Note: Added line3 to the note() option
        
        if (`discrete'==1) {
            local kmax = floor(`vmax')
            local xmin = -0.5
            local xmax = `kmax' + 0.5

            if `"`desc'"' != "" {
                twoway (hist `var' if AITreat==0, discrete start(-0.5) width(1) frac fcolor(navy%25) lcolor(navy%60)) (hist `var' if AITreat==1, discrete start(-0.5) width(1) frac fcolor(maroon%25) lcolor(maroon%60)), `legopts' `regopts' `yopts' xscale(range(`xmin' `xmax')) xlabel(0(1)`kmax', grid angle(0)) xtitle(`"`nice_label'"') note("`line1'" "`line2'" "`line3'", size(vsmall) span)
            }
            else {
                twoway (hist `var' if AITreat==0, discrete start(-0.5) width(1) frac fcolor(navy%25) lcolor(navy%60)) (hist `var' if AITreat==1, discrete start(-0.5) width(1) frac fcolor(maroon%25) lcolor(maroon%60)), `legopts' `regopts' `yopts' xscale(range(`xmin' `xmax')) xlabel(0(1)`kmax', grid angle(0)) xtitle(`"`nice_label'"')
            }
        }
        else {
            quietly _pctile `var', p(`plow' `phigh')
            local lo = r(r1)
            local hi = r(r2)
            if (`hi' <= `lo') local hi = `lo' + 1

            if `"`desc'"' != "" {
                twoway (hist `var' if AITreat==0, width(`width') frac fcolor(navy%25) lcolor(navy%60)) (hist `var' if AITreat==1, width(`width') frac fcolor(maroon%25) lcolor(maroon%60)), `legopts' `regopts' `yopts' xscale(range(`lo' `hi')) xlabel(, grid angle(0)) xtitle(`"`nice_label'"') note("`line1'" "`line2'" "`line3'", size(vsmall) span)
            }
            else {
                twoway (hist `var' if AITreat==0, width(`width') frac fcolor(navy%25) lcolor(navy%60)) (hist `var' if AITreat==1, width(`width') frac fcolor(maroon%25) lcolor(maroon%60)), `legopts' `regopts' `yopts' xscale(range(`lo' `hi')) xlabel(, grid angle(0)) xtitle(`"`nice_label'"') note(" ", size(vsmall) span)
            }
        }

        graph export "$output_folder/sample`sample_number'/AI_bargraphs/`var'_AITreat_Dist.pdf", replace
    restore
end

cap program drop twoway_histogram_Identify
program define twoway_histogram_Identify
    version 16.0
    syntax, outcome(string) sample_number(numlist) width(numlist) [i(numlist)] [standardize(string)] [subtitle(string asis)] [plow(numlist max=1)] [phigh(numlist max=1)] [idvar(name)]

    if "`plow'"  == "" local plow  1
    if "`phigh'" == "" local phigh 99
    if "`idvar'" == "" local idvar "Identify"
	* We actually do not clip the x-axis to p1-p99. Read the twoway_histogram_AI for more information.
	
    local N ""
    if "`standardize'" == "yes" local N "_N"

    local ii ""
    if "`i'" != "" local ii "`i'"
    local var "`outcome'`ii'`N'"

    preserve
        quietly keep if sample`sample_number' == 1
        quietly keep if inlist(`idvar',0,1)

        capture confirm variable `var'
        if _rc {
            di as error "Variable not found: `var'"
            restore
            exit 111
        }
        quietly keep if !missing(`var')

		* Nice Names
		nice_name_as_label
		local nice_label : variable label `var'
		if `"`nice_label'"' == "" local nice_label "`var'"
		
        * --- LOGIC TO CHOOSE DESCRIPTION OR PROMPT ---
        local base = "`var'"
        local base : subinstr local base "_N" "", all
        
        * 1. Try to find a 'description' char (For OUTCOMES)
        local desc : char `var'[description]
        local label_prefix "Description: "
        
        * 2. If no description, look for 'prompt' (For GPT_OUTCOMES)
        if "`desc'" == "" {
            local desc : char `var'[prompt]
            local label_prefix "Prompt: "
        }
        
        * 3. Repeat checks for base variable if specialized one is empty
        if "`desc'" == "" {
            local desc : char `base'[description] 
            local label_prefix "Description: "
        }
        if "`desc'" == "" {
            local desc : char `base'[prompt]
            local label_prefix "Prompt: "
        }

        * --- SMART WORD WRAP LOGIC (3 LINES) ---
        local line1 ""
        local line2 ""
        local line3 ""
        
        if `"`desc'"' != "" {
            local full_text = "`label_prefix'" + `"`desc'"'
            local max_len = 90
            
            * --- Line 1 ---
            if strlen(`"`full_text'"') <= `max_len' {
                local line1 `"`full_text'"'
            }
            else {
                local chunk = substr(`"`full_text'"', 1, `max_len')
                local split_pos = strrpos(`"`chunk'"', " ")
                if `split_pos' == 0 local split_pos = `max_len'
                
                local line1 = substr(`"`full_text'"', 1, `split_pos')
                local remainder = substr(`"`full_text'"', `split_pos' + 1, .)
                
                * --- Line 2 ---
                if strlen(`"`remainder'"') <= `max_len' {
                    local line2 `"`remainder'"'
                }
                else {
                    local chunk = substr(`"`remainder'"', 1, `max_len')
                    local split_pos = strrpos(`"`chunk'"', " ")
                    if `split_pos' == 0 local split_pos = `max_len'
                    
                    local line2 = substr(`"`remainder'"', 1, `split_pos')
                    local line3 = substr(`"`remainder'"', `split_pos' + 1, .)
                }
            }
        }
        * ----------------------------------------------

        local legopts `"legend(label(1 "Anonymous") label(2 "Identified") ring(1) pos(11) cols(1) size(vsmall) region(lcolor(none)))"'
        local regopts "graphregion(color(white) margin(r+8)) plotregion(margin(small))"
        local yopts   `"ytitle("Fraction") ylabel(, grid angle(0))"'

        quietly summarize `var', meanonly
        local vmin = r(min)
        local vmax = r(max)

        local discrete = 0
        if (`vmin' >= 0 & `vmax' <= 10) {
            if (floor(`vmin')==`vmin' & floor(`vmax')==`vmax') local discrete = 1
        }

        cap mkdir "$output_folder/sample`sample_number'"
        cap mkdir "$output_folder/sample`sample_number'/Identify_bargraphs"

        if (`discrete'==1) {
            local kmax = floor(`vmax')
            local xmin = -0.5
            local xmax = `kmax' + 0.5

            if `"`desc'"' != "" {
                twoway (hist `var' if `idvar'==0, discrete start(-0.5) width(1) frac fcolor(navy%25) lcolor(navy%60)) (hist `var' if `idvar'==1, discrete start(-0.5) width(1) frac fcolor(maroon%25) lcolor(maroon%60)), `legopts' `regopts' `yopts' xscale(range(`xmin' `xmax')) xlabel(0(1)`kmax', grid angle(0)) xtitle(`"`nice_label'"') note("`line1'" "`line2'" "`line3'", size(vsmall) span)
            }
            else {
                twoway (hist `var' if `idvar'==0, discrete start(-0.5) width(1) frac fcolor(navy%25) lcolor(navy%60)) (hist `var' if `idvar'==1, discrete start(-0.5) width(1) frac fcolor(maroon%25) lcolor(maroon%60)), `legopts' `regopts' `yopts' xscale(range(`xmin' `xmax')) xlabel(0(1)`kmax', grid angle(0)) xtitle(`"`nice_label'"')
            }
        }
        else {
            quietly _pctile `var', p(`plow' `phigh')
            local lo = r(r1)
            local hi = r(r2)
            if (`hi' <= `lo') local hi = `lo' + 1

            if `"`desc'"' != "" {
                twoway (hist `var' if `idvar'==0, width(`width') frac fcolor(navy%25) lcolor(navy%60)) (hist `var' if `idvar'==1, width(`width') frac fcolor(maroon%25) lcolor(maroon%60)), `legopts' `regopts' `yopts' xscale(range(`lo' `hi')) xlabel(, grid angle(0)) xtitle(`"`nice_label'"') note("`line1'" "`line2'" "`line3'", size(vsmall) span)
            }
            else {
                twoway (hist `var' if `idvar'==0, width(`width') frac fcolor(navy%25) lcolor(navy%60)) (hist `var' if `idvar'==1, width(`width') frac fcolor(maroon%25) lcolor(maroon%60)), `legopts' `regopts' `yopts' xscale(range(`lo' `hi')) xlabel(, grid angle(0)) xtitle(`"`nice_label'"') note(" ", size(vsmall) span)
            }
        }

        graph export "$output_folder/sample`sample_number'/Identify_bargraphs/`var'_IdenTreat_Dist.pdf", replace
    restore
end

cap program drop single_hist
program define single_hist
    version 16.0
    syntax, var(name) sample_number(numlist) [width(numlist max=1)] [xlabel(string asis)] [plow(numlist max=1)] [phigh(numlist max=1)]

    if "`width'" == "" local width 1
    if "`plow'"  == "" local plow  1
    if "`phigh'" == "" local phigh 99

    preserve
        nice_name_as_label

        quietly keep if sample`sample_number' == 1
        quietly keep if !missing(`var')
        
        if _N == 0 {
            di as text "Note: No data for `var' in sample `sample_number'. Skipping."
            restore
            exit
        }

        * Formatting options
        local regopts "graphregion(color(white) margin(r+6)) plotregion(margin(small))"
        local yopts   `"ytitle("Fraction") ylabel(, grid angle(0))"'

        quietly summarize `var', meanonly
        local vmin = r(min)
        local vmax = r(max)

        local is_binary = 0
        local is_small_discrete = 0
        if (`vmin'==0 & `vmax'==1) local is_binary = 1
        if (`vmin' >= 0 & `vmax' <= 10 & floor(`vmin')==`vmin' & floor(`vmax')==`vmax') local is_small_discrete = 1

        * Clean user input: remove any leading comma user might have typed
        local clean_xlab = trim(`"`xlabel'"')
        if substr("`clean_xlab'",1,1) == "," local clean_xlab = trim(substr("`clean_xlab'", 2, .))

        * --- CONSTRUCTION OF X-AXIS LABELS ---
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
            * Continuous variables: Use user's string exactly as provided
            if "`clean_xlab'" != "" local xlabopt "xlabel(`clean_xlab')"
        }

        cap mkdir "$output_folder/sample`sample_number'"
        cap mkdir "$output_folder/sample`sample_number'/single_var_hist"

        if (`is_binary'==1) {
             histogram `var', fraction discrete start(-0.5) width(1) fcolor(navy%25) lcolor(navy%70) ///
                `regopts' `yopts' xscale(range(-0.5 1.5)) `xlabopt' 
        }
        else if (`is_small_discrete'==1) {
            histogram `var', fraction discrete start(`= `vmin' - 0.5') width(1) fcolor(navy%25) lcolor(navy%70) ///
                `regopts' `yopts' xscale(range(`= `vmin' - 0.5' `= `vmax' + 0.5')) `xlabopt'
				
        }
        else {
            quietly _pctile `var', p(`plow' `phigh')
            local lo = r(r1)
            local hi = r(r2)
            if (`hi' <= `lo') local hi = `lo' + 1
            histogram `var', fraction width(`width') fcolor(navy%25) lcolor(navy%70) ///
                `regopts' `yopts' xscale(range(`lo' `hi')) `xlabopt' 
        }

        graph export "$output_folder/sample`sample_number'/single_var_hist/`var'_Dist.pdf", replace
    restore
end

cap program drop bot_histograms
program bot_histograms
    * Define syntax to accept the sample number
    syntax, sample(numlist max=1)

    preserve
        nice_name_as_label

        * Shift values so bars sit side-by-side
        * Assumes original values are integers (1, 2, 3, 4, 5)
        replace BotSupport_1 = BotSupport_1 - 0.25 
        replace BotSupport_AI = BotSupport_AI + 0.25

        * Ensure the output directory exists to avoid r(691)
        cap mkdir "$output_folder/sample`sample'"

        * Histogram 1: Bot Support
        twoway (hist BotSupport_1, color(blue%30)  width(0.25) frac) ///
               (hist BotSupport_2, color(green%30) width(0.25) frac) ///
               (hist BotSupport_AI, color(red%30)   width(0.25) frac) ///
               , legend(label(1 "Human") label(2 "Bot") label(3 "AI") cols(3) region(lcolor(white))) ///
               xlabel(1 "Strongly Prefer Not" 5 "Strongly Prefer", labsize(small)) ///
               ytitle("Fraction") xtitle("") graphregion(color(white))

        graph export "$output_folder/sample`sample'/BotSupport_Dist.pdf", replace

        * Shift values for the second set
        replace BotSocialMedia_1 = BotSocialMedia_1 - 0.25 
        replace BotSocialMedia_AI = BotSocialMedia_AI + 0.25

        * Histogram 2: Social Media
        twoway (hist BotSocialMedia_1, color(blue%30)  width(0.25) frac) ///
               (hist BotSocialMedia_2, color(green%30) width(0.25) frac) ///
               (hist BotSocialMedia_AI, color(red%30)   width(0.25) frac) ///
               , legend(label(1 "Human") label(2 "Bot") label(3 "AI") cols(3) region(lcolor(white))) ///
               xlabel(1 "Strongly Prefer Not" 5 "Strongly Prefer", labsize(small)) ///
               ytitle("Fraction") xtitle("") graphregion(color(white))

        graph export "$output_folder/sample`sample'/BotSocialMedia_Dist.pdf", replace

    restore
end


* --- outcome_ciplot ---

cap program drop y_title_range_diagnosis
program y_title_range_diagnosis
	// -------------------------------------------------------
	// DIAGNOSIS BLOCK: Global CI ranges across all HTE plots
	// -------------------------------------------------------
	
	local all_outcomes    Finished Post_meaningfulness index_Post_effort index_Post_nlp Post_AIness index_Post_overall ///
						TimePost_W WTP TimeWTP_W TimeWTPExplain_W ///
						GenAIEffective PerceiveAI SignalValue PerceiveEngaged
	
	local all_samples     2 20
	local all_moderators  index_ClimateBinary DonationBinary_pos ///
						ImageConcernBinary_p50 not_shared_handle Instagram_use index_Image_minus_privacyBinary ///
						AgeBinary_adult Grad_degree Vote Switzerland Female ETH ///
						index_ai_trustBinary_p50 index_bot_supportBinary_p50 index_reactBinary_p50 index_guess_humanBinary_p50
	
	foreach outcome of local all_outcomes {
		
			quietly summ `outcome'
			local true_min = r(min)
			local true_max = r(max)
		
			local global_ci_min = .
			local global_ci_max = .
		
			foreach samp of local all_samples {
				foreach cond in "none" "finished" {
					foreach mod of local all_moderators {
						foreach m_val in 0 1 {
		
							preserve
		
							quietly keep if sample`samp' == 1 & !missing(`outcome')
							if "`cond'" == "finished" {
								quietly keep if Finished == 1
							}
							quietly keep if `mod' == `m_val'
		
							capture {
								collapse (count) n=`outcome' (mean) beta=`outcome' (sd) sd=`outcome', by(Treatment_Group)
								gen se      = sd / sqrt(n)
								gen tcrit   = invttail(n-1, 0.025)
								gen ci_lo   = beta - tcrit*se
								gen ci_hi   = beta + tcrit*se
								replace ci_hi = `true_max' if ci_hi > `true_max'
								replace ci_lo = `true_min' if ci_lo < `true_min'
		
								quietly summ ci_lo
								if `global_ci_min' == . | r(min) < `global_ci_min' {
									local global_ci_min = r(min)
								}
								quietly summ ci_hi
								if `global_ci_max' == . | r(max) > `global_ci_max' {
									local global_ci_max = r(max)
								}
							}
		
							restore
						}
					}
				}
			}
		
			di "OUTCOME: `outcome'   CI_MIN = `global_ci_min'   CI_MAX = `global_ci_max'"
		}
end
	

cap program drop nice_ciplot_4treat_pvalue
program define nice_ciplot_4treat_pvalue
    version 17.0
    syntax, outcome(varname) sample_number(integer) slabel(string) sname(string)

    // ---------------------------------------------------------
    // 1. Finished-dataset detection (system macro — not a data op)
    // ---------------------------------------------------------
    local finished_tag = regexm(c(filename), "_ff\.dta")

    // ---------------------------------------------------------
    // 2. xtitle and filetag
    // ---------------------------------------------------------
    if `finished_tag' {
        local xtitle  "Treatment Group (Co-sender Composition × Disclosure) - `slabel', Finished"
        local filetag "ciplot_`outcome'_`sname'_raw_finished"
    }
    else {
        local xtitle  "Treatment Group (Co-sender Composition × Disclosure) - `slabel'"
        local filetag "ciplot_`outcome'_`sname'_raw"
    }

    // ---------------------------------------------------------
    // 3. Output directory (self-contained mkdir)
    // ---------------------------------------------------------
    local outdir "$output_dir/outcome_ciplot/raw_mean"
    capture mkdir "`outdir'"

    // ---------------------------------------------------------
    // 4. Filter condition (string ops only — no data access)
    // ---------------------------------------------------------
    local full_cond "sample`sample_number' == 1 & !missing(`outcome')"

    // ---------------------------------------------------------
    // 5. ALL DATA OPERATIONS INSIDE PRESERVE / RESTORE
    // ---------------------------------------------------------
    preserve

        keep if `full_cond'

        // -- y-axis settings: ylow, yhigh, ystep, yfmt set via c_local --
        yaxis_range_raw, outcome(`outcome')

        // -- ytitle from standardised variable labels --
        nice_name_as_label
        local ytitle_final : variable label `outcome'
        if `"`ytitle_final'"' == "" local ytitle_final "`outcome'"

        // -- Total N --
        quietly count
        local total_N_val = r(N)
        local total_N_str : di %9.0fc `total_N_val'
        local total_N_str = strtrim("`total_N_str'")

        // -- Arm sizes --
        forvalues i = 1/4 {
            quietly count if Treatment_Group == `i'
            local n`i' = r(N)
        }

        // -- T-tests (two-sided, unequal variance) --
        quietly ttest `outcome' if (Treatment_Group==1 | Treatment_Group==2), ///
            by(Treatment_Group) unequal
        local p12_str : di %6.3f r(p)

        quietly ttest `outcome' if (Treatment_Group==3 | Treatment_Group==4), ///
            by(Treatment_Group) unequal
        local p34_str : di %6.3f r(p)

        quietly ttest `outcome', by(Identify) unequal
        local p12_34_str : di %6.3f r(p)

        // -- True data bounds for CI capping --
        quietly summ `outcome'
        local true_min = r(min)
        local true_max = r(max)

        // -- Collapse to treatment-group cell means and CIs --
        collapse (count) n=`outcome' (mean) mean=`outcome' (sd) sd=`outcome', ///
            by(Treatment_Group)

        gen se       = sd / sqrt(n)
        gen tcrit    = invttail(n-1, 0.025)
        gen ci_lo    = mean - tcrit*se
        gen ci_hi    = mean + tcrit*se

        gen mean_plot  = mean
        gen ci_lo_plot = ci_lo
        gen ci_hi_plot = ci_hi
        replace ci_hi_plot = `true_max' if ci_hi_plot > `true_max'
        replace ci_lo_plot = `true_min' if ci_lo_plot < `true_min'

        // ---------------------------------------------------------
        // 6. P-VALUE BOX POSITIONING (unchanged)
        // ---------------------------------------------------------
        local range_y  = `yhigh' - `ylow'
        local gap      = `range_y' * 0.06
        local line2_y  = `ylow' + (`range_y' * 0.15)
        local line1_y  = `line2_y' + `gap'
        local line3_y  = `line2_y' - `gap'
        local box_x    = 0.7

        // ---------------------------------------------------------
        // 7. PLOT
        // ---------------------------------------------------------
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
            /* Dummy series for legend only */ ///
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
            /* LAYER 1: White box background */ ///
            text(`line2_y' `box_x' "`txt1'" " " "`txt2'" " " "`txt3'", ///
                 place(e) box fcolor(white) lcolor(black) margin(vsmall) ///
                 size(small) justification(left) color(white)) ///
            /* LAYER 2: Navy text (top) */ ///
            text(`line1_y' `box_x' "`txt1'", ///
                 place(e) margin(small) size(small) justification(left) color(`c1')) ///
            /* LAYER 3: Maroon text (middle) */ ///
            text(`line2_y' `box_x' "`txt2'", ///
                 place(e) margin(small) size(small) justification(left) color(`c2')) ///
            /* LAYER 4: Black text (bottom) */ ///
            text(`line3_y' `box_x' "`txt3'", ///
                 place(e) margin(small) size(small) justification(left) color(`c3')) ///
            legend(off) ///
            plotregion(margin(zero)) ///
            name(Ci_4treat_nice, replace)

        graph display Ci_4treat_nice, xsize(10) ysize(7)
        graph export "`outdir'/`filetag'.pdf", replace
        graph drop Ci_4treat_nice

    restore
end

cap program drop ciplot_4treat_pval_no_resid
program define ciplot_4treat_pval_no_resid
    * This program plots the 4-treatment raw means with p-values
    version 17.0
    
    // Added slabel and sname to syntax; removed title
    syntax, outcome(varname) sample_number(integer) slabel(string) sname(string) [if_condition(string)]

	// We do this here so we don't accidentally cap CIs at the wrong limits
    quietly summ `outcome'
    local true_min = r(min)
    local true_max = r(max)
	
    // Global y-axis range for this outcome
    local all_samples 2 20 // Make sure this matches your RUN_SAMPLES!
    local global_ci_min = .
    local global_ci_max = .


    foreach s of local all_samples {
        foreach cond in "" "if Finished == 1" {
            preserve
			keep if !missing(`outcome')
            keep if sample`s' == 1
            if "`cond'" != "" {
                keep `cond'
            }
            
            // Suppress errors in case a sample/condition combo is empty
            capture collapse (count) n=`outcome' (mean) beta=`outcome' (sd) sd=`outcome', by(Treatment_Group)
            if _rc == 0 & _N > 0 {
                gen se = sd/sqrt(n)
                gen tcrit = invttail(n-1, 0.025)
                gen temp_ci_lo = beta - tcrit*se
                gen temp_ci_hi = beta + tcrit*se
                
                // Keep the same capping logic you use for the actual plots
                replace temp_ci_hi = `true_max' if temp_ci_hi > `true_max'
                replace temp_ci_lo = `true_min' if temp_ci_lo < `true_min'
                
                quietly summ temp_ci_lo
                if `global_ci_min' == . | r(min) < `global_ci_min' {
                    local global_ci_min = r(min)
                }
                
                quietly summ temp_ci_hi
                if `global_ci_max' == . | r(max) > `global_ci_max' {
                    local global_ci_max = r(max)
                }
            }
            restore
        }
    }

    preserve
    keep if sample`sample_number' == 1
    keep if !missing(`outcome')
    if "`if_condition'" != "" {
        keep `if_condition'
    }
    
    // Dynamic xtitle and filetag based on arguments
    local xtitle "Treatment Group (Co-sender Composition × Disclosure) - `slabel', Finished"
    local filetag "ciplot_`outcome'_`sname'_raw_finished"
    
    if "`if_condition'" == "if Finished == 1" {
        local xtitle "Treatment Group (Co-sender Composition × Disclosure) - `slabel', Finished"
        local filetag "ciplot_`outcome'_`sname'_raw_finished"
    }

    // Dynamic ytitle based on outcome variable label
	nice_name_as_label
    local ytitle : variable label `outcome'
    if "`ytitle'" == "" {
        local ytitle "`outcome'" 
    }

    capture mkdir "$output_folder/outcome_ciplot"
    capture mkdir "$output_folder/outcome_ciplot/raw_mean"
    local outdir "$output_folder/outcome_ciplot/raw_mean"
    
    // -------------------------------------------------------
    // P-Values (Two-sided T-tests with unequal variance)
    // -------------------------------------------------------
    // Comparison 1: NoAI NotIden (Grp 1) vs AI NotIden (Grp 2)
    quietly ttest `outcome' if (Treatment_Group==1 | Treatment_Group==2), by(Treatment_Group) unequal
    local p12_str : di %6.3f r(p)

    // Comparison 2: NoAI Iden (Grp 3) vs AI Iden (Grp 4)
    quietly ttest `outcome' if (Treatment_Group==3 | Treatment_Group==4), by(Treatment_Group) unequal
    local p34_str : di %6.3f r(p)
    
    // Comparison 3: Not Identified (Grp 1&2) vs Not Identified (Grp 3&4)
    quietly ttest `outcome', by(Identify) unequal
    local p12_34_str : di %6.3f r(p)

    // -------------------------------------------------------
    // Calculate Stats (Collapse)
    // -------------------------------------------------------
    collapse (count) n=`outcome' (mean) beta=`outcome' (sd) sd=`outcome', by(Treatment_Group)

    gen se    = sd/sqrt(n)
    gen tcrit = invttail(n-1, 0.025)
    gen ci_lo = beta - tcrit*se
    gen ci_hi = beta + tcrit*se

    // -------------------------------------------------------
    // Cap CIs at Data Min/Max
    // -------------------------------------------------------
    replace ci_hi = `true_max' if ci_hi > `true_max'
    replace ci_lo = `true_min' if ci_lo < `true_min'

    // Capture Ns for labels
    forvalues i = 1/4 {
        quietly sum n if Treatment_Group == `i'
        local n`i' = r(mean)
    }

    // -------------------------------------------------------
    // Plotting 
    // -------------------------------------------------------
    local max_val = `global_ci_max'
    local min_val = `global_ci_min'
    
    local range = `max_val' - `min_val'
    if `range' == 0 local range = 1

    local ybottom = `min_val' - (`range' * 0.1)
    local ytop    = `max_val' + (`range' * 0.1)
	
    // Compute a "nice" ylabel step (snap to 1, 2, or 5 × 10^k)
    local raw_step = (`ytop' - `ybottom') / 5
    local mag = 10^floor(log10(`raw_step'))
    local norm = `raw_step' / `mag'
    if `norm' <= 1       local step = 1 * `mag'
    else if `norm' <= 2  local step = 2 * `mag'
    else if `norm' <= 5  local step = 5 * `mag'
    else                 local step = 10 * `mag'
    
    // Snap ybottom down and ytop up to multiples of step
    local ybottom = `step' * floor(`ybottom' / `step')
    local ytop    = `step' * ceil(`ytop' / `step')
	
	local ylab_lo = `ybottom'
	local ylab_hi = `ytop'
	
	if inlist("`outcome'", "Finished", "Post_meaningfulness") {
		local ytop = 1.05
		local ybottom = 0.60
		local ylab_lo = 0.60
		local ylab_hi = 1.0
		local step = 0.1
	}
	
    // Dynamic format based on step size
    if `ytop' < 1        local yfmt "%9.2f"
    else if `ytop' < 10  local yfmt "%9.1f"
    else                 local yfmt "%9.0f"
    
    local c1 "navy"
    local c2 "maroon"
    local c3 "black"

    // Removed title() from twoway
    twoway ///
        (rcap ci_hi ci_lo Treatment_Group if Treatment_Group<=2, lcolor(`c1') lwidth(medthin)) ///
        (scatter beta Treatment_Group if Treatment_Group<=2, msymbol(Dh) msize(small) mcolor(none) mlcolor(`c1')) ///
        (rcap ci_hi ci_lo Treatment_Group if Treatment_Group> 2, lcolor(`c2') lwidth(medthin)) ///
        (scatter beta Treatment_Group if Treatment_Group> 2, msymbol(Dh) msize(small) mcolor(none) mlcolor(`c2')) ///
        , ///
        xlabel(1 `""No AI, Anonymous" "(n=`n1')""' ///
               2 `""AI, Anonymous" "(n=`n2')""' ///
               3 `""No AI, Identified" "(n=`n3')""' ///
               4 `""AI, Identified" "(n=`n4')""', labsize(small)) ///
        xscale(range(0.5 4.5)) ///
        ylabel(`ylab_lo'(`step')`ylab_hi', format(`yfmt') labsize(small)) yscale(range(`ybottom' `ytop') noextend) ///
        xtitle("`xtitle'", size(small)) ///
        ytitle("`ytitle'", size(small)) ///
        text(`ytop' 1 "P-Val (Diff): `p12_str'", place(e) size(vsmall) color(`c1')) ///
        text(`ytop' 3.32 "P-Val (Diff): `p34_str'", place(e) size(vsmall) color(`c2')) ///
        text(`ytop' 1.99 "P-Val (Anon vs Iden): `p12_34_str'", place(e) size(vsmall) color(`c3')) ///
        legend(off) ///
        graphregion(color(white) margin(medium)) ///
        name(raw_ciplot, replace)

    graph export "`outdir'/`filetag'.pdf", replace
    graph drop raw_ciplot

    restore
end

cap program drop ciplot_4treat_pval_fwl_resid
program define ciplot_4treat_pval_fwl_resid
    version 17.0
   
    syntax, outcome(varname) sample_number(integer) slabel(string) sname(string) [if_condition(string)]

    // -------------------------------------------------------
    // 1. Identify Forced Base Control (Post_ → Base_ mapping)
    // -------------------------------------------------------
    local forced_base ""
    
    if strpos("`outcome'", "Post_") == 1 {
        local suffix = substr("`outcome'", 6, .)
        foreach bvar of global BASE_TEXT_CONTROLS {
            if "`bvar'" == "Base_`suffix'" {
                local forced_base "`bvar'"				
            }
        }		
    }

    // -------------------------------------------------------
    // 2. Setup for Lasso + Regression
    // -------------------------------------------------------
    local cand_clean "$CONTROLS"
    local vce "robust"
    
    local is_bin = 0
    if strpos(" $OUTCOMES_BIN ", " `outcome' ") > 0 local is_bin = 1

    // -------------------------------------------------------
    // 3. Global Y-Axis Range (across all samples & conditions)
    // -------------------------------------------------------
    local all_samples 2 20  // Must match RUN_SAMPLES!
    local global_ci_min = .
    local global_ci_max = .

    foreach s of local all_samples {
        foreach cond in "" "if Finished == 1" {
            preserve
            keep if !missing(`outcome')
            keep if sample`s' == 1
            if "`cond'" != "" {
                keep `cond'
            }
            
            // Lasso selection for this sample/condition
            local controls_sel_temp ""
            quietly count
            if r(N) >= 20 {
                if `is_bin' {
                    capture quietly lasso logit `outcome' `cand_clean', selection(plugin)
                    if !_rc local controls_sel_temp "`e(allvars_sel)'"
                }
                else {
                    capture quietly lasso linear `outcome' `cand_clean', selection(plugin)
                    if !_rc local controls_sel_temp "`e(allvars_sel)'"
                }
            }
            
            local final_controls_temp "`controls_sel_temp' `forced_base'"
            

			capture quietly regress `outcome' AI_x_Anon NoAI_x_Iden AI_x_Iden `final_controls_temp', vce(`vce')
            if !_rc {
                foreach coef in AI_x_Anon NoAI_x_Iden AI_x_Iden {
                    local b_temp = _b[`coef']
                    local se_temp = _se[`coef']
                    local lo = `b_temp' - 1.96*`se_temp'
                    local hi = `b_temp' + 1.96*`se_temp'
                    if `global_ci_min' == . | `lo' < `global_ci_min' {
                        local global_ci_min = `lo'
                    }
                    if `global_ci_max' == . | `hi' > `global_ci_max' {
                        local global_ci_max = `hi'
                    }
                }
            }
            restore
        }
    }
    
    // Ensure zero is always in range (reference group anchored at 0)
    if `global_ci_min' != . & `global_ci_min' > 0 local global_ci_min = 0
    if `global_ci_max' != . & `global_ci_max' < 0 local global_ci_max = 0
    
    // Fallback if all regressions failed
    if `global_ci_min' == . local global_ci_min = -1
    if `global_ci_max' == . local global_ci_max = 1

    // -------------------------------------------------------
    // 4. Actual Plot: Preserve & Subset
    // -------------------------------------------------------
    preserve
    keep if sample`sample_number' == 1
    keep if !missing(`outcome')
    if "`if_condition'" != "" {
        keep `if_condition'
    }


    // Dynamic xtitle and filetag
    local xtitle "Treatment Group (Co-sender Composition × Disclosure) - `slabel', Finished"
    local filetag "ciplot_`outcome'_`sname'_resid_finished"
    
    if "`if_condition'" == "if Finished == 1" {
        local xtitle "Treatment Group (Co-sender Composition × Disclosure) - `slabel', Finished"
        local filetag "ciplot_`outcome'_`sname'_resid_finished"
    }

    // Dynamic ytitle from variable label
    nice_name_as_label
    local ytitle : variable label `outcome'
    if "`ytitle'" == "" {
        local ytitle "`outcome'"
    }
	
    capture mkdir "$output_folder/outcome_ciplot"
    capture mkdir "$output_folder/outcome_ciplot/residualized"
    local outdir "$output_folder/outcome_ciplot/residualized"

    // -------------------------------------------------------
    // 5. Lasso Selection
    // -------------------------------------------------------
    local controls_sel ""
    
    quietly count
    if r(N) >= 20 {
        if `is_bin' {
            capture quietly lasso logit `outcome' `cand_clean', selection(plugin)
            if !_rc local controls_sel "`e(allvars_sel)'"
        }
        else {
            capture quietly lasso linear `outcome' `cand_clean', selection(plugin)
            if !_rc local controls_sel "`e(allvars_sel)'"
        }
    }

    local final_controls "`controls_sel' `forced_base'"

	display "Outcome: `outcome' - Selected Control: `final_controls'"
    // -------------------------------------------------------
    // 6. Regression
    // -------------------------------------------------------
    
    quietly regress `outcome' AI_x_Anon NoAI_x_Iden AI_x_Iden `final_controls', vce(`vce')

    tempvar touse
    gen byte `touse' = e(sample)

    forvalues i = 1/4 {
        quietly count if Treatment_Group==`i' & `touse'
        local n`i' = r(N)
    }

    // -------------------------------------------------------
    // 7. P-Values
    // -------------------------------------------------------
    // Group 2 vs Group 1 (Ref)
    quietly test AI_x_Anon = 0
    local p12_str : di %6.3f r(p)
    
    // Group 4 vs Group 3 (AI vs No AI within Identified)
    quietly test AI_x_Iden = NoAI_x_Iden
    local p34_str : di %6.3f r(p)

    // Pooled Identified vs Anonymous
    quietly test NoAI_x_Iden + AI_x_Iden - AI_x_Anon = 0
    local p12_34_str : di %6.3f r(p)

    // -------------------------------------------------------
    // 8. Build Plotting Data
    // -------------------------------------------------------
    drop _all
    set obs 4
    gen Treatment_Group = _n
    gen beta = .
    gen se   = .

    replace beta = 0 in 1
    replace se   = 0 in 1

    replace beta = _b[AI_x_Anon] in 2
    replace se   = _se[AI_x_Anon] in 2
    
    replace beta = _b[NoAI_x_Iden] in 3
    replace se   = _se[NoAI_x_Iden] in 3
    
    replace beta = _b[AI_x_Iden] in 4
    replace se   = _se[AI_x_Iden] in 4

    gen ci_lo = beta - 1.96*se
    gen ci_hi = beta + 1.96*se

    // -------------------------------------------------------
    // 9. Plotting
    // -------------------------------------------------------
    local max_val = `global_ci_max'
    local min_val = `global_ci_min'
    
    local range = `max_val' - `min_val'
    if `range' == 0 local range = 1

    local ybottom = `min_val' - (`range' * 0.1)
    local ytop    = `max_val' + (`range' * 0.1)
    
    // Compute a "nice" ylabel step (snap to 1, 2, or 5 × 10^k)
    local raw_step = (`ytop' - `ybottom') / 5
    local mag = 10^floor(log10(`raw_step'))
    local norm = `raw_step' / `mag'
    if `norm' <= 1       local step = 1 * `mag'
    else if `norm' <= 2  local step = 2 * `mag'
    else if `norm' <= 5  local step = 5 * `mag'
    else                 local step = 10 * `mag'
    
    // Snap ybottom down and ytop up to multiples of step
    local ybottom = `step' * floor(`ybottom' / `step')
    local ytop    = `step' * ceil(`ytop' / `step')
	
    // Dynamic format based on step size
    if `step' < 0.1      local yfmt "%9.2f"
    else if `step' < 1   local yfmt "%9.1f"
    else                  local yfmt "%9.0f"
    
    local c1 "navy"
    local c2 "maroon"
    local c3 "black"

    twoway ///
        (rcap ci_hi ci_lo Treatment_Group if Treatment_Group<=2, lcolor(`c1') lwidth(medthin)) ///
        (scatter beta Treatment_Group if Treatment_Group<=2, msymbol(Dh) msize(small) mcolor(none) mlcolor(`c1')) ///
        (rcap ci_hi ci_lo Treatment_Group if Treatment_Group> 2, lcolor(`c2') lwidth(medthin)) ///
        (scatter beta Treatment_Group if Treatment_Group> 2, msymbol(Dh) msize(small) mcolor(none) mlcolor(`c2')) ///
        , ///
        yline(0, lcolor(gs10) lpattern(dash)) ///
        xlabel(1 `""No AI, Anonymous" "(n=`n1')""' ///
               2 `""AI, Anonymous" "(n=`n2')""' ///
               3 `""No AI, Identified" "(n=`n3')""' ///
               4 `""AI, Identified" "(n=`n4')""', labsize(small)) ///
        xscale(range(0.5 4.5)) ///
        ylabel(`ybottom'(`step')`ytop', format(`yfmt') labsize(small)) ///
        yscale(range(`ybottom' `ytop') noextend) ///
        xtitle("`xtitle'", size(small)) ///
        ytitle("`ytitle'", size(small)) ///
        text(`ytop' 1 "P-Val (vs Ref): `p12_str'", place(e) size(vsmall) color(`c1')) ///
        text(`ytop' 3.32 "P-Val (Diff): `p34_str'", place(e) size(vsmall) color(`c2')) ///
        text(`ytop' 1.99 "P-Val (Anon vs Iden): `p12_34_str'", place(e) size(vsmall) color(`c3')) ///
        legend(off) ///
        graphregion(color(white) margin(medium)) ///
        name(fwl_ciplot, replace)

    graph export "`outdir'/`filetag'.pdf", replace
    graph drop fwl_ciplot

    restore
end


* --- outcome_table ---

capture program drop tbl_treat_eff_app
program define tbl_treat_eff_app

    syntax, outcome(varname) sample_number(integer) slabel(string) sname(string) [if_condition(string)]


    local col1_title "No Controls"
    local col2_title "Demographics"
    local col3_title "All Controls"


    * C2: Demographics
    local c2_controls "AgeBinary_adult Female Switzerland Grad_degree ETH Vote"

    * C3: All Controls
    local c3_add_controls "Instagram_use not_shared_handle ImageConcernBinary_p50 DonationBinary_pos BotKnowBinary AIEffectiveBinary AIDiffBinary PostReactBinary ReadingReact1Binary ReadingReact2Binary Guess1_asHuman Guess2_asHuman BotSupport_AIBinary BotSocialMedia_AIBinary"


    preserve

    quietly keep if sample`sample_number' == 1 & !missing(`outcome')
    if "`if_condition'" != "" {
        keep `if_condition'
    }


    nice_name_as_label
    local ytitle : variable label `outcome'
    if "`ytitle'" == "" local ytitle "`outcome'"
	
	if "`outcome'" == "ImageConcernBinary_p50" {
		local ytitle "High Image Concern"
	}

    // ---------------------------------------------------------
    // title and fname
    // ---------------------------------------------------------
	local finished_tag = regexm(c(filename), "_ff\.dta")
	
	

    if `finished_tag' {
        local fname  "table_te_`outcome'_`sname'_finished"
        local tbl_title "Treatment Effects on `ytitle' - `slabel', Finished"
    }
    else {
        local fname  "table_te_`outcome'_`sname'"
        local tbl_title "Treatment Effects on `ytitle' - `slabel'"
    }
	
    local outdir "$output_dir/outcome_table/treatment_effect"

    // -------------------------------------------------------
    // 5. Forced Base Control (Post_* outcomes only, used in C3)
    // -------------------------------------------------------
	local forced_base ""
	
	if inlist("`outcome'", "Post_meaningfulness", "Post_TextLength_log", "Post_AIness","index_Post_effort", "index_Post_nlp") {
		local forced_base = subinstr("`outcome'", "Post_", "Base_", 1)
	}

    // -------------------------------------------------------
    // 6. Three Treatment Arms (base = NoAI_x_Anon = _cons)
    // -------------------------------------------------------
    local three_arms "Identify AITreat AIXIdentifyTreat"

    // -------------------------------------------------------
    // 7. Run Regressions
    // -------------------------------------------------------
    eststo clear
    local models_to_tab ""

    capture quietly regress `outcome' `three_arms', vce(robust)
    if _rc == 0 {
        eststo model1
        local models_to_tab "`models_to_tab' model1"
    }

    capture quietly regress `outcome' `three_arms' `c2_controls', vce(robust)
    if _rc == 0 {
        eststo model2
        local models_to_tab "`models_to_tab' model2"
    }


    capture quietly regress `outcome' `three_arms' `c2_controls' `forced_base' `c3_add_controls', vce(robust)
    if _rc == 0 {
        eststo model3
        local models_to_tab "`models_to_tab' model3"
    }

    // -------------------------------------------------------
    // 8. Export Table
    // -------------------------------------------------------
    if "`models_to_tab'" != "" {
        esttab `models_to_tab' using "`outdir'/`fname'.tex", replace      ///
            main(b %9.3f) aux(se %9.3f)                                    ///
            starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001)                   ///
            label                                                           ///
            keep(`three_arms' * _cons)                                      ///
            order(`three_arms') 	                                      ///
            coeflabels(Identify   "Identified Treatment"                    ///
                       AITreat     "AI Treatment"                 ///
                       AIXIdentifyTreat   "AI \$\times\$ Identified"            ///
					   _cons       "Constant")                				   ///
            stats(r2_a N, fmt(%9.3f %9.0fc)                                ///
                labels("Adj. \(R^2\)" "\(N\)"))                            ///
            mtitles("`col1_title'" "`col2_title'" "`col3_title'" )         ///
            numbers                                                         ///
            title("`tbl_title'") nonotes                                    ///
            booktabs compress width(\hsize)                                 ///
			prehead(`"\documentclass{article}"'                            ///
                    `"\usepackage{booktabs}"'                               ///
                    `"\usepackage{caption}"'                                ///
                    `"\usepackage[paperheight=11in, paperwidth=8.5in, margin=1in]{geometry}"' ///
                    `"\begin{document}"'                                    ///
                    `"\begin{table}[htbp]\centering"'                       ///
                    `"\footnotesize"'                                       ///
                    `"\renewcommand{\arraystretch}{0.85}"'                  ///
                    `"\setlength{\defaultaddspace}{0.25em}"'                 ///
                    `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"'          ///
                    `"\caption*{@title}"'                                    ///
                    `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                    `"\toprule"')                                           ///
            postfoot(`"\bottomrule"'                                        ///
                     `"\end{tabular*}"'                                     ///
                     `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"'  ///
                     `"Standard errors in parentheses. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$. \\"' ///
                     `"All the Behavioral and Demographics controls are binarized to match the HTE results. \\"' ///
                     `"All time-based metrics are reported in seconds (s) and Winsorized at the 95th percentile (top 5\% only)."' ///
                     `"\end{minipage}"'                                     ///
                     `"\end{table}"'                                        ///
                     `"\end{document}"')
    }
    else {
        display as error "No models successfully estimated for `outcome' in sample `sample_number'."
    }

    restore
end


** Divided by samples & playing with focal behavioral controls
/*
** On Sample# (Sample2, Sample20,...) **

cap program drop outcome_img_prv_ins_tbl_Noctrl
program define outcome_img_prv_ins_tbl_Noctrl
    syntax, sample_number(integer) outcome(varname) imageconcenrn(varname) slabel(string) [if_condition(string)]
    
    preserve
    
    quietly keep if sample`sample_number' == 1 & !missing(`outcome')
    if "`if_condition'" != "" {
        keep `if_condition'
    }

    local tbl_title "Regression of `outcome' (No Controls) using `slabel'"
    local fname "`outcome'_NoControl"
    
    if "`if_condition'" == "if Finished == 1" {
        local tbl_title "Regression of `outcome' (No Controls) using `slabel' $|$ Finished = 1"
        local fname "`outcome'_NoControl_finished"
    }

    capture mkdir "$output_folder/outcome_table"
    local outdir "$output_folder/outcome_table/sample`sample_number'"
    capture mkdir "`outdir'"

    local three_arms AI_x_Anon NoAI_x_Iden AI_x_Iden 
    

    local c_img  "i.`imageconcenrn'"
    local c_prv  "i.not_shared_handle"
    local c_inst "i.Instagram_use"
    
    local models_to_tab ""
    eststo clear
    
    quietly count
    local N_obs = r(N)
    
    if `N_obs' > 10 {
        forvalues i = 1/8 {
            local current_controls ""
            local lbl_img "No"
            local lbl_prv "No"
            local lbl_insta "No"
            
            if `i' == 2 {
                local current_controls `c_img'
                local lbl_img "Yes"
            }
            if `i' == 3 {
                local current_controls `c_img' `c_prv'
                local lbl_img "Yes"
                local lbl_prv "Yes"
            }
            if `i' == 4 {
                local current_controls `c_prv'
                local lbl_prv "Yes"
            }
            if `i' == 5 {
                local current_controls `c_inst'
                local lbl_insta "Yes"
            }
            if `i' == 6 {
                local current_controls `c_inst' `c_img'
                local lbl_insta "Yes"
                local lbl_img "Yes"
            }
            if `i' == 7 {
                local current_controls `c_inst' `c_img' `c_prv'
                local lbl_insta "Yes"
                local lbl_img "Yes"
                local lbl_prv "Yes"
            }
            if `i' == 8 {
                local current_controls `c_inst' `c_prv'
                local lbl_insta "Yes"
                local lbl_prv "Yes"
            }
            
            capture eststo model_`i': reghdfe `outcome' `current_controls' `three_arms', vce(robust) 
            
            if _rc == 0 {
                quietly estadd local imgconcern "`lbl_img'"
                quietly estadd local privacy "`lbl_prv'"
                quietly estadd local insta "`lbl_insta'"
                quietly estadd scalar samplesize = e(N)
                local models_to_tab "`models_to_tab' model_`i'"
            }
        }
    }
    else {
        display as error "Not enough observations for Sample `sample_number'"
    }

    esttab `models_to_tab' using "`outdir'/`fname'.tex", replace ///
        main(b %9.3f) aux(se %9.3f) ///
        starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
        keep(_cons AI_x_Anon NoAI_x_Iden AI_x_Iden *) ///
        order(_cons AI_x_Anon NoAI_x_Iden AI_x_Iden) ///
        coeflabels(_cons "NoAI_x_Anon") ///
        stats(r2_a imgconcern privacy insta samplesize, fmt(%9.3f 0 0 0 %9.0fc) ///
            labels("Adj. \(R^2\)" "Control: Image Concern" "Control: Privacy Concern" "Control: Instagram Usage" "\(N\)")) ///
        nomtitles ///
        title("`tbl_title'") nonotes ///
        booktabs compress width(\hsize) ///
        prehead(`"\documentclass{article}"' ///
                `"\usepackage{booktabs}"' ///
                `"\usepackage[paperheight=8in, paperwidth=9in, margin=0.5in]{geometry}"' ///
                `"\begin{document}"' ///
                `"\begin{table}[htbp]\centering"' ///
                `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
                `"\caption{@title}"' ///
                `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                `"\toprule"') ///
        postfoot(`"\bottomrule"' ///
                 `"\end{tabular*}"' ///
                 `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"' ///
                 `"\textbf{Note:} The reference group (NoAI x NotIden) is represented by the intercept. \\"' ///
                 `"Standard errors in parentheses. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$."' ///
                 `"\end{minipage}"' ///
                 `"\end{table}"' ///
                 `"\end{document}"')
    restore
end

capture program drop outcome_img_prv_ins_tbl_Lasso
program define outcome_img_prv_ins_tbl_Lasso
    syntax, sample_number(integer) outcome(varname) imageconcenrn(varname) slabel(string) standardize(integer) [if_condition(string)]
    
    preserve
    quietly keep if sample`sample_number' == 1 & !missing(`outcome')
    if "`if_condition'" != "" {
        keep `if_condition'
    }

    local tbl_title "Regression of `outcome' (Lasso Controls) using `slabel'"
    if `standardize' {
        local fname "`outcome'_Lasso_standardized"
    }
    else {
        local fname "`outcome'_Lasso"
    }
    
    if "`if_condition'" == "if Finished == 1" {
        local tbl_title "Regression of `outcome' (Lasso Controls) using `slabel' $|$ Finished = 1"
        if `standardize' {
            local fname "`outcome'_Lasso_standardized_finished"
        }
        else {
            local fname "`outcome'_Lasso_finished"
        }
    }

    capture mkdir "$output_folder/outcome_table"
    local outdir "$output_folder/outcome_table/sample`sample_number'"
    capture mkdir "`outdir'"
    
    local three_arms AI_x_Anon NoAI_x_Iden AI_x_Iden 
    

    local forced_base ""
    
    if "`outcome'" == "PostTextLength"      local forced_base "BaseTextLength"
    else if "`outcome'" == "PostTextLength_log"  local forced_base "BaseTextLength_log"
	else if "`outcome'" == "grammatical_mistakes" local forced_base "Base_grammatical_mistakes"
	else if "`outcome'" == "Meaningful_post"     local forced_base "i.Meaningful_base"
	
    else {
        capture confirm variable Base_`outcome'
        if !_rc local forced_base "i.Base_`outcome'"
    }
    
    // -------------------------------------------------------
    // Lasso Selection
    // -------------------------------------------------------
	
	local lasso_cands "$CONTROLS_CONT_NOFACTOR"
	
    * Add Categorical with i. prefix (Excluding the manual controls)
    local cat_vars_to_remove "Instagram_use ImageConcern not_shared_handle"
    foreach v of global CONTROLS_CAT_NOFACTOR {
        local is_manual = (strpos("`cat_vars_to_remove'", "`v'") > 0)
        if `is_manual' == 0 {
            local lasso_cands "`lasso_cands' i.`v'"
        }
    }


    local is_binary = (strpos("$OUTCOMES_BIN", " `outcome' ") > 0)
    local controls_lasso_sel ""
    
    if `is_binary' {
        capture quietly lasso logit `outcome' `lasso_cands', selection(plugin)
        if _rc == 0 {
            local controls_lasso_sel "`e(allvars_sel)'"
        }
    }
    else {
        capture quietly lasso linear `outcome' `lasso_cands', selection(plugin)
        if _rc == 0 {
            local controls_lasso_sel "`e(allvars_sel)'"
        }
    }
    

    local controls_lasso_final ""
    
    foreach v of local controls_lasso_sel {
		
		* Spaces are necessary to prevent mismatches
        local is_cont = (strpos(" $CONTROLS_CONT_NOFACTOR ", " `v' ") > 0)
        

        if `is_cont' {
            if `standardize' == 1 {
                capture drop `v'_S
                quietly summarize `v'
                if r(sd) > 0 & r(sd) < . {
                    gen `v'_S = (`v' - r(mean)) / r(sd)
                    local controls_lasso_final "`controls_lasso_final' `v'_S"
                }
                else {
					* Fallback if variance is 0
					local controls_lasso_final "`controls_lasso_final' `v'"
                }
            }
            else {
				* No need for standardization
                local controls_lasso_final "`controls_lasso_final' `v'" 
            }
        }
        else {
            * If it was not continuous, it's already chosen as categorical.
            local controls_lasso_final "`controls_lasso_final' `v'"
        }
    }
	
	** Or, we can just use "if `is_cont' & `standardize'" and one "else".
            
    // -------------------------------------------------------
    // Build Models
    // -------------------------------------------------------
    local c_img  "i.`imageconcenrn'"
    local c_prv  "i.not_shared_handle"
    local c_inst "i.Instagram_use"
    
    local models_to_tab ""
    eststo clear
    quietly count
    local N_obs = r(N)
    
    if `N_obs' > 10 {
        forvalues i = 1/8 {
            local current_main_controls ""
            local lbl_img "No"
            local lbl_prv "No"
            local lbl_insta "No"
            
            if `i' == 1 {
                local current_main_controls ""
            }
            if `i' == 2 {
                local current_main_controls `c_img'
                local lbl_img "Yes"
            }
            if `i' == 3 {
                local current_main_controls `c_img' `c_prv'
                local lbl_img "Yes"
                local lbl_prv "Yes"
            }
            if `i' == 4 {
                local current_main_controls `c_prv'
                local lbl_prv "Yes"
            }
            if `i' == 5 {
                local current_main_controls `c_inst'
                local lbl_insta "Yes"
            }
            if `i' == 6 {
                local current_main_controls `c_inst' `c_img' 
                local lbl_img "Yes"
                local lbl_insta "Yes"
            }
            if `i' == 7 {
                local current_main_controls `c_inst' `c_img' `c_prv' 
                local lbl_img "Yes"
                local lbl_prv "Yes"
                local lbl_insta "Yes"
            }
            if `i' == 8 {
                local current_main_controls `c_inst' `c_prv' 
                local lbl_prv "Yes"
                local lbl_insta "Yes"
            }
            
            capture eststo model_`i': reghdfe `outcome' `current_main_controls' `controls_lasso_final' `forced_base' `three_arms', vce(robust) 
            
            if _rc == 0 {
                quietly estadd local imgconcern "`lbl_img'"
                quietly estadd local privacy "`lbl_prv'"
                quietly estadd local insta "`lbl_insta'"
                quietly estadd scalar samplesize = e(N)
                local models_to_tab "`models_to_tab' model_`i'"
            }
        }
    }
    else {
        display as error "Not enough observations for Sample `sample_number'"
    }

    esttab `models_to_tab' using "`outdir'/`fname'.tex", replace ///
        main(b %9.3f) aux(se %9.3f) ///
        starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
        keep(_cons AI_x_Anon NoAI_x_Iden AI_x_Iden *) ///
        order(_cons AI_x_Anon NoAI_x_Iden AI_x_Iden) ///
        coeflabels(_cons "NoAI_x_Anon") ///
        stats(r2_a imgconcern privacy insta samplesize, ///
            fmt(%9.3f 0 0 0 %9.0fc) ///
            labels("Adj. \(R^2\)" "Control: Image Concern" "Control: Privacy Concern" "Control: Instagram Usage" "\(N\)")) ///
        nomtitles ///
        title("`tbl_title'") nonotes ///
        booktabs compress width(\hsize) ///
        prehead(`"\documentclass{article}"' ///
                `"\usepackage{booktabs}"' ///
                `"\usepackage[paperheight=12in, paperwidth=10in, margin=0.5in]{geometry}"' ///
                `"\begin{document}"' ///
                `"\begin{table}[htbp]\centering"' ///
                `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
                `"\caption{@title}"' ///
                `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                `"\toprule"') ///
        postfoot(`"\bottomrule"' ///
                 `"\end{tabular*}"' ///
                 `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"' ///
                 `"\textbf{Note:} The reference group (NoAI x NotIden) is represented by the intercept. \\"' ///
                 `"Standard errors in parentheses. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$."' ///
                 `"\end{minipage}"' ///
                 `"\end{table}"' ///
                 `"\end{document}"')

    restore
end

cap program drop lasso_diagnosis_controls2
program define lasso_diagnosis_controls2
	* ==============================================================================
	* DIAGNOSIS TEST: Full Variable Pipeline & Model Loop Check
	* ==============================================================================
	set more off
	cls
	
	* TOGGLE: Set to 1 to test the standardization logic, 0 to skip
	local standardize = 0
	
	* FIX: Define the specific variable names for the manual controls here
	* (This fixes the potential typo "imageconcenrn" in your snippet)
	local imageconcenrn   "ImageConcern"
	local not_shared_handle "not_shared_handle"
	local Instagram_use     "Instagram_use"
	
	display as text "{hline 80}"
	display as result " RUNNING DIAGNOSIS: CANDIDATES -> LASSO -> FORMATTING -> MODEL ITERATIONS"
	display as text "{hline 80}"
	
	foreach outcome in $OUTCOMES $TEXT_OUTCOMES {
		
		* -------------------------------------------------------
		* 1. FORCED BASE LOGIC
		* -------------------------------------------------------
		local forced_base ""
		if "`outcome'" == "PostTextLength"       local forced_base "BaseTextLength"
		else if "`outcome'" == "PostTextLength_log"  local forced_base "BaseTextLength_log"
		else if "`outcome'" == "grammatical_mistakes" local forced_base "Base_grammatical_mistakes"
		else if "`outcome'" == "Meaningful_post"     local forced_base "i.Meaningful_base"
		else {
			capture confirm variable Base_`outcome'
			if !_rc local forced_base "i.Base_`outcome'"
		}
	
		* -------------------------------------------------------
		* 2. LASSO CANDIDATE CONSTRUCTION
		* -------------------------------------------------------
		local lasso_cands "$CONTROLS_CONT_NOFACTOR"
		
		* Add Categorical with i. prefix (Excluding the manual controls)
		local cat_vars_to_remove "Instagram_use ImageConcern not_shared_handle"
		foreach v of global CONTROLS_CAT_NOFACTOR {
			local is_manual = (strpos("`cat_vars_to_remove'", "`v'") > 0)
			if `is_manual' == 0 {
				local lasso_cands "`lasso_cands' i.`v'"
			}
		}
	
		* -------------------------------------------------------
		* 3. LASSO SELECTION (Execution)
		* -------------------------------------------------------
		local is_binary = (strpos(" $OUTCOMES_BIN ", " `outcome' ") > 0)
		local controls_lasso_sel "INVALID/SKIPPED (N<20 or Error)"
		
		quietly count if !missing(`outcome')
		if r(N) >= 20 {
			if `is_binary' {
				capture quietly lasso logit `outcome' `lasso_cands', selection(plugin)
				if _rc == 0 local controls_lasso_sel "`e(allvars_sel)'"
				else        local controls_lasso_sel "ERROR in Lasso Logit"
			}
			else {
				capture quietly lasso linear `outcome' `lasso_cands', selection(plugin)
				if _rc == 0 local controls_lasso_sel "`e(allvars_sel)'"
				else        local controls_lasso_sel "ERROR in Lasso Linear"
			}
		}
	
		* -------------------------------------------------------
		* 4. FORMATTING & STANDARDIZATION (Your Logic)
		* -------------------------------------------------------
		local controls_lasso_final ""
		
		if substr("`controls_lasso_sel'", 1, 5) != "ERROR" & "`controls_lasso_sel'" != "INVALID/SKIPPED (N<20 or Error)" {
			
			foreach v of local controls_lasso_sel {
				
				* Double Padding Check
				local is_cont = (strpos(" $CONTROLS_CONT_NOFACTOR ", " `v' ") > 0)
	
				if `is_cont' {
					if `standardize' == 1 {
						capture drop `v'_N
						quietly summarize `v'
						if r(sd) > 0 & r(sd) < . {
							quietly gen `v'_N = (`v' - r(mean)) / r(sd)
							local controls_lasso_final "`controls_lasso_final' `v'_N"
						}
						else {
							* Fallback if variance is 0
							local controls_lasso_final "`controls_lasso_final' `v'"
						}
					}
					else {
						* No standardization (No prefix per your new logic)
						local controls_lasso_final "`controls_lasso_final' `v'" 
					}
				}
				else {
					* If not continuous, i. is redundent. Get back is problematic. See the outcome_img_prv_ins_tbl_Lasso.
					local controls_lasso_final "`controls_lasso_final' i.`v'"
				}
			}
		}
		
		* -------------------------------------------------------
		* 5. OUTPUT DISPLAY
		* -------------------------------------------------------
		display as text "Outcome: " _col(25) as result "`outcome'"
		display as text "Forced Base: " _col(25) as result "`forced_base'"
		display as text "Lasso Cands: " _col(25) as result "`lasso_cands'"
		display as text "Lasso Raw: " _col(25) as result "`controls_lasso_sel'"
		display as text "Lasso Final: " _col(25) as result "`controls_lasso_final'"
		display ""
		display as text "{ul:Model Iteration Check (1-8):}"
		
		* -------------------------------------------------------
		* 6. MODEL LOOP SIMULATION
		* -------------------------------------------------------
		* Define the manual controls based on your logic
		local c_img  "i.`imageconcenrn'"
		local c_prv  "i.`not_shared_handle'"
		local c_inst "i.`Instagram_use'"
		
		display as text "Iter" _col(10) "Manual Controls (current_main_controls)"
		display as text "{hline 60}"
		
		forvalues i = 1/8 {
			local current_main_controls ""
			
			if `i' == 1  local current_main_controls ""
			if `i' == 2  local current_main_controls "`c_img'"
			if `i' == 3  local current_main_controls "`c_img' `c_prv'"
			if `i' == 4  local current_main_controls "`c_prv'"
			if `i' == 5  local current_main_controls "`c_inst'"
			if `i' == 6  local current_main_controls "`c_inst' `c_img'" 
			if `i' == 7  local current_main_controls "`c_inst' `c_img' `c_prv'" 
			if `i' == 8  local current_main_controls "`c_inst' `c_prv'" 
			
			display as result "`i'" _col(10) "`current_main_controls'"
		}
		display as text "{hline 80}"
	}
	
	display as result "DIAGNOSIS COMPLETE"

end


** On Sub-Samples based on the Low/High of ImageConcenrnBinary X Privacy **

cap program drop outcome_divby_img_prv_tbl_Noctrl
program define outcome_divby_img_prv_tbl_Noctrl
    syntax, outcome(varname) imageconcenrn_binary(varname) [if_condition(string)]
    
    preserve
    keep if !missing(`outcome')
    if "`if_condition'" != "" {
        keep `if_condition'
    }

    local tbl_title "Regression of '`outcome'' (No Controls) on Sub-Samples"
    local fname "`outcome'_NoControl"
    
    if "`if_condition'" == "if Finished == 1" {
        local tbl_title "Regression of `outcome' (No Controls) on Sub-Samples $|$ Finished = 1"
        local fname "`outcome'_NoControl_finished"
    }
    
    capture mkdir "$output_folder/outcome_table"
    local outdir "$output_folder/outcome_table/div_by_img_prv_insta"
    capture mkdir "`outdir'"
    
    local three_arms AI_x_Anon NoAI_x_Iden AI_x_Iden 
    local models_to_tab ""
    
    local cond1 "`imageconcenrn_binary' == 0 & not_shared_handle == 0"
    local labs1 "Low Low Yes"
    local cond2 "`imageconcenrn_binary' == 1 & not_shared_handle == 0"
    local labs2 "High Low Yes"
    local cond3 "`imageconcenrn_binary' == 1 & not_shared_handle == 1"
    local labs3 "High High Yes"
    local cond4 "`imageconcenrn_binary' == 0 & not_shared_handle == 1"
    local labs4 "Low High Yes"

    forvalues i = 1/4 {
        quietly count if `cond`i''
        local N_obs = r(N)
        tokenize `"`labs`i''"'
        local lbl_img "`1'"
        local lbl_prv  "`2'"
        local lbl_insta  "`3'"
        local nice_N : display %9.0fc `N_obs'

        if `N_obs' > 10 {
            capture eststo est`i': reghdfe `outcome' `three_arms' i.Instagram_use if `cond`i'', vce(robust) 

            if _rc == 0 {
                estadd local imgconcern "`lbl_img'", replace
                estadd local privacy "`lbl_prv'", replace
                estadd local insta "`lbl_insta'", replace
                estadd local samplesize "`nice_N'", replace
                local models_to_tab "`models_to_tab' est`i'"
            }
        }
    }   
    
    local cond5 "`imageconcenrn_binary' == 0 & not_shared_handle == 0"
    local labs5 "Low Low No"
    local cond6 "`imageconcenrn_binary' == 1 & not_shared_handle == 0"
    local labs6 "High Low No"
    local cond7 "`imageconcenrn_binary' == 1 & not_shared_handle == 1"
    local labs7 "High High No"
    local cond8 "`imageconcenrn_binary' == 0 & not_shared_handle == 1"
    local labs8 "Low High No"

    forvalues i = 5/8 {
        quietly count if `cond`i''
        local N_obs = r(N)
        tokenize `"`labs`i''"'
        local lbl_img "`1'"
        local lbl_prv  "`2'"
        local lbl_insta  "`3'"
        local nice_N : display %9.0fc `N_obs'

        if `N_obs' > 10 {
            capture eststo est`i': reghdfe `outcome' `three_arms' if `cond`i'', vce(robust) 
            
            if _rc == 0 {
                estadd local imgconcern "`lbl_img'", replace
                estadd local privacy "`lbl_prv'", replace
                estadd local insta "`lbl_insta'", replace
                estadd local samplesize "`nice_N'", replace
                local models_to_tab "`models_to_tab' est`i'"
            }
        }
    }

    esttab `models_to_tab' using "`outdir'/`fname'.tex", replace ///
        main(b %9.3f) aux(se %9.3f) ///
        starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
        keep(_cons AI_x_Anon NoAI_x_Iden AI_x_Iden *) ///
        order(_cons AI_x_Anon NoAI_x_Iden AI_x_Iden) ///
        coeflabels(_cons "NoAI_x_Anon") ///
        stats(r2_a imgconcern privacy insta samplesize, ///
            labels("Adj. \(R^2\)" "Image Concern" "Privacy Concern" "Inst Use Control" "\(N\)")) ///
        nomtitles ///
        title("`tbl_title'") nonotes ///
        booktabs compress width(\hsize) ///
        prehead(`"\documentclass{article}"' ///
                `"\usepackage{booktabs}"' ///
                `"\usepackage[paperheight=8in, paperwidth=9in, margin=0.5in]{geometry}"' ///
                `"\begin{document}"' ///
                `"\begin{table}[htbp]\centering"' ///
                `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
                `"\caption{@title}"' ///
                `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                `"\toprule"') ///
        postfoot(`"\bottomrule"' ///
                 `"\end{tabular*}"' ///
                 `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"' ///
                 `"\textbf{Note:} The reference group (NoAI x NotIden) is represented by the intercept. \\"' ///
                 `"Standard errors in parentheses. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$."' ///
                 `"\end{minipage}"' ///
                 `"\end{table}"' ///
                 `"\end{document}"')
    restore
end

capture program drop outcome_divby_img_prv_tbl_Lasso
program define outcome_divby_img_prv_tbl_Lasso
    syntax, outcome(varname) imageconcenrn_binary(varname) standardize(integer) [if_condition(string)]
    
    preserve
    quietly keep if !missing(`outcome')
    if "`if_condition'" != "" {
        keep `if_condition'
    }
    
    local tbl_title "Regression of `outcome' (Lasso Controls) by Subgroups"
    
    if `standardize' {
        local fname "`outcome'_Lasso_standardized"
    }
    else {
        local fname "`outcome'_Lasso"
    }
    
    if "`if_condition'" == "if Finished == 1" {
        local tbl_title "Regression of `outcome' (Lasso Controls) $|$ Finished = 1"
        if `standardize' {
            local fname "`outcome'_Lasso_standardized_finished"
        }
        else {
            local fname "`outcome'_Lasso_finished"
        }
    }
    
    capture mkdir "$output_folder/outcome_table"
    local outdir "$output_folder/outcome_table/div_by_img_prv_insta"
    capture mkdir "`outdir'"
    
    local three_arms AI_x_Anon NoAI_x_Iden AI_x_Iden 
    
    local forced_base ""
    
    if "`outcome'" == "PostTextLength"           local forced_base "BaseTextLength"
    else if "`outcome'" == "PostTextLength_log"  local forced_base "BaseTextLength_log"
    else if "`outcome'" == "grammatical_mistakes" local forced_base "Base_grammatical_mistakes"
    else if "`outcome'" == "Meaningful_post"     local forced_base "i.Meaningful_base"
    else {
        capture confirm variable Base_`outcome'
        if !_rc local forced_base "i.Base_`outcome'"
    }
    
    // -------------------------------------------------------
    // Lasso Selection
    // -------------------------------------------------------
	
    local lasso_cands "$CONTROLS_CONT_NOFACTOR"
    local manual_excludes "Instagram_use ImageConcern not_shared_handle `imageconcenrn_binary'"   
    * Add Categorical Vars (with i. prefix)
    foreach v of global CONTROLS_CAT_NOFACTOR {
        local is_manual = (strpos("`manual_excludes'", "`v'") > 0)
        if `is_manual' == 0 {
            local lasso_cands "`lasso_cands' i.`v'"
        }
    }

    local is_binary = (strpos("$OUTCOMES_BIN", " `outcome' ") > 0)
    local controls_lasso_sel ""
    
    if `is_binary' {
        capture quietly lasso logit `outcome' `lasso_cands', selection(plugin)
        if _rc == 0 {
            local controls_lasso_sel "`e(allvars_sel)'"
        }
    }
    else {
        capture quietly lasso linear `outcome' `lasso_cands', selection(plugin)
        if _rc == 0 {
            local controls_lasso_sel "`e(allvars_sel)'"
        }
    }
    
    * Standardize ONLY Continuous
	
    local controls_lasso_final ""
    
    foreach v of local controls_lasso_sel {
		* Spaces are necessary to prevent mismatches
        local is_cont = (strpos(" $CONTROLS_CONT_NOFACTOR ", " `v' ") > 0)

        if `is_cont' {
            if `standardize' == 1 {
                capture drop `v'_S
                quietly summarize `v'
                if r(sd) > 0 & r(sd) < . {
                    gen `v'_S = (`v' - r(mean)) / r(sd)
                    local controls_lasso_final "`controls_lasso_final' `v'_S"
                }
                else {
                     local controls_lasso_final "`controls_lasso_final' `v'"
                }
            }
            else {
                local controls_lasso_final "`controls_lasso_final' `v'" 
            }
        }
        else {
            local controls_lasso_final "`controls_lasso_final' `v'"
        }
    }
    
    // -------------------------------------------------------
    // Run Models on Subgroups
    // -------------------------------------------------------
    local models_to_tab ""
    
    * Define Conditions
    local cond1 "`imageconcenrn_binary' == 0 & not_shared_handle == 0"
    local labs1 "Low Low Yes"
    local cond2 "`imageconcenrn_binary' == 1 & not_shared_handle == 0"
    local labs2 "High Low Yes"
    local cond3 "`imageconcenrn_binary' == 1 & not_shared_handle == 1"
    local labs3 "High High Yes"
    local cond4 "`imageconcenrn_binary' == 0 & not_shared_handle == 1"
    local labs4 "Low High Yes"
    
    local cond5 "`imageconcenrn_binary' == 0 & not_shared_handle == 0"
    local labs5 "Low Low No"
    local cond6 "`imageconcenrn_binary' == 1 & not_shared_handle == 0"
    local labs6 "High Low No"
    local cond7 "`imageconcenrn_binary' == 1 & not_shared_handle == 1"
    local labs7 "High High No"
    local cond8 "`imageconcenrn_binary' == 0 & not_shared_handle == 1"
    local labs8 "Low High No"

    * First 4 models: Include Instagram_use as specific control
    * Note: Instagram_use is categorical in globals. We DO NOT standardize it.
    
    forvalues i = 1/4 {
        quietly count if `cond`i''
        local N_obs = r(N)
        tokenize `"`labs`i''"'
        local lbl_img "`1'"
        local lbl_prv  "`2'"
        local lbl_insta  "`3'"
        local nice_N : display %9.0fc `N_obs'

        if `N_obs' > 10 {
            capture eststo est`i': reghdfe `outcome' `three_arms' i.Instagram_use `controls_lasso_final' `forced_base' if `cond`i'', vce(robust) 
            
            if _rc == 0 {
                estadd local imgconcern "`lbl_img'", replace
                estadd local privacy "`lbl_prv'", replace
                estadd local insta "`lbl_insta'", replace
                estadd local samplesize "`nice_N'", replace
                local models_to_tab "`models_to_tab' est`i'"
            }
        }
    }   
    
    * Next 4 models: No Instagram_use control
    forvalues i = 5/8 {
        quietly count if `cond`i''
        local N_obs = r(N)
        tokenize `"`labs`i''"'
        local lbl_img "`1'"
        local lbl_prv  "`2'"
        local lbl_insta  "`3'"
        local nice_N : display %9.0fc `N_obs'

        if `N_obs' > 10 {
            capture eststo est`i': reghdfe `outcome' `three_arms' `controls_lasso_final' `forced_base' if `cond`i'', vce(robust) 
            
            if _rc == 0 {
                estadd local imgconcern "`lbl_img'", replace
                estadd local privacy "`lbl_prv'", replace
                estadd local insta "`lbl_insta'", replace
                estadd local samplesize "`nice_N'", replace
                local models_to_tab "`models_to_tab' est`i'"
            }
        }
    }

    
    esttab `models_to_tab' using "`outdir'/`fname'.tex", replace ///
        main(b %9.3f) aux(se %9.3f) ///
        starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
        keep(_cons AI_x_Anon NoAI_x_Iden AI_x_Iden *) ///
        order(_cons AI_x_Anon NoAI_x_Iden AI_x_Iden) ///
        coeflabels(_cons "NoAI_x_Anon") ///
        stats(r2_a imgconcern privacy insta samplesize, ///
            fmt(%9.3f 0 0 0 %9.0fc) ///
            labels("Adj. \(R^2\)" "Image Concern" "Privacy Concern" "Inst Use Control" "\(N\)")) ///
        nomtitles ///
        title("`tbl_title'") nonotes ///
        booktabs compress width(\hsize) ///
        prehead(`"\documentclass{article}"' ///
                `"\usepackage{booktabs}"' ///
                `"\usepackage[paperheight=13in, paperwidth=9in, margin=0.5in]{geometry}"' ///
                `"\begin{document}"' ///
                `"\begin{table}[htbp]\centering"' ///
                `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
                `"\caption{@title}"' ///
                `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                `"\toprule"') ///
        postfoot(`"\bottomrule"' ///
                 `"\end{tabular*}"' ///
                 `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"' ///
                 `"\textbf{Note:} The reference group (NoAI x NotIden) is represented by the intercept. \\"' ///
                 `"Standard errors in parentheses. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$."' ///
                 `"\end{minipage}"' ///
                 `"\end{table}"' ///
                 `"\end{document}"')
    restore
end

cap program drop lasso_diagnosis_controls3
program define lasso_diagnosis_controls3

	* ==============================================================================
	* DIAGNOSIS TEST: Program Logic Check (Lasso -> Subgroups)
	* ==============================================================================
	set more off
	cls
	
	* ------------------------------------------------------------------------------
	* USER SETTINGS: Simulate the arguments passed to the program
	* ------------------------------------------------------------------------------
	local standardize   = 1                       // 1 = Test Standardization, 0 = No
	local img_bin_var   "ImageConcern_binary"     // The variable passed as `imageconcenrn_binary`
	
	* ------------------------------------------------------------------------------
	* DIAGNOSIS EXECUTION
	* ------------------------------------------------------------------------------
	display as text "{hline 80}"
	display as result " RUNNING PROGRAM DIAGNOSIS"
	display as text " Standardization: " as result "`standardize'"
	display as text " Binary Split Var: " as result "`img_bin_var'"
	display as text "{hline 80}"
	
	foreach outcome in $OUTCOMES $TEXT_OUTCOMES {
		
		* -------------------------------------------------------
		* 1. LASSO CANDIDATES (Replicating Program Logic)
		* -------------------------------------------------------
		local lasso_cands "$CONTROLS_CONT_NOFACTOR"
		
		* The program excludes these specific variables from the Lasso pool
		local manual_excludes "Instagram_use ImageConcern not_shared_handle `img_bin_var'"    
		
		foreach v of global CONTROLS_CAT_NOFACTOR {
			local is_manual = (strpos("`manual_excludes'", "`v'") > 0)
			if `is_manual' == 0 {
				local lasso_cands "`lasso_cands' i.`v'"
			}
		}
	
		* -------------------------------------------------------
		* 2. LASSO SELECTION (Simulation)
		* -------------------------------------------------------
		local is_binary = (strpos(" $OUTCOMES_BIN ", " `outcome' ") > 0)
		local controls_lasso_sel "INVALID/SKIPPED (N<20 or Error)"
		local type_str ""
		
		quietly count if !missing(`outcome')
		if r(N) >= 20 {
			if `is_binary' {
				local type_str "Logit"
				capture quietly lasso logit `outcome' `lasso_cands', selection(plugin)
				if _rc == 0 local controls_lasso_sel "`e(allvars_sel)'"
				else        local controls_lasso_sel "ERROR in Lasso Logit"
			}
			else {
				local type_str "Linear"
				capture quietly lasso linear `outcome' `lasso_cands', selection(plugin)
				if _rc == 0 local controls_lasso_sel "`e(allvars_sel)'"
				else        local controls_lasso_sel "ERROR in Lasso Linear"
			}
		}
	
		* -------------------------------------------------------
		* 3. FINAL FORMATTING (Standardization + Prefixing)
		* -------------------------------------------------------
		local controls_lasso_final ""
		
		if substr("`controls_lasso_sel'", 1, 5) != "ERROR" & "`controls_lasso_sel'" != "INVALID/SKIPPED (N<20 or Error)" {
			
			foreach v of local controls_lasso_sel {
				
				* Double Padding Check
				local is_cont = (strpos(" $CONTROLS_CONT_NOFACTOR ", " `v' ") > 0)
	
				if `is_cont' {
					if `standardize' == 1 {
						capture drop `v'_N
						quietly summarize `v'
						if r(sd) > 0 & r(sd) < . {
							quietly gen `v'_N = (`v' - r(mean)) / r(sd)
							local controls_lasso_final "`controls_lasso_final' `v'_N"
						}
						else {
							* Fallback if variance is 0
							local controls_lasso_final "`controls_lasso_final' `v'"
						}
					}
					else {
						local controls_lasso_final "`controls_lasso_final' `v'" 
					}
				}
				else {
					local controls_lasso_final "`controls_lasso_final' `v'"
				}
			}
		}
		
		* -------------------------------------------------------
		* 4. OUTPUT DISPLAY
		* -------------------------------------------------------
		display as text "Outcome: "  _col(20) as result "`outcome'" " (`type_str')"
		display as text "Manual Excludes: " _col(20) as result "`manual_excludes'"
		display as text "Lasso Candidates:" 
		display as result "`lasso_cands'"
		display ""
		display as text "Lasso Selected (Raw):" 
		display as result "`controls_lasso_sel'"
		display ""
		display as text "Lasso Final (Formatted):" 
		display as result "`controls_lasso_final'"
		display as text "{hline 50}"
	}
	
	display as result "DIAGNOSIS COMPLETE"

end

*/


* --- HTE ---

/*
* Table: With interaction
capture program drop hte_table_generator0
program define hte_table_generator0

    syntax, outcome(varname) imgconcern_control(varname) moderator(varname) sample_number(integer) sample_label(string) [if_condition(string)]
    
    preserve
    quietly keep if sample`sample_number' == 1 & !missing(`outcome')
    if "`if_condition'" != "" {
        keep `if_condition'
    }
    
    local tbl_title "HTE: `outcome' by `moderator' (`sample_label')"
    local fname "`outcome'_hte_by_`moderator'_table"
	
    if "`if_condition'" == "if Finished == 1" {
        local tbl_title "HTE: `outcome' by `moderator' (`sample_label') $|$ Finished = 1"
		local fname "`outcome'_hte_by_`moderator'_table_finished"

    }	
	
	capture mkdir "$output_folder/hte"
    capture mkdir "$output_folder/hte/hte_table_with_interaction"
    local outdir "$output_folder/hte/hte_table_with_interaction/sample`sample_number'"
    capture mkdir "`outdir'"
    

	*******************************************************
    * 1. Dynamic Variable Removal (Avoid Collinearity)    *
    *******************************************************
	* Over-inclusion of variables with similar information is safe because Stata's list subtraction operator ("-") ignores variables that are not present in the Control list.
	
    eststo clear

    local VARS_TO_REMOVE ""

    * --- Insta, ImageConcern, and Privacy ---
	
    if strpos("`moderator'", "Instagram_use") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Instagram_use"
    }
    if strpos("`moderator'", "not_shared_handle") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' not_shared_handle index_Image_minus_privacy Image_minus_privacyBinary"
    }
    if strpos("`moderator'", "ImageConcern") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern ImageConcernBinary_p50 ImageConcernBinary2 ImageConcernBinary3 ImageConcernBinary4 index_Image_minus_privacy Image_minus_privacyBinary"
    }
    if strpos("`moderator'", "Image_minus_privacy") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern ImageConcernBinary_p50 ImageConcernBinary2 ImageConcernBinary3 ImageConcernBinary4 index_Image_minus_privacy Image_minus_privacyBinary not_shared_handle"
    }

    * --- Demographics ---
    if strpos("`moderator'", "Grad_degree") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Grad_degree"
    }
    if strpos("`moderator'", "Vote") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Vote"
    }
    if strpos("`moderator'", "Switzerland") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Switzerland"
    }
    if strpos("`moderator'", "Female") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Female"
    }
    if strpos("`moderator'", "ETH") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ETH"
    }
    if strpos("`moderator'", "Age") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Age AgeBinary_p50 AgeBinary_adult"
    }
	

    * --- Other Controls ---

    if strpos("`moderator'", "index_Climate") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' index_Climate index_ClimateBinary ClimateWorry ClimatePersonal"
    }
    if strpos("`moderator'", "Donation") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Donation DonationBinary_p50 DonationBinary_pos"
    }
    if strpos("`moderator'", "BotKnow") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotKnow BotKnowBinary"
    }
    if strpos("`moderator'", "AIEffective") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' InitialAIEffective AIEffectiveBinary"
    }
    if strpos("`moderator'", "AIDiff") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BaseAIDiff AIDiffBinary"
    }

    if strpos("`moderator'", "BotSupport") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotSupport_AI BotSupport_AIBinary BotSupport_AI"
    }
    if strpos("`moderator'", "BotSocialMedia") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotSocialMedia_AI BotSocialMedia_AIBinary BotSocialMedia_AI"
    }
	* For now, I assumed they are highly colinear.
    if strpos("`moderator'", "React") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ReadingReact1 ReadingReact1Binary ReadingReact2  ReadingReact2Binary PostReact PostReactBinary"
    }
    if strpos("`moderator'", "Guess") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' GuessWriterHuman GuessWriterAI GuessHuman_asHuman GuessAI_asHuman"
    }

    * --- Base Text Controls ---
	* Right now, we don't run HTE for the $BASE_TEXT_CONTROLS. For that case, removing them is not enough since we are adding back the "local forced_base" in the following section. It needs more complex dynamic removal.
    
    * Just in case we miss them above
    local VARS_TO_REMOVE "`VARS_TO_REMOVE' `moderator'"

    * TO ensures that removing "VAR" also removes "i.VAR"
    local VARS_TO_REMOVE_EXPANDED "`VARS_TO_REMOVE'"
    foreach var in `VARS_TO_REMOVE' {
        local VARS_TO_REMOVE_EXPANDED "`VARS_TO_REMOVE_EXPANDED' i.`var'"
    }

    
    *******************************************************
    * 2. Define Control Sets                              *
    *******************************************************
	* Identify Specific Base Control
	
	local forced_base ""
    
    * Explicit Mappings
    if "`outcome'" == "PostTextLength"      local forced_base "BaseTextLength"
    else if "`outcome'" == "PostTextLength_log"  local forced_base "BaseTextLength_log"
	else if "`outcome'" == "grammatical_mistakes" local forced_base "Base_grammatical_mistakes"
	else if "`outcome'" == "Meaningful_post"     local forced_base "i.Meaningful_base"
    
    * Default Mapping: Check if Base_Outcome exists
    else {
        capture confirm variable Base_`outcome'
        if !_rc local forced_base "i.Base_`outcome'"
    }
	
    * -- C1: No Controls  --
	
    * -- C2: Base Controls (ImageConcern, Privacy, Insta) --
	
	local base_vars "i.`imgconcern_control' i.not_shared_handle i.Instagram_use"
    if "`VARS_TO_REMOVE_EXPANDED'" != "" {
        local base_vars : list base_vars - VARS_TO_REMOVE_EXPANDED
    }

    * -- C3: Base + Demographics --
    local col3_controls "i.`imgconcern_control' i.not_shared_handle i.Instagram_use $DEMOG"
    if "`VARS_TO_REMOVE_EXPANDED'" != "" {
        local col3_controls : list col3_controls - VARS_TO_REMOVE_EXPANDED
    }
 
    * -- C4: Lasso Selection --
    
    
	local lasso_cands "$CONTROLS `forced_base'"
    if "`VARS_TO_REMOVE_EXPANDED'" != "" {
        local lasso_cands : list lasso_cands - VARS_TO_REMOVE_EXPANDED
    }
    
    local col4_controls ""
    
    if (strpos("$OUTCOMES_BIN", "`outcome'") > 0) {
	    capture quietly lasso logit `outcome' `lasso_cands', selection("cv")
	}
	
	else {
	    capture quietly lasso linear `outcome' `lasso_cands', selection("cv")
	}
	
	if _rc == 0 {
	    local col4_controls "`e(allvars_sel)'"
		}



	*******************************************************
    * 3. Run Regressions                                  *
    *******************************************************

    local models_to_tab ""
    local dynamic_mtitles ""

    * -- Model 1: No Controls --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator', vce(robust)
    if _rc == 0 {
        eststo model1
        local models_to_tab "`models_to_tab' model1"
        local dynamic_mtitles "`dynamic_mtitles' "No Controls""
    }
    
    * -- Model 2: Base Controls --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator' `base_vars' `forced_base', vce(robust)
    if _rc == 0 {
        eststo model2
        local models_to_tab "`models_to_tab' model2"
        local dynamic_mtitles "`dynamic_mtitles' "Basic Controls""
    }
    
    * -- Model 3: Base + Demog --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator' `col3_controls' `forced_base', vce(robust)
    if _rc == 0 {
        eststo model3
        local models_to_tab "`models_to_tab' model3"
        local dynamic_mtitles "`dynamic_mtitles' "Basic and Demographics""
    }
    
    * -- Model 4: Lasso --
	capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator' `col4_controls', vce(robust)
	if _rc == 0 {
			eststo model4
			local models_to_tab "`models_to_tab' model4"
			local dynamic_mtitles "`dynamic_mtitles' "Lasso-Selected""
		}
	

	*******************************************************
    * 4. Export Table                                     *
    *******************************************************

    if "`models_to_tab'" != "" {
        esttab `models_to_tab' using "`outdir'/`fname'.tex", replace ///
            main(b %9.3f) aux(se %9.3f) ///
            starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
            nobase noomit ///
            order(_cons 1.AITreat 1.Identify ///
                  1.AITreat#1.Identify ///
				  `moderator' ///
                  1.AITreat#c.`moderator' ///
                  1.Identify#c.`moderator' ///
                  1.AITreat#1.Identify#c.`moderator') ///
            coeflabels(_cons "Intercept" ///
                       1.AITreat "AI Treat" ///
                       1.Identify "Identified Treat" ///
                       1.AITreat#1.Identify "AI $\times$ Identified" ///
					   `moderator' "`moderator'" ///
                       1.AITreat#c.`moderator' "AI $\times$ `moderator'" ///
                       1.Identify#c.`moderator' "Identified $\times$ `moderator'" ///
                       1.AITreat#1.Identify#c.`moderator' "AI $\times$ Identified $\times$ `moderator'") ///
            stats(r2_a N, fmt(%9.3f %9.0fc) labels("Adj. \(R^2\)" "\(N\)")) ///
            mtitles(`dynamic_mtitles') ///
            title("`tbl_title'") nonotes /// 
            booktabs compress width(\hsize) ///
            prehead(`"\documentclass{article}"' ///
                    `"\usepackage{booktabs}"' ///
                    `"\usepackage[paperheight=18in, paperwidth=10in, margin=0.5in]{geometry}"' ///
                    `"\begin{document}"' ///
                    `"\begin{table}[htbp]\centering"' ///
                    `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
                    `"\caption{@title}"' ///
                    `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                    `"\toprule"') ///
            postfoot(`"\bottomrule"' ///
                     `"\end{tabular*}"' ///
                     `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"' ///
                     `"Standard errors in parentheses. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$."' ///
                     `"\\ Base Controls: Image Concern, Privacy Concern, Instagram Use."' ///
                     `"\\ Demographics: Grad degree, Vote, Age, ETH, Switzerland, Female."' ///
                     `"\\ Lasso selects from all available controls."' ///
                     `"\end{minipage}"' ///
                     `"\end{table}"' ///
                     `"\end{document}"')
    }
    else {
        display "No models were successfully estimated for `outcome' by `moderator' in sample `sample_number'."
    }
	
    restore

end

capture program drop hte_table_generator1
program define hte_table_generator1

    syntax, outcome(varname) moderator(varname) sample_number(integer) slabel(string) sname(string) [if_condition(string)]
    
    preserve
    quietly keep if sample`sample_number' == 1 & !missing(`outcome')
    if "`if_condition'" != "" {
        keep `if_condition'
    }

    // -------------------------------------------------------
    // 0. Nice Names & Dynamic Labels
    // -------------------------------------------------------
    nice_name_as_label

    local ytitle : variable label `outcome'
    if "`ytitle'" == "" {
        local ytitle "`outcome'"
    }

    // Moderator label (from variable label, overridden below)
    local moderator_lbl : variable label `moderator'
    if "`moderator_lbl'" == "" {
        local moderator_lbl "`moderator'"
    }

    * --- Median-split variables ---
    if "`moderator'" == "index_ClimateBinary" {
        local moderator_lbl "Climate Concern (Binary)"
    }
    if "`moderator'" == "DonationBinary_p50" {
        local moderator_lbl "Donation (Binary)"
    }
    if "`moderator'" == "DonationBinary_pos" {
        local moderator_lbl "Donated (Binary)"
    }
    if "`moderator'" == "ImageConcernBinary_p50" {
        local moderator_lbl "Image Concern (Binary)"
    }
    if "`moderator'" == "AgeBinary_p50" {
        local moderator_lbl "Age (Binary: 18-23 vs 24+)"
    }
    if "`moderator'" == "Image_minus_privacyBinary" {
        local moderator_lbl "Image - Disclosure (Binary)"
    }

    * --- Threshold-split variables ---
    if "`moderator'" == "AIDiffBinary" {
        local moderator_lbl "Different from AI Writing (Binary)"
    }
    if "`moderator'" == "ImageConcernBinary2" {
        local moderator_lbl "Image Concern $\geq$ 2"
    }
    if "`moderator'" == "ImageConcernBinary3" {
        local moderator_lbl "Image Concern $\geq$ 3"
    }
    if "`moderator'" == "ImageConcernBinary4" {
        local moderator_lbl "Image Concern $\geq$ 4"
    }
    if "`moderator'" == "AgeBinary_adult" {
        local moderator_lbl "Age (Binary: 18-24 vs 25+)"
    }
    if "`moderator'" == "BotKnowBinary" {
        local moderator_lbl "Frequent AI User (Binary)"
    }
    if "`moderator'" == "AIEffectiveBinary" {
        local moderator_lbl "AI Persuasion Belief (Binary)"
    }
    if "`moderator'" == "BotSupport_AIBinary" {
        local moderator_lbl "Prefers AI Customer Support (Binary)"
    }
    if "`moderator'" == "BotSocialMedia_AIBinary" {
        local moderator_lbl "Prefers AI on Social Media (Binary)"
    }
    if "`moderator'" == "Instagram_use" {
        local moderator_lbl "Instagram User"
    }
    if "`moderator'" == "Grad_degree" {
        local moderator_lbl "Graduate Degree"
    }
    if "`moderator'" == "Vote" {
        local moderator_lbl "Voted"
    }
    if "`moderator'" == "Switzerland" {
        local moderator_lbl "Swiss"
    }
    if "`moderator'" == "Female" {
        local moderator_lbl "Female"
    }
    if "`moderator'" == "ETH" {
        local moderator_lbl "ETH"
    }

    * --- Reaction variables ---
    if "`moderator'" == "ReadingReact1Binary" {
        local moderator_lbl "Reacted to Human Content"
    }
    if "`moderator'" == "ReadingReact2Binary" {
        local moderator_lbl "Reacted to Pool Content"
    }
    if "`moderator'" == "PostReactBinary" {
        local moderator_lbl "Reacted to (Human) Post"
    }

    * --- Guess variables ---
    if "`moderator'" == "GuessHuman_asHuman" {
        local moderator_lbl "Guessed Human as Human"
    }
    if "`moderator'" == "GuessAI_asHuman" {
        local moderator_lbl "Guessed AI as Human"
    }

    * --- Ordinal / Continuous moderators (used in $HTE_MODERATORS_TABLE) ---
    if "`moderator'" == "index_Climate" {
        local moderator_lbl "Climate Concern Index"
    }
    if "`moderator'" == "Donation" {
        local moderator_lbl "Donation Amount"
    }
    if "`moderator'" == "BaseAIDiff" {
        local moderator_lbl "Perceived Difference from AI"
    }
    if "`moderator'" == "ImageConcern" {
        local moderator_lbl "Image Concern"
    }
    if "`moderator'" == "not_shared_handle" {
        local moderator_lbl "Did Not Share Handle"
    }
    if "`moderator'" == "Age" {
        local moderator_lbl "Age"
    }
    if "`moderator'" == "BotKnow" {
        local moderator_lbl "AI Familiarity"
    }
    if "`moderator'" == "InitialAIEffective" {
        local moderator_lbl "AI Persuasion Belief"
    }
    if "`moderator'" == "BotSupport_AI" {
        local moderator_lbl "Pref. AI Customer Support"
    }
    if "`moderator'" == "BotSocialMedia_AI" {
        local moderator_lbl "Pref. AI Social Media"
    }
    if "`moderator'" == "index_Image_minus_privacy" {
        local moderator_lbl "Image - Disclosure Index"
    }
    if "`moderator'" == "ReadingReact1" {
        local moderator_lbl "Reaction to Human Content"
    }
    if "`moderator'" == "ReadingReact2" {
        local moderator_lbl "Reaction to Pool Content"
    }
    if "`moderator'" == "GuessWriterHuman" {
        local moderator_lbl "Guessed Writer Human"
    }
    if "`moderator'" == "GuessWriterAI" {
        local moderator_lbl "Guessed Writer AI"
    }
    if "`moderator'" == "PostReact" {
        local moderator_lbl "Reaction to (Human) Post"
    }

    // -------------------------------------------------------
    // 1. Dynamic Title and Filetag
    // -------------------------------------------------------
    local tbl_title "HTE: `ytitle' by `moderator_lbl' (`slabel')"
    local fname "`outcome'_hte_by_`moderator'_`sname'_table"
	
    if "`if_condition'" == "if Finished == 1" {
        local tbl_title "HTE: `ytitle' by `moderator_lbl' (`slabel') $|$ Finished = 1"
        local fname "`outcome'_hte_by_`moderator'_`sname'_table_finished"
    }

    // Flat output directory (no sample subdirectory)
    capture mkdir "$output_folder/hte"
    capture mkdir "$output_folder/hte/hte_table_with_interaction"
    local outdir "$output_folder/hte/hte_table_with_interaction"

    // -------------------------------------------------------
    // 2. Dynamic Variable Removal (Avoid Collinearity)
    // -------------------------------------------------------
    eststo clear

    local VARS_TO_REMOVE ""

    * --- Insta, ImageConcern, and Privacy ---
    if strpos("`moderator'", "Instagram_use") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Instagram_use"
    }
    if strpos("`moderator'", "not_shared_handle") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' not_shared_handle index_Image_minus_privacy Image_minus_privacyBinary"
    }
    if strpos("`moderator'", "ImageConcern") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern ImageConcernBinary_p50 ImageConcernBinary2 ImageConcernBinary3 ImageConcernBinary4 index_Image_minus_privacy Image_minus_privacyBinary"
    }
    if strpos("`moderator'", "Image_minus_privacy") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern ImageConcernBinary_p50 ImageConcernBinary2 ImageConcernBinary3 ImageConcernBinary4 index_Image_minus_privacy Image_minus_privacyBinary not_shared_handle"
    }

    * --- Demographics ---
    if strpos("`moderator'", "Grad_degree") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Grad_degree"
    }
    if strpos("`moderator'", "Vote") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Vote"
    }
    if strpos("`moderator'", "Switzerland") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Switzerland"
    }
    if strpos("`moderator'", "Female") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Female"
    }
    if strpos("`moderator'", "ETH") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ETH"
    }
    if strpos("`moderator'", "Age") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Age AgeBinary_p50 AgeBinary_adult"
    }

    * --- Other Controls ---
    if strpos("`moderator'", "index_Climate") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' index_Climate index_ClimateBinary ClimateWorry ClimatePersonal"
    }
    if strpos("`moderator'", "Donation") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Donation DonationBinary_p50 DonationBinary_pos"
    }
    if strpos("`moderator'", "BotKnow") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotKnow BotKnowBinary"
    }
    if strpos("`moderator'", "AIEffective") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' InitialAIEffective AIEffectiveBinary"
    }
    if strpos("`moderator'", "AIDiff") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BaseAIDiff AIDiffBinary"
    }
    if strpos("`moderator'", "BotSupport") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotSupport_AI BotSupport_AIBinary"
    }
    if strpos("`moderator'", "BotSocialMedia") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotSocialMedia_AI BotSocialMedia_AIBinary"
    }
    if strpos("`moderator'", "React") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ReadingReact1 ReadingReact1Binary ReadingReact2 ReadingReact2Binary PostReact PostReactBinary"
    }
    if strpos("`moderator'", "Guess") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' GuessWriterHuman GuessWriterAI GuessHuman_asHuman GuessAI_asHuman"
    }

    * Just in case we miss them above
    local VARS_TO_REMOVE "`VARS_TO_REMOVE' `moderator'"

    * Ensure removing "VAR" also removes "i.VAR"
    local VARS_TO_REMOVE_EXPANDED "`VARS_TO_REMOVE'"
    foreach var in `VARS_TO_REMOVE' {
        local VARS_TO_REMOVE_EXPANDED "`VARS_TO_REMOVE_EXPANDED' i.`var'"
    }

    // -------------------------------------------------------
    // 3. Generic Post_ → Base_ Forced Base Mapping
    //    (from $BASE_TEXT_CONTROLS, like hte_ciplot_Lasso)
    // -------------------------------------------------------
    local forced_base ""
    
    if strpos("`outcome'", "Post_") == 1 {
        local suffix = substr("`outcome'", 6, .)
        foreach bvar of global BASE_TEXT_CONTROLS {
            if "`bvar'" == "Base_`suffix'" {
                local forced_base "`bvar'"
            }
        }
        if "`forced_base'" == "" {
            local suffix_l = lower("`suffix'")
            foreach bvar of global BASE_TEXT_CONTROLS {
                local bsuffix_l = lower(substr("`bvar'", 6, .))
                if strpos("`suffix_l'", "`bsuffix_l'") > 0 {
                    local forced_base "`bvar'"
                }
            }
        }
    }

    // Explicit overrides for non-Post_ outcomes that have known base controls
    if "`outcome'" == "PostTextLength"          local forced_base "BaseTextLength"
    else if "`outcome'" == "PostTextLength_log"  local forced_base "BaseTextLength_log"
    else if "`outcome'" == "grammatical_mistakes" local forced_base "Base_grammatical_mistakes"
    else if "`outcome'" == "Meaningful_post"     local forced_base "i.Meaningful_base"
    else {
        // Default fallback: check if Base_<outcome> exists (only if not already found)
        if "`forced_base'" == "" {
            capture confirm variable Base_`outcome'
            if !_rc local forced_base "i.Base_`outcome'"
        }
    }

    // -------------------------------------------------------
    // 4. Define Control Sets
    // -------------------------------------------------------

    * -- C1: No Controls --

    * -- C2: Base Controls (ImageConcern, Privacy, Insta) --
    local base_vars "i.ImageConcern i.not_shared_handle i.Instagram_use"
    if "`VARS_TO_REMOVE_EXPANDED'" != "" {
        local base_vars : list base_vars - VARS_TO_REMOVE_EXPANDED
    }

    * -- C3: Base + Demographics --
    local col3_controls "i.ImageConcern i.not_shared_handle i.Instagram_use $DEMOG"
    if "`VARS_TO_REMOVE_EXPANDED'" != "" {
        local col3_controls : list col3_controls - VARS_TO_REMOVE_EXPANDED
    }

    * -- C4: Lasso Selection (plugin, matching CI plot convention) --
    local lasso_cands "$CONTROLS `forced_base'"
    if "`VARS_TO_REMOVE_EXPANDED'" != "" {
        local lasso_cands : list lasso_cands - VARS_TO_REMOVE_EXPANDED
    }
    if trim("`lasso_cands'") == "" {
        local lasso_cands "i.Identify"
    }

    local is_bin = 0
    if strpos(" $OUTCOMES_BIN ", " `outcome' ") > 0 local is_bin = 1

    local col4_controls ""

    if `is_bin' {
        capture quietly lasso logit `outcome' `lasso_cands', selection(plugin)
    }
    else {
        capture quietly lasso linear `outcome' `lasso_cands', selection(plugin)
    }

    if _rc == 0 {
        local col4_controls "`e(allvars_sel)'"
    }

    // -------------------------------------------------------
    // 5. Run Regressions
    // -------------------------------------------------------
    local models_to_tab ""
    local dynamic_mtitles ""

    * -- Model 1: No Controls --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator', vce(robust)
    if _rc == 0 {
        eststo model1
        local models_to_tab "`models_to_tab' model1"
        local dynamic_mtitles "`dynamic_mtitles' "No Controls""
    }

    * -- Model 2: Base Controls --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator' `base_vars' `forced_base', vce(robust)
    if _rc == 0 {
        eststo model2
        local models_to_tab "`models_to_tab' model2"
        local dynamic_mtitles "`dynamic_mtitles' "Basic Controls""
    }

    * -- Model 3: Base + Demographics --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator' `col3_controls' `forced_base', vce(robust)
    if _rc == 0 {
        eststo model3
        local models_to_tab "`models_to_tab' model3"
        local dynamic_mtitles "`dynamic_mtitles' "Basic and Demographics""
    }

    * -- Model 4: Lasso-Selected --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator' `col4_controls', vce(robust)
    if _rc == 0 {
        eststo model4
        local models_to_tab "`models_to_tab' model4"
        local dynamic_mtitles "`dynamic_mtitles' "Lasso-Selected""
    }

    // -------------------------------------------------------
    // 6. Export Table
    // -------------------------------------------------------
    if "`models_to_tab'" != "" {
        esttab `models_to_tab' using "`outdir'/`fname'.tex", replace ///
            main(b %9.3f) aux(se %9.3f) ///
            starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
            nobase noomit ///
            order(_cons 1.AITreat 1.Identify ///
                  1.AITreat#1.Identify ///
                  `moderator' ///
                  1.AITreat#c.`moderator' ///
                  1.Identify#c.`moderator' ///
                  1.AITreat#1.Identify#c.`moderator') ///
            coeflabels(_cons "Intercept" ///
                       1.AITreat "AI Treat" ///
                       1.Identify "Identified Treat" ///
                       1.AITreat#1.Identify "AI $\times$ Identified" ///
                       `moderator' "`moderator_lbl'" ///
                       1.AITreat#c.`moderator' "AI $\times$ `moderator_lbl'" ///
                       1.Identify#c.`moderator' "Identified $\times$ `moderator_lbl'" ///
                       1.AITreat#1.Identify#c.`moderator' "AI $\times$ Identified $\times$ `moderator_lbl'") ///
            stats(r2_a N, fmt(%9.3f %9.0fc) labels("Adj. \(R^2\)" "\(N\)")) ///
            mtitles(`dynamic_mtitles') ///
            title("`tbl_title'") nonotes ///
            booktabs compress width(\hsize) ///
            prehead(`"\documentclass{article}"' ///
                    `"\usepackage{booktabs}"' ///
                    `"\usepackage[paperheight=18in, paperwidth=10in, margin=0.5in]{geometry}"' ///
                    `"\begin{document}"' ///
                    `"\begin{table}[htbp]\centering"' ///
                    `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' ///
                    `"\caption{@title}"' ///
                    `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                    `"\toprule"') ///
            postfoot(`"\bottomrule"' ///
                     `"\end{tabular*}"' ///
                     `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"' ///
                     `"Standard errors in parentheses. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$."' ///
                     `"\\ Base Controls: Image Concern, Privacy Concern, Instagram Use."' ///
                     `"\\ Demographics: Grad degree, Vote, Age, ETH, Switzerland, Female."' ///
                     `"\\ Lasso selects from all available controls (plugin)."' ///
                     `"\end{minipage}"' ///
                     `"\end{table}"' ///
                     `"\end{document}"')
    }
    else {
        display "No models were successfully estimated for `outcome' by `moderator' in `slabel'."
    }

    restore

end

capture program drop hte_table_generator
program define hte_table_generator

    syntax, outcome(varname) moderator(varname) sample_number(integer) slabel(string) sname(string) [if_condition(string)]

    // -------------------------------------------------------
    // 0. Column Header Labels (edit here to rename columns)
    // -------------------------------------------------------
    local col1_title "No Controls"
    local col2_title "Focal Behavioral Controls"
    local col3_title "All Behavioral Controls"
    local col4_title "Full Controls"

    // -------------------------------------------------------
    // 1. Control Variable Lists (all binary, no i. prefix)
    //    VARS_TO_REMOVE subtracts collinear vars below.
    //    forced_base (Post_* outcomes) appended only to C4.
    // -------------------------------------------------------
    local c2_controls "Instagram_use ImageConcernBinary_p50 not_shared_handle"
    local c3_controls "Instagram_use ImageConcernBinary_p50 not_shared_handle DonationBinary_pos BotKnowBinary AIEffectiveBinary AIDiffBinary ReadingReact1Binary ReadingReact2Binary GuessHuman_asHuman GuessAI_asHuman PostReactBinary BotSupport_AIBinary BotSocialMedia_AIBinary"
    local c4_controls "Instagram_use ImageConcernBinary_p50 not_shared_handle DonationBinary_pos BotKnowBinary AIEffectiveBinary AIDiffBinary ReadingReact1Binary ReadingReact2Binary GuessHuman_asHuman GuessAI_asHuman PostReactBinary BotSupport_AIBinary BotSocialMedia_AIBinary AgeBinary_adult Female Switzerland Grad_degree ETH Vote"

    // -------------------------------------------------------
    // 2. Setup: Sample + Condition Filter
    // -------------------------------------------------------
    preserve
    quietly keep if sample`sample_number' == 1 & !missing(`outcome')
    if "`if_condition'" != "" {
        keep `if_condition'
    }

    // -------------------------------------------------------
    // 3. Nice Names + Table-Specific Label Overrides
    // -------------------------------------------------------
    nice_name_as_label

    capture label variable ImageConcernBinary_p50    "Image Concern"
    capture label variable index_ClimateBinary       "Climate Concern"
    capture label variable DonationBinary_p50        "Donated"
    capture label variable AIDiffBinary              "Writing Differently From AI"
    capture label variable Image_minus_privacyBinary "(Image - Disclosure) Index"

    local ytitle : variable label `outcome'
    if "`ytitle'" == "" local ytitle "`outcome'"


	// -------------------------------------------------------
    // 4. Moderator Label
    //    nice_name_as_label handles most variables. Only
    //    manual overrides for labels that differ from it.
    // -------------------------------------------------------
	
    local moderator_lbl : variable label `moderator'
    if "`moderator_lbl'" == "" local moderator_lbl "`moderator'"

    * --- Manual overrides (shorter/cleaner than nice_name_as_label) ---
    if "`moderator'" == "Donation"           local moderator_lbl "Donation"
    if "`moderator'" == "BaseAIDiff"         local moderator_lbl "Perceived Difference from AI"
    if "`moderator'" == "ImageConcern"       local moderator_lbl "Image Concern"
    if "`moderator'" == "Vote"               local moderator_lbl "Voted"
    if "`moderator'" == "Female"             local moderator_lbl "Gender (Female)"
    if "`moderator'" == "BotKnow"            local moderator_lbl "AI Familiarity"
    if "`moderator'" == "InitialAIEffective" local moderator_lbl "AI Persuasion"
    if "`moderator'" == "BotSupport_AI"      local moderator_lbl "Customer Support Bot"
    if "`moderator'" == "BotSocialMedia_AI"  local moderator_lbl "Social Media Bot"
	
	
    // -------------------------------------------------------
    // 5. Title and Filename
    // -------------------------------------------------------
    local tbl_title "HTE: `ytitle' by `moderator_lbl' - `slabel'"
    local fname "table_`outcome'_hte_by_`moderator'_`sname'"

    if "`if_condition'" == "if Finished == 1" {
        local tbl_title "HTE: `ytitle' by `moderator_lbl' - `slabel', Finished"
        local fname "table_`outcome'_hte_by_`moderator'_`sname'_finished"
    }

    capture mkdir "$output_folder/hte"
    capture mkdir "$output_folder/hte/hte_table_with_interaction"
    local outdir "$output_folder/hte/hte_table_with_interaction"

    // -------------------------------------------------------
    // 6. Dynamic Variable Removal (Avoid Collinearity)
    //    Removes all variables that share information with
    //    the moderator from C2/C3/C4 control sets.
    // -------------------------------------------------------
    eststo clear
    local VARS_TO_REMOVE ""

    * --- Instagram ---
    if strpos("`moderator'", "Instagram_use") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Instagram_use"
    }

    * --- Privacy (not_shared_handle and its derived index) ---
    if strpos("`moderator'", "not_shared_handle") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' not_shared_handle index_Image_minus_privacy Image_minus_privacyBinary"
    }

    * --- ImageConcern and all derived variables ---
    *     index_Image_minus_privacy is also derived from ImageConcern
    if strpos("`moderator'", "ImageConcern") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern ImageConcernBinary_p50 ImageConcernBinary2 ImageConcernBinary3 ImageConcernBinary4 index_Image_minus_privacy Image_minus_privacyBinary"
    }

    * --- Image_minus_privacy: derived from both ImageConcern and not_shared_handle ---
    if strpos("`moderator'", "Image_minus_privacy") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern ImageConcernBinary_p50 ImageConcernBinary2 ImageConcernBinary3 ImageConcernBinary4 index_Image_minus_privacy Image_minus_privacyBinary not_shared_handle"
    }

    * --- Demographics ---
    if strpos("`moderator'", "Grad_degree") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Grad_degree"
    }
    if strpos("`moderator'", "Vote") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Vote"
    }
    if strpos("`moderator'", "Switzerland") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Switzerland"
    }
    if strpos("`moderator'", "Female") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Female"
    }
    if strpos("`moderator'", "ETH") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ETH"
    }
    if strpos("`moderator'", "Age") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Age AgeBinary_p50 AgeBinary_adult"
    }

    * --- Climate ---
    if strpos("`moderator'", "index_Climate") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' index_Climate index_ClimateBinary ClimateWorry ClimatePersonal"
    }

    * --- Donation ---
    if strpos("`moderator'", "Donation") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Donation DonationBinary_p50 DonationBinary_pos"
    }

    * --- BotKnow ---
    if strpos("`moderator'", "BotKnow") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotKnow BotKnowBinary"
    }

    * --- AI Persuasion ---
    if strpos("`moderator'", "AIEffective") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' InitialAIEffective AIEffectiveBinary"
    }

    * --- AI Writing Difference ---
    if strpos("`moderator'", "AIDiff") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BaseAIDiff AIDiffBinary"
    }

    * --- Bot Support (ordinal + binary both derived from same source) ---
    if strpos("`moderator'", "BotSupport") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotSupport_AI BotSupport_AIBinary"
    }

    * --- Bot Social Media (ordinal + binary both derived from same source) ---
    if strpos("`moderator'", "BotSocialMedia") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotSocialMedia_AI BotSocialMedia_AIBinary"
    }

    * --- Reaction variables (all three share the same task family) ---
    if strpos("`moderator'", "React") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ReadingReact1 ReadingReact1Binary ReadingReact2 ReadingReact2Binary PostReact PostReactBinary"
    }

    * --- Guess variables (same guessing task: one for human text, one for AI text) ---
    if strpos("`moderator'", "Guess") > 0 {
        local VARS_TO_REMOVE "`VARS_TO_REMOVE' GuessWriterHuman GuessWriterAI GuessHuman_asHuman GuessAI_asHuman"
    }

    * Safety net: always remove the moderator itself
    local VARS_TO_REMOVE "`VARS_TO_REMOVE' `moderator'"

    * Build expanded list covering both plain and i.VAR versions
    local VARS_TO_REMOVE_EXPANDED "`VARS_TO_REMOVE'"
    foreach var in `VARS_TO_REMOVE' {
        local VARS_TO_REMOVE_EXPANDED "`VARS_TO_REMOVE_EXPANDED' i.`var'"
    }

    // -------------------------------------------------------
    // 7. Apply Variable Removal to Control Sets
    // -------------------------------------------------------
    if "`VARS_TO_REMOVE_EXPANDED'" != "" {
        local c2_controls : list c2_controls - VARS_TO_REMOVE_EXPANDED
        local c3_controls : list c3_controls - VARS_TO_REMOVE_EXPANDED
        local c4_controls : list c4_controls - VARS_TO_REMOVE_EXPANDED
    }

    // -------------------------------------------------------
    // 8. Forced Base Control (Post_* outcomes only, C4 only)
    // -------------------------------------------------------
    local forced_base ""

    if strpos("`outcome'", "Post_") == 1 {
        local suffix = substr("`outcome'", 6, .)
        foreach bvar of global BASE_TEXT_CONTROLS {
            if "`bvar'" == "Base_`suffix'" {
                local forced_base "`bvar'"
            }
        }
    }

    // -------------------------------------------------------
    // 9. Display Final Control Sets (for log verification)
    // -------------------------------------------------------
    display as txt "--- hte_table_generator: `outcome' by `moderator' [`sname'] ---"
    display as txt "  C2: `c2_controls'"
    display as txt "  C3: `c3_controls'"
    display as txt "  C4: `c4_controls' `forced_base'"

    // -------------------------------------------------------
    // 10. Run Regressions
    // -------------------------------------------------------
    local models_to_tab ""

    * -- C1: No Controls --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator', vce(robust)
    if _rc == 0 {
        eststo model1
        local models_to_tab "`models_to_tab' model1"
    }

    * -- C2: Focal Behavioral Controls --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator' `c2_controls', vce(robust)
    if _rc == 0 {
        eststo model2
        local models_to_tab "`models_to_tab' model2"
    }

    * -- C3: All Behavioral Controls --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator' `c3_controls', vce(robust)
    if _rc == 0 {
        eststo model3
        local models_to_tab "`models_to_tab' model3"
    }

    * -- C4: Full Controls + forced base (if Post_*) --
    capture quietly regress `outcome' i.AITreat##i.Identify##c.`moderator' `c4_controls' `forced_base', vce(robust)
    if _rc == 0 {
        eststo model4
        local models_to_tab "`models_to_tab' model4"
    }

    // -------------------------------------------------------
    // 11. Export Table
    // -------------------------------------------------------
    if "`models_to_tab'" != "" {
        esttab `models_to_tab' using "`outdir'/`fname'.tex", replace        ///
            main(b %9.3f) aux(se %9.3f)                                      ///
            starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001)                     ///
            label                                                             ///
            nobase noomit                                                     ///
            order(_cons 1.AITreat 1.Identify                                 ///
                  1.AITreat#1.Identify                                        ///
                  `moderator'                                                 ///
                  1.AITreat#c.`moderator'                                     ///
                  1.Identify#c.`moderator'                                    ///
                  1.AITreat#1.Identify#c.`moderator')                         ///
            coeflabels(_cons "Intercept"                                     ///
                       1.AITreat "AI Treat"                                  ///
                       1.Identify "Identified Treat"                         ///
                       1.AITreat#1.Identify "AI \$\times\$ Identified"       ///
                       `moderator' "`moderator_lbl'"                         ///
                       1.AITreat#c.`moderator' "AI \$\times\$ `moderator_lbl'" ///
                       1.Identify#c.`moderator' "Identified \$\times\$ `moderator_lbl'" ///
                       1.AITreat#1.Identify#c.`moderator' "AI \$\times\$ Identified \$\times\$ `moderator_lbl'") ///
            stats(r2_a N, fmt(%9.3f %9.0fc)                                  ///
                labels("Adj. \(R^2\)" "\(N\)"))                              ///
            mtitles("`col1_title'" "`col2_title'"                            ///
                    "`col3_title'" "`col4_title'")                           ///
            numbers                                                           ///
            title("`tbl_title'") nonotes                                      ///
            booktabs compress width(\hsize)                                   ///
            prehead(`"\documentclass{article}"'                              ///
                    `"\usepackage{booktabs}"'                                 ///
                    `"\usepackage{caption}"'                                  ///
                    `"\usepackage[paperheight=18in, paperwidth=10in, margin=0.5in]{geometry}"' ///
                    `"\begin{document}"'                                      ///
                    `"\begin{table}[htbp]\centering"'                         ///
                    `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"'           ///
                    `"\caption*{@title}"'                                     ///
                    `"\begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@M}{c}}"' ///
                    `"\toprule"')                                             ///
            postfoot(`"\bottomrule"'                                          ///
                     `"\end{tabular*}"'                                       ///
                     `"\begin{minipage}{\hsize}\vspace{1ex}\footnotesize"'    ///
                     `"Standard errors in parentheses. $^{+} p<0.10, ^{*} p<0.05, ^{**} p<0.01, ^{***} p<0.001$. \\"' ///
                     `"All the Behavioral and Demographics controls are binarized to match the HTE results. \\"' ///
                     `"All time-based metrics are reported in seconds (s) and Winsorized at the 1\% level."' ///
                     `"\end{minipage}"'                                       ///
                     `"\end{table}"'                                          ///
                     `"\end{document}"')
    }
    else {
        display as error "No models successfully estimated for `outcome' by `moderator' in `slabel'."
    }

    restore

end
*/

*
* CIplot: No interaction

capture program drop diag_hte_lasso_range
program define diag_hte_lasso_range
    syntax, outcome(varname) moderator(varname) sample_number(integer)

    local forced_base ""
    if inlist("`outcome'", "Post_meaningfulness", "Post_AIness", "index_Post_effort", "index_Post_nlp", "Post_TextLength_log") {
        local forced_base = subinstr("`outcome'", "Post_", "Base_", 1)
    }

    // Fully synced variable removal logic
    local VARS_TO_REMOVE ""
    if strpos("`moderator'", "Instagram_use") > 0       local VARS_TO_REMOVE "`VARS_TO_REMOVE' Instagram_use"
    if strpos("`moderator'", "not_shared_handle") > 0   local VARS_TO_REMOVE "`VARS_TO_REMOVE' not_shared_handle index_Image_minus_privacy Image_minus_privacyBinary"
    if strpos("`moderator'", "ImageConcern") > 0        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern ImageConcernBinary_p50 ImageConcernBinary2 ImageConcernBinary3 ImageConcernBinary4 index_Image_minus_privacy Image_minus_privacyBinary"
    if strpos("`moderator'", "Image_minus_privacy") > 0 local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern ImageConcernBinary_p50 ImageConcernBinary2 ImageConcernBinary3 ImageConcernBinary4 index_Image_minus_privacy Image_minus_privacyBinary not_shared_handle"
    if strpos("`moderator'", "Grad_degree") > 0         local VARS_TO_REMOVE "`VARS_TO_REMOVE' Grad_degree"
    if strpos("`moderator'", "Vote") > 0                local VARS_TO_REMOVE "`VARS_TO_REMOVE' Vote"
    if strpos("`moderator'", "Switzerland") > 0         local VARS_TO_REMOVE "`VARS_TO_REMOVE' Switzerland"
    if strpos("`moderator'", "Female") > 0              local VARS_TO_REMOVE "`VARS_TO_REMOVE' Female"
    if strpos("`moderator'", "ETH") > 0                 local VARS_TO_REMOVE "`VARS_TO_REMOVE' ETH"
    if strpos("`moderator'", "Age") > 0                 local VARS_TO_REMOVE "`VARS_TO_REMOVE' Age AgeBinary_p50 AgeBinary_adult"
    if strpos("`moderator'", "index_Climate") > 0       local VARS_TO_REMOVE "`VARS_TO_REMOVE' index_Climate index_ClimateBinary ClimateWorry ClimatePersonal"
    if strpos("`moderator'", "Donation") > 0            local VARS_TO_REMOVE "`VARS_TO_REMOVE' Donation DonationBinary_p50 DonationBinary_pos"
    if strpos("`moderator'", "BotKnow") > 0             local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotKnow BotKnowBinary"
    if strpos("`moderator'", "AIEffective") > 0         local VARS_TO_REMOVE "`VARS_TO_REMOVE' InitialAIEffective AIEffectiveBinary"
    if strpos("`moderator'", "AIDiff") > 0              local VARS_TO_REMOVE "`VARS_TO_REMOVE' BaseAIDiff AIDiffBinary"
    if strpos("`moderator'", "BotSupport") > 0          local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotSupport_AI BotSupport_AIBinary"
    if strpos("`moderator'", "BotSocialMedia") > 0      local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotSocialMedia_AI BotSocialMedia_AIBinary"
    if strpos("`moderator'", "React") > 0               local VARS_TO_REMOVE "`VARS_TO_REMOVE' ReadingReact1 ReadingReact1Binary ReadingReact2 ReadingReact2Binary PostReact PostReactBinary"
    if strpos("`moderator'", "Guess") > 0               local VARS_TO_REMOVE "`VARS_TO_REMOVE' GuessWriterHuman GuessWriterAI GuessHuman_asHuman GuessAI_asHuman"

    local VARS_TO_REMOVE "`VARS_TO_REMOVE' `moderator'"
    local VARS_TO_REMOVE_EXPANDED "`VARS_TO_REMOVE'"
    foreach var in `VARS_TO_REMOVE' {
        local VARS_TO_REMOVE_EXPANDED "`VARS_TO_REMOVE_EXPANDED' i.`var'"
    }

    local lasso_cands "$CONTROLS `forced_base'"
    if "`VARS_TO_REMOVE_EXPANDED'" != "" {
        local lasso_cands : list lasso_cands - VARS_TO_REMOVE_EXPANDED
    }
    if trim("`lasso_cands'") == "" {
        local lasso_cands "i.Identify"
    }

    local is_bin = 0
    if strpos(" $OUTCOMES_BIN ", " `outcome' ") > 0 local is_bin = 1

    preserve
    quietly keep if sample`sample_number' == 1 & !missing(`outcome')

    local diag_min = 0
    local diag_max = 0

    foreach m_val in 0 1 {
        local controls_sel_temp ""
        quietly count if `moderator' == `m_val'
        if r(N) >= 20 {
            if `is_bin' {
                capture quietly lasso logit `outcome' `lasso_cands' if `moderator' == `m_val', selection(plugin)
                if _rc == 0 local controls_sel_temp "`e(allvars_sel)'"
            }
            else {
                capture quietly lasso linear `outcome' `lasso_cands' if `moderator' == `m_val', selection(plugin)
                if _rc == 0 local controls_sel_temp "`e(allvars_sel)'"
            }
        }

        capture quietly regress `outcome' i.Treatment_Group `controls_sel_temp' if `moderator' == `m_val', vce(robust)
        if _rc == 0 {
            matrix T_diag = r(table)
            forvalues i = 2/4 {
                local lo = T_diag[5, `i']
                local hi = T_diag[6, `i']
                if `lo' < `diag_min' local diag_min = `lo'
                if `hi' > `diag_max' local diag_max = `hi'
            }
        }
    }

    display "DIAG | outcome=`outcome' | moderator=`moderator' | sample=`sample_number' | CI_min=`diag_min' | CI_max=`diag_max'"
    restore
end

capture program drop hte_ciplot_NoCtrl
program define hte_ciplot_NoCtrl
    syntax, outcome(varname) moderator(varname) sample_number(integer) slabel(string) sname(string) [if_condition(string)]

    // True data bounds for CI capping
    quietly summ `outcome'
    local true_min = r(min)
    local true_max = r(max)

    // -------------------------------------------------------
    // 1. Global Y-Axis Range (across all samples & conditions)
    // -------------------------------------------------------
    local all_samples 2 5 8 20 80  // Must match RUN_SAMPLES!
    local global_min_ll = .
    local global_max_ul = .

    foreach samp of local all_samples {
        foreach cond in "" "if Finished == 1" {
            preserve
            quietly keep if sample`samp' == 1 & !missing(`outcome')
            if "`cond'" != "" {
                keep `cond'
            }
            
            foreach m_val in 0 1 {
                capture quietly regress `outcome' ibn.Treatment_Group if `moderator' == `m_val', noconstant vce(robust)
                if !_rc {
                    matrix T = r(table)
                    local n_cols = colsof(T)
                    forvalues c = 1/`n_cols' {
                        local this_ll = T[5, `c']
                        local this_ul = T[6, `c']
                        
                        // Cap at data bounds
                        if `this_ul' > `true_max' local this_ul = `true_max'
                        if `this_ll' < `true_min' local this_ll = `true_min'
                        
                        if `global_min_ll' == . | `this_ll' < `global_min_ll' {
                            local global_min_ll = `this_ll'
                        }
                        if `global_max_ul' == . | `this_ul' > `global_max_ul' {
                            local global_max_ul = `this_ul'
                        }
                    }
                }
            }
            restore
        }
    }
    
    // Fallback if all regressions failed
    if `global_min_ll' == . local global_min_ll = 0
    if `global_max_ul' == . local global_max_ul = 1
	
    // -------------------------------------------------------
    // 2. Actual Plot: Preserve & Subset
    // -------------------------------------------------------
    preserve
    quietly keep if sample`sample_number' == 1 & !missing(`outcome')
    if "`if_condition'" != "" {
        keep `if_condition'
    }

    // Ns for labels
    forvalues i = 1/4 {
        quietly count if Treatment_Group == `i' & `moderator' == 0
        local n0`i' = r(N)
        quietly count if Treatment_Group == `i' & `moderator' == 1
        local n1`i' = r(N)
    }

    // Dynamic xtitle and filetag
    local xtitle "Treatment Group (Co-sender Composition × Disclosure) - `slabel'"
    local filetag "ciplot_`outcome'_hte_`moderator'_`sname'_NoCtrl"
    
    if "`if_condition'" == "if Finished == 1" {
        local xtitle "Treatment Group (Co-sender Composition × Disclosure) - `slabel', Finished"
        local filetag "ciplot_`outcome'_hte_`moderator'_`sname'_NoCtrl_finished"
    }

    // Dynamic ytitle from variable label
    nice_name_as_label
    local ytitle : variable label `outcome'
    if "`ytitle'" == "" {
        local ytitle "`outcome'"
    }

    // Moderator label
    local moderator_lbl : variable label `moderator'
    if "`moderator_lbl'" == "" {
        local moderator_lbl "`moderator'"
    }

    * Default (overridden below for every CIPLOT moderator)
    local lab0 "Low `moderator_lbl'"
    local lab1 "High `moderator_lbl'"

    * --- Median-split variables ---
    if "`moderator'" == "index_ClimateBinary" {
        local lab0 "Low Climate Concern"
        local lab1 "High Climate Concern"
    }
    if "`moderator'" == "DonationBinary_p50" {
        local lab0 "Low Donation"
        local lab1 "High Donation"
    }
    if "`moderator'" == "DonationBinary_pos" {
        local lab0 "Not Donated"
        local lab1 "Donated"
    }
    if "`moderator'" == "ImageConcernBinary_p50" {
        local lab0 "Low Image Concern"
        local lab1 "High Image Concern"
    }
    if "`moderator'" == "AgeBinary_p50" {
        local lab0 "18-23 Years"
        local lab1 "24+ Years"
    }
    if "`moderator'" == "Image_minus_privacyBinary" {
        local lab0 "Low (Image - Disclosure)"
        local lab1 "High (Image - Disclosure)"
    }

    * --- Threshold-split variables ---
    if "`moderator'" == "AIDiffBinary" {
        local lab0 "Not Different to AI Writing"
        local lab1 "Different from AI Writing"
    }
    if "`moderator'" == "ImageConcernBinary_p50" {
        local lab0 "Low Image Concern"
        local lab1 "High Image Concern"
    }
    if "`moderator'" == "ImageConcernBinary2" {
        local lab0 "Image Concern = 1"
        local lab1 "Image Concern ≥ 2"
    }
    if "`moderator'" == "ImageConcernBinary3" {
        local lab0 "Image Concern ≤ 2"
        local lab1 "Image Concern ≥ 3"
    }
    if "`moderator'" == "ImageConcernBinary4" {
        local lab0 "Image Concern ≤ 3"
        local lab1 "Image Concern ≥ 4"
    }
    if "`moderator'" == "AgeBinary_adult" {
        local lab0 "18-24 Years"
        local lab1 "25+ Years"
    }
    if "`moderator'" == "BotKnowBinary" {
        local lab0 "Less Familiar with AI"
        local lab1 "Frequent AI User"
    }
    if "`moderator'" == "AIEffectiveBinary" {
        local lab0 "Low AI Persuasion Belief"
        local lab1 "High AI Persuasion Belief"
    }
    if "`moderator'" == "BotSupport_AIBinary" {
        local lab0 "Not Prefer AI Customer Support"
        local lab1 "Prefers AI Customer Support"
    }
    if "`moderator'" == "BotSocialMedia_AIBinary" {
        local lab0 "Not Prefer AI on Social Media"
        local lab1 "Prefers AI on Social Media"
    }
    if "`moderator'" == "Instagram_use" {
        local lab0 "Non-Instagram User"
        local lab1 "Instagram User"
    }
    if "`moderator'" == "Grad_degree" {
        local lab0 "Non-Graduate Degree"
        local lab1 "Graduate Degree"
    }
    if "`moderator'" == "Vote" {
        local lab0 "Did Not Vote"
        local lab1 "Voted"
    }
    if "`moderator'" == "Switzerland" {
        local lab0 "Non-Swiss"
        local lab1 "Swiss"
    }
    if "`moderator'" == "Female" {
        local lab0 "Male"
        local lab1 "Female"
    }
    if "`moderator'" == "ETH" {
        local lab0 "Non-ETH"
        local lab1 "ETH"
    }

    * --- Reaction variables (0 = No Reaction, 1 = Reacted) ---
    if "`moderator'" == "ReadingReact1Binary" {
        local lab0 "No Reaction to Human Content"
        local lab1 "Reacted to Human Content"
    }
    if "`moderator'" == "ReadingReact2Binary" {
        local lab0 "No Reaction to Pool Content"
        local lab1 "Reacted to Pool Content"
    }
    if "`moderator'" == "PostReactBinary" {
        local lab0 "No Reaction to (Human) Post"
        local lab1 "Reacted to (Human) Post"
    }

    * --- Guess variables (0 = Perceived as AI/Bot, 1 = Perceived as Human) ---
    if "`moderator'" == "GuessHuman_asHuman" {
        local lab0 "Guessed Human as AI"
        local lab1 "Guessed Human as Human"
    }
    if "`moderator'" == "GuessAI_asHuman" {
        local lab0 "Guessed AI as AI"
        local lab1 "Guessed AI as Human"
    }



    capture mkdir "$output_folder/hte"
    capture mkdir "$output_folder/hte/hte_ciplot_no_interaction"
    local outdir "$output_folder/hte/hte_ciplot_no_interaction"

    // -------------------------------------------------------
    // 3. Run Regressions & Extract into Plotting Data
    // -------------------------------------------------------
    local success_count = 0
    
    foreach m_val in 0 1 {
        capture quietly regress `outcome' ibn.Treatment_Group if `moderator' == `m_val', noconstant vce(robust)
        if _rc == 0 {
            local success_count = `success_count' + 1
            matrix T_`m_val' = r(table)
        }
    }

    if `success_count' == 2 {
    
        // Build plotting dataset from regression results
        drop _all
        set obs 8
        gen Treatment_Group = .
        gen beta = .
        gen ci_lo = .
        gen ci_hi = .
        gen mod_group = .
        
        // Moderator = 0 (rows 1-4)
        forvalues i = 1/4 {
            replace Treatment_Group = `i' in `i'
            replace beta  = T_0[1, `i'] in `i'
            replace ci_lo = T_0[5, `i'] in `i'
            replace ci_hi = T_0[6, `i'] in `i'
            replace mod_group = 0 in `i'
        }
        
        // Moderator = 1 (rows 5-8)
        forvalues i = 1/4 {
            local row = `i' + 4
            replace Treatment_Group = `i' in `row'
            replace beta  = T_1[1, `i'] in `row'
            replace ci_lo = T_1[5, `i'] in `row'
            replace ci_hi = T_1[6, `i'] in `row'
            replace mod_group = 1 in `row'
        }
        
        // Cap CIs at data bounds
        replace ci_hi = `true_max' if ci_hi > `true_max'
        replace ci_lo = `true_min' if ci_lo < `true_min'
        
        // X-offset: moderator=0 slightly left, moderator=1 slightly right
        gen xpos = Treatment_Group - 0.15 if mod_group == 0
        replace xpos = Treatment_Group + 0.15 if mod_group == 1

        // -------------------------------------------------------
        // 4. Nice Y-Axis
        // -------------------------------------------------------
        local max_val = `global_max_ul'
        local min_val = `global_min_ll'
        
        local range = `max_val' - `min_val'
        if `range' == 0 local range = 1

        local ybottom = `min_val' - (`range' * 0.1)
        local ytop    = `max_val' + (`range' * 0.1)
        
        local raw_step = (`ytop' - `ybottom') / 5
        local mag = 10^floor(log10(`raw_step'))
        local norm = `raw_step' / `mag'
        if `norm' <= 1       local step = 1 * `mag'
        else if `norm' <= 2  local step = 2 * `mag'
        else if `norm' <= 5  local step = 5 * `mag'
        else                 local step = 10 * `mag'
        
        local ybottom = `step' * floor(`ybottom' / `step')
        local ytop    = `step' * ceil(`ytop' / `step')
        
		if inlist("`outcome'", "Finished", "Post_meaningfulness") local ytop = 1
		if inlist("`outcome'", "Finished", "Post_meaningfulness") local ybottom = 0.6
		if inlist("`outcome'", "Finished", "Post_meaningfulness") local step = 0.1
		
        if `ytop' < 1        local yfmt "%9.2f"
        else if `ytop' < 10  local yfmt "%9.1f"
        else                 local yfmt "%9.0f"

        // -------------------------------------------------------
        // 5. Plot
        // -------------------------------------------------------
        local c1 "navy"
        local c2 "maroon"

        twoway ///
            (rcap ci_hi ci_lo xpos if mod_group==0, lcolor(`c1') lwidth(medthin)) ///
            (scatter beta xpos if mod_group==0, msymbol(Dh) msize(medium) mcolor(none) mlcolor(`c1')) ///
            (rcap ci_hi ci_lo xpos if mod_group==1, lcolor(`c2') lwidth(medthin)) ///
            (scatter beta xpos if mod_group==1, msymbol(Dh) msize(medium) mcolor(none) mlcolor(`c2')) ///
            , ///
            xlabel(1 `""No AI, Anonymous" "(n0=`n01') & (n1=`n11')""' ///
                   2 `""AI, Anonymous" "(n0=`n02') & (n1=`n12')""' ///
                   3 `""No AI, Identified" "(n0=`n03') & (n1=`n13')""' ///
                   4 `""AI, Identified" "(n0=`n04') & (n1=`n14')""', ///
                   labsize(small) grid) ///
            xscale(range(0.5 4.5)) ///
            ylabel(`ybottom'(`step')`ytop', format(`yfmt') labsize(small)) ///
            yscale(range(`ybottom' `ytop') noextend) ///
            xtitle("`xtitle'", size(small)) ///
            ytitle("`ytitle'", size(small)) ///
            legend(order(2 "`lab0'" 4 "`lab1'") pos(6) rows(1) region(lcolor(black) lwidth(thin))) ///
            graphregion(color(white) margin(medium)) ///
            name(g_noctrl, replace)
                 
        graph export "`outdir'/`filetag'.pdf", replace
        graph drop g_noctrl
    }
    else {
        display as error "Regression failed for `outcome' by `moderator' (No Ctrl). One or both subgroups failed."
    }

    restore
end

cap program drop hte_ciplot_raw
program define hte_ciplot_raw
    version 17.0
    syntax, outcome(varname) moderator(varname) sample_number(integer) ///
            slabel(string) sname(string)

    // ---------------------------------------------------------
    // 1. Finished-dataset detection (system macro — not a data op)
    // ---------------------------------------------------------
    local finished_tag = regexm(c(filename), "_ff\.dta")

    // ---------------------------------------------------------
    // 2. xtitle and filetag
    // ---------------------------------------------------------
    if `finished_tag' {
        local xtitle  "Treatment Group (Co-sender Composition × Disclosure) - `slabel', Finished"
        local filetag "ciplot_`outcome'_hte_`moderator'_`sname'_raw_finished"
    }
    else {
        local xtitle  "Treatment Group (Co-sender Composition × Disclosure) - `slabel'"
        local filetag "ciplot_`outcome'_hte_`moderator'_`sname'_raw"
    }

    // ---------------------------------------------------------
    // 3. Output directory (self-contained mkdir)
    // ---------------------------------------------------------
    local outdir "$output_dir/outcome_ciplot/hte_raw"
    capture mkdir "`outdir'"

    // ---------------------------------------------------------
    // 4. ALL DATA OPERATIONS INSIDE PRESERVE / RESTORE
    // ---------------------------------------------------------
    preserve

        keep if sample`sample_number' == 1 & !missing(`outcome')

        // -- y-axis settings: ylow, yhigh, ystep, yfmt set via c_local --
        yaxis_range_raw, outcome(`outcome')

        // -- ytitle from standardised variable labels --
        nice_name_as_label
        local ytitle : variable label `outcome'
        if "`ytitle'" == "" local ytitle "`outcome'"

        // -- Moderator group labels --
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

        // -- Ns for x-axis labels --
        forvalues i = 1/4 {
            quietly count if Treatment_Group == `i' & `moderator' == 0
            local n0`i' = r(N)
            quietly count if Treatment_Group == `i' & `moderator' == 1
            local n1`i' = r(N)
        }

        // -- P-values (computed before collapse) --
        capture quietly ttest `outcome' if `moderator'==0 & ///
            (Treatment_Group==3 | Treatment_Group==4), by(Treatment_Group) unequal
        if _rc == 0  local p_lab0 : di %6.3f r(p)
        else         local p_lab0 "N/A"

        capture quietly ttest `outcome' if `moderator'==1 & ///
            (Treatment_Group==3 | Treatment_Group==4), by(Treatment_Group) unequal
        if _rc == 0  local p_lab1 : di %6.3f r(p)
        else         local p_lab1 "N/A"

        // -- P-value label strings --
        local txt1 "P-Value (No AI vs. AI | Identified, `lab0') = `p_lab0'"
        local txt2 "P-Value (No AI vs. AI | Identified, `lab1') = `p_lab1'"

        // -- P-value box positioning (unchanged) --
        local range_y = `yhigh' - `ylow'
        local gap     = `range_y' * 0.06
        local line2_y = `ylow' + (`range_y' * 0.12)
        local line1_y = `line2_y' + `gap'
        local box_y   = `line2_y' + (`gap' / 2)
        local box_x   = 0.7

        // -- Collapse for moderator == 0 --
        tempfile current_data
        quietly save `current_data'

        local c1 "navy"
        local c2 "maroon"

        keep if `moderator' == 0
        collapse (count) n=`outcome' (mean) beta=`outcome' (sd) sd=`outcome', ///
            by(Treatment_Group)
        gen se    = sd/sqrt(n)
        gen tcrit = invttail(n-1, 0.025)
        gen ci_lo = beta - tcrit*se
        gen ci_hi = beta + tcrit*se
        gen mod_group = 0
        tempfile mod0
        quietly save `mod0'

        // -- Collapse for moderator == 1 --
        use `current_data', clear
        keep if `moderator' == 1
        collapse (count) n=`outcome' (mean) beta=`outcome' (sd) sd=`outcome', ///
            by(Treatment_Group)
        gen se    = sd/sqrt(n)
        gen tcrit = invttail(n-1, 0.025)
        gen ci_lo = beta - tcrit*se
        gen ci_hi = beta + tcrit*se
        gen mod_group = 1

        append using `mod0'

        gen xpos = Treatment_Group - 0.15 if mod_group == 0
        replace xpos = Treatment_Group + 0.15 if mod_group == 1

        // -- Plot --
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
            /* LAYER 1: White box background */ ///
            text(`box_y' `box_x' "`txt1'" " " "`txt2'", ///
                 place(e) box fcolor(white) lcolor(black) margin(small) ///
                 size(small) justification(left) color(white)) ///
            /* LAYER 2: Navy text (top row) */ ///
            text(`line1_y' `box_x' "`txt1'", ///
                 place(e) margin(small) size(small) justification(left) color(`c1')) ///
            /* LAYER 3: Maroon text (bottom row) */ ///
            text(`line2_y' `box_x' "`txt2'", ///
                 place(e) margin(small) size(small) justification(left) color(`c2')) ///
            legend(order(2 "`lab0'" 4 "`lab1'") pos(6) rows(1) ///
                size(small) region(lcolor(black) lwidth(thin))) ///
            plotregion(margin(zero)) ///
            name(g_raw_hte, replace)

        graph display g_raw_hte, xsize(10) ysize(7)
        graph export "`outdir'/`filetag'.pdf", replace
        graph drop g_raw_hte

    restore
end

capture program drop hte_ciplot_Lasso
program define hte_ciplot_Lasso
    syntax, outcome(varname) moderator(varname) sample_number(integer) slabel(string) sname(string) [if_condition(string)]

	local forced_base ""
	
	if inlist("`outcome'", "Post_meaningfulness", "Post_AIness", "index_Post_effort", "index_Post_nlp") {
		local forced_base = subinstr("`outcome'", "Post_", "Base_", 1)
	}

    // -------------------------------------------------------
    // Dynamic Variable Removal Logic (unchanged from original)
    // -------------------------------------------------------
    local VARS_TO_REMOVE ""

    if strpos("`moderator'", "Instagram_use") > 0       local VARS_TO_REMOVE "`VARS_TO_REMOVE' Instagram_use"
    if strpos("`moderator'", "not_shared_handle") > 0   local VARS_TO_REMOVE "`VARS_TO_REMOVE' not_shared_handle index_Image_minus_privacy Image_minus_privacyBinary"
    if strpos("`moderator'", "ImageConcern") > 0        local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern ImageConcernBinary_p50 ImageConcernBinary2 ImageConcernBinary3 ImageConcernBinary4 index_Image_minus_privacy Image_minus_privacyBinary"
    if strpos("`moderator'", "Image_minus_privacy") > 0 local VARS_TO_REMOVE "`VARS_TO_REMOVE' ImageConcern ImageConcernBinary_p50 ImageConcernBinary2 ImageConcernBinary3 ImageConcernBinary4 index_Image_minus_privacy Image_minus_privacyBinary not_shared_handle"

    if strpos("`moderator'", "Grad_degree") > 0 local VARS_TO_REMOVE "`VARS_TO_REMOVE' Grad_degree"
    if strpos("`moderator'", "Vote") > 0        local VARS_TO_REMOVE "`VARS_TO_REMOVE' Vote"
    if strpos("`moderator'", "Switzerland") > 0 local VARS_TO_REMOVE "`VARS_TO_REMOVE' Switzerland"
    if strpos("`moderator'", "Female") > 0      local VARS_TO_REMOVE "`VARS_TO_REMOVE' Female"
    if strpos("`moderator'", "ETH") > 0         local VARS_TO_REMOVE "`VARS_TO_REMOVE' ETH"
    if strpos("`moderator'", "Age") > 0         local VARS_TO_REMOVE "`VARS_TO_REMOVE' Age AgeBinary_p50 AgeBinary_adult"

    if strpos("`moderator'", "index_Climate") > 0    local VARS_TO_REMOVE "`VARS_TO_REMOVE' index_Climate index_ClimateBinary ClimateWorry ClimatePersonal"
    if strpos("`moderator'", "Donation") > 0         local VARS_TO_REMOVE "`VARS_TO_REMOVE' Donation DonationBinary_p50 DonationBinary_pos"
    if strpos("`moderator'", "BotKnow") > 0          local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotKnow BotKnowBinary"
    if strpos("`moderator'", "AIEffective") > 0      local VARS_TO_REMOVE "`VARS_TO_REMOVE' InitialAIEffective AIEffectiveBinary"
    if strpos("`moderator'", "AIDiff") > 0           local VARS_TO_REMOVE "`VARS_TO_REMOVE' BaseAIDiff AIDiffBinary"
    if strpos("`moderator'", "BotSupport") > 0       local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotSupport_AI BotSupport_AIBinary"
    if strpos("`moderator'", "BotSocialMedia") > 0   local VARS_TO_REMOVE "`VARS_TO_REMOVE' BotSocialMedia_AI BotSocialMedia_AIBinary"
    if strpos("`moderator'", "React") > 0            local VARS_TO_REMOVE "`VARS_TO_REMOVE' ReadingReact1 ReadingReact1Binary ReadingReact2 ReadingReact2Binary PostReact PostReactBinary"
    if strpos("`moderator'", "Guess") > 0            local VARS_TO_REMOVE "`VARS_TO_REMOVE' GuessWriterHuman GuessWriterAI GuessHuman_asHuman GuessAI_asHuman"

    local VARS_TO_REMOVE "`VARS_TO_REMOVE' `moderator'"

    local VARS_TO_REMOVE_EXPANDED "`VARS_TO_REMOVE'"
    foreach var in `VARS_TO_REMOVE' {
        local VARS_TO_REMOVE_EXPANDED "`VARS_TO_REMOVE_EXPANDED' i.`var'"
    }

    local lasso_cands "$CONTROLS `forced_base'"
    if "`VARS_TO_REMOVE_EXPANDED'" != "" {
        local lasso_cands : list lasso_cands - VARS_TO_REMOVE_EXPANDED
    }
    if trim("`lasso_cands'") == "" {
        local lasso_cands "i.Identify"
    }

    // -------------------------------------------------------
    // Setup
    // -------------------------------------------------------
    local is_bin = 0
    if strpos(" $OUTCOMES_BIN ", " `outcome' ") > 0 local is_bin = 1
    local vce "robust"


    preserve
    quietly keep if sample`sample_number' == 1 & !missing(`outcome')
    if "`if_condition'" != "" {
        keep `if_condition'
    }

    // -------------------------------------------------------
    // Ns for x-axis labels
    // -------------------------------------------------------
    forvalues i = 1/4 {
        quietly count if Treatment_Group == `i' & `moderator' == 0
        local n0`i' = r(N)
        quietly count if Treatment_Group == `i' & `moderator' == 1
        local n1`i' = r(N)
    }

    // -------------------------------------------------------
    // P-values for box (raw ttest on outcome, TG3 vs TG4,
    //    computed here BEFORE drop _all below)
    // -------------------------------------------------------
    capture quietly ttest `outcome' if `moderator'==0 & (Treatment_Group==3 | Treatment_Group==4), by(Treatment_Group) unequal
    if _rc == 0  local p_lab0 : di %6.3f r(p)
    else         local p_lab0 "N/A"

    capture quietly ttest `outcome' if `moderator'==1 & (Treatment_Group==3 | Treatment_Group==4), by(Treatment_Group) unequal
    if _rc == 0  local p_lab1 : di %6.3f r(p)
    else         local p_lab1 "N/A"

    // -------------------------------------------------------
    // xtitle, filetag, ytitle
    // -------------------------------------------------------
    local xtitle "Treatment Group (Co-sender Composition × Disclosure) - `slabel', Finished"
    local filetag "ciplot_`outcome'_hte_`moderator'_`sname'_resid_finished"

    if "`if_condition'" == "if Finished == 1" {
        local xtitle "Treatment Group (Co-sender Composition × Disclosure) - `slabel', Finished"
        local filetag "ciplot_`outcome'_hte_`moderator'_`sname'_resid_finished"
    }

    nice_name_as_label
    local ytitle : variable label `outcome'
    if "`ytitle'" == "" local ytitle "`outcome'"

    // -------------------------------------------------------
    // Moderator group labels (unchanged from original)
    // -------------------------------------------------------
    local moderator_lbl : variable label `moderator'
    if "`moderator_lbl'" == "" local moderator_lbl "`moderator'"

    local lab0 "Low `moderator_lbl'"
    local lab1 "High `moderator_lbl'"

    if "`moderator'" == "index_ClimateBinary" {
        local lab0 "Low Climate Concern"
        local lab1 "High Climate Concern"
    }
    else if "`moderator'" == "DonationBinary_p50" {
        local lab0 "Low Donation"
        local lab1 "High Donation"
    }
    else if "`moderator'" == "DonationBinary_pos" {
        local lab0 "Not Donated"
        local lab1 "Donated"
    }
    else if "`moderator'" == "ImageConcernBinary_p50" {
        local lab0 "Low Image Concern"
        local lab1 "High Image Concern"
    }
    else if "`moderator'" == "AgeBinary_p50" {
        local lab0 "18-23 Years"
        local lab1 "24+ Years"
    }
    else if "`moderator'" == "Image_minus_privacyBinary" {
        local lab0 "Low (Image - Disclosure)"
        local lab1 "High (Image - Disclosure)"
    }
    else if "`moderator'" == "index_Image_minus_privacyBinary" {
        local lab0 "Low (Image - Disclosure)"
        local lab1 "High (Image - Disclosure)"
    }
    else if "`moderator'" == "AIDiffBinary" {
        local lab0 "Not Different to AI Writing"
        local lab1 "Different from AI Writing"
    }
    else if "`moderator'" == "ImageConcernBinary2" {
        local lab0 "Image Concern = 1"
        local lab1 "Image Concern ≥ 2"
    }
    else if "`moderator'" == "ImageConcernBinary3" {
        local lab0 "Image Concern ≤ 2"
        local lab1 "Image Concern ≥ 3"
    }
    else if "`moderator'" == "ImageConcernBinary4" {
        local lab0 "Image Concern ≤ 3"
        local lab1 "Image Concern ≥ 4"
    }
    else if "`moderator'" == "AgeBinary_adult" {
        local lab0 "18-24 Years"
        local lab1 "25+ Years"
    }
    else if "`moderator'" == "BotKnowBinary" {
        local lab0 "Less Familiar with AI"
        local lab1 "Frequent AI User"
    }
    else if "`moderator'" == "AIEffectiveBinary" {
        local lab0 "Low AI Persuasion Belief"
        local lab1 "High AI Persuasion Belief"
    }
    else if "`moderator'" == "BotSupport_AIBinary" {
        local lab0 "Not Prefer AI Customer Support"
        local lab1 "Prefers AI Customer Support"
    }
    else if "`moderator'" == "BotSocialMedia_AIBinary" {
        local lab0 "Not Prefer AI on Social Media"
        local lab1 "Prefers AI on Social Media"
    }
    else if "`moderator'" == "Instagram_use" {
        local lab0 "Non-Instagram User"
        local lab1 "Instagram User"
    }
    else if "`moderator'" == "Grad_degree" {
        local lab0 "Non-Graduate Degree"
        local lab1 "Graduate Degree"
    }
    else if "`moderator'" == "Vote" {
        local lab0 "Did Not Vote"
        local lab1 "Voted"
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
    else if "`moderator'" == "ReadingReact1Binary" {
        local lab0 "No Reaction to Human Content"
        local lab1 "Reacted to Human Content"
    }
    else if "`moderator'" == "ReadingReact2Binary" {
        local lab0 "No Reaction to Pool Content"
        local lab1 "Reacted to Pool Content"
    }
    else if "`moderator'" == "PostReactBinary" {
        local lab0 "No Reaction to (Human) Post"
        local lab1 "Reacted to (Human) Post"
    }
    else if "`moderator'" == "GuessHuman_asHuman" {
        local lab0 "Guessed Human as AI"
        local lab1 "Guessed Human as Human"
    }
    else if "`moderator'" == "GuessAI_asHuman" {
        local lab0 "Guessed AI as AI"
        local lab1 "Guessed AI as Human"
    }
    else if "`moderator'" == "index_ai_trustBinary_p50" {
        local lab0 "Low AI Trust Index"
        local lab1 "High AI Trust Index"
    }
    else if "`moderator'" == "index_bot_supportBinary_p50" {
        local lab0 "Low Bot Support Index"
        local lab1 "High Bot Support Index"
    }
    else if "`moderator'" == "index_reactBinary_p50" {
        local lab0 "Low Reaction Rate Index"
        local lab1 "High Reaction Rate Index"
    }
    else if "`moderator'" == "index_guess_humanBinary_p50" {
        local lab0 "Low Propensity to Guess Human Index"
        local lab1 "High Propensity to Guess Human Index"
    }

	// -------------------------------------------------------
    // 6. Hardcoded y-axis (UPDATED FOR Lasso EFFECTS: Centered around 0)
    // -------------------------------------------------------
    if "`outcome'" == "Finished" {
        local ylow = -0.20
        local yhigh = 0.20
        local ystep = 0.10
		local yfmt "%4.2f"
    }
    else if "`outcome'" == "Post_meaningfulness" {
        local ylow = -0.20
        local yhigh = 0.20
        local ystep = 0.10
		local yfmt "%4.2f"
    }
    else if "`outcome'" == "Post_TextLength_log" {
        local ylow = -3.00
        local yhigh = 3.00
        local ystep = 0.05
    }
    else if "`outcome'" == "Post_AIness" {
        local ylow = -0.30
        local yhigh = 0.30
        local ystep = 0.10
    }
    else if "`outcome'" == "index_Post_effort" {
        local ylow = -1.00
        local yhigh = 0.50
        local ystep = 0.25
		local yfmt "%4.2f"
    }
    else if "`outcome'" == "index_Post_nlp" {
        local ylow = -0.80
        local yhigh = 0.40
        local ystep = 0.20
		local yfmt "%4.2f"
    }
    else if "`outcome'" == "TimePost_W" {
        local ylow = -200
        local yhigh = 200
        local ystep = 100
    }
    else if "`outcome'" == "index_Post_overall" {
        local ylow = -0.80
        local yhigh = 0.40
        local ystep = 0.20
    }
    else if "`outcome'" == "WTP" {
        local ylow = -1.50
        local yhigh = 2.00
        local ystep = 0.50
    }
    else if "`outcome'" == "TimeWTP_W" {
        local ylow = -40
        local yhigh = 40
        local ystep = 20
    }
    else if "`outcome'" == "TimeWTPExplain_W" {
        local ylow = -40
        local yhigh = 40
        local ystep = 20
    }
    else if "`outcome'" == "GenAIEffective" {
        local ylow = -0.60
        local yhigh = 0.60
        local ystep = 0.30
    }
    else if "`outcome'" == "PerceiveAI" {
        local ylow = -1.00
        local yhigh = 1.00
        local ystep = 0.50
    }
    else if "`outcome'" == "SignalValue" {
        local ylow = -1.00
        local yhigh = 1.00
        local ystep = 0.50
    }
    else if "`outcome'" == "PerceiveEngaged" {
        local ylow = -1.00
        local yhigh = 1.00
        local ystep = 0.50
    }
    else {
        // Fallback for any unlisted outcome: dynamic range for EFFECTS
        // Centers around 0 using the standard deviation as a reasonable range
        quietly summ `outcome'
        local sd = r(sd)
        local yhigh = round(`sd', 0.1)
        if `yhigh' == 0 local yhigh = 0.5
        local ylow  = -`yhigh'
        local ystep = `yhigh' / 2
    }

    // -------------------------------------------------------
    // P-value box positioning (same formula as nice_ciplot)
    // -------------------------------------------------------
    local range_y = `yhigh' - `ylow'
    local gap     = `range_y' * 0.06
    local line2_y = `ylow' + (`range_y' * 0.12)   // maroon (bottom row)
    local line1_y = `line2_y' + `gap'              // navy   (top row)
	local box_y   = `line2_y' + (`gap' / 2)
    local box_x   = 0.7

    local txt1 "P-Value (No AI vs. AI | Identified, `lab0') = `p_lab0'"
    local txt2 "P-Value (No AI vs. AI | Identified, `lab1') = `p_lab1'"

    // -------------------------------------------------------
    // Output directory
    // -------------------------------------------------------
    capture mkdir "$output_folder/outcome_ciplot/hte_residualized"
    local outdir "$output_folder/outcome_ciplot/hte_residualized"

    // -------------------------------------------------------
    //  Run Lasso + Regression per moderator subgroup
    //     (i.Treatment_Group: Group 1 = omitted base)
    // -------------------------------------------------------
    local success_count = 0

    foreach m_val in 0 1 {

        local controls_sel_temp ""
        quietly count if `moderator' == `m_val'
        if r(N) >= 20 {
            if `is_bin' {
                capture quietly lasso logit `outcome' `lasso_cands' if `moderator' == `m_val', selection(plugin)
                if !_rc local controls_sel_temp "`e(allvars_sel)'"
            }
            else {
                capture quietly lasso linear `outcome' `lasso_cands' if `moderator' == `m_val', selection(plugin)
                if !_rc local controls_sel_temp "`e(allvars_sel)'"
            }
        }

        capture quietly regress `outcome' i.Treatment_Group `controls_sel_temp' if `moderator' == `m_val', vce(`vce')
        if _rc == 0 {
            local success_count = `success_count' + 1
            matrix T_`m_val' = r(table)
        }
    }

    // -------------------------------------------------------
    // 13. Build plotting dataset and draw
    //     Group 1 anchored at 0; Groups 2-4 = treatment effects
    //     Matrix cols: 1=1b.TG (base), 2=2.TG, 3=3.TG, 4=4.TG
    // -------------------------------------------------------
    if `success_count' == 2 {
		
        drop _all
        set obs 8
        gen Treatment_Group = .
        gen beta  = .
        gen ci_lo = .
        gen ci_hi = .
        gen mod_group = .

        // Moderator = 0
        replace Treatment_Group = 1 in 1
        replace beta  = 0 in 1
        replace ci_lo = 0 in 1
        replace ci_hi = 0 in 1
        replace mod_group = 0 in 1
        forvalues i = 2/4 {
            replace Treatment_Group = `i' in `i'
            replace beta  = T_0[1, `i'] in `i'
            replace ci_lo = T_0[5, `i'] in `i'
            replace ci_hi = T_0[6, `i'] in `i'
            replace mod_group = 0 in `i'
        }

        // Moderator = 1
        replace Treatment_Group = 1 in 5
        replace beta  = 0 in 5
        replace ci_lo = 0 in 5
        replace ci_hi = 0 in 5
        replace mod_group = 1 in 5
        forvalues i = 2/4 {
            local row = `i' + 4
            replace Treatment_Group = `i' in `row'
            replace beta  = T_1[1, `i'] in `row'
            replace ci_lo = T_1[5, `i'] in `row'
            replace ci_hi = T_1[6, `i'] in `row'
            replace mod_group = 1 in `row'
        }

        gen xpos = Treatment_Group - 0.15 if mod_group == 0
        replace xpos = Treatment_Group + 0.15 if mod_group == 1

        local c1 "navy"
        local c2 "maroon"

        twoway ///
            (rcap ci_hi ci_lo xpos if mod_group==0, lcolor(`c1') lwidth(medthin)) ///
            (scatter beta xpos if mod_group==0, msymbol(Dh) msize(small) mcolor(none) mlcolor(`c1')) ///
            (rcap ci_hi ci_lo xpos if mod_group==1, lcolor(`c2') lwidth(medthin)) ///
            (scatter beta xpos if mod_group==1, msymbol(Dh) msize(small) mcolor(none) mlcolor(`c2')) ///
            , ///
            xlabel(1 `""No AI, Anonymous" "(n0=`n01') & (n1=`n11')""' ///
                   2 `""AI, Anonymous" "(n0=`n02') & (n1=`n12')""' ///
                   3 `""No AI, Identified" "(n0=`n03') & (n1=`n13')""' ///
                   4 `""AI, Identified" "(n0=`n04') & (n1=`n14')""', ///
                   labsize(small) grid) ///
            xscale(range(0.5 4.5)) ///
            yscale(range(`ylow' `yhigh')) ///
            ylabel(`ylow'(`ystep')`yhigh', format(`yfmt') labsize(medsmall)) ///
            yline(0, lcolor(gs10) lpattern(dash) lwidth(thin)) ///
            xtitle("`xtitle'", size(small)) ///
            ytitle("`ytitle'", size(small)) ///
			/* LAYER 1: White box background */ ///
			text(`box_y' `box_x' "`txt1'" " " "`txt2'", ///
				place(e) box fcolor(white) lcolor(black) margin(small) size(small) justification(left) color(white)) ///
			/* LAYER 2: Navy text (top row) */ ///
			text(`line1_y' `box_x' "`txt1'", ///
				place(e) margin(small) size(small) justification(left) color(`c1')) ///
			/* LAYER 3: Maroon text (bottom row) */ ///
			text(`line2_y' `box_x' "`txt2'", ///
				place(e) margin(small) size(small) justification(left) color(`c2')) ///
            legend(order(2 "`lab0'" 4 "`lab1'") pos(6) rows(1) size(small) region(lcolor(black) lwidth(thin))) ///
            plotregion(margin(zero)) ///
            name(g_lasso, replace)

        graph display g_lasso, xsize(10) ysize(7)
        graph export "`outdir'/`filetag'.pdf", replace
        graph drop g_lasso
    }
    else {
        display as error "Regression failed for `outcome' by `moderator' (Lasso). One or both subgroups failed."
    }

    restore
end
