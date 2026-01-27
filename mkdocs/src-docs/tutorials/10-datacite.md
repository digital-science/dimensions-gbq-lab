# DataCite Example Queries

The following examples explore how to use the openly available BigQuery dataset available at: `ds-external-data.datacite.records_2025`

Further documentation on the DataCite schema, along with how to get connected to BigQuery can be found at:

https://support.datacite.org/docs/api

!!! warning "Prerequisites"
    In order to run this tutorial, please ensure that you have
    
    * [Configured a Google Cloud project](https://docs.dimensions.ai/bigquery/gcp-setup.html#).
    * Basic familiarity with Python and [Jupyter notebooks](https://jupyter.org/).

(This tutorial is based on a Jupyter notebook that is [available directly via GitHub](https://github.com/digital-science/dimensions-gbq-lab/blob/master/notebooks/10-datacite.ipynb).)


```python
from google.colab import auth
auth.authenticate_user()
print('Authenticated')
```


```python
from google.cloud import bigquery

from google.cloud.bigquery import magics

project_id = input("Enter the name of a GBQ project to use when running the code in this notebook: ")

magics.context.project = project_id

bq_params = {}

client = bigquery.Client(project=project_id)

%load_ext bigquery_magics
```


```python
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
```

**Before we go further, a quick warning. In BigQuery don't use "SELECT *" to explore a dataset. It will be expensive. Use only the columns that you need.**

# Exploring the DataCite dataset on Google BigQuery

In this notebook, we breakdown the DataCite schema in BigQuery, and demonstrate how to query each section.

* [Counting Records](#counting_records)

* [Attributes](#attributes)
  * [Resource Types](#attributes.types)
  * [Publication Years](#attributes.publicationYear)
  * [Titles and Publishers](#attributes.titles)
  * [Descriptions (Abstracts)](#attributes.descriptions)
  * [Subjects (Keywords)](#attributes.subjects)
  * [GeoLocations](#attributes.geoLocations)
  * [Rights & Licenses](#attributes.rightsList)
  * [Usage Counts](#attributes.usage)

* [People & Organizations](#people_orgs)
  * [Creators & Affiliations (ROR)](#creators)
  * [PID Adoption (ORCID)](#pids)

* [Connections & Funding](#connections)
  * [Related Identifiers (The PID Graph)](#attributes.relatedIdentifiers)
  * [Funding References](#attributes.fundingReferences)

* [Advanced: Deduplication](#deduplication)
  * [Handling Versions](#versions)

## <a name="counting_records"> Counting Records</a>

How many active DataCite DOIs do we have in this snapshot?


```python
%%bigquery df_overview
SELECT
  COUNT(*) as total_records
FROM
  `ds-external-data.datacite.records_2025`
```


```python
print(f"Total DataCite Records: {df_overview['total_records'][0]:,}")
```

## <a name="attributes">Attributes</a>

### <a name="attributes.types">attributes.types</a>
What are the most common resource types?


```python
%%bigquery df_types
SELECT
  attributes.types.resourceTypeGeneral as type,
  COUNT(*) as count
FROM
  `ds-external-data.datacite.records_2025`
GROUP BY
  1
ORDER BY
  2 DESC
LIMIT 20
```


```python
df_types
```

We can also look at the specific `resourceType` (free text) vs the controlled `resourceTypeGeneral`.


```python
%%bigquery df_types_detailed
SELECT
  attributes.types.resourceTypeGeneral as general_type,
  COALESCE(attributes.types.resourceType, '(Not Specified)') as specific_type,
  COUNT(*) as count
FROM
  `ds-external-data.datacite.records_2025`
GROUP BY
  1, 2
ORDER BY
  count DESC
LIMIT 15
```


```python
df_types_detailed
```

### <a name="attributes.publicationYear">attributes.publicationYear</a>
How has the volume of research outputs grown over time?


```python
%%bigquery df_years
SELECT
  attributes.publicationYear as year,
  COUNT(*) as count
FROM
  `ds-external-data.datacite.records_2025`
WHERE
  attributes.publicationYear BETWEEN 2010 AND 2025
GROUP BY
  1
ORDER BY
  1 DESC
```


```python
plt.figure(figsize=(10, 5))
plt.plot(df_years['year'], df_years['count'], marker='o')
plt.title('DataCite Records by Publication Year (2010-2025)')
plt.xlabel('Year')
plt.ylabel('Count')
plt.grid(True)
plt.show()
```

### <a name="attributes.titles">attributes.titles & attributes.publisher</a>
What is the basic descriptive metadata for these records?


```python
%%bigquery df_core_detailed
SELECT
  id as doi,
  attributes.titles[SAFE_OFFSET(0)].title as primary_title,
  attributes.publisher.name as publisher,
  attributes.publicationYear
FROM
  `ds-external-data.datacite.records_2025`
LIMIT 5
```


```python
df_core_detailed
```

### <a name="attributes.descriptions">attributes.descriptions</a>
What are these records about? (Extracting abstracts)


```python
%%bigquery df_descriptions
SELECT
  id as doi,
  description_entry.descriptionType,
  COALESCE(SUBSTR(description_entry.description, 0, 200), '(No Description Available)') as abstract_snippet
FROM
  `ds-external-data.datacite.records_2025`,
  UNNEST(attributes.descriptions) as description_entry
WHERE
  description_entry.descriptionType = 'Abstract'
ORDER BY
  LENGTH(description_entry.description) DESC
LIMIT 5
```


```python
df_descriptions
```

### <a name="attributes.subjects">attributes.subjects</a>
What are the most frequent keywords used in the dataset?


```python
%%bigquery df_subjects_list
SELECT
  subj.subject as keyword,
  COUNT(*) as frequency
FROM
  `ds-external-data.datacite.records_2025`,
  UNNEST(attributes.subjects) as subj
GROUP BY
  1
ORDER BY
  2 DESC
LIMIT 10
```


```python
df_subjects_list
```

### <a name="attributes.geoLocations">attributes.geoLocations</a>
Where was data collected?


```python
%%bigquery df_geoloc
SELECT
  id as doi,
  geo.geoLocationPlace,
  geo.geoLocationPoint.pointLatitude as lat,
  geo.geoLocationPoint.pointLongitude as long
FROM
  `ds-external-data.datacite.records_2025`,
  UNNEST(attributes.geoLocations) as geo
WHERE
  geo.geoLocationPlace IS NOT NULL
LIMIT 10
```


```python
df_geoloc
```

### <a name="attributes.rightsList">attributes.rightsList</a>
What are the most common licenses?


```python
%%bigquery df_licenses
SELECT
  r.rights as license_name,
  r.rightsUri as license_url,
  COUNT(*) as count
FROM
  `ds-external-data.datacite.records_2025`,
  UNNEST(attributes.rightsList) as r
GROUP BY
  1, 2
ORDER BY
  3 DESC
LIMIT 10
```


```python
df_licenses
```

### <a name="attributes.usage">attributes.citationCount & attributes.viewCount</a>
Which records have citations or views recorded in the record?


```python
%%bigquery df_usage
SELECT
  id as doi,
  attributes.titles[SAFE_OFFSET(0)].title as title,
  attributes.citationCount,
  attributes.viewCount,
  attributes.downloadCount
FROM
  `ds-external-data.datacite.records_2025`
WHERE
  attributes.citationCount > 0
ORDER BY
  attributes.citationCount DESC
LIMIT 10
```


```python
df_usage
```

## <a name="people_orgs">People & Organizations</a>

### <a name="creators">Creators & Affiliations (ROR)</a>
Who created this work, and what organizations are they affiliated with?


```python
%%bigquery df_creators_detailed
SELECT
  id as doi,
  creator.name as creator_name,
  (SELECT nameIdentifier FROM UNNEST(creator.nameIdentifiers) WHERE nameIdentifierScheme = 'ORCID' LIMIT 1) as orcid,
  ARRAY_TO_STRING(ARRAY(SELECT name FROM UNNEST(creator.affiliation)), '; ') as affiliations
FROM
  `ds-external-data.datacite.records_2025`,
  UNNEST(attributes.creators) as creator
WHERE
  ARRAY_LENGTH(creator.affiliation) > 0
LIMIT 10
```


```python
df_creators_detailed
```

We can also find works by a specific organization (e.g., CERN) by joining with the **ROR** table.


```python
%%bigquery df_org
SELECT


  affiliation.affiliationIdentifier, affiliation.name,

  count(distinct dc.id) dois,
FROM
  `ds-external-data.datacite.records_2025` dc
INNER JOIN
  UNNEST(dc.attributes.creators) as creator
INNER JOIN
  UNNEST(creator.affiliation) as affiliation
WHERE
  affiliation.affiliationIdentifierScheme = 'ROR'
  AND dc.attributes.publicationYear = 2024
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10
```


```python
display(df_org)
```

### <a name="pids">PID Adoption (ORCID & ROR)</a>

How many records include an ORCID iD for creators or contributors?


```python
%%bigquery df_orcid_by_type


SELECT
  attributes.types.resourceTypeGeneral as resource_type,
  COUNT(distinct id) allrecords,
  COUNT(distinct CASE WHEN ni.nameIdentifierScheme  = 'ORCID' THEN  id END) as creator_orcid_count,
  COUNT(distinct CASE WHEN nit.nameIdentifierScheme = 'ORCID' THEN  id END) as contributor_orcid_count
FROM
  `ds-external-data.datacite.records_2025`
  LEFT JOIN UNNEST(attributes.creators) c
    LEFT JOIN UNNEST(c.nameIdentifiers) ni
  LEFT JOIN UNNEST(attributes.contributors) ct
    LEFT JOIN UNNEST(ct.nameIdentifiers) nit
 #WHERE  'ORCID' in (ni.nameIdentifierScheme,nit.nameIdentifierScheme)

GROUP BY
  1
ORDER BY
  2 DESC
```


```python

```


```python
df_orcid_by_type
```


```python
%%bigquery df_orcid_by_type_year
SELECT
  attributes.publicationYear as year,
  COUNT(distinct id) allrecords,
  COUNT(distinct CASE WHEN ni.nameIdentifierScheme =  'ORCID' THEN  id END) as creator_orcid_count,
  COUNT(distinct CASE WHEN nit.nameIdentifierScheme = 'ORCID' THEN  id END) as contributor_orcid_count,
  ROUND(100*COUNT(distinct CASE WHEN 'ORCID' in (nit.nameIdentifierScheme,ni.nameIdentifierScheme) THEN  id END)/ COUNT(distinct id) ,2) percentage_with_orcid
FROM
  `ds-external-data.datacite.records_2025`
  LEFT JOIN UNNEST(attributes.creators) c
    LEFT JOIN UNNEST(c.nameIdentifiers) ni
  LEFT JOIN UNNEST(attributes.contributors) ct
    LEFT JOIN UNNEST(ct.nameIdentifiers) nit
 WHERE  attributes.types.resourceTypeGeneral = 'Dataset'
 and attributes.publicationYear between 2015 and 2025
GROUP BY
  1
ORDER BY
  1 ASC
```


```python
df_orcid_by_type_year.plot(x='year', y='percentage_with_orcid', kind='bar')
```

How many records contain at least one ROR ID in the affiliation metadata?


```python
%%bigquery df_ror_count
SELECT
  COUNT(DISTINCT id) as records_with_ror_affiliation,
  COUNTIF(EXISTS(
    SELECT 1 FROM UNNEST(attributes.creators) c, UNNEST(c.affiliation) a
    WHERE a.affiliationIdentifierScheme = 'ROR'
  )) as records_with_creator_ror,
  COUNTIF(EXISTS(
    SELECT 1 FROM UNNEST(attributes.contributors) c, UNNEST(c.affiliation) a
    WHERE a.affiliationIdentifierScheme = 'ROR'
  )) as records_with_contributor_ror
FROM
  `ds-external-data.datacite.records_2025`
```


```python
display(df_ror_count)
```

## <a name="connections">Connections & Funding</a>

### <a name="attributes.relatedIdentifiers">attributes.relatedIdentifiers (The PID Graph)</a>
What other research objects (papers, software, versions) is this record connected to?


```python
%%bigquery df_pid_graph
SELECT
  id as source_doi,
  rel.relationType,
  rel.relatedIdentifierType as target_type,
  rel.relatedIdentifier as target_id
FROM
  `ds-external-data.datacite.records_2025`,
  UNNEST(attributes.relatedIdentifiers) as rel
WHERE
  rel.relationType IN ('IsSupplementTo', 'Cites', 'IsVersionOf')
LIMIT 10
```


```python
display(df_pid_graph)
```

Which relationship types are most common?


```python
%%bigquery df_relations
SELECT
  relation.relationType,
  COUNT(*) as frequency
FROM
  `ds-external-data.datacite.records_2025`,
  UNNEST(attributes.relatedIdentifiers) as relation
GROUP BY
  1
ORDER BY
  2 DESC
LIMIT 15
```


```python
display(df_relations)
```

### <a name="attributes.fundingReferences">attributes.fundingReferences</a>
Who paid for this research?


```python
%%bigquery df_funding_refs
SELECT
  id as doi,
  funding.funderName,
  funding.awardNumber,
  funding.awardTitle
FROM
  `ds-external-data.datacite.records_2025`,
  UNNEST(attributes.fundingReferences) as funding
ORDER BY
  funding.funderName DESC
LIMIT 10
```


```python
display(df_funding_refs)
```

## <a name="deduplication">Advanced: Deduplication</a>

### <a name="versions">Handling Versions</a>

When analyzing research outputs, you often want to avoid double-counting. For example, a dataset might have versions 1.0, 1.1, and 2.0, all with different DOIs.

The following query uses a rigorous filtering strategy to remove superseded versions (`IsPreviousVersionOf`) and redundant identical copies (`IsIdenticalTo`), keeping only the most relevant record.


```python
%%bigquery df_deduplicated
WITH dois_to_remove AS (
    SELECT
        dc.id
    FROM
        `ds-external-data.datacite.records_2025` dc
    INNER JOIN
        UNNEST(dc.attributes.relatedIdentifiers) related
        ON related.relationType IN ('IsIdenticalTo', 'IsPreviousVersionOf')
    -- Join with the table again to get the related DOI's metadata (date)
    INNER JOIN
        `ds-external-data.datacite.records_2025` dc2
        ON dc2.id = related.relatedIdentifier
    WHERE
        (
            -- Logic for Identical items: Remove the one registered LATER (or higher ID if tie)
            (related.relationType = 'IsIdenticalTo'
            AND (
                SAFE_CAST(dc.attributes.registered AS TIMESTAMP) > SAFE_CAST(dc2.attributes.registered AS TIMESTAMP)
                OR (
                    SAFE_CAST(dc.attributes.registered AS TIMESTAMP) = SAFE_CAST(dc2.attributes.registered AS TIMESTAMP)
                    AND dc.id > dc2.id
                )
            ))
            -- Logic for Versions: If dc is a "Previous Version Of" something else, remove dc.
            OR (related.relationType = 'IsPreviousVersionOf')
        )
    -- Optional: Ensure we only deduplicate items owned by the same client/repository
    AND dc2.relationships.client.data.id = dc.relationships.client.data.id
)

SELECT
    COUNT(dc.id) as unique_records
FROM
    `ds-external-data.datacite.records_2025` dc
LEFT JOIN
    dois_to_remove dcr
    ON dcr.id = dc.id
WHERE
    dcr.id IS NULL
```


```python
print(f"Total Deduped Records: {df_deduplicated['unique_records'][0]:,}")
```


```python

```
