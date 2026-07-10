# KoboToolbox verification log

Status: **NOT YET TESTED**

Complete this log only with results observed in your own KoboToolbox session.
Do not enter real respondent information.

## Environment

- Tester:
- Date:
- Kobo server/region:
- Browser:
- XLSForm Git commit or SHA-256:

## Test procedure

1. From the Projects page, select **NEW**.
2. Select **Upload an XLSForm** and choose
   `survey/impact_survey_xlsform.xlsx`.
3. Create the test project and record any upload error verbatim.
4. Open **Preview**. Confirm the synthetic-data warning is visible.
5. Test `consent = no`; confirm monitoring questions remain hidden.
6. Test `consent = yes` and `participated_training = no`; confirm training
   questions remain hidden.
7. Test `participated_training = yes`; confirm training questions appear and
   reject an invalid score or date.
8. Test `follow_up_requested = no` and `yes`; confirm the preferred-channel
   question is hidden and shown respectively.
9. Change region and confirm the site list is filtered to that region.
10. Enter a synthetic preview record and confirm the form reaches completion.

## Results

| Check | Pass/Fail | Evidence or observation |
|---|---|---|
| Upload without structural error | Not tested | |
| Synthetic warning visible | Not tested | |
| Consent skip path | Not tested | |
| Training skip path | Not tested | |
| Constraints reject invalid entries | Not tested | |
| Follow-up skip path | Not tested | |
| Region/site filtering | Not tested | |
| Preview completion | Not tested | |

## Issues and corrective actions

Record failures here. A failed check is evidence for improvement, not something
to hide from the portfolio history.

