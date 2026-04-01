* ------------------------------------------------------------------------------
* Base-10 sample system (reference list for future extension)
* Possible samples you may run later:
*   2 3 4 5 6 7 8 9 10 11 12 20 30 40 80 90 100 110 120 - Look at \AIComm\analysis\output\sample_definition.xlsx for more informations
* ------------------------------------------------------------------------------

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

** Set the correct project path for your system

global PATH "D:\Projects\Original\AIComm\analysis"
cd $PATH
adopath +  "."
qui include code/sub_programs.do

capture mkdir "output"
capture mkdir "output/descriptive_histograms"
global output_folder "output/descriptive_histograms"
capture mkdir "$output_folder"
// cap log using $output_folder/descriptive_histograms.log, replace

* This script RUNS ONLY:
*   2 (Full) and  20 (Instagram Users)

local ALL_SAMPLES "2 3 4 5 6 7 8 9 10 11 12 20 30 40 80 90 100 110 120"
local RUN_SAMPLES "2 20"


foreach i of local RUN_SAMPLES {
    capture mkdir "$output_folder/sample`i'"
    capture mkdir "$output_folder/sample`i'/AI_bargraphs"
	capture mkdir "$output_folder/sample`i'/Identify_bargraphs"
	capture mkdir "$output_folder/sample`i'/single_var_hist"
}

use input/SwissSurvey_Insta_Experiment_clean.dta, clear


* ======================================================================
* CORRELATION ANALYSIS: Shared Handle vs. Image Concern
* ======================================================================

label define ImageConcern_lbl 1 "Not important" 2 "Slightly" 3 "Moderately" 4 "Very" 5 "Extremely important", replace
label values ImageConcern ImageConcern_lbl

foreach i in 2 20 {
    local slabel "Sample `i'"
    if `i'==2  local slabel "Full Sample"
    if `i'==20 local slabel "Instagram Users"

    di as text "Running Correlation Analysis for Sample `i'..."

    ciplot_corr_binary_by_category if sample`i'==1, ///
        sample(`i') ///
        sample_label("`slabel'") ///
        outcome(shared_handle) ///
		ytitle_arg("Pr (High Disclosure Concern)") ///
        xvar(ImageConcern) ///
		xtitle_arg("Image Concern") ///
        xlow(1) xhigh(5) ///
        xvallabel(ImageConcern_lbl) ///
        ylow(0.3) yhigh(1.0)
	
	* Correlations
    preserve
    di as result "--- Correlations for Sample `i' ---"
	
	* 1. Pairwise Correlation (Pearson / Point-Biserial / Phi)
	* This gives you the standard correlation coefficient (r).
	* - For Binary vs Continuous (ImageConcern), this is Point-Biserial correlation.
	* - For Binary vs Binary (ImageConcernBinary#), this is the Phi coefficient.
    pwcorr shared_handle ImageConcern ImageConcernBinary_p50 ImageConcernBinary2 ImageConcernBinary3 ImageConcernBinary4 if sample`i' == 1, star(0.05) sig
	
	* 2. Spearman Correlation
	* Since ImageConcern is 1-5 (Ordinal), Spearman is often more robust than Pearson.
    spearman shared_handle ImageConcern if sample`i' == 1, star(0.05)
	
    restore
}


* ==============================================================================
* Histograms of $OUTCOMES and $GPT_OUTCOMES for AI Treatment
* ==============================================================================

/*
*------------------------------------------------------------
* Ranges / quantiles for $OUTCOMES and $GPT_OUTCOMES
*------------------------------------------------------------
di as text "=== Range + quantiles for GPT_OUTCOMES ==="
foreach v of global GPT_OUTCOMES {
    capture confirm variable `v'
    if _rc {
        di as error "`v'  --> NOT FOUND in dataset"
        continue
    }

    quietly summarize `v', detail
	
	local lo = r(p1)
	local hi = r(p99)
	di as text "Suggested x-range (p1–p99): [" %9.4f `lo' ", " %9.4f `hi' "]"

    di as text "------------------------------------------------------------"
    di as result "`v'"
    di as text "N=" %9.0g r(N) "  mean=" %9.4f r(mean) "  sd=" %9.4f r(sd)
    di as text "min=" %9.4f r(min) "  p1=" %9.4f r(p1) "  p5=" %9.4f r(p5) "  p25=" %9.4f r(p25) ///
               "  p50=" %9.4f r(p50) "  p75=" %9.4f r(p75) "  p95=" %9.4f r(p95) "  p99=" %9.4f r(p99) ///
               "  max=" %9.4f r(max)
}

di as text "=== DIAGNOSTICS FOR OUTCOME WIDTHS ==="
foreach v of global OUTCOMES {
    capture confirm variable `v'
    if _rc {
        di as error "`v' NOT FOUND"
        continue
    }
    quietly summarize `v', detail
    
    local range = r(max) - r(min)
    local p_range = r(p99) - r(p1)
    
    di as result "Variable: `v'"
    di as text "   Type: " cond(r(min)==0 & r(max)==1, "Binary", "Continuous/Discrete")
    di as text "   Min: " %9.2f r(min) "  Max: " %9.2f r(max)
    di as text "   p1:  " %9.2f r(p1)  "  p99: " %9.2f r(p99)
    di as text "   SD:  " %9.2f r(sd)  "  Range: " %9.2f `range'
    di as text "--------------------------------------"
}


***********************************************
** Useful Explanations for Graphs if Needed **
***********************************************
* ----------------------------
* GPT-coded text measures
* ----------------------------
char define personal_anecdote[prompt]      "Score 0/1/2 for personal anecdotes (explicit/implicit first-person experience/story: I/me/my, my friends/family, at our university, etc.). 0 = none."
char define emotional_appeal[prompt]       "Score 0/1/2 for emotional appeal (explicit/implicit emotions like fear/anger/hope/sadness/anxiety/guilt; dramatic wording to evoke strong feelings about climate change)."
char define emotional_appeal_new[prompt]   "Emotional appeal re-check: prior score=1 (0/1/2 scale). If disagree, assign 0 or 2; if agree, return 1."
char define scientific_argument[prompt]    "Score 0/1/2 for scientific arguments (statistics, data-driven claims, referring to a study, methodological/structured reasoning). 0 = none."
char define progressive_score[prompt]      "Score 0/1/2 for European ideological orientation: 0 right-wing (market/individual responsibility/min regulation), 1 neutral/balanced, 2 left-wing (regulation/collective action/social justice/redistribution/strong mandates)"
char define grammatical_mistakes[prompt]   "Count total grammatical mistakes (spelling/grammar errors; includes informal spellings like gonna, u for you). Return an integer count."
char define moral_narratives[prompt]       "Score 0/1/2 for moral narratives (right/wrong, duty, justice, fairness, ethical responsibility, moral judgments). 0 = none."
char define causal_narratives[prompt]      "Score 0/1/2 for causal narratives (cause-effect/mechanisms; A causes/results in B; explanatory structure). 0 = none."
char define sentiment[prompt]             "Score 0/1/2 for overall sentiment: 0 negative (pessimistic/critical), 1 neutral (balanced/factual), 2 positive (optimistic/encouraging)."
char define collective_action[prompt]      "Score 0/1/2 for emphasis on collective/systemic action: 0 none, 1 occasional mentions (community/government/group), 2 strong emphasis (multiple calls for systemic change/organizing/group interventions)."
char define individual_action[prompt]      "Score 0/1/2 for emphasis on individual/household actions (public transport, cycling, fewer flights, save energy, reduce meat, recycle, second-hand, etc.). 0 = none."
char define local_focus[prompt]           "Score 0/1/2 for local focus (Zurich/Switzerland, home town/country, local university, immediate local community/environment). 0 = none."
char define global_focus[prompt]          "Score 0/1/2 for global focus (Europe, other countries, worldwide/global framing). 0 = none."
char define policy_action[prompt]         "Score 0/1/2 for policy content (laws/regulations/taxes/subsidies/public programs at city/canton/national/EU levels). 0 = none."
char define economic_concern[prompt]      "Score 0/1/2 for economic content (money, prices, taxes, financial costs, economic systems). 0 = none."
char define risk_consequence[prompt]      "Score 0/1/2 for risk/harms/consequences of climate change (floods, fires, heatwaves, crop failures, sea level rise, health impacts, etc.). 0 = none."
char define ai_technology[prompt]         "Score 0/1/2 for AI/technology mentions in climate solutions: 0 none; 1 brief/passing mention (e.g., smart thermostats/AI could help); 2 substantial emphasis (multiple mentions, specific AI applications: optimization, prediction, smart grids, automation)."
char define Meaningful_post[prompt]        "Meaningfulness (0/1): 1 if coherent and on-topic to climate/environment/impacts (any well-formed reflection/opinion/description counts); 0 only if empty/gibberish/unrelated (jokes/spam)."

* ----------------------------
* Survey/behavioral outcomes (non-GPT)
* Note: Using [description] instead of [prompt] triggers the new label in the graph
* ----------------------------
char define Finished[description]              "Binary variable - whether participant completed the survey or not."
char define TaskQuizCorrect[description]           "Binary indicator - whether participant correctly identified the post database composition (0% vs 75% AI-generated) based on assigned treatment group."
char define WTP[description]                   "Maximum amount (0–10 CHF) participant is willing to forfeit to ensure their climate post is removed from the database and not shared with others."
char define WTPBinary_pos[description]         "Dummy - participant willing to pay any positive amount (>0 CHF) to ensure their climate post is removed from the database and not shared with others."
char define WTPBinary_p50[description]         "Dummy - participant willing to pay a amount greater than the median to ensure their climate post is removed from the database and not shared with others."
char define GenAIEffective[description]        "Belief about whether Gen-AI bots are more, equally, or less effective than human students at writing posts that attract likes on social media."
char define PerceiveAI[description]            "Self-assessment - how likely participant believes the student audience will perceive their human-written post as AI-generated."
char define SignalValue[description]           "Importance to participant that the audience perceives them positively."
char define PerceiveEngaged[description]       "Participant's estimate of how engaged/committed to combating climate change they will appear to the audience based on their post."
char define PostTextLength[description]        "Total character count of the climate change post written for the signaling task."
char define PostTextLength_log[description]    "Log-transformed and winsorized character count of the participant's post (normalizes text length distribution)."
char define TimePost[description]              "Total time (seconds) spent on the page where participant wrote their climate change post; winsorized to handle outliers."
char define TimeInstructionsPost[description]  "Time (seconds) spent reading signaling task instructions and database composition details before starting the writing task."
char define TimeWTP[description]               "Time (seconds) spent on the page deciding maximum willingness to pay to remove their post from the study database."
char define TimeWTPExplain[description]        "Time (seconds) spent providing a written explanation for factors influencing their willingness-to-pay decision."
*/


local RUN_SAMPLES "2 20"
foreach sample_number of local RUN_SAMPLES {
        

    foreach outcome in $OUTCOMES {
   
        * Default width
        local w = 1
        
        * Time variables (SD ~70-270) -> Width 50
        if inlist("`outcome'", "TimePost", "TimeInstructionsPost", "TimeWTP", "TimeWTPExplain", "TimePost_W", "TimeInstructionsPost_W", "TimeWTP_W", "TimeWTPExplain_W") local w = 50
        
        * Text Length (SD ~300) -> Width 50
        if "`outcome'" == "PostTextLength" local w = 50
               
        * Log Text Length (Range 0-7) -> Width 0.2
        if "`outcome'" == "PostTextLength_log" local w = 0.2
        
        * WTP (Range 0-10) -> Width 0.5
        if "`outcome'" == "WTP" local w = 0.5
        
        * Plot AI histogram
        twoway_histogram_AI, outcome(`outcome') sample_number(`sample_number') width(`w') subtitle("`outcome'")
        
        * Plot Identify histogram
        twoway_histogram_Identify, outcome(`outcome') sample_number(`sample_number') width(`w') subtitle("`outcome'")
    }
}


* =================================================================================
* Generic histograms for Control variables (per sample), Excluding the Base text
* =================================================================================

/*
di as text "=== Range + type + (optional) description for requested vars ==="

local PRE_TREATMENT_VARS "Grad_degree Vote Age ETH_Dummy Switzerland Female Instagram_use not_shared_handle ImageConcern index_Image_minus_privacy Donation index_Climate i.BotKnow i.InitialAIEffective i.BaseAIDiff i.ReadingReact1 i.GuessWriterHuman i.ReadingReact2 i.GuessWriterAI"

foreach raw of local PRE_TREATMENT_VARS {

    * Allow factor notation in the list (i.Var). We only want the base var name.
    local v = subinstr("`raw'","i.","",.)
    local v = subinstr("`v'","c.","",.)
    local v = subinstr("`v'","#","",.)   // just in case interactions show up later

    capture confirm variable `v'
    if _rc {
        di as error "`raw'  --> NOT FOUND (base var: `v')"
        di as text "------------------------------------------------------------"
        continue
    }

    quietly summarize `v', detail

    * Pull optional description from your dictionary (char var[prompt])
    local d : char `v'[prompt]
    if `"`d'"' == "" local d "(no description set; add char define `v'[prompt] ...)"

    * Determine variable "type" heuristically
    local vmin = r(min)
    local vmax = r(max)

    local type "continuous"
    if (`vmin'==0 & `vmax'==1) local type "binary"
    else if (`vmin' >= 0 & `vmax' <= 10 & floor(`vmin')==`vmin' & floor(`vmax')==`vmax') local type "small_discrete_int"

    * Suggested plotting range
    local lo = r(p1)
    local hi = r(p99)

    di as result "`raw'   (base: `v')"
    di as text   "Type guess: `type'"
    di as text   "Description: `d'"
    di as text   "Suggested x-range (p1–p99): [" %9.4f `lo' ", " %9.4f `hi' "]"
    di as text   "N=" %9.0g r(N) "  mean=" %9.4f r(mean) "  sd=" %9.4f r(sd)
    di as text   "min=" %9.4f r(min) "  p1=" %9.4f r(p1) "  p5=" %9.4f r(p5) "  p25=" %9.4f r(p25) ///
                 "  p50=" %9.4f r(p50) "  p75=" %9.4f r(p75) "  p95=" %9.4f r(p95) "  p99=" %9.4f r(p99) ///
                 "  max=" %9.4f r(max)
    di as text "------------------------------------------------------------"
}

*/

label define GuessWriter1 2 "Rule-based bot" 3 "Gen-AI bot", modify
label define GuessWriter2 2 "Rule-based bot" 3 "Gen-AI bot", modify


local RUN_SAMPLES "2 20"
foreach sample_number of local RUN_SAMPLES {
	
	* --- Social Media ---
	
	quietly count if ((YouTube==1 | Instagram==1 | LinkedIn==1 | Snapchat==1) & sample`sample_number'==1)
    local N = r(N)
	vennbar YouTube Instagram LinkedIn Snapchat, subtitle("(n=`N')", size(small))  ylab(, labsize(small)) bar(1, color(navy%70))
	graph export "$output_folder/sample`sample_number'/social_media_use_vennbar.pdf", replace
	
    local soc YouTube Instagram LinkedIn Snapchat TikTok Facebook_excl_Messenger X_Twitter BlueSky Reddit No_SoMe Other_SoMe
    preserve
    collapse (sum) `soc'
    foreach v of local soc {
        local clean_label = subinstr("`v'", "_", " ", .)
        label var `v' "`clean_label'"
    }
    graph bar (asis) `soc', asyvars showyvars ///
        ytitle("Count (value = 1)") ///
        legend(off) ///
        blabel(bar, format(%9.0g)) ///
        yvaroptions(label(angle(45) labsize(small)))
        
    graph export "$output_folder/sample`sample_number'/social_media_use_histogram.pdf", replace
    restore
	
	* --- Graphical Histograms ---
	
	preserve
	    nice_name_as_label
		
		hist ClimateWorry if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ///
			ytitle("") color(blue%30) ///
			xlabel(1 "Not at all worried" 5 "Extremely worried", labsize(small)) xscale(range(0 6))
		graph export "$output_folder/sample`sample_number'/single_var_hist/ClimateWorry_Dist.pdf", replace

		hist ClimatePersonal if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ///
			ytitle("") color(blue%30) ///
			xlabel(1 "Not at all responsible" 5 "Extremely responsible", labsize(small)) xscale(range(0 6))
		graph export "$output_folder/sample`sample_number'/single_var_hist/ClimatePersonal_Dist.pdf", replace

		hist ImageConcern if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ///
			ytitle("") color(blue%30) ///
			xlabel(1 "Not important at all" 5 "Extremely important", labsize(small)) xscale(range(0 6))
		graph export "$output_folder/sample`sample_number'/single_var_hist/ImageConcern_Dist.pdf", replace

		hist Donation if sample`sample_number'==1, frac width(2) ytitle("") color(blue%30) ///
			xscale(range(0 6))
		graph export "$output_folder/sample`sample_number'/single_var_hist/Donation_Dist.pdf", replace

		hist BotKnow if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ///
			ytitle("") color(blue%30) ///
			xlabel(5 "Familiar, Use frequently" 3 "Somewhat familiar, Use rarely" 1 "Not aware", labsize(small)) xscale(range(0 6))
		graph export "$output_folder/sample`sample_number'/single_var_hist/BotKnow_Dist.pdf", replace

		hist InitialAIEffective if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ///
			ytitle("") color(blue%30) ///
			xlabel(1 "Not at all effective" 5 "Extremely effective", labsize(small)) xscale(range(0 6))
		graph export "$output_folder/sample`sample_number'/single_var_hist/InitialAIEffective_Dist.pdf", replace

		hist BaseAIDiff if sample`sample_number'==1, frac discrete xlabel(1 2 3 4 5) width(0.5) ///
			ytitle("") color(blue%30) ///
			xlabel(1 "Not at all different" 5 "Extremely different", labsize(small)) xscale(range(0 6))
		graph export "$output_folder/sample`sample_number'/single_var_hist/BaseAIDiff_Dist.pdf", replace
	restore

	* --- General Histograms ---
	
    * --- Binary Variables ---
    * (The program automatically adds 0 and 1. Do NOT put 0 1 here)
    single_hist, var(Grad_degree)       sample_number(`sample_number') xlabel(labsize(small))
    single_hist, var(Vote)              sample_number(`sample_number') xlabel(labsize(small))
    single_hist, var(ETH)               sample_number(`sample_number') xlabel(labsize(small))
    single_hist, var(Switzerland)       sample_number(`sample_number') xlabel(labsize(small))
    single_hist, var(Female)            sample_number(`sample_number') xlabel(labsize(small))
    single_hist, var(Instagram_use)     sample_number(`sample_number') xlabel(labsize(small))
    single_hist, var(not_shared_handle) sample_number(`sample_number') xlabel(labsize(small))
    
    * --- Discrete Variables ---
    * (The program automatically adds integer ticks. Do NOT put 1(1)3 here)
    single_hist, var(ReadingReact1)    sample_number(`sample_number') xlabel(valuelabel labsize(small) alternate)
    single_hist, var(GuessWriter1) sample_number(`sample_number') xlabel(valuelabel labsize(small))
    single_hist, var(ReadingReact2)    sample_number(`sample_number') xlabel(valuelabel labsize(small) alternate)
    single_hist, var(GuessWriter2)    sample_number(`sample_number') xlabel(valuelabel labsize(small))
    
    * --- Continuous / Index Variables ---
    * (Specify your ticks and formatting together here)
    single_hist, var(Age)                       sample_number(`sample_number') width(1)
    single_hist, var(Donation)                  sample_number(`sample_number') width(5) xlabel(0(20)100, labsize(small))
    single_hist, var(index_Image_minus_privacy) sample_number(`sample_number') width(0.2)
	single_hist, var(index_Climate) 			sample_number(`sample_number') width(0.2)
	
	single_hist, var(index_Base_effort)                       sample_number(`sample_number') width(0.2)
	single_hist, var(index_Base_nlp)                       sample_number(`sample_number') width(0.2)
	single_hist, var(Base_AIness)                       sample_number(`sample_number') width(0.2)
	single_hist, var(index_ai_trust)                       sample_number(`sample_number') width(0.2)
	single_hist, var(index_bot_support)                       sample_number(`sample_number') width(0.2)
	single_hist, var(index_react)                       sample_number(`sample_number') width(0.2)
	single_hist, var(index_guess_human)                       sample_number(`sample_number') width(0.2)
	
	bot_histograms, sample(`sample_number')
}


// log close