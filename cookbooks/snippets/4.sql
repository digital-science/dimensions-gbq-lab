#standardSQL
-- [Title:Top concepts in the journal Nature in 2020]
-- [Desc:]
-- [Tags:journal, concepts]

SELECT
    count(*) AS count,
    c.concept
FROM
    `dimensions-ai.data_restricted_internal.publications`,
    UNNEST(concepts) AS c
WHERE
    year = 2020
    AND journal.id = "jour.1018957"
GROUP BY
    c.concept
ORDER BY
    1 DESC