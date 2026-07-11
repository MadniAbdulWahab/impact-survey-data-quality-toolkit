-- Common analysis and quality-control queries for the synthetic database.
-- Database: data/processed/impact_survey_synthetic.sqlite

-- 1. Responses by fictional region and round.
SELECT region_code,
       survey_round,
       COUNT(*) AS responses
FROM survey_responses
WHERE region_code IS NOT NULL
GROUP BY region_code, survey_round
ORDER BY region_code, survey_round;

-- 2. Participation and mean satisfaction by fictional region.
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

-- 3. Open automated QC issues.
SELECT issue_label,
       COUNT(*) AS record_level_flags,
       COUNT(DISTINCT response_id) AS affected_response_ids
FROM qc_issues
WHERE status = 'Open'
GROUP BY issue_label
ORDER BY record_level_flags DESC;

-- 4. Themes in the synthetic qualitative comments.
SELECT theme,
       COUNT(*) AS comments
FROM qualitative_comments
GROUP BY theme
ORDER BY comments DESC;
