# Synthetic-data design

## Purpose and boundaries

The dataset is a fictional community-services and training follow-up survey
created to exercise collection, validation, analysis, and reporting workflows.
It is not based on a real organisation, population, respondent, site, or
programme.

The form intentionally avoids direct identifiers: it has no name, phone,
email, address, GPS coordinate, exact birth date, or free-text contact field.
Identifiers such as `SYN-0001`, `SUB-0001`, and `ENUM_01` are generated codes.

## Reproducibility

- Seed: `20260710`
- Requested responses: `420`
- Fixed survey period: 1 April–30 September 2025
- Fixed reporting reference date: 1 October 2025
- Generator: `scripts/generate_synthetic_data.py`
- Manifest: `data/raw/generation_manifest.json`

The generator starts with 410 base records and appends ten intentionally
duplicated response identifiers using distinct submission identifiers.

## Deliberately injected problems

The generator creates known examples of:

- missing conditionally required values;
- codes outside defined choice lists;
- activity, training, and interview dates in an impossible order;
- values outside documented ranges;
- training and follow-up fields populated despite skip conditions;
- site codes inconsistent with their region;
- duplicate response identifiers.

`data/raw/injected_issue_truth_synthetic.csv` documents the injections. Some
records may trigger more than one validation rule, so detected flag totals need
not equal the number of unique affected records.

## Qualitative component

Optional comments are selected from a small, documented synthetic phrase
library covering positive feedback, timing, access, and requests for more
content. They support transparent theme-coding checks, not statistical
inference or comprehensive qualitative analysis.
