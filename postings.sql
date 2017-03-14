WITH filtered_title AS (
SELECT *
FROM postings
WHERE job_title NOT LIKE '%design%'
AND job_title NOT LIKE '%devops%'
AND job_title NOT LIKE '%marketing%'
AND job_title NOT LIKE '%administrator%'
AND job_title NOT LIKE '%manager%'
AND job_title NOT LIKE '%salesforce%'
AND job_title NOT LIKE '%writer%'
AND job_title NOT LIKE '%account%'
AND job_title NOT LIKE '%intern%'
GROUP BY job_title, company, location
HAVING count(*) = 1
)

SELECT COUNT(cte2.junior_flag), cte2.location, cte2.junior_flag
FROM filtered_title
INNER JOIN (SELECT * FROM filtered_title
        WHERE
         REPLACE
        (REPLACE
        (REPLACE
        (REPLACE
        (REPLACE
        (REPLACE
        (REPLACE
        (REPLACE
        (REPLACE
        (REPLACE (location, '0', ''),
        '1', ''),
        '2', ''),
        '3', ''),
        '4', ''),
        '5', ''),
        '6', ''),
        '7', ''),
        '8', ''),
        '9', '') = location ) AS cte2

ON cte2.job_summary = filtered_title.job_summary
GROUP BY cte2.junior_flag, cte2.location
ORDER BY cte2.location
