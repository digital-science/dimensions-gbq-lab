# From the DSL API to Google BigQuery

This tutorial demonstrates how to perform a full-text search in Dimensions using the Analytics API and then export the data to Google BigQuery for further analysis.

This technique allows to take advantage of the strengths of each of these data products:

* The [Analytics API](https://docs.dimensions.ai/dsl) allows to run [full-text searches](https://docs.dimensions.ai/dsl/language.html#full-text-searching) over the tens of millions documents stored in the Dimensions database. This makes it an ideal tool for identifying a corpus of documents using collections of keywords and/or other filters (note: this is the same functionality available when you search on app.dimensions.ai)
* The [Dimensions on Google BigQuery](https://docs.dimensions.ai/bigquery/) database allows to run SQL queries of any complexity using a cloud-based environment containing all of the metadata available in Dimensions, thus removing the need to download/analyse the data offline first. This makes is the perfect solution for advanced analytics tasks such as benchmarking, metrics calculations or impact analyses.


!!! warning "Prerequisites"
    In order to run this tutorial, please ensure that: 

    * You have a valid [Dimensions on Google BigQuery account](https://www.dimensions.ai/products/bigquery/) and have [configured a Google Cloud project](https://docs.dimensions.ai/bigquery/gcp-setup.html#).
    * You have a valid [Dimensions API account](https://docs.dimensions.ai/dsl/). 
    * You have some basic familiarity with Python and [Jupyter notebooks](https://jupyter.org/).
    

## Example: profiling researchers linked to a topic

The concrete usecase we'll be looking at involves running a full-text search for "moon landing" publications using the DSL API, then creating a corpus in GBQ based on this search (eg see this [search](https://app.dimensions.ai/discover/publication?search_mode=content&search_text=%22moon%20landing%22%20AND%20Moon%20AND%20%22lunar%20surface%22%20&search_type=kws&search_field=full_search)).

Once we have the publication corpus available in GBQ, we will extract all associated researchers (=authors). At the same time, we are going to use SQL in order to enrich the results using other metrics (eg more `researchers` metadata including citations & altmetric).


## Getting started

The following code will load the Python BigQuery library and authenticate you as a valid user.


```python
!pip install google-cloud-bigquery -U --quiet
%load_ext google.cloud.bigquery

import sys
print("==\nAuthenticating...")
if 'google.colab' in sys.modules:
    from google.colab import auth
    auth.authenticate_user()
    print('..done (method: Colab)')
else:
    from google.cloud import bigquery
    print('..done (method: local credentials)')

#
# PLEASE UPDATE USING YOUR CLOUD PROJECT ID (= the 'billing' account)
#

MY_PROJECT_ID = "ds-data-solutions-gbq"

print("==\nTesting connection..")
client = bigquery.Client(project=MY_PROJECT_ID)
test = client.query("""
    SELECT COUNT(*) as pubs
    from `dimensions-ai.data_analytics.publications`
    """)
rows = [x for x in test.result()]
print("...success!")
print("Total publications in Dimensions: ", rows[0]['pubs'])
```

    The google.cloud.bigquery extension is already loaded. To reload it, use:
      %reload_ext google.cloud.bigquery
    ==
    Authenticating...
    ..done (method: local credentials)
    ==
    Testing connection..
    ...success!
    Total publications in Dimensions:  115963650


## 1. Connecting to the DSL API

For more background on the Analytics API and how to work with it, see this [tutorial](https://docs.dimensions.ai/dsl/tour.html)


```python
!pip install dimcli --quiet

import dimcli
from dimcli.utils import *
import json
import sys
import pandas as pd
#

ENDPOINT = "https://app.dimensions.ai"
USERNAME, PASSWORD  = "", ""
dimcli.login(USERNAME, PASSWORD, ENDPOINT)
dsl = dimcli.Dsl()
```

Let's try running a sample query.

**TIP** Review the [full text search syntax](https://docs.dimensions.ai/dsl/language.html#full-text-searching) of the Dimensions Search Language.


```python
%%dsldf

search publications for
  " \"moon landing\" AND Moon AND \"lunar surface\" "
return publications limit 10
```

    Returned Publications: 10 (total = 11305)
    [2mTime: 0.72s[0m


<table>
  <thead>
    <tr style="text-align: right;">
      <th>Row</th>
      <th>type</th>
      <th>volume</th>
      <th>pages</th>
      <th>id</th>
      <th>year</th>
      <th>author_affiliations</th>
      <th>title</th>
      <th>journal.id</th>
      <th>journal.title</th>
      <th>issue</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>article</td>
      <td>122</td>
      <td>100692</td>
      <td>pub.1134954138</td>
      <td>2021</td>
      <td>`[[{'raw_affiliation': ['Department of Aerospac...`</td>
      <td>Review of space habitat designs for long term ...</td>
      <td>jour.1139377</td>
      <td>Progress in Aerospace Sciences</td>
      <td><i>NaN</i></td>
    </tr>
    <tr>
      <td>1</td>
      <td>article</td>
      <td>181</td>
      <td>167-189</td>
      <td>pub.1130384298</td>
      <td>2021</td>
      <td>`[[{'raw_affiliation': ['U.S. Naval War College...`</td>
      <td>Joseph G. Gavin, Jr. and MIT’s contribution to...</td>
      <td>jour.1134138</td>
      <td>Acta Astronautica</td>
      <td><i>NaN</i></td>
    </tr>
    <tr>
      <td>2</td>
      <td>article</td>
      <td>180</td>
      <td>650-678</td>
      <td>pub.1134475636</td>
      <td>2021</td>
      <td>`[[{'raw_affiliation': ['Skolkovo Institute of ...`</td>
      <td>Regolith-based additive manufacturing for sust...</td>
      <td>jour.1134138</td>
      <td>Acta Astronautica</td>
      <td><i>NaN</i></td>
    </tr>
    <tr>
      <td>3</td>
      <td>article</td>
      <td><i>NaN</i></td>
      <td>1-13</td>
      <td>pub.1135101079</td>
      <td>2021</td>
      <td>`[[{'raw_affiliation': ['Centre for Teaching an...`</td>
      <td>Looking at Gail Jones’s “The Man in the Moon” ...</td>
      <td>jour.1137860</td>
      <td>Journal of Australian Studies</td>
      <td><i>NaN</i></td>
    </tr>
    <tr>
      <td>4</td>
      <td>article</td>
      <td>21</td>
      <td>959</td>
      <td>pub.1135057882</td>
      <td>2021</td>
      <td>`[[{'raw_affiliation': ['School of Artificial I...`</td>
      <td>Three-Dimensional Model of the Moon with Seman...</td>
      <td>jour.1033312</td>
      <td>Sensors</td>
      <td>3</td>
    </tr>
  </tbody>
</table>


## 2. Exporting DSL results to GBQ


First off, we want to run the full-text search so to extract *all* relevant publications IDs.

Second, we will export the publications IDs to GBQ. NOTE: Pandas provides a handy command to move data to GBQ: [DataFrame.to_gbq](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.to_gbq.html).


```python
%%dslloopdf

search publications for
  " \"moon landing\" AND Moon AND \"lunar surface\" "
return publications[id]
```

    Starting iteration with limit=1000 skip=0 ...
    0-1000 / 11201 (0.43s)
    1000-2000 / 11201 (1.01s)
    2000-3000 / 11201 (0.69s)
    3000-4000 / 11201 (1.03s)
    4000-5000 / 11201 (1.30s)
    5000-6000 / 11201 (1.58s)
    6000-7000 / 11201 (0.33s)
    7000-8000 / 11201 (0.25s)
    8000-9000 / 11201 (0.27s)
    9000-10000 / 11201 (0.64s)
    10000-11000 / 11201 (1.05s)
    11000-11201 / 11201 (1.80s)
    ===
    Records extracted: 11201

<div>
<table>
  <thead>
    <tr style="text-align: right;">
      <th>Row</th>
      <th>id</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>pub.1128771471</td>
    </tr>
    <tr>
      <td>1</td>
      <td>pub.1130814402</td>
    </tr>
    <tr>
      <td>2</td>
      <td>pub.1131658726</td>
    </tr>
    <tr>
      <td>3</td>
      <td>pub.1124123379</td>
    </tr>
    <tr>
      <td>4</td>
      <td>pub.1131232278</td>
    </tr>
    <tr>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <td>11196</td>
      <td>pub.1061739351</td>
    </tr>
    <tr>
      <td>11197</td>
      <td>pub.1025947790</td>
    </tr>
    <tr>
      <td>11198</td>
      <td>pub.1091822752</td>
    </tr>
    <tr>
      <td>11199</td>
      <td>pub.1025757974</td>
    </tr>
    <tr>
      <td>11200</td>
      <td>pub.1023928923</td>
    </tr>
  </tbody>
</table>
<p>11201 rows × 1 columns</p>
</div>




```python
df = dsl_last_results
```

The command below will add a new table `moonlanding` to the `demo_dsl` dataset in GQB.

That destination table is entirely up to you of course, so you need to make sure you have *write* access to the database.


```python
DATASET = "demo_dsl"
table_id = DATASET + ".moonlanding"
df.to_gbq(table_id, project_id = PROJECTID, if_exists="replace")
```

    1it [00:05,  5.05s/it]


That's it - you should now be able to go to the [online GBQ console](https://console.cloud.google.com/bigquery) and see the new `demo_dsl.moonlanding` dataset.

## 3. Querying your new dataset using a JOIN on Dimensions

We can now use the publications IDs we imported in order to create a JOIN query on the main Dimensions dataset. This is a bit like creating a 'view' of Dimensions corresponding to the full-text search we have done above.

GOAL: Roughly, the results should be the same as the 'publication year' facet in the [webapp](https://app.dimensions.ai/discover/publication?search_mode=content&search_text=%22moon%20landing%22%20AND%20Moon%20AND%20%22lunar%20surface%22%20&search_type=kws&search_field=full_search)


```sql
%%bigquery --project $PROJECTID

WITH mypubs AS (
  SELECT dim_pubs.*
  FROM
    `dimensions-ai.data_analytics.publications` dim_pubs
  JOIN
    `ds-data-solutions-gbq.demo_dsl.moonlanding` dslexport
  ON
    dim_pubs.id = dslexport.id
)

SELECT
  COUNT(id) as tot,
  year
FROM mypubs
GROUP BY year
ORDER BY tot DESC
```


<table>
  <thead>
    <tr style="text-align: right;">
      <th>Row</th>
      <th>tot</th>
      <th>year</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>10052</td>
      <td>2003</td>
    </tr>
    <tr>
      <td>1</td>
      <td>133</td>
      <td>2020</td>
    </tr>
    <tr>
      <td>2</td>
      <td>97</td>
      <td>2019</td>
    </tr>
    <tr>
      <td>3</td>
      <td>70</td>
      <td>2015</td>
    </tr>
    <tr>
      <td>4</td>
      <td>66</td>
      <td>2017</td>
    </tr>
    <tr>
      <td>5</td>
      <td>65</td>
      <td>2018</td>
    </tr>
    <tr>
      <td>6</td>
      <td>63</td>
      <td>2009</td>
    </tr>
    <tr>
      <td>7</td>
      <td>59</td>
      <td>2013</td>
    </tr>
    <tr><td colspan=3><i>rows truncated for display</i></td></tr>
  </tbody>
</table>


## 4. Using GBQ to generate researcher statistics

The goal is to generate a table just like the one in the 'researchers' analytical view in the [webapp](https://app.dimensions.ai/analytics/publication/author/aggregated?search_mode=content&search_text=%22moon%20landing%22%20AND%20Moon%20AND%20%22lunar%20surface%22%20&search_type=kws&search_field=full_search).

For each researcher we want to display some extra information:

* the total number of publications
* the citations count
* the total Altmetric Attention Score


```sql
%%bigquery --project $PROJECTID

WITH mypubs AS (
  SELECT dim_pubs.*
  FROM
    `dimensions-ai.data_analytics.publications` dim_pubs
  JOIN
    `ds-data-solutions-gbq.demo_dsl.moonlanding` dslexport
  ON
    dim_pubs.id = dslexport.id
),

researchers_metrics AS (
  SELECT researcher_id,
    COUNT(id) as publications_count,
    SUM(citations_count) as citations_count,
    SUM(altmetrics.score) as altmetric_sum
  FROM
    mypubs,
    UNNEST( researcher_ids ) as researcher_id
  GROUP BY researcher_id
)

SELECT * FROM researchers_metrics
ORDER BY publications_count DESC
```


<table>
  <thead>
    <tr style="text-align: right;">
      <th>Row</th>
      <th>researcher_id</th>
      <th>publications_count</th>
      <th>citations_count</th>
      <th>altmetric_sum</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>ur.01056354465.10</td>
      <td>11</td>
      <td>21.0</td>
      <td>49.0</td>
    </tr>
    <tr>
      <td>1</td>
      <td>ur.014402173273.44</td>
      <td>6</td>
      <td>42.0</td>
      <td>10.0</td>
    </tr>
    <tr>
      <td>2</td>
      <td>ur.012373502003.54</td>
      <td>4</td>
      <td>63.0</td>
      <td><i>NaN</i></td>
    </tr>
    <tr>
      <td>3</td>
      <td>ur.010534421371.14</td>
      <td>4</td>
      <td>63.0</td>
      <td><i>NaN</i></td>
    </tr>
    <tr>
      <td>4</td>
      <td>ur.015145367415.34</td>
      <td>4</td>
      <td>44.0</td>
      <td>1.0</td>
    </tr>
    <tr>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <td>1080</td>
      <td>ur.0767272510.86</td>
      <td>1</td>
      <td>5.0</td>
      <td><i>NaN</i></td>
    </tr>
    <tr>
      <td>1081</td>
      <td>ur.07637166751.28</td>
      <td>1</td>
      <td>3.0</td>
      <td><i>NaN</i></td>
    </tr>
    <tr>
      <td>1082</td>
      <td>ur.012762707227.21</td>
      <td>1</td>
      <td>3.0</td>
      <td><i>NaN</i></td>
    </tr>
    <tr>
      <td>1083</td>
      <td>ur.010101533313.52</td>
      <td>1</td>
      <td><i>NaN</i></td>
      <td>1.0</td>
    </tr>
    <tr>
      <td>1084</td>
      <td>ur.016406136233.64</td>
      <td>1</td>
      <td><i>NaN</i></td>
      <td>16.0</td>
    </tr>
  </tbody>
</table>

**Final step**: let's add researchers names and current organization details by joining up data from the [GRID table](https://docs.dimensions.ai/bigquery/datasource-organizations.html).



```sql
%%bigquery --project $PROJECTID

WITH mypubs AS (

  SELECT dim_pubs.*
  FROM
    `dimensions-ai.data_analytics.publications` dim_pubs
  JOIN
    `ds-data-solutions-gbq.demo_dsl.moonlanding` dslexport
  ON
    dim_pubs.id = dslexport.id

),

researchers_metrics AS (

  SELECT researcher_id,
    COUNT(id) as publications_count,
    SUM(citations_count) as citations_count,
    SUM(altmetrics.score) as altmetric_sum
  FROM
    mypubs,
    UNNEST( researcher_ids ) as researcher_id
  GROUP BY researcher_id

),

researchers_full AS (

  SELECT researchers_metrics.*,
    r.first_name, r.last_name, r.total_grants,
    grid.id as grid_id,
    grid.name as grid_name,
    grid.address.city as grid_city,
    grid.address.country as grid_country
  FROM
    researchers_metrics
  JOIN
    `dimensions-ai.data_analytics.researchers` r
    ON researchers_metrics.researcher_id = r.id
  JOIN
    `dimensions-ai.data_analytics.grid` grid
    ON grid.id = r.current_research_org

)



SELECT * FROM researchers_full
ORDER BY publications_count DESC
```


<table>
  <thead>
    <tr style="text-align: right;">
      <th>Row</th>
      <th>researcher_id</th>
      <th>publications_count</th>
      <th>citations_count</th>
      <th>altmetric_sum</th>
      <th>first_name</th>
      <th>last_name</th>
      <th>total_grants</th>
      <th>grid_id</th>
      <th>grid_name</th>
      <th>grid_city</th>
      <th>grid_country</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>ur.01056354465.10</td>
      <td>11</td>
      <td>21.0</td>
      <td>49.0</td>
      <td>Roger D</td>
      <td>Launius</td>
      <td>4</td>
      <td>grid.1214.6</td>
      <td>Smithsonian Institution</td>
      <td>Washington D.C.</td>
      <td>United States</td>
    </tr>
    <tr>
      <td>1</td>
      <td>ur.014402173273.44</td>
      <td>6</td>
      <td>42.0</td>
      <td>10.0</td>
      <td>Joseph N</td>
      <td>Pelton</td>
      <td>0</td>
      <td>grid.33224.34</td>
      <td>International Space University</td>
      <td>Illkirch-Graffenstaden</td>
      <td>France</td>
    </tr>
    <tr>
      <td>2</td>
      <td>ur.010243405673.63</td>
      <td>4</td>
      <td>14.0</td>
      <td><i>NaN</i></td>
      <td>Sachiko</td>
      <td>Wakabayashi</td>
      <td>1</td>
      <td>grid.62167.34</td>
      <td>Japan Aerospace Exploration Agency</td>
      <td>Tokyo</td>
      <td>Japan</td>
    </tr>
    <tr>
      <td>3</td>
      <td>ur.012503545245.69</td>
      <td>4</td>
      <td>12.0</td>
      <td>1.0</td>
      <td>Stephan</td>
      <td>Theil</td>
      <td>2</td>
      <td>grid.7551.6</td>
      <td>German Aerospace Center</td>
      <td>Cologne</td>
      <td>Germany</td>
    </tr>
    <tr>
      <td>4</td>
      <td>ur.0720745255.73</td>
      <td>4</td>
      <td>8.0</td>
      <td>28.0</td>
      <td>Chun-Lai</td>
      <td>Li</td>
      <td>3</td>
      <td>grid.450302.0</td>
      <td>National Astronomical Observatories</td>
      <td>Beijing</td>
      <td>China</td>
    </tr>
    <tr>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <td>886</td>
      <td>ur.011430662526.22</td>
      <td>1</td>
      <td>10.0</td>
      <td><i>NaN</i></td>
      <td>Gang</td>
      <td>Lei</td>
      <td>0</td>
      <td>grid.458502.e</td>
      <td>Technical Institute of Physics and Chemistry</td>
      <td>Beijing</td>
      <td>China</td>
    </tr>
    <tr>
      <td>887</td>
      <td>ur.015477605337.38</td>
      <td>1</td>
      <td>1.0</td>
      <td><i>NaN</i></td>
      <td>Olivier</td>
      <td>Dubois-Matra</td>
      <td>0</td>
      <td>grid.424669.b</td>
      <td>European Space Research and Technology Centre</td>
      <td>Noordwijk-Binnen</td>
      <td>Netherlands</td>
    </tr>
    <tr>
      <td>888</td>
      <td>ur.013214745135.53</td>
      <td>1</td>
      <td><i>NaN</i></td>
      <td><i>NaN</i></td>
      <td>Catherine L</td>
      <td>Newell</td>
      <td>0</td>
      <td>grid.26790.3a</td>
      <td>University of Miami</td>
      <td>Coral Gables</td>
      <td>United States</td>
    </tr>
    <tr>
      <td>889</td>
      <td>ur.014464032227.37</td>
      <td>1</td>
      <td>41.0</td>
      <td>141.0</td>
      <td>Andrew M</td>
      <td>Carton</td>
      <td>0</td>
      <td>grid.25879.31</td>
      <td>University of Pennsylvania</td>
      <td>Philadelphia</td>
      <td>United States</td>
    </tr>
    <tr>
      <td>890</td>
      <td>ur.010610572173.89</td>
      <td>1</td>
      <td>10.0</td>
      <td><i>NaN</i></td>
      <td>Zhan</td>
      <td>Liu</td>
      <td>0</td>
      <td>grid.411510.0</td>
      <td>China University of Mining and Technology</td>
      <td>Xuzhou</td>
      <td>China</td>
    </tr>
  </tbody>
</table>
