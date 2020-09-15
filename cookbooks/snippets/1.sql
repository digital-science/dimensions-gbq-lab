#standardSQL

-- [Title:Statistics about publications with corresponding authors, segmented by publisher]
-- [Desc:]
-- [Tags:corresponding-authors, publisher]

SELECT
    count(DISTINCT id) AS tot,
    publisher.name
FROM
    `dimensions-ai.data_analytics.publications`,
    unnest(author_affiliations) aff
WHERE
    aff.corresponding IS TRUE
    AND publisher.name IS NOT NULL
GROUP BY
    publisher.name
ORDER BY
    tot DESC