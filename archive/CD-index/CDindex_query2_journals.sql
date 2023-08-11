CREATE OR REPLACE TABLE `{your-gbq-project}.{you-gbq-dataset}.publications_cd_index_journals` 
CLUSTER BY id 
AS
(
  WITH publications AS
  (
    SELECT id, year, citations, reference_ids
    FROM `dimensions-ai.data_analytics.publications`
    WHERE year IS NOT NULL AND type ="article" AND ARRAY_LENGTH(reference_ids)>=10 AND journal.id IS NOT NULL
  )

  SELECT focal_id AS id,
  (SUM(score)/COUNT(DISTINCT citation_id))+2 AS cd_5,
  COUNTIF(score = -1)*((SUM(score)/COUNT(DISTINCT citation_id))+2) AS mcd_5
  FROM
  (
    (
      SELECT DISTINCT publications.id AS focal_id, 
      citation.id AS citation_id,
      -1 AS score
      FROM publications
      LEFT JOIN UNNEST(publications.citations) AS citation
      WHERE citation.year - publications.year BETWEEN 1 AND 5
    )
    UNION ALL
    (
      SELECT DISTINCT publications.id AS focal_id, 
      reference_citation.id as citation_id,
      -2 as score
      FROM publications
      LEFT JOIN UNNEST(publications.reference_ids) AS reference_id
      INNER JOIN publications AS references 
      ON references.id = reference_id
      LEFT JOIN UNNEST(references.citations) AS reference_citation
      WHERE reference_citation.year - publications.year BETWEEN 1 AND 5
    )
  )
  GROUP BY 1
)