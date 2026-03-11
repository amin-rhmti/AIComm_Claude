import pandas as pd
import numpy as np
import json
import re
import os
import time
from datetime import datetime
from openai import OpenAI


# ==============================================================================
# CONFIGURATION
# ==============================================================================
Output_version = "4omini"
INPUT_FILE = "../input/SwissSurvey_Insta_Experiment.dta"
OUTPUT_CSV = "SwissSurvey_Analysis_GPT_Measurements_" + Output_version + ".csv"
OUTPUT_DTA = "SwissSurvey_Analysis_GPT_Measurements_" + Output_version + ".dta"

API_KEY = "********************************"  # Replace with your actual OpenAI API key
MODEL_NAME = "gpt-4o-mini"
MAX_RETRIES = 3

# What to write when the text is empty
EMPTY_EXPLANATION = "Empty String"
EMPTY_SCORE = np.nan  # missing

client = OpenAI(api_key=API_KEY)

# Pricing ($ per 1M tokens)
MODEL_PRICING = {
    "gpt-4o-mini": {
        "input_per_mtoken": 0.150,
        "cached_input_per_mtoken": 0.075,
        "output_per_mtoken": 0.60,
    },
}

# Strings that commonly appear when missing values get cast to str(...)
_EMPTY_SENTINELS = {"nan", "none", "<na>", "null"}

# ==============================================================================
# CONTEXT & PROMPT DEFINITIONS (Must match original)
# ==============================================================================

CONTEXT_QUESTIONS = {
    "Post": (
        "How can you and other students in Zurich contribute to combating climate change in their daily lives?"
    ),
    "ClimateLong": (
        "What do you think are the most serious consequences of climate change for Europe and the world?"
    )
}

GPT_Measurements = {
    'personal_anecdote': "For the following response, assign a score of '0', '1' or '2' based on explicit or implicit usage of personal anecdotes (e.g., personal experience, habit, or story using first-person language like 'I', 'me', 'my', 'my friends', 'my family', 'at our university', etc.). Note that '0' is the lowest score – No personal anecdote at all.",
    
    'emotional_appeal': "For the following response, assign a score of '0', '1' or '2' based on its emotional appeal (e.g., explicitly or implicitly express distinct emotions like fear, anger, hope, sadness, anxiety, hope, anger, guilt, sadness OR usage of dramatic wording meant to evoke strong feelings about climate change, etc.).",
    
    'emotional_appeal_new': "For the following response, I have assigned a score of '1' out of {'0', '1', '2'} based on its emotional appeal (e.g., explicitly or implicitly express distinct emotions like fear, anger, hope, sadness, anxiety, etc.). If you disagree, assign a score of '0' or '2' based on its emotional appeal. If you agree with my score, just return '1', the original score.",
    
    'scientific_argument': "For the following response, assign a score of '0', '1' or '2' based on scientific arguments (e.g., statistical arguments, data driven arguments, referring a study, methodological structure in the response, etc.). Note that '0' is the lowest score – No scientific argument at all.",
    
    'progressive_score': "For the following response, assign a score of '0', '1' or '2' based on the ideological orientation of its proposed solutions or framing in a European political context. Assign '0' if it expresses right-wing positions (emphasis on market-based solutions, individual responsibility, voluntary action, technological innovation by private sector, minimal regulation), '1' if it is ideologically neutral or balanced (no clear ideological stance, or presents both market and regulatory approaches), and '2' if it expresses left-wing positions (emphasis on government regulation, collective action, social justice, wealth redistribution, strong climate mandates, or critique of capitalism/consumption).",
    
    'grammatical_mistakes': "For the following response, count the total number of grammatical mistakes (e.g., spelling errors, nontraditional spellings like informal spellings like \"gonna\" or \"u\" for \"you\", etc.). Return the exact number of errors in a digit format like '2'.",
    
    'moral_narratives': "For the following response, assign a score of '0', '1' or '2' based on explicit or implicit usage of moral narratives (e.g., framing the issue using terms of right/wrong, duty, justice, fairness, or ethical responsibility, moral judgments, etc.). Note that '0' is the lowest score – No moral narratives at all.",
    
    'causal_narratives': "For the following response, assign a score of '0', '1' or '2' based on its use of causal narratives (e.g., cause-effect relationships/mechanism, explanations of why things happen, structural logical relation of the clause as \"A\" causes/results in \"B\", etc.). Note that '0' is the lowest score – No causal narratives at all.",
    
    'sentiment': "For the following response, assign a score of '0', '1' or '2' based on its overall sentiment. Assign '0' if it expresses negative sentiment (pessimistic tone, negative emotions, critical language), 1 if it is neutral (balanced, factual, no clear emotional valence), and 2 if it expresses positive sentiment (optimistic tone, positive emotions, encouraging language).",
    
    'collective_action': "For the following response, assign a score of '0', '1' or '2' based on its emphasis on collective action or systemic responses. Assign 0 if it doesn't emphasize collective action at all (focuses on individual actions or no action framing), 1 if it mentions collective action occasionally (one or two references to community, government, or group responses), and 2 if it strongly emphasizes collective action (multiple calls for systemic change, community organizing, or group-level interventions).",
    
    'individual_action': "For the following response, assign a score of '0', '1' or '2' based on its emphasis on individual actions rather than collective actions. If the response mentions individual- or household-level actions that a person can take in daily life (e.g., using public transport, cycling, reducing flights, saving energy, reducing meat, recycling, buying second-hand, etc.), assign higher score. Note that '0' is the lowest score – No implicit or explicit mention of individual actions at all.",
    
    'local_focus': "For the following response, assign a score of '0', '1' or '2' based on its emphasis on Zurich, Switzerland, home town, home country, the local university, or the immediate local environment/community. Note that '0' is the lowest score – No implicit or explicit mention of local context.",
    
    'global_focus': "For the following response, assign a score of '0', '1' or '2' based on its emphasis on Europe, other countries, or the world as a whole (e.g., 'globally', 'worldwide', 'in Europe', 'in poorer/richer countries', etc.). Note that '0' is the lowest score – No implicit or explicit related content to outside of the local country.",
    
    'policy_action': "For the following response, assign a score of '0', '1' or '2' based on its policy-related content (e.g., government policies, laws, regulations, taxes, subsidies, government/public programs at city, canton, national, or EU level, etc.) as ways to address climate change. Note that '0' is the lowest score – No policy related content at all.",
    
    'economic_concern': "For the following response, assign a score of '0', '1' or '2' based on its economics content (e.g., discuss money, prices, taxes, financial costs, economic systems, etc.). Note that '0' is the lowest score – No economics related content at all.",
    
    'risk_consequence': "For the following response, assign a score of '0', '1' or '2' based on risk-related content (e.g., risks, harms, or consequences of climate changes like floods, fires, heatwaves, crop failures, sea level rise, health impacts, etc.). Note that '0' is the lowest score – No risk related content at all.",
    
    'privacy_concern_guess': "Your task is to infer how concerned this person seems to be about PRIVACY, especially regarding online data and social media platforms such as Instagram (e.g., data collection, tracking, profiling, surveillance, targeted ads, exposure of personal information, digital footprint, etc.). Use the following scale to rate the person's IMPLIED PRIVACY CONCERN based ONLY on the content of their answer:\n•\t'-1' = There is no IMPLICIT or Explicit information in the answer about privacy, data, surveillance, or social media risks.\n•\t'0' = No or very low privacy concern\no\tThe answer shows no indication of worrying about privacy.\no\tThe person freely suggests or accepts the use of social media / digital tools / data collection without mentioning any downside for privacy.\n•\t'1' = Moderate or implicit privacy concern\no\tThe answer contains mild, indirect, or ambiguous signs of privacy concern.\no\tExample signals: mentions of \"being careful what you share,\" wanting some control over data, mild concern about big tech or algorithms, but not very strong or emotional.\no\tPrivacy is not the main theme, and Instagram / social media privacy may be mentioned only briefly or implicitly.\n•\t'2' = Strong privacy concern\no\tThe answer clearly expresses strong concern about privacy, especially related to social media (e.g., Instagram), apps, or online platforms.\no\tExample signals: worrying about surveillance, tracking, data misuse, profiling by companies or governments, fear of personal information leaking, avoiding or limiting social media because of privacy concerns, insistence on anonymity or strict control over what is shared.\no\tPrivacy risks are a clear and important theme in the answer.\nImportant:\n•\tThe original question is about climate change. You should still look for any hints about privacy-related concern (both inside or outside the digital or social media realm).\n•\tIf the answer contains no information at all related to privacy, data, or social media, assign a score of '-1' by default.",
    
    'Image_concern_guess': "Your task is to infer how concerned this person seems to be about their IMAGE and how they are perceived by others, especially in a social or social-media context (e.g., wanting to look good, be admired, appear responsible, avoid judgment, manage their reputation on platforms like Instagram).\nFocus on:\n•\tHow much they seem to care about what others think of them.\n•\tWhether their answer sounds performative, reputation-seeking, or driven by social approval.\n•\tSignals of self-presentation, virtue-signaling, or wanting to be seen as a \"good\" or \"responsible\" person.\n•\tAny explicit or implicit references to social media, online image, or public perception.\nRate the person's IMPLIED IMAGE CONCERN using this scale:\n•\t'-1' = There is no IMPLICIT or Explicit information in the answer about image, reputation, or how others see them.\n•\t'0' = No or very low image concern\no\tThe answer is straightforward, practical, or factual with no signs of worrying about how they look to others.\no\tNo indication of wanting to impress, appear virtuous, or manage their public image.\no\tNo references to reputation, social judgment, or social media image.\n•\t'1' = Moderate or implicit image concern\no\tThe answer contains mild or indirect signs that the person cares about how they are perceived.\no\tExample signals: wanting to \"set a good example,\" mentioning what \"people should think\" or \"what others will say,\" polite or socially desirable phrasing that hints at reputation but is not a dominant theme.\no\tThey may describe actions that make them or their group look good, but without strong emphasis on image.\no\tSocial media / Instagram may be mentioned, but not as a strong, central concern.\n•\t'2' = Strong image concern\no\tThe answer clearly suggests that reputation, social approval, or looking good to others is highly important.\no\tExample signals: emphasis on appearing responsible, being admired, being seen as moral or progressive, worrying about judgment from peers, caring about likes/followers, curating what is posted, or explicitly referencing how they \"look\" on Instagram or other platforms.\no\tSelf-presentation, public perception, or social-media image is a clear theme in the answer.\nImportant:\n•\tThe original question is about climate change. Still, you should look for any hints that the respondent frames their actions or opinions in terms of how they will be seen by others (offline or online).\n•\tIf the answer contains no information related to image, reputation, social perception, etc. at all, assign a score of '-1' by default.",
    
    'ai_technology': "For the following response, assign a score of '0', '1' or '2' based on whether it mentions or relates to artificial intelligence and its role in addressing climate change. Assign '0' if it contains no reference to AI, machine learning, algorithms, smart systems, automation, or intelligent technology, '1' if it contains brief or passing mention of AI/smart technology (e.g., \"use smart thermostats,\" \"AI could help,\" mentioned once without elaboration), and '2' if it significantly emphasizes AI or intelligent systems as solutions (multiple mentions, discusses specific AI applications like optimization algorithms, predictive models, smart grids, automated systems, or AI's potential role in detail).",
    
    'typos_count': "For the following response, count the total number of clear typographical errors: misspelled words, transposed letters (e.g., 'teh' for 'the'), omitted or duplicated letters, missing spaces, or repeated words. Do not count intentional informal spellings (e.g., 'u', 'gonna'), punctuation choices, or wrong-word grammatical errors (e.g., 'their' vs. 'there'). If there are no typos, the count is 0. Return the exact number of typos in a digit format like '2'.",
    
    'ai_likelihood': "For the following response, evaluate the likelihood that the text was generated by an AI. Keep in mind the context: humans taking surveys frequently write short, terse sentence fragments, bullet points, or unformatted keyword lists (e.g., 'floods, heat, migration') to save time. This brevity is a strong indicator of human writing, as AI tends to be overly verbose. Assign a score of '0', '1', '2', or '3': '0' = Definitely not AI (probability < 5%; strong personal voice, typos, irregular grammar, OR terse, fragmented keyword lists/shorthand typical of quick survey answers). '1' = Low chance of AI (probability 5%-50%; brief but neat lists of concepts, or natural but formal flow without AI verbosity). '2' = High chance of AI (probability 50%-95%; overly balanced, formulaic paragraph structure, excessive transitions, or frequent use of AI vocabulary like 'delve', 'multifaceted', 'crucial'). '3' = Definitely AI (probability > 95%; multiple strong AI markers, verbose disclaimer-style phrasing, exhaustive heavily-formatted lists with bolding/descriptions, and unnatural comprehensiveness). Return the exact score in a digit format like '2'.",
    
    'meaningfulness': "For the following response, assign a score of '0' or '1' for whether it is a meaningful, on-topic answer.\n•\t1 if the response is coherent and clearly related to climate change, the environment, or its consequences, even if it does not directly list specific actions the respondent can take. Treat any well-formed reflection, opinion, or description about climate change or its impacts as meaningful and return 1.\n•\t0 only if the response is empty, pure gibberish, or clearly unrelated to climate or the environment (e.g., random jokes, spam, etc.)."
}

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

def estimate_cost_usd(usage_obj, model_name: str) -> float:
    """
    Estimate cost in USD for a single API call based on token usage and model.
    Counts cached input tokens when available (prompt_tokens_details.cached_tokens).
    """
    if usage_obj is None:
        return 0.0

    prices = MODEL_PRICING.get(model_name)
    if not prices:
        return 0.0

    input_rate = prices.get("input_per_mtoken", 0.0) / 1_000_000
    cached_rate = prices.get("cached_input_per_mtoken", input_rate) / 1_000_000
    output_rate = prices.get("output_per_mtoken", 0.0) / 1_000_000

    prompt_tokens = getattr(usage_obj, "prompt_tokens", 0) or 0
    completion_tokens = getattr(usage_obj, "completion_tokens", 0) or 0

    cached_tokens = 0
    prompt_details = getattr(usage_obj, "prompt_tokens_details", None)
    if prompt_details is not None:
        if hasattr(prompt_details, "cached_tokens"):
            cached_tokens = getattr(prompt_details, "cached_tokens", 0) or 0
        elif isinstance(prompt_details, dict):
            cached_tokens = prompt_details.get("cached_tokens", 0) or 0

    cached_tokens = max(0, min(prompt_tokens, cached_tokens))
    non_cached_tokens = prompt_tokens - cached_tokens

    return (
        non_cached_tokens * input_rate
        + cached_tokens * cached_rate
        + completion_tokens * output_rate
    )


def _clean_and_extract_json(raw_content: str) -> str:
    """
    Best-effort cleanup if the model returns markdown-wrapped JSON or extra text.
    """
    if raw_content is None:
        return "{}"
    cleaned = raw_content.strip()

    cleaned = re.sub(r"^```json\s*", "", cleaned)
    cleaned = re.sub(r"^```\s*", "", cleaned)
    cleaned = re.sub(r"\s*```$", "", cleaned).strip()

    if not cleaned.startswith("{"):
        m = re.search(r"\{.*\}", cleaned, re.DOTALL)
        if m:
            cleaned = m.group(0).strip()

    return cleaned


def normalize_text(cell) -> str:
    """
    Robust empty detection:
      - pd.isna -> ""
      - whitespace-only -> ""
      - stringified missing sentinels like "nan", "None", "<NA>", "null" -> ""
    Returns a stripped string (or empty string).
    """
    if pd.isna(cell):
        return ""
    s = str(cell).strip()
    if s == "":
        return ""
    if s.lower() in _EMPTY_SENTINELS:
        return ""
    return s


def query_gpt_variable(question: str, response: str, measurement: str, prompt: str) -> tuple[int, str, float]:
    """
    Calls GPT for a specific (text, measurement).
    Returns (score_int, explanation, cost_usd).
    On failure returns (-100, "Error ...", cost_if_any).
    """
    system_content = (
        "You are assisting a researcher in cleaning and classifying open-ended survey data by assigning scores "
        "to participants’ open-ended responses.\n\n"
        f'The original survey question that the participant responded to is: "{question}"\n\n'
        f"{prompt}\n\n"
        "Provide a concise explanation of your scoring decision in approximately 100 words, citing specific examples "
        "from the original response.\n\n"
        f'Your answer must follow this exact JSON format: {{ "measurement": "{measurement}", "score": "your score here", '
        '"explanation": "your explanation here in approximately 100 words" }}\n'
        "Do not include any text outside of this JSON structure."
    )

    messages = [
        {"role": "developer", "content": system_content},
        {"role": "user", "content": str(response)},
    ]

    last_exception = None
    last_cost = 0.0

    for attempt in range(MAX_RETRIES):
        try:
            # Prefer JSON mode. If unsupported for any reason, fall back.
            try:
                resp = client.chat.completions.create(
                    model=MODEL_NAME,
                    messages=messages,
                    temperature=0,
                    top_p=1,
                    response_format={"type": "json_object"},
                )
            except Exception:
                resp = client.chat.completions.create(
                    model=MODEL_NAME,
                    messages=messages,
                    temperature=0,
                    top_p=1,
                )

            raw_content = (resp.choices[0].message.content or "").strip()
            cleaned_content = _clean_and_extract_json(raw_content)
            data = json.loads(cleaned_content)

            score = data.get("score", "0")
            explanation = data.get("explanation", "")

            try:
                score_int = int(score)
            except Exception:
                if isinstance(score, str) and score:
                    m = re.search(r"\d+", score)
                    score_int = int(m.group(0)) if m else 0
                else:
                    score_int = 0

            cost = estimate_cost_usd(resp.usage, MODEL_NAME)
            return score_int, explanation, cost

        except Exception as e:
            last_exception = e
            try:
                last_cost = estimate_cost_usd(resp.usage, MODEL_NAME)  # noqa: F821
            except Exception:
                pass

            if attempt < MAX_RETRIES - 1:
                time.sleep(1)
            else:
                print(f"FAILED {measurement} after {MAX_RETRIES} attempts: {last_exception}")
                return -100, "Error in API call or Parsing", last_cost


# ==============================================================================
# FAILURE REPAIR (redo only cells with -100)
# ==============================================================================

def fix_failed_measurements(csv_path: str = OUTPUT_CSV, max_retries: int = 3) -> dict:
    """
    Re-runs ONLY the (ResponseId, column, measurement) cells where the score == -100.
    Skips API calls for empty text.
    Updates score, explanation, and adds incremental cost to the row's Cost.
    """
    print(f"Loading CSV from {csv_path}...")

    try:
        df = pd.read_csv(csv_path, dtype={"ResponseId": str})
    except Exception as e:
        print(f"Error loading CSV: {e}")
        return {"total_failures": 0, "fixed": 0, "still_failed": 0}

    if "model_name" not in df.columns:
        df["model_name"] = MODEL_NAME

    target_columns = ["Post", "ClimateLong"]
    measurement_names = list(GPT_Measurements.keys())

    failures = []
    for idx, row in df.iterrows():
        if str(row.get("model_name", MODEL_NAME)) != MODEL_NAME:
            continue

        for col_target in target_columns:
            for measure_name in measurement_names:
                score_col = f"{col_target}-{measure_name}"
                if score_col not in df.columns:
                    continue

                if row[score_col] == -100:
                    failures.append((idx, col_target, measure_name))

    stats = {
        "total_failures": len(failures),
        "fixed": 0,
        "still_failed": 0,
    }

    if not failures:
        print("✅ No failures found! Nothing to fix.")
        return stats

    print(f"🔍 Found {len(failures)} failed cells (-100). Retrying...")

    old_max = globals().get("MAX_RETRIES", 3)
    globals()["MAX_RETRIES"] = max_retries

    try:
        for i, (idx, col_target, measure_name) in enumerate(failures, 1):
            rid = str(df.at[idx, "ResponseId"])

            # IMPORTANT: we do NOT modify df[col_target] itself; only use normalized copy for calling
            text_norm = normalize_text(df.at[idx, col_target])

            print(f"[{i}/{len(failures)}] Retrying ResponseId={rid} | {col_target}-{measure_name}")

            # Empty => do NOT call API; set missing score + marker explanation
            if text_norm == "":
                df.at[idx, f"{col_target}-{measure_name}"] = EMPTY_SCORE
                df.at[idx, f"{col_target}-{measure_name}-explanation"] = EMPTY_EXPLANATION
                stats["fixed"] += 1
                continue

            question_ctx = CONTEXT_QUESTIONS[col_target]
            measure_prompt = GPT_Measurements[measure_name]

            score, explanation, cost = query_gpt_variable(
                question=question_ctx,
                response=text_norm,
                measurement=measure_name,
                prompt=measure_prompt,
            )

            if score != -100:
                df.at[idx, f"{col_target}-{measure_name}"] = score
                df.at[idx, f"{col_target}-{measure_name}-explanation"] = explanation

                if "Cost" not in df.columns:
                    df["Cost"] = 0.0
                try:
                    df.at[idx, "Cost"] = float(df.at[idx, "Cost"]) + float(cost)
                except Exception:
                    df.at[idx, "Cost"] = float(cost)

                stats["fixed"] += 1
            else:
                stats["still_failed"] += 1
    finally:
        globals()["MAX_RETRIES"] = old_max

    print(f"💾 Saving updated CSV to {csv_path}...")
    df.to_csv(csv_path, index=False, encoding="utf-8")
    print("✅ CSV updated.")

    try:
        df.to_stata(OUTPUT_DTA, write_index=False, version=118)
        print(f"✅ Stata file refreshed: {OUTPUT_DTA}")
    except Exception as e:
        print(f"Warning: Could not save Stata file after fixes. {e}")

    print("SUMMARY:", stats)
    return stats


# ==============================================================================
# MAIN PROCESSING (INCREMENTAL CSV WRITES)
# ==============================================================================

def main():
    print("Loading Stata file or existing DataFrame...")
    try:
        df_full = pd.read_stata(INPUT_FILE)
    except FileNotFoundError:
        print(f"File not found at {INPUT_FILE}. Please check path.")
        return
    except Exception as e:
        try:
            df_full = pd.read_csv(INPUT_FILE)
        except Exception as e2:
            print(f"Could not load data from INPUT_FILE as Stata or CSV: {e} | {e2}")
            return

    required_cols = ["ResponseId", "Post", "ClimateLong"]
    missing = [c for c in required_cols if c not in df_full.columns]
    if missing:
        print(f"Missing columns in input: {missing}")
        return

    df = df_full[required_cols].copy()
    total_rows = len(df)

    print(f"Data loaded. Rows: {total_rows}. Measurements per text: {len(GPT_Measurements)}.")
    print(f"Model: {MODEL_NAME} (temperature=0, top_p=1)")

    processed_ids = set()
    total_batch_cost = 0.0

    if os.path.exists(OUTPUT_CSV):
        try:
            existing_df = pd.read_csv(OUTPUT_CSV, dtype={"ResponseId": str})
            if "model_name" not in existing_df.columns:
                existing_df["model_name"] = MODEL_NAME
                existing_df.to_csv(OUTPUT_CSV, index=False, encoding="utf-8")
                print("Upgraded existing CSV schema by adding 'model_name' column.")

            existing_df = existing_df[existing_df["model_name"].astype(str) == MODEL_NAME].copy()
            processed_ids = set(existing_df["ResponseId"].astype(str))

            if "Cost" in existing_df.columns:
                total_batch_cost = existing_df["Cost"].sum()

            print(
                f"Found existing CSV with {len(existing_df)} rows for model={MODEL_NAME}. "
                "Will resume and skip already processed ResponseIds."
            )
        except Exception as e:
            print(f"Warning: Could not read existing CSV for resume. Starting fresh. ({e})")

    print("Starting Main Loop...")

    target_columns = ["Post", "ClimateLong"]
    processed_count = 0

    for idx, row in df.iterrows():
        rid = row["ResponseId"]
        rid_str = str(rid)

        if rid_str in processed_ids:
            continue

        print(f"Processing ResponseId: {rid_str} ({idx + 1}/{total_rows})")

        # IMPORTANT: keep original text columns untouched
        row_data = {
            "ResponseId": rid,
            "Date_log_gptapi": datetime.utcnow().isoformat(),
            "Post": row["Post"],
            "ClimateLong": row["ClimateLong"],
            "Cost": 0.0,
            "model_name": MODEL_NAME,
        }

        row_total_cost = 0.0

        for col_target in target_columns:
            # normalized copy only for decision/calling
            text_norm = normalize_text(row[col_target])

            # Empty => do NOT call API; missing score + marker explanation
            if text_norm == "":
                for measure_name in GPT_Measurements.keys():
                    row_data[f"{col_target}_{measure_name}"] = EMPTY_SCORE
                    row_data[f"{col_target}_{measure_name}_explanation"] = EMPTY_EXPLANATION
                continue

            question_ctx = CONTEXT_QUESTIONS[col_target]

            for measure_name, measure_prompt in GPT_Measurements.items():
                score, explanation, cost = query_gpt_variable(
                    question=question_ctx,
                    response=text_norm,
                    measurement=measure_name,
                    prompt=measure_prompt,
                )

                row_data[f"{col_target}-{measure_name}"] = score
                row_data[f"{col_target}-{measure_name}-explanation"] = explanation
                row_total_cost += cost

        row_data["Cost"] = row_total_cost
        total_batch_cost += row_total_cost
        processed_count += 1

        df_row = pd.DataFrame([row_data])
        file_exists = os.path.exists(OUTPUT_CSV)
        df_row.to_csv(
            OUTPUT_CSV,
            mode="a",
            header=not file_exists,
            index=False,
            encoding="utf-8",
        )

        if processed_count % 5 == 0:
            print(
                f"Processed {processed_count} new rows "
                f"(last index {idx + 1}/{total_rows}) | "
                f"Last Row Cost: ${row_total_cost:.4f}"
            )

    print("\nProcessing Complete.")
    print(f"Total Batch Cost (including prior runs if any): ${total_batch_cost:.2f}")

    try:
        final_df = pd.read_csv(OUTPUT_CSV)
        final_df.to_stata(OUTPUT_DTA, write_index=False, version=118)
        print(f"Stata file saved to: {OUTPUT_DTA}")
    except Exception as e:
        print(f"Warning: Could not save Stata file (likely column name limits). {e}")


if __name__ == "__main__":
    main()

    print("\n" + "=" * 60)
    print("FIXING FAILED MEASUREMENTS (-100 CELLS)")
    print("=" * 60)

    fix_failed_measurements(
        csv_path=OUTPUT_CSV,
        max_retries=3,
    )
