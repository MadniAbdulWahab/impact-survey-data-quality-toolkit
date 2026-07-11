# Synthetic survey instrument

`impact_survey_xlsform.xlsx` is generated from the diffable CSV sheets in
`survey/source/` by `scripts/build_xlsform.py`.

The form contains no name, phone, email, address, birth-date, or GPS question.
It exercises survey logic and data-quality controls using synthetic entries
only; it is not a live deployment.

Structural validation and KoboToolbox preview results are recorded separately
under `docs/verification/`.
