"""Shared, non-sensitive project configuration.

All people, places, identifiers, and responses produced from this configuration
are fictional and synthetic. Fixed dates are intentional so regeneration does
not depend on the computer's clock.
"""

from __future__ import annotations

SEED = 20260710
N_RESPONSES = 420
N_BASE_RESPONSES = 410
SURVEY_VERSION = "1.0.0"
DATASET_LABEL = "SYNTHETIC DATA - NOT REAL PEOPLE OR PROGRAMME OPERATIONS"
SURVEY_START = "2025-04-01"
SURVEY_END = "2025-09-30"
REFERENCE_DATE = "2025-10-01"

REGIONS = {
    "NORTH": ["N01", "N02", "N03"],
    "SOUTH": ["S01", "S02", "S03"],
    "EAST": ["E01", "E02", "E03"],
    "WEST": ["W01", "W02", "W03"],
}

REGION_LABELS = {
    "NORTH": "North Region (fictional)",
    "SOUTH": "South Region (fictional)",
    "EAST": "East Region (fictional)",
    "WEST": "West Region (fictional)",
}

ENUMERATORS = [f"ENUM_{i:02d}" for i in range(1, 9)]
SURVEY_ROUNDS = ["ROUND_1", "ROUND_2"]
YES_NO = ["yes", "no"]
AGE_GROUPS = ["18_24", "25_34", "35_44", "45_54", "55_plus"]
GENDERS = ["woman", "man", "non_binary", "prefer_not"]
TRAINING_TOPICS = ["planning", "financial_skills", "digital_skills", "leadership"]
PREFERRED_CHANNELS = ["community_meeting", "printed_material", "radio", "none"]

COMMENT_THEMES = {
    "positive": [
        "The practical examples made the sessions easier to understand.",
        "The facilitator explained the topic clearly and respectfully.",
        "I have already used one of the planning tools from the session.",
        "The group activities helped me learn from other participants.",
    ],
    "timing": [
        "The session was useful, but the timing conflicted with other responsibilities.",
        "Shorter sessions on more days would be easier to attend.",
        "The activity should start earlier so participants can travel home safely.",
    ],
    "access": [
        "Travel to the meeting location was difficult during bad weather.",
        "A location closer to the community would improve attendance.",
        "Printed materials would help people who cannot attend every session.",
    ],
    "content_request": [
        "I would like more examples about budgeting and record keeping.",
        "A follow-up session on digital tools would be helpful.",
        "More time for questions and practice would improve the training.",
    ],
}

DATA_DICTIONARY = [
    ("submission_id", "string", "Unique synthetic submission identifier", "non-missing; unique", "all"),
    ("response_id", "string", "Intended unique monitoring response identifier", "SYN-0001 format; unique", "all"),
    ("synthetic_data", "string", "Explicit synthetic-data marker", "must equal yes", "all"),
    ("survey_version", "string", "Version of the survey instrument", SURVEY_VERSION, "all"),
    ("survey_round", "categorical", "Monitoring round", "ROUND_1 or ROUND_2", "consent=yes"),
    ("interview_date", "date", "Synthetic interview date", f"{SURVEY_START} to {SURVEY_END}", "consent=yes"),
    ("program_start_date", "date", "Start date of the fictional activity", "on/before interview_date", "consent=yes"),
    ("region_code", "categorical", "Fictional region code", "NORTH, SOUTH, EAST, WEST", "consent=yes"),
    ("site_code", "categorical", "Fictional site code", "must belong to selected region", "consent=yes"),
    ("enumerator_code", "categorical", "Fictional enumerator identifier", "ENUM_01 to ENUM_08", "consent=yes"),
    ("consent", "categorical", "Agreement to continue the fictional survey", "yes or no", "all"),
    ("age_group", "categorical", "Age band; no exact birth date collected", ", ".join(AGE_GROUPS), "consent=yes"),
    ("gender", "categorical", "Self-described gender category", ", ".join(GENDERS), "consent=yes"),
    ("household_size", "integer", "Number of people in the household", "1 to 20", "consent=yes"),
    ("disability_access", "categorical", "Whether accessibility support was needed", "yes or no", "consent=yes"),
    ("participated_training", "categorical", "Participation in the fictional training", "yes or no", "consent=yes"),
    ("training_date", "date", "Date of training attendance", "program_start_date through interview_date", "participated_training=yes"),
    ("training_topic", "categorical", "Main training topic", ", ".join(TRAINING_TOPICS), "participated_training=yes"),
    ("satisfaction_score", "integer", "Satisfaction rating", "1 to 5", "participated_training=yes"),
    ("knowledge_before", "integer", "Self-rated knowledge before training", "1 to 5", "participated_training=yes"),
    ("knowledge_after", "integer", "Self-rated knowledge after training", "1 to 5", "participated_training=yes"),
    ("used_skill", "categorical", "Whether a training skill has been applied", "yes or no", "participated_training=yes"),
    ("service_access", "integer", "Ease of accessing services", "1 to 5", "consent=yes"),
    ("follow_up_requested", "categorical", "Whether more information was requested", "yes or no", "consent=yes"),
    ("preferred_channel", "categorical", "Non-personal follow-up channel", ", ".join(PREFERRED_CHANNELS), "follow_up_requested=yes"),
    ("open_comment", "text", "Optional synthetic qualitative comment", "optional; synthetic phrase library", "consent=yes"),
    ("completion_minutes", "number", "Synthetic interview duration in minutes", "3 to 60", "consent=yes"),
]

