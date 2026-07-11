# Synthetic survey instrument

`impact_survey_xlsform.xlsx` is generated from the diffable CSV sheets in
`survey/source/` by `scripts/build_xlsform.py`.

The form contains no name, phone, email, address, birth-date, or GPS question.
It exercises survey logic and data-quality controls using synthetic entries
only. The public deployment is available at
<https://ee.kobotoolbox.org/x/KTUkyR6W>; it is not used for real field
collection.

Structural validation and KoboToolbox preview results are recorded separately
under `docs/verification/`.
