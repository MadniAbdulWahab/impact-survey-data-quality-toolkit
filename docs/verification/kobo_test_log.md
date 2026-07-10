# KoboToolbox verification log

Status: **PASSED — USER-VERIFIED ON 10 JULY 2026**

Complete this log only with results observed in your own KoboToolbox session.
Do not enter real respondent information.

## Environment

- Tester: Repository owner (user-reported manual verification)
- Date: 10 July 2026
- Kobo server/region: Not recorded
- Browser: Not recorded
- XLSForm SHA-256:
  `fc928a45b1d2ca1a1fb55e664efe84fd880e84509db3bee3963849c654be9f4c`

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
| Upload without structural error | Pass | User reported successful XLSForm upload and project creation. |
| Synthetic warning visible | Pass | User reported the warning appeared in preview. |
| Consent skip path | Pass | User reported monitoring questions remained hidden for no consent. |
| Training skip path | Pass | User reported training questions hid and appeared as expected. |
| Constraints reject invalid entries | Pass | User reported the score and date constraints behaved as expected. |
| Follow-up skip path | Pass | User reported preferred channel hid and appeared as expected. |
| Region/site filtering | Pass | User reported site choices changed with the selected region. |
| Preview completion | Pass | User completed the synthetic preview flow successfully. |

## Issues and corrective actions

No issue was reported during the manual Kobo preview. No deployment or live
data collection is claimed. Browser/server details and screenshots were not
provided, so they are intentionally not recorded or implied.
