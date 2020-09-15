#standardSQL
-- [Title:Journal funding sources and number of grants]
-- [Desc:]

WITH funding AS (
    SELECT
        funding.grid_id AS funder_id,
        count(id) AS pubs_tot,
        count(funding.grant_id) AS grants_tot
    FROM
        `dimensions-ai.data_analytics.publications`,  
        unnest(funding_details) AS funding
    WHERE
        journal.id = "jour.1113716" -- nature medicine 
    GROUP BY
        funder_id
)
SELECT
    funding.funder_id, grid.name as funder_name, funding.pubs_tot, funding.grants_tot
FROM
    funding
    JOIN `dimensions-ai.data_analytics.grid`  grid ON funding.funder_id = grid.id