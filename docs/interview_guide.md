# Interview walkthrough

A short script for talking through this portfolio project. Everything is
synthetic; no record represents a real person, programme, or organisation.

## One-minute summary

"I built a small but complete monitoring-data workflow. A fictional community
services and training follow-up survey is defined as an XLSForm, deliberately
seeded with realistic data-quality problems, validated and reported with R,
queried with SQL over SQLite, and monitored in Excel. Every artefact is
reproducible from a fixed seed, and I only mark something 'tested' after it
actually runs — including application-level gates in Kobo and Excel that were
verified separately from the source-code tests."

## The pieces, in order

1. **Survey design** — a Git-friendly XLSForm (`survey/source/*.csv` built into
   `survey/impact_survey_xlsform.xlsx`) with skip logic, constraints, and
   cascading region→site choices. Structurally validated with `pyxform` and
   previewed in KoboToolbox.
2. **Synthetic data** — `scripts/generate_synthetic_data.py` produces 420
   responses from seed `20260710`, plus an injected-issue truth file so
   detection can be checked against known answers.
3. **Validation and reporting** — the R pipeline (`scripts/run_pipeline.R`)
   flags seven issue types, writes a clean analysis copy and an issue log,
   builds charts, and feeds a Quarto HTML report.
4. **Database** — a SQLite database with saved, reviewable queries
   (`sql/common_queries.sql`, `docs/query_guide.md`).
5. **Excel monitoring** — a generated workbook with data validation, lookup
   formulas, the seven QC rules re-implemented as formulas, conditional
   formatting, a Power Query import of the full extract, pivots, and a VBA
   refresh/export macro.

## Explain one validation rule

**Region/site consistency (`qc_region_site_consistency`).** Each site code
belongs to exactly one region (N01–N03 to NORTH, and so on). The rule flags any
consented record where the site does not belong to the selected region. In R it
is a lookup against the region→site map; in Excel it is the same idea:
`INDEX(SiteRegionList, MATCH(site, SiteList, 0))` compared to the region cell.
Issue counts overlap by design — an invalid site can trip both this rule and the
invalid-code rule — which is why the summary reports flags, not mutually
exclusive buckets.

## Explain one design choice

**Immutable raw data with an injection-truth file.** The generator writes raw
data once, records its SHA-256, and never edits it downstream. A separate truth
file lists every deliberate issue. This lets the tests assert that detection
finds the known problems, keeps the raw layer honest, and makes the whole thing
reproducible — two clean rebuilds produce identical hashes.

## Explain one limitation

**The qualitative coding is a transparent demo, not research.** Comments come
from a small synthetic phrase library and are themed with documented keywords.
It shows a defensible, inspectable workflow, but the themes would not generalise
to real open-text at scale. I state this in the report rather than overclaiming.

## If asked "what did you not automate?"

Application-level gates, on purpose: uploading and previewing the form in
KoboToolbox, and exercising the Excel Power Query, pivots, and VBA in desktop
Excel. The Excel assembly was driven through COM automation and then audited
from the saved workbook package. I document exact steps and only record observed
results — see `docs/verification/`.
