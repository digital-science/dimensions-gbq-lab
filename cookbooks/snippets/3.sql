#standardSQL
-- [Title:Find journals with title matching a string value]
-- [Desc:]
-- [Tags:journal, publisher, text-search]

SELECT
    DISTINCT journal.id,
    journal.title,
    journal.issn,
    journal.eissn,
    publisher.name as publisher
FROM
    `dimensions-ai.data_analytics.publications`
WHERE
    LOWER(journal.title) LIKE CONCAT('%', "machine learning", '%')
ORDER BY
    journal.title