"""Generate the portfolio's reproducible synthetic survey data.

Usage from the repository root:
    python scripts/generate_synthetic_data.py

The script deliberately injects documented data-quality problems. It never
uses or attempts to imitate real personal data.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
import pandas as pd

from project_config import (
    AGE_GROUPS,
    COMMENT_THEMES,
    DATASET_LABEL,
    DATA_DICTIONARY,
    ENUMERATORS,
    GENDERS,
    N_BASE_RESPONSES,
    N_RESPONSES,
    PREFERRED_CHANNELS,
    REFERENCE_DATE,
    REGIONS,
    SEED,
    SURVEY_END,
    SURVEY_ROUNDS,
    SURVEY_START,
    SURVEY_VERSION,
    TRAINING_TOPICS,
)

ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = ROOT / "data" / "raw"


def weighted_choice(rng: np.random.Generator, values: list[str], weights: list[float], size: int) -> np.ndarray:
    return rng.choice(values, p=np.asarray(weights) / np.sum(weights), size=size)


def iso_date(value: pd.Timestamp | pd.NaT) -> str:
    return "" if pd.isna(value) else value.strftime("%Y-%m-%d")


def build_clean_base(rng: np.random.Generator) -> pd.DataFrame:
    n = N_BASE_RESPONSES
    interview_dates = pd.to_datetime(SURVEY_START) + pd.to_timedelta(
        rng.integers(0, (pd.Timestamp(SURVEY_END) - pd.Timestamp(SURVEY_START)).days + 1, n), unit="D"
    )
    program_offsets = rng.integers(30, 150, n)
    program_dates = interview_dates - pd.to_timedelta(program_offsets, unit="D")

    regions = weighted_choice(rng, list(REGIONS), [0.26, 0.24, 0.28, 0.22], n)
    sites = [rng.choice(REGIONS[region]) for region in regions]
    consent = weighted_choice(rng, ["yes", "no"], [0.98, 0.02], n)
    participated = weighted_choice(rng, ["yes", "no"], [0.74, 0.26], n)
    follow_up = weighted_choice(rng, ["yes", "no"], [0.31, 0.69], n)

    knowledge_before = rng.integers(1, 5, n)
    improvement = weighted_choice(rng, [0, 1, 2], [0.18, 0.57, 0.25], n).astype(int)
    knowledge_after = np.minimum(5, knowledge_before + improvement)
    training_dates = [
        start + pd.to_timedelta(int(rng.integers(0, max(1, (end - start).days + 1))), unit="D")
        for start, end in zip(program_dates, interview_dates)
    ]

    df = pd.DataFrame(
        {
            "submission_id": [f"SUB-{i:04d}" for i in range(1, n + 1)],
            "response_id": [f"SYN-{i:04d}" for i in range(1, n + 1)],
            "synthetic_data": "yes",
            "survey_version": SURVEY_VERSION,
            "survey_round": weighted_choice(rng, SURVEY_ROUNDS, [0.48, 0.52], n),
            "interview_date": [iso_date(x) for x in interview_dates],
            "program_start_date": [iso_date(x) for x in program_dates],
            "region_code": regions,
            "site_code": sites,
            "enumerator_code": rng.choice(ENUMERATORS, n),
            "consent": consent,
            "age_group": weighted_choice(rng, AGE_GROUPS, [0.18, 0.30, 0.25, 0.17, 0.10], n),
            "gender": weighted_choice(rng, GENDERS, [0.53, 0.43, 0.02, 0.02], n),
            "household_size": np.clip(rng.poisson(4.2, n) + 1, 1, 12),
            "disability_access": weighted_choice(rng, ["yes", "no"], [0.12, 0.88], n),
            "participated_training": participated,
            "training_date": [iso_date(x) for x in training_dates],
            "training_topic": weighted_choice(rng, TRAINING_TOPICS, [0.28, 0.29, 0.24, 0.19], n),
            "satisfaction_score": weighted_choice(rng, [1, 2, 3, 4, 5], [0.03, 0.07, 0.20, 0.43, 0.27], n).astype(int),
            "knowledge_before": knowledge_before,
            "knowledge_after": knowledge_after,
            "used_skill": weighted_choice(rng, ["yes", "no"], [0.63, 0.37], n),
            "service_access": weighted_choice(rng, [1, 2, 3, 4, 5], [0.05, 0.12, 0.28, 0.36, 0.19], n).astype(int),
            "follow_up_requested": follow_up,
            "preferred_channel": rng.choice(PREFERRED_CHANNELS[:-1], n),
            "open_comment": "",
            "completion_minutes": np.round(np.clip(rng.normal(18, 6, n), 4, 45), 1),
        }
    )

    # Conditional questions need genuine blanks in the raw CSV. Object dtype
    # allows those blanks without relying on pandas' deprecated implicit casts.
    df = df.astype(object)

    training_fields = [
        "training_date",
        "training_topic",
        "satisfaction_score",
        "knowledge_before",
        "knowledge_after",
        "used_skill",
    ]
    df.loc[df["participated_training"] == "no", training_fields] = ""
    df.loc[df["follow_up_requested"] == "no", "preferred_channel"] = ""

    no_consent_fields = [
        c for c in df.columns if c not in {"submission_id", "response_id", "synthetic_data", "survey_version", "consent"}
    ]
    df.loc[df["consent"] == "no", no_consent_fields] = ""

    eligible_comments = df.index[(df["consent"] == "yes") & (df["participated_training"] == "yes")]
    comment_rows = rng.choice(eligible_comments, size=72, replace=False)
    theme_names = list(COMMENT_THEMES)
    for row in comment_rows:
        theme = rng.choice(theme_names, p=[0.42, 0.20, 0.19, 0.19])
        df.at[row, "open_comment"] = rng.choice(COMMENT_THEMES[theme])

    return df


def inject_quality_issues(df: pd.DataFrame, rng: np.random.Generator) -> tuple[pd.DataFrame, list[dict[str, str]]]:
    issues: list[dict[str, str]] = []
    eligible = df.index[df["consent"] == "yes"].to_numpy()
    rng.shuffle(eligible)
    cursor = 0

    def take(count: int) -> np.ndarray:
        nonlocal cursor
        rows = eligible[cursor : cursor + count]
        cursor += count
        return rows

    def record(row: int, issue_type: str, field: str, reason: str) -> None:
        issues.append(
            {
                "issue_type": issue_type,
                "submission_id": str(df.at[row, "submission_id"]),
                "response_id": str(df.at[row, "response_id"]),
                "field": field,
                "reason": reason,
            }
        )

    for row, field in zip(take(8), ["region_code", "site_code", "age_group", "gender"] * 2):
        df.at[row, field] = ""
        record(row, "missing_required", field, "Required field deliberately blank")

    invalid_specs = [
        ("region_code", "CENTRAL"),
        ("site_code", "X99"),
        ("enumerator_code", "ENUM_99"),
        ("age_group", "under_18"),
        ("gender", "unknown_code"),
        ("training_topic", "other_invalid"),
    ]
    for row, (field, value) in zip(take(len(invalid_specs)), invalid_specs):
        if field == "training_topic" and df.at[row, "participated_training"] == "no":
            df.at[row, "participated_training"] = "yes"
            df.at[row, "training_date"] = df.at[row, "interview_date"]
            df.at[row, "satisfaction_score"] = 3
            df.at[row, "knowledge_before"] = 2
            df.at[row, "knowledge_after"] = 3
            df.at[row, "used_skill"] = "yes"
        df.at[row, field] = value
        record(row, "invalid_code", field, f"Invalid code deliberately set to {value}")

    date_rows = take(6)
    for position, row in enumerate(date_rows):
        if position < 2:
            df.at[row, "program_start_date"] = (
                pd.Timestamp(df.at[row, "interview_date"]) + pd.Timedelta(days=14)
            ).strftime("%Y-%m-%d")
            field, reason = "program_start_date", "Programme start deliberately after interview"
        elif position < 4:
            df.at[row, "interview_date"] = "2026-01-15"
            field, reason = "interview_date", "Interview deliberately outside survey period"
        else:
            df.at[row, "participated_training"] = "yes"
            df.at[row, "training_date"] = "2024-12-15"
            df.at[row, "training_topic"] = "planning"
            df.at[row, "satisfaction_score"] = 4
            df.at[row, "knowledge_before"] = 2
            df.at[row, "knowledge_after"] = 4
            df.at[row, "used_skill"] = "yes"
            field, reason = "training_date", "Training deliberately before programme start"
        record(row, "inconsistent_date", field, reason)

    outlier_specs = [
        ("household_size", 0),
        ("household_size", 45),
        ("household_size", 99),
        ("completion_minutes", 1),
        ("completion_minutes", 180),
        ("satisfaction_score", 9),
    ]
    for row, (field, value) in zip(take(len(outlier_specs)), outlier_specs):
        if field == "satisfaction_score" and df.at[row, "participated_training"] == "no":
            df.at[row, "participated_training"] = "yes"
            df.at[row, "training_date"] = df.at[row, "interview_date"]
            df.at[row, "training_topic"] = "planning"
            df.at[row, "knowledge_before"] = 2
            df.at[row, "knowledge_after"] = 3
            df.at[row, "used_skill"] = "no"
        df.at[row, field] = value
        record(row, "out_of_range", field, f"Out-of-range value deliberately set to {value}")

    skip_rows = take(8)
    for position, row in enumerate(skip_rows):
        if position < 5:
            df.at[row, "participated_training"] = "no"
            df.at[row, "training_date"] = df.at[row, "interview_date"]
            df.at[row, "training_topic"] = "digital_skills"
            df.at[row, "satisfaction_score"] = 4
            df.at[row, "knowledge_before"] = 2
            df.at[row, "knowledge_after"] = 4
            df.at[row, "used_skill"] = "yes"
            field, reason = "training_topic", "Training fields populated when participation is no"
        else:
            df.at[row, "follow_up_requested"] = "no"
            df.at[row, "preferred_channel"] = "radio"
            field, reason = "preferred_channel", "Channel populated when follow-up request is no"
        record(row, "skip_logic_violation", field, reason)

    mismatch_rows = take(4)
    wrong_site = {"NORTH": "S01", "SOUTH": "E01", "EAST": "W01", "WEST": "N01"}
    for row in mismatch_rows:
        df.at[row, "site_code"] = wrong_site[df.at[row, "region_code"]]
        record(row, "consistency_violation", "site_code", "Site deliberately does not belong to region")

    duplicate_sources = rng.choice(df.index[df["consent"] == "yes"], size=N_RESPONSES - len(df), replace=False)
    duplicates = df.loc[duplicate_sources].copy()
    for number, (source_row, duplicate_index) in enumerate(zip(duplicate_sources, duplicates.index), start=1):
        duplicates.at[duplicate_index, "submission_id"] = f"SUB-DUP-{number:03d}"
        issues.append(
            {
                "issue_type": "duplicate_response_id",
                "submission_id": f"SUB-DUP-{number:03d}",
                "response_id": str(df.at[source_row, "response_id"]),
                "field": "response_id",
                "reason": "Response identifier deliberately duplicated",
            }
        )

    combined = pd.concat([df, duplicates], ignore_index=True)
    combined = combined.sample(frac=1, random_state=SEED).reset_index(drop=True)
    return combined, issues


def write_outputs(df: pd.DataFrame, issues: list[dict[str, str]], output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    data_path = output_dir / "survey_responses_synthetic.csv"
    df.to_csv(data_path, index=False, lineterminator="\n")

    issue_path = output_dir / "injected_issue_truth_synthetic.csv"
    pd.DataFrame(issues).sort_values(["issue_type", "submission_id"]).to_csv(
        issue_path, index=False, lineterminator="\n"
    )

    dictionary = pd.DataFrame(
        DATA_DICTIONARY,
        columns=["variable", "type", "description", "valid_values_or_rule", "required_when"],
    )
    dictionary.insert(0, "synthetic_data_notice", DATASET_LABEL)
    dictionary.to_csv(ROOT / "data" / "data_dictionary.csv", index=False, lineterminator="\n")

    digest = hashlib.sha256(data_path.read_bytes()).hexdigest()
    issue_counts = pd.Series([item["issue_type"] for item in issues]).value_counts().sort_index().to_dict()
    manifest = {
        "synthetic_data_notice": DATASET_LABEL,
        "seed": SEED,
        "requested_response_count": N_RESPONSES,
        "actual_response_count": int(len(df)),
        "survey_version": SURVEY_VERSION,
        "fixed_reference_date": REFERENCE_DATE,
        "sha256": digest,
        "injected_issue_records": len(issues),
        "injected_issue_counts": issue_counts,
        "generator": "scripts/generate_synthetic_data.py",
    }
    (output_dir / "generation_manifest.json").write_text(
        json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )


def generate(output_dir: Path = RAW_DIR) -> pd.DataFrame:
    rng = np.random.default_rng(SEED)
    clean = build_clean_base(rng)
    data, issues = inject_quality_issues(clean, rng)
    write_outputs(data, issues, output_dir)
    return data


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-dir", type=Path, default=RAW_DIR)
    args = parser.parse_args()
    data = generate(args.output_dir)
    print(f"Generated {len(data)} synthetic responses in {args.output_dir}")


if __name__ == "__main__":
    main()
