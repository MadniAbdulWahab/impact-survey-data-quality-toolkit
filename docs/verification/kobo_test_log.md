# KoboToolbox verification log

Status: **PASSED — MANUALLY RECHECKED ON 11 JULY 2026**

The checks below were performed in KoboToolbox Preview using synthetic entries
only.

## Environment

- Method: Manual verification in KoboToolbox Preview
- Date: 11 July 2026
- Kobo server/region: Not recorded
- Browser: Not recorded
- XLSForm SHA-256:
  `71d8bb48d584a7ba369ca559d627f3a48548bd83432e1bb784a7859fe71d8782`

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
| Upload without structural error | Pass | XLSForm uploaded and the project was created successfully. |
| Synthetic warning visible | Pass | The warning appeared in preview. |
| Consent skip path | Pass | Monitoring questions remained hidden when consent was `no`. |
| Training skip path | Pass | Training questions hid and appeared as expected. |
| Constraints reject invalid entries | Pass | Score and date constraints behaved as expected. |
| Follow-up skip path | Pass | Preferred channel hid and appeared as expected. |
| Region/site filtering | Pass | Site choices changed with the selected region. |
| Preview completion | Pass | A synthetic preview record reached completion successfully. |

## Issues and corrective actions

No issues occurred during the manual Kobo preview. Testing was limited to form
upload and preview; there was no live deployment or field collection.
