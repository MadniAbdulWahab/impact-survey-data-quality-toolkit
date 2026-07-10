# Answering common data queries

The processed SQLite database is
`data/processed/impact_survey_synthetic.sqlite`. It contains only synthetic
data. Use saved, reviewable queries and state the denominator and filters in
every answer.

Run all portfolio database checks without shell-quoting complications:

```powershell
Rscript scripts/check_database.R
```

The script prints the result tables and stops with an error if expected table,
row, QC, region, or qualitative-theme totals do not reconcile.

## Query checklist

1. Restate the question as a metric, population, period, and grouping.
2. Confirm whether the requester needs raw submissions, consented submissions,
   unique analysis responses, or flagged records.
3. Check the data dictionary and the latest pipeline manifest.
4. Write and save the SQL; avoid manual spreadsheet counting.
5. Reconcile the result with a report or CSV summary when possible.
6. Report the extraction version, query, denominator, missing-value treatment,
   and limitations.

## Connect from R

```r
library(DBI)
library(RSQLite)

con <- dbConnect(
  SQLite(),
  "data/processed/impact_survey_synthetic.sqlite"
)
dbListTables(con)
```

Always close the connection:

```r
dbDisconnect(con)
```

## Examples

### Responses by fictional region and round

```sql
SELECT region_code,
       survey_round,
       COUNT(*) AS responses
FROM survey_responses
WHERE region_code IS NOT NULL
GROUP BY region_code, survey_round
ORDER BY region_code, survey_round;
```

### Participation and satisfaction

```sql
SELECT region_code,
       COUNT(*) AS responses,
       ROUND(100.0 * AVG(participated_training = 'yes'), 1)
         AS participation_percent,
       ROUND(AVG(CASE WHEN participated_training = 'yes'
                      THEN satisfaction_score END), 2)
         AS mean_satisfaction
FROM survey_responses
WHERE region_code IS NOT NULL
GROUP BY region_code
ORDER BY region_code;
```

### Open QC issues

```sql
SELECT issue_label,
       COUNT(*) AS record_level_flags,
       COUNT(DISTINCT response_id) AS affected_response_ids
FROM qc_issues
WHERE status = 'Open'
GROUP BY issue_label
ORDER BY record_level_flags DESC;
```

### Synthetic qualitative themes

```sql
SELECT theme,
       COUNT(*) AS comments
FROM qualitative_comments
GROUP BY theme
ORDER BY comments DESC;
```

## Response template

> Using the processed synthetic dataset from commit `<hash>`, I counted
> `<denominator>` unique consented responses after duplicate handling. The
> requested result is `<value>`. Records with `<relevant rule>` were treated as
> `<treatment>`. This is a portfolio demonstration and does not describe real
> programme performance.
