from __future__ import annotations

import hashlib
import json

import pandas as pd

from generate_synthetic_data import generate
from project_config import N_RESPONSES, SEED


EXPECTED_ISSUE_TYPES = {
    "missing_required",
    "invalid_code",
    "inconsistent_date",
    "out_of_range",
    "skip_logic_violation",
    "consistency_violation",
    "duplicate_response_id",
}


def test_generation_is_byte_reproducible(tmp_path):
    first = tmp_path / "first"
    second = tmp_path / "second"
    generate(first)
    generate(second)

    first_bytes = (first / "survey_responses_synthetic.csv").read_bytes()
    second_bytes = (second / "survey_responses_synthetic.csv").read_bytes()
    assert first_bytes == second_bytes

    manifest = json.loads((first / "generation_manifest.json").read_text(encoding="utf-8"))
    assert manifest["seed"] == SEED
    assert manifest["actual_response_count"] == N_RESPONSES
    assert manifest["sha256"] == hashlib.sha256(first_bytes).hexdigest()


def test_dataset_is_synthetic_and_contains_no_direct_identifiers(tmp_path):
    output = tmp_path / "data"
    generate(output)
    data = pd.read_csv(output / "survey_responses_synthetic.csv", dtype=str, keep_default_na=False)

    assert len(data) == N_RESPONSES
    assert set(data["synthetic_data"]) == {"yes"}
    forbidden = {"name", "full_name", "phone", "email", "address", "gps", "latitude", "longitude", "date_of_birth"}
    assert forbidden.isdisjoint(set(data.columns))


def test_all_planned_quality_issue_categories_are_injected(tmp_path):
    output = tmp_path / "data"
    generate(output)
    truth = pd.read_csv(output / "injected_issue_truth_synthetic.csv")
    assert EXPECTED_ISSUE_TYPES == set(truth["issue_type"])
    assert truth["submission_id"].notna().all()
    assert (truth.groupby("issue_type").size() > 0).all()


def test_duplicate_response_ids_are_real_in_raw_output(tmp_path):
    output = tmp_path / "data"
    generate(output)
    data = pd.read_csv(output / "survey_responses_synthetic.csv", dtype=str)
    duplicate_ids = data.loc[data["response_id"].duplicated(keep=False), "response_id"]
    assert duplicate_ids.nunique() == 10
    assert len(duplicate_ids) == 20

