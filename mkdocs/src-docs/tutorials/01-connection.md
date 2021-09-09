# Verifying your connection

In this tutorial we will show how to connect to Dimensions on Google BigQuery using Python, so that we can then run a few sample queries.

!!! note "Note"
    This tutorial is intended for people who want to query BigQuery via a notebook, but the SQL queries in this lab can also be run directly from the [BigQuery console](https://console.cloud.google.com/bigquery).

## Prerequisites
In order to run this tutorial, please ensure that:

* You have a valid [Dimensions on Google BigQuery account](https://www.dimensions.ai/products/bigquery/) and have [configured a Google Cloud project](https://docs.dimensions.ai/bigquery/gcp-setup.html#).
* You have some basic familiarity with Python and [Jupyter notebooks](https://jupyter.org/).

## Connection methods

There are a few options available:

1. **Use Google Colaboratory and your personal credentials.** This option is the simplest of all, as it doesn't require you to install anything on your computer. It is normally ok for small to mid-sized projects that can live in the cloud.
2. **Use a local Jupyter environment and your personal credentials.** This option requires you to install the Google Cloud SDK in order to authenticate. It is the best option if you want to work locally and/or have other Python libraries or services that you need to access.
3. **Use a local Jupyter environment and a service account.** This option is really a variance on the option 2, for those users that must use a service account.

NOTE All of these options require you to first set up a [GCP project](https://docs.dimensions.ai/bigquery/gcp-setup.html#projects) (as you haven't done it already) and provide your project ID. E.g.:


```python
MY_PROJECT_ID = "my-cool-gbq-project"
```

### Option 1: using Google Colaboratory and your personal credentials

[Google Colaboratory](https://colab.research.google.com/) is a free cloud-based Jupyter environment from Google. This option provides an easy service allowing you to get started with notebooks.

Using your Google Account you can create notebooks, execute BigQuery queries and share these with other Google Accounts quickly and easily.




```python
# authentication happens via your browser
from google.colab import auth
auth.authenticate_user()
print('Authenticated')

MY_PROJECT_ID = "my-cool-gbq-project"
from google.cloud import bigquery
client = bigquery.Client(project=MY_PROJECT_ID)
```

### Option 2: using a local Jupyter and your personal credentials

A Google Account represents a developer, an administrator, or any other person who interacts with Google Cloud.
This is normally the Google account one has used to get access to the Dimensions on BigQuery product.

In order to configure programmatic access for local development, the easiest way is to authenticate using the [Google Cloud SDK](https://googleapis.dev/python/google-api-core/latest/auth.html).

```
$ gcloud auth application-default login
```

Note: the command above should be run from a Terminal or console. This will generate a JSON file that is used as the default application credentials for the account that was selected in the above login process. When using the default Client for each Google provided package (such as BigQuery) they should automatically authenticate using these default credentials.


```python
# install python client library
!pip install google-cloud-bigquery -U --quiet
```


```python
from google.cloud import bigquery

MY_PROJECT_ID = "my-cool-gbq-project"
client = bigquery.Client(project=MY_PROJECT_ID)
```

### Option 3: using a local Jupyter and a service account

A [service account](https://cloud.google.com/iam/docs/service-accounts) is a special kind of account used by an application or a virtual machine (VM) instance, not a person.

Each service account is associated with two sets of public/private RSA key pairs that are used to authenticate to Google: Google-managed keys, and user-managed keys.

When using a service account you'd just have to point your client object to the a key file.


```python
from google.cloud import bigquery
credentials_file = 'my-awesome-gbq-project-47616836.json'

MY_PROJECT_ID = "my-cool-gbq-project"

# Explicitly use service account credentials by specifying the private key file
client = bigquery.Client.from_service_account_json(credentials_file)
```

## Running queries

Once the connection is set up, all you have to do is to type in a SQL query and run it using the `client` object.


```python

# Query: Top publications from Oxford univ. by Altmetric Score in 2020

query_1 = """
SELECT
    id,
    title.preferred as title,
    ARRAY_LENGTH(authors) as authors_count,
    CAST(altmetrics.score as INT64) as altmetric_score
FROM
    `dimensions-ai.data_analytics.publications`
WHERE
    year = 2020 AND 'grid.4991.5' in UNNEST(research_orgs)
ORDER BY
    altmetric_score DESC
LIMIT 5"""

# 1 - main syntax

query_job = client.query(query_1)

results = query_job.result()  # Waits for job to complete.

for row in results:
  print("> {} : {}\n\tAuthors: {}\n\tAltmetric Score: {}".format(row.id, row.title, row.authors_count, row.altmetric_score))
```

    > pub.1129493369 : Safety and immunogenicity of the ChAdOx1 nCoV-19 vaccine against SARS-CoV-2: a preliminary report of a phase 1/2, single-blind, randomised controlled trial
    	Authors: 366
    	Altmetric Score: 15451
    > pub.1130340155 : Two metres or one: what is the evidence for physical distancing in covid-19?
    	Authors: 6
    	Altmetric Score: 15125
    > pub.1127239818 : Remdesivir in adults with severe COVID-19: a randomised, double-blind, placebo-controlled, multicentre trial
    	Authors: 46
    	Altmetric Score: 12675
    > pub.1131721397 : Scientific consensus on the COVID-19 pandemic: we need to act now
    	Authors: 31
    	Altmetric Score: 10192
    > pub.1126016857 : Quantifying SARS-CoV-2 transmission suggests epidemic control with digital contact tracing
    	Authors: 9
    	Altmetric Score: 8320


An slighly alternative syntax is also possible


```python
# 2 - omit calling result()

query_job = client.query(query_1)
for row in query_job:
    print(row)
```

    Row(('pub.1129493369', 'Safety and immunogenicity of the ChAdOx1 nCoV-19 vaccine against SARS-CoV-2: a preliminary report of a phase 1/2, single-blind, randomised controlled trial', 366, 15451), {'id': 0, 'title': 1, 'authors_count': 2, 'altmetric_score': 3})
    Row(('pub.1130340155', 'Two metres or one: what is the evidence for physical distancing in covid-19?', 6, 15125), {'id': 0, 'title': 1, 'authors_count': 2, 'altmetric_score': 3})
    Row(('pub.1127239818', 'Remdesivir in adults with severe COVID-19: a randomised, double-blind, placebo-controlled, multicentre trial', 46, 12675), {'id': 0, 'title': 1, 'authors_count': 2, 'altmetric_score': 3})
    Row(('pub.1131721397', 'Scientific consensus on the COVID-19 pandemic: we need to act now', 31, 10192), {'id': 0, 'title': 1, 'authors_count': 2, 'altmetric_score': 3})
    Row(('pub.1126016857', 'Quantifying SARS-CoV-2 transmission suggests epidemic control with digital contact tracing', 9, 8320), {'id': 0, 'title': 1, 'authors_count': 2, 'altmetric_score': 3})


Another quite handy feature is to transform data direclty into [Pandas dataframes](https://pandas.pydata.org/pandas-docs/)


```python
# 3 - return a dataframe

query_job = client.query(query_1).to_dataframe()
query_job
```
| Row | id    | title | authors_count | altmetric_score |
| --- | ----- | ----- | ------------- | --------------- |
| 1 | pub.1129493369 | Safety and immunogenicity of the ChAdOx1 nCoV-... | 366 | 15451 |
| 2 | pub.1130340155 | Two metres or one: what is the evidence for ph... | 6 | 15125 |
| 3 | pub.1127239818 | Remdesivir in adults with severe COVID-19: a r... | 46 | 12675 |
| 4 | pub.1131721397 | Scientific consensus on the COVID-19 pandemic:... | 31 | 10192 |
| 5 | pub.1126016857 | Quantifying SARS-CoV-2 transmission suggests e... | 9 | 8320 |


### Advanced: BigQuery magic command and dynamic parameters

The Google BigQuery library comes with a [magic command](https://googleapis.dev/python/bigquery/latest/magics.html) that is essentially a nice shortcut method for running queries.

This extensions needs to be loaded sepately e.g.:


```python
%load_ext google.cloud.bigquery
```

We can then set up a couple of query parameters for the query itself, as well as the usual project ID value.


```python
project_id = MY_PROJECT_ID
bq_params = {}
bq_params["journal_id"] = "jour.1115214"
```

Finally we can query by starting a cell with the command `%%bigquery ... `:


```python
%%bigquery --params $bq_params --project $project_id

# Publications per year for Nature Biotechnology

SELECT
    count(*) as pubs, year, journal.title
FROM
    `dimensions-ai.data_analytics.publications`
WHERE
    year >= 2010
    AND journal.id = @journal_id
GROUP BY
    year, journal.title
ORDER BY
    year DESC

```

```
Query complete after 0.02s: 100%|██████████| 1/1 [00:00<00:00, 699.28query/s]
Downloading: 100%|██████████| 11/11 [00:02<00:00,  4.31rows/s]
```

| Row | pubs | year | title |
| --- | ---- | ---- | ----- |
| 1 | 438 | 2020 | Nature Biotechnology |
| 2 | 386 | 2019 | Nature Biotechnology |
| 3 | 374 | 2018 | Nature Biotechnology |
| 4 | 380 | 2017 | Nature Biotechnology |
| 5 | 436 | 2016 | Nature Biotechnology |
| 6 | 467 | 2015 | Nature Biotechnology |
| 7 | 475 | 2014 | Nature Biotechnology |
| 8 | 462 | 2013 | Nature Biotechnology |
| 9 | 507 | 2012 | Nature Biotechnology |
| 10 | 459 | 2011 | Nature Biotechnology |
| 11 | 486 | 2010 | Nature Biotechnology |


## Troubleshooting

* Query fails wit `to_dataframe() ArrowNotImplementedError`
    * Try reinstalling pyarrow ie `pip install pyarrow -U`
* Query fails with `AttributeError: 'NoneType' object has no attribute 'transport'`
    * Try `pip install google-cloud-bigquery-storage -U` and restarting the notebook
