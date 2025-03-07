# Exploring the ORCiD dataset on Google Bigquery

The following examples explore how to use the openly available bigquery dataset available at: `ds-open-datasets.orcid.summaries_2024`

Further documentation on the orcid schema, along with how to get connected to bigquery can be found at: https://docs.dimensions.ai/bigquery/

!!! warning "Prerequisites"
    In order to run this tutorial, please ensure that you have
    
    * [Configured a Google Cloud project](https://docs.dimensions.ai/bigquery/gcp-setup.html#).
    * Basic familiarity with Python and [Jupyter notebooks](https://jupyter.org/).

(This tutorial is based on a Jupyter notebook that is [available directly via GitHub](https://github.com/digital-science/dimensions-gbq-lab/blob/master/notebooks/09-orcid.ipynb).)

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


**Before we go further, a quick warning.  In bigquery don't use "select *" to explore a dataset. It will be expensive. Use only the columns that you need**
  

## 1. <a name="orcid_identifier"> Querying orcid identifiers</a>

### 1.1 How many active orcids do we have?


```sql
%%bigquery

select count(orcid_identifier)
from ds-open-datasets.orcid.summaries_2024
   where history.deactivation_date is null
```

<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>f0_</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>21046010</td>
    </tr>
  </tbody>
</table>




### 1.2 How many orcid records have a publicly verified email?


```sql
%%bigquery

select count(orcid_identifier)
from ds-open-datasets.orcid.summaries_2024
   where history.deactivation_date is null
   and history.verified_email is True
```


<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>f0_</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>16623231</td>
    </tr>
  </tbody>
</table>




### 1.3 How many orcids have been created by year?


```sql
%%bigquery

select
  extract(YEAR FROM timestamp(history.submission_date)) AS year,
  count(orcid_identifier)
from ds-open-datasets.orcid.summaries_2024
   where history.deactivation_date is null
   group by 1 -- i.e. year
   order by 1
```

<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>year</th>
      <th>f0_</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>2012</td>
      <td>43695</td>
    </tr>
    <tr>
      <td>1</th>
      <td>2013</td>
      <td>420762</td>
    </tr>
    <tr>
      <td>2</th>
      <td>2014</td>
      <td>584072</td>
    </tr>
    <tr>
      <td>3</th>
      <td>2015</td>
      <td>731309</td>
    </tr>
    <tr>
      <td>4</th>
      <td>2016</td>
      <td>1021238</td>
    </tr>
    <tr>
      <td>5</th>
      <td>2017</td>
      <td>1343595</td>
    </tr>
    <tr>
      <td>6</th>
      <td>2018</td>
      <td>1546783</td>
    </tr>
    <tr>
      <td>7</th>
      <td>2019</td>
      <td>1959241</td>
    </tr>
    <tr>
      <td>8</th>
      <td>2020</td>
      <td>2598695</td>
    </tr>
    <tr>
      <td>9</th>
      <td>2021</td>
      <td>2659905</td>
    </tr>
    <tr>
      <td>10</th>
      <td>2022</td>
      <td>2748914</td>
    </tr>
    <tr>
      <td>11</th>
      <td>2023</td>
      <td>2975162</td>
    </tr>
    <tr>
      <td>12</th>
      <td>2024</td>
      <td>2412639</td>
    </tr>
  </tbody>
</table>




### 1.4 How many orcids have been modified in 2023 (2024 is only up to the date of the snapshot) ?


```sql
%%bigquery

select  count(orcid_identifier)
from ds-open-datasets.orcid.summaries_2024
   where history.deactivation_date is null
   and extract(YEAR FROM timestamp(history.last_modified_date)) = 2023
```

  <div id="df-2648a2c3-9819-44a9-a55e-be4a8b4452af" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>f0_</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>7471503</td>
    </tr>
  </tbody>
</table>
</div>
  </div>




## 2. `person`

### 2.1 How many orcid names are public?


```sql
%%bigquery

select
  count(orcid_identifier)
from ds-open-datasets.orcid.summaries_2024
where person.name.visibility = 'public'
```

<div id="df-7d2b7375-15eb-4157-92c1-a4bfe763dc52" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>f0_</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>21023410</td>
    </tr>
  </tbody>
</table>
</div>
    
  </div>




### 2.2 How many orcid records have other names?


```sql
%%bigquery

 select count(orcid_identifier)
 from ds-open-datasets.orcid.summaries_2024
 where person.other_names is not null
```

  <div id="df-075b30a0-f4e6-4a93-93a1-b222badee702" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>f0_</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>742479</td>
    </tr>
  </tbody>
</table>
</div>
    
  </div>




### 2.3 How many orcids have a populated credit name?


```sql
%%bigquery

 select count(orcid_identifier)
 from
 ds-open-datasets.orcid.summaries_2024
 where person.name.credit_name is not null
```


  <div id="df-7ca7029e-c371-40f9-8476-65cff41df53d" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>f0_</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>811105</td>
    </tr>
  </tbody>
</table>
</div>
    
  </div>

### 2.4 What are the dominant domains of URLs in author profiles?


```sql
%%bigquery

select
  substr(url.url,1,25) url_beginning,
  count(orcid_identifier) as orcid_count
from ds-open-datasets.orcid.summaries_2024
  cross join unnest(person.researcher_urls.urls) as url
group by 1 -- url beginining
order by 2 desc -- count of orcids
limit 10
```

  <div id="df-b775bbe5-194a-4ba7-9174-199c75cf04d0" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>url_beginning</th>
      <th>orcid_count</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>https://www.linkedin.com/</td>
      <td>238827</td>
    </tr>
    <tr>
      <td>1</th>
      <td>https://www.researchgate.</td>
      <td>150454</td>
    </tr>
    <tr>
      <td>2</th>
      <td>https://scholar.google.co</td>
      <td>125628</td>
    </tr>
    <tr>
      <td>3</th>
      <td>https://www.facebook.com/</td>
      <td>40467</td>
    </tr>
    <tr>
      <td>4</th>
      <td>http://www.linkedin.com/i</td>
      <td>35762</td>
    </tr>
    <tr>
      <td>5</th>
      <td>https://www.instagram.com</td>
      <td>24594</td>
    </tr>
    <tr>
      <td>6</th>
      <td>https://sites.google.com/</td>
      <td>23693</td>
    </tr>
    <tr>
      <td>7</th>
      <td>https://publons.com/resea</td>
      <td>13536</td>
    </tr>
    <tr>
      <td>8</th>
      <td>https://www.webofscience.</td>
      <td>12911</td>
    </tr>
    <tr>
      <td>9</th>
      <td>https://scholar.google.es</td>
      <td>10752</td>
    </tr>
  </tbody>
</table>
</div>
   
  </div>


### 2.5 How many profiles have biographies?


```sql
%%bigquery

select count(orcid_identifier)
 from ds-open-datasets.orcid.summaries_2024
where person.biography.content is not null
```

  <div id="df-22042cff-42f3-46be-87d6-86b8ee26138b" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>f0_</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>917857</td>
    </tr>
  </tbody>
</table>
</div>
   
  </div>




### 2.6 What are some of the most used words in biographies (other than stop words)?



```sql
%%bigquery

with
  bio_tokens as (
      select
        orcid_identifier.path orcid,
        split(person.biography.content,' ') as tokens
      from ds-open-datasets.orcid.summaries_2024
      where person.biography.content is not null
    ),
  tf_idf as (
    SELECT
      orcid,
      TF_IDF(tokens, 10000, 20) OVER() AS results
    FROM bio_tokens
    ORDER BY orcid
  )

select
  token.index,
  count(orcid) AS profiles
from tf_idf
  cross join unnest(results) as token
where token.index is not null
  and LENGTH(token.index) > 2
  and token.value > .7
group by 1 -- the word
order by 2 desc -- number of profiles including the word
limit 200
```


  <div id="df-58eadae4-cb50-479c-9950-ded78137d565" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>index</th>
      <th>profiles</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>Estudiante</td>
      <td>1149</td>
    </tr>
    <tr>
      <td>1</th>
      <td>Student</td>
      <td>1087</td>
    </tr>
    <tr>
      <td>2</th>
      <td>Medical</td>
      <td>886</td>
    </tr>
    <tr>
      <td>3</th>
      <td>Researcher</td>
      <td>880</td>
    </tr>
    <tr>
      <td>4</th>
      <td>student</td>
      <td>860</td>
    </tr>
    <tr>
      <td>...</th>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <td>195</th>
      <td>Graduate</td>
      <td>111</td>
    </tr>
    <tr>
      <td>196</th>
      <td>Cesar</td>
      <td>110</td>
    </tr>
    <tr>
      <td>197</th>
      <td>Social</td>
      <td>110</td>
    </tr>
    <tr>
      <td>198</th>
      <td>Applied</td>
      <td>110</td>
    </tr>
    <tr>
      <td>199</th>
      <td>Finance</td>
      <td>109</td>
    </tr>
  </tbody>
</table>
<p>200 rows × 2 columns</p>
</div>
    
  </div>

### 2.7 How many public emails are available in ORCiD?


```sql
%%bigquery

select count(distinct email.email)
from ds-open-datasets.orcid.summaries_2024,
   unnest(person.emails.emails) as email
WHERE email.visibility = 'public'
  AND email IS NOT NULL
```

  <div id="df-1c526eea-2aa1-457a-9479-f207a797a1d9" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>f0_</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>729428</td>
    </tr>
  </tbody>
</table>
</div>
   
  </div>




### 2.8 How many people give publicly visible countries/regions in ORCiD?

The `person.addresses` field records the countries a person has worked in.

```sql
%%bigquery

select count(distinct address.source.source_orcid.path)
from ds-open-datasets.orcid.summaries_2024,
   unnest(person.addresses.addresses) as address
WHERE address.visibility = 'public'
  AND address IS NOT NULL
```

  <div id="df-0b45efbc-24ea-4a0b-95b0-1f086ade2a01" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>f0_</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>2552260</td>
    </tr>
  </tbody>
</table>
</div>
  </div>


### 2.9 Which countries?


```sql
%%bigquery

select
  address.country,
  count(distinct address.source.source_orcid.path)
from ds-open-datasets.orcid.summaries_2024,
   unnest(person.addresses.addresses) as address
where address.visibility = 'public'
  and address is not null
group by address.country
order by 2 DESC -- count of orcids
```

  <div id="df-4c55d2a7-4224-48c7-a728-542053bce0f5" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>country</th>
      <th>f0_</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>BR</td>
      <td>272986</td>
    </tr>
    <tr>
      <td>1</th>
      <td>CN</td>
      <td>231405</td>
    </tr>
    <tr>
      <td>2</th>
      <td>US</td>
      <td>209177</td>
    </tr>
    <tr>
      <td>3</th>
      <td>IN</td>
      <td>171638</td>
    </tr>
    <tr>
      <td>4</th>
      <td>ES</td>
      <td>100541</td>
    </tr>
    <tr>
      <td>...</th>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <td>245</th>
      <td>NU</td>
      <td>6</td>
    </tr>
    <tr>
      <td>246</th>
      <td>CC</td>
      <td>6</td>
    </tr>
    <tr>
      <td>247</th>
      <td>BV</td>
      <td>5</td>
    </tr>
    <tr>
      <td>248</th>
      <td>TK</td>
      <td>4</td>
    </tr>
    <tr>
      <td>249</th>
      <td>PM</td>
      <td>4</td>
    </tr>
  </tbody>
</table>
<p>250 rows × 2 columns</p>
</div>
  </div>




### 2.10 What are the most frequent keywords in the ORCID dataset?


```sql
## Most frequent keywords?

%%bigquery

select lower(keyword.content), count(orcid_identifier.path)
from ds-open-datasets.orcid.summaries_2024,
   unnest(person.keywords.keywords) keyword
group by lower(keyword.content)
order by 2 desc -- i.e. count
```

  <div id="df-8418da5a-9f59-4cff-a40b-edf434957338" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>f0_</th>
      <th>f1_</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>machine learning</td>
      <td>19257</td>
    </tr>
    <tr>
      <td>1</th>
      <td>artificial intelligence</td>
      <td>10382</td>
    </tr>
    <tr>
      <td>2</th>
      <td>deep learning</td>
      <td>7789</td>
    </tr>
    <tr>
      <td>3</th>
      <td>bioinformatics</td>
      <td>7404</td>
    </tr>
    <tr>
      <td>4</th>
      <td>education</td>
      <td>6359</td>
    </tr>
    <tr>
      <td>...</th>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <td>1189703</th>
      <td>социально-психологическая виктимология</td>
      <td>1</td>
    </tr>
    <tr>
      <td>1189704</th>
      <td>analog circuits,oscillators, pll, adc, dac, lo...</td>
      <td>1</td>
    </tr>
    <tr>
      <td>1189705</th>
      <td>high education, internationalization of educat...</td>
      <td>1</td>
    </tr>
    <tr>
      <td>1189706</th>
      <td>structural mechanics, structural health monito...</td>
      <td>1</td>
    </tr>
    <tr>
      <td>1189707</th>
      <td>ritual cognition</td>
      <td>1</td>
    </tr>
  </tbody>
</table>
<p>1189708 rows × 2 columns</p>
</div>
    
  </div>




### 2.11 What are the most common identifier types in ORCiD?


```sql
%%bigquery

select
  lower(identifier.type),
  count(orcid_identifier.path)
from ds-open-datasets.orcid.summaries_2024,
   unnest(person.external_identifiers.identifiers) identifier
group by 1 -- i.e. identifier type
order by 2 desc -- i.e. count
limit 10
```

  <div id="df-870663d9-4d7e-4372-9a4f-3c5676e4f50f" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>f0_</th>
      <th>f1_</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>scopus author id</td>
      <td>1791459</td>
    </tr>
    <tr>
      <td>1</th>
      <td>researcherid</td>
      <td>700225</td>
    </tr>
    <tr>
      <td>2</th>
      <td>sciprofiles</td>
      <td>325959</td>
    </tr>
    <tr>
      <td>3</th>
      <td>loop profile</td>
      <td>261417</td>
    </tr>
    <tr>
      <td>4</th>
      <td>ciência id</td>
      <td>67820</td>
    </tr>
    <tr>
      <td>5</th>
      <td>researcher name resolver id</td>
      <td>14228</td>
    </tr>
    <tr>
      <td>6</th>
      <td>gnd</td>
      <td>9692</td>
    </tr>
    <tr>
      <td>7</th>
      <td>中国科学家在线</td>
      <td>5457</td>
    </tr>
    <tr>
      <td>8</th>
      <td>isni</td>
      <td>4227</td>
    </tr>
    <tr>
      <td>9</th>
      <td>pitt id</td>
      <td>3400</td>
    </tr>
  </tbody>
</table>
</div>
    
  </div>




## 3. <a name="activities">`activities`</a>

### 3.1 What are the most common academic roles in ORCiD?


```sql
%%bigquery

select
  record.role_title,
  count(orcid_identifier.path) as orcids
from ds-open-datasets.orcid.summaries_2024,
   unnest(activities.educations.groups) grp,
   unnest(grp.records) record
   where start_date.year = "2024"
group by record.role_title
order by orcids desc
limit 40
```

  <div id="df-098ccd0a-933d-454d-b7bd-a5f1c1293ea1" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>role_title</th>
      <th>orcids</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>PhD</td>
      <td>2118</td>
    </tr>
    <tr>
      <td>1</th>
      <td>None</td>
      <td>1768</td>
    </tr>
    <tr>
      <td>2</th>
      <td>Mestrado</td>
      <td>753</td>
    </tr>
    <tr>
      <td>3</th>
      <td>Doctor of Philosophy</td>
      <td>666</td>
    </tr>
    <tr>
      <td>4</th>
      <td>Doutorado</td>
      <td>583</td>
    </tr>
    <tr>
      <td>5</th>
      <td>Ph.D.</td>
      <td>510</td>
    </tr>
    <tr>
      <td>6</th>
      <td>PhD Student</td>
      <td>372</td>
    </tr>
    <tr>
      <td>7</th>
      <td>Master</td>
      <td>317</td>
    </tr>
    <tr>
      <td>8</th>
      <td>PhD student</td>
      <td>293</td>
    </tr>
    <tr>
      <td>9</th>
      <td>Master of Science</td>
      <td>256</td>
    </tr>
    <tr>
      <td>10</th>
      <td>Ph.D</td>
      <td>222</td>
    </tr>
    <tr>
      <td>11</th>
      <td>Mestranda</td>
      <td>216</td>
    </tr>
    <tr>
      <td>12</th>
      <td>Completed the course and project</td>
      <td>168</td>
    </tr>
    <tr>
      <td>13</th>
      <td>Mestrando</td>
      <td>149</td>
    </tr>
    <tr>
      <td>14</th>
      <td>Doutoranda</td>
      <td>145</td>
    </tr>
    <tr>
      <td>15</th>
      <td>Graduação</td>
      <td>137</td>
    </tr>
    <tr>
      <td>16</th>
      <td>PhD Candidate</td>
      <td>136</td>
    </tr>
    <tr>
      <td>17</th>
      <td>Doctor</td>
      <td>126</td>
    </tr>
    <tr>
      <td>18</th>
      <td>Doutorando</td>
      <td>119</td>
    </tr>
    <tr>
      <td>19</th>
      <td>Mestre</td>
      <td>112</td>
    </tr>
    <tr>
      <td>20</th>
      <td>Phd</td>
      <td>97</td>
    </tr>
    <tr>
      <td>21</th>
      <td>Estudiante</td>
      <td>94</td>
    </tr>
    <tr>
      <td>22</th>
      <td>PhD candidate</td>
      <td>93</td>
    </tr>
    <tr>
      <td>23</th>
      <td>MD</td>
      <td>91</td>
    </tr>
    <tr>
      <td>24</th>
      <td>Doctorate</td>
      <td>89</td>
    </tr>
    <tr>
      <td>25</th>
      <td>Masters</td>
      <td>84</td>
    </tr>
    <tr>
      <td>26</th>
      <td>MSc</td>
      <td>78</td>
    </tr>
    <tr>
      <td>27</th>
      <td>Especialização</td>
      <td>75</td>
    </tr>
    <tr>
      <td>28</th>
      <td>Master's Degree</td>
      <td>74</td>
    </tr>
    <tr>
      <td>29</th>
      <td>Doctor of Philosophy (PhD)</td>
      <td>69</td>
    </tr>
    <tr>
      <td>30</th>
      <td>Doctor of Medicine</td>
      <td>68</td>
    </tr>
    <tr>
      <td>31</th>
      <td>Ph.D. Student</td>
      <td>63</td>
    </tr>
    <tr>
      <td>32</th>
      <td>Master's degree</td>
      <td>58</td>
    </tr>
    <tr>
      <td>33</th>
      <td>ESTUDIANTE</td>
      <td>58</td>
    </tr>
    <tr>
      <td>34</th>
      <td>MS</td>
      <td>56</td>
    </tr>
    <tr>
      <td>35</th>
      <td>PHD</td>
      <td>55</td>
    </tr>
    <tr>
      <td>36</th>
      <td>Doctoral Student</td>
      <td>51</td>
    </tr>
    <tr>
      <td>37</th>
      <td>Bacharelado</td>
      <td>49</td>
    </tr>
    <tr>
      <td>38</th>
      <td>Master's</td>
      <td>48</td>
    </tr>
    <tr>
      <td>39</th>
      <td>Graduate Student</td>
      <td>47</td>
    </tr>
  </tbody>
</table>
</div>
    
  </div>




### 3.2 How many employments have disambiguated addresses in 2024?



```sql
#How many employments have disambiguated addresses in 2024?

%%bigquery

select organization.disambiguated_organization.source, count(orcid_identifier.path)
from ds-open-datasets.orcid.summaries_2024,
   unnest(activities.employments.groups) grp,
   unnest(grp.records) record
   where start_date.year = "2024"
group by 1
order by 2 desc
```

  <div id="df-01c973b9-baa1-43a8-aeed-d9ab4d39c5b6" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>source</th>
      <th>f0_</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>ROR</td>
      <td>228862</td>
    </tr>
    <tr>
      <td>1</th>
      <td>None</td>
      <td>30104</td>
    </tr>
    <tr>
      <td>2</th>
      <td>RINGGOLD</td>
      <td>2865</td>
    </tr>
    <tr>
      <td>3</th>
      <td>FUNDREF</td>
      <td>1904</td>
    </tr>
    <tr>
      <td>4</th>
      <td>GRID</td>
      <td>576</td>
    </tr>
  </tbody>
</table>
</div>
    
  </div>



### 3.3 What organizations have been tagged the most times in ORCID as having awarded funding?


```sql
%%bigquery

select
  funding_record.organization.name,
  count(*) AS mentioned_count
from ds-open-datasets.orcid.summaries_2024,
  unnest(activities.fundings.groups) as funding_groups,
  unnest(funding_groups.records) as funding_record
where funding_record.organization.name <> 'N/A'
group by funding_record.organization.name
order by mentioned_count desc
limit 10
```

  <div id="df-05c1885d-b294-4663-962c-d0b4436feadc" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>name</th>
      <th>mentioned_count</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>Fundação para a Ciência e a Tecnologia</td>
      <td>75382</td>
    </tr>
    <tr>
      <td>1</th>
      <td>European Commission</td>
      <td>47984</td>
    </tr>
    <tr>
      <td>2</th>
      <td>Japan Society for the Promotion of Science</td>
      <td>43370</td>
    </tr>
    <tr>
      <td>3</th>
      <td>National Natural Science Foundation of China</td>
      <td>20965</td>
    </tr>
    <tr>
      <td>4</th>
      <td>Fundação para a Ciência e a Tecnologia, I.P.</td>
      <td>17160</td>
    </tr>
    <tr>
      <td>5</th>
      <td>Coordenação de Aperfeiçoamento de Pessoal de N...</td>
      <td>15851</td>
    </tr>
    <tr>
      <td>6</th>
      <td>Conselho Nacional de Desenvolvimento Científic...</td>
      <td>15311</td>
    </tr>
    <tr>
      <td>7</th>
      <td>Canadian Institutes of Health Research</td>
      <td>15123</td>
    </tr>
    <tr>
      <td>8</th>
      <td>Australian Research Council</td>
      <td>14738</td>
    </tr>
    <tr>
      <td>9</th>
      <td>Swiss National Science Foundation</td>
      <td>14689</td>
    </tr>
  </tbody>
</table>
</div>
  </div>




### 3.4 What organizations make the most use of peer reviewers?


```sql
%%bigquery

select
  record.reviewer_role,
  record.review_type,
  record.convening_organization.name,
  count(orcid_identifier.path) AS orcids
from ds-open-datasets.orcid.summaries_2024,
    unnest(activities.peer_reviews.groups) as grp,
    unnest(grp.groups) as grpp,
    unnest(grpp.records) as record
group by record.reviewer_role, record.review_type, record.convening_organization.name
order by orcids desc
limit 10
```

  <div id="df-562c639f-18f2-437d-9644-ce10ff7bebdf" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>reviewer_role</th>
      <th>review_type</th>
      <th>name</th>
      <th>orcids</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>reviewer</td>
      <td>review</td>
      <td>Clarivate PLC</td>
      <td>3232053</td>
    </tr>
    <tr>
      <td>1</th>
      <td>reviewer</td>
      <td>review</td>
      <td>Publons</td>
      <td>3117297</td>
    </tr>
    <tr>
      <td>2</th>
      <td>reviewer</td>
      <td>review</td>
      <td>Elsevier, Inc.</td>
      <td>2660331</td>
    </tr>
    <tr>
      <td>3</th>
      <td>reviewer</td>
      <td>review</td>
      <td>Springer Nature</td>
      <td>2261495</td>
    </tr>
    <tr>
      <td>4</th>
      <td>reviewer</td>
      <td>review</td>
      <td>American Chemical Society</td>
      <td>1382847</td>
    </tr>
    <tr>
      <td>5</th>
      <td>reviewer</td>
      <td>review</td>
      <td>MDPI</td>
      <td>694117</td>
    </tr>
    <tr>
      <td>6</th>
      <td>reviewer</td>
      <td>review</td>
      <td>SpringerNature</td>
      <td>363646</td>
    </tr>
    <tr>
      <td>7</th>
      <td>reviewer</td>
      <td>review</td>
      <td>Wiley-VCH</td>
      <td>300707</td>
    </tr>
    <tr>
      <td>8</th>
      <td>reviewer</td>
      <td>review</td>
      <td>Public Library of Science</td>
      <td>166378</td>
    </tr>
    <tr>
      <td>9</th>
      <td>reviewer</td>
      <td>review</td>
      <td>BMJ Publishing Group</td>
      <td>83693</td>
    </tr>
  </tbody>
</table>
</div>
  </div>




### 3.5 What are the most used identifier types for works claimed in ORCID?


```sql
%%bigquery

select
  identifier.type,
  count(identifier.value) AS instances
from ds-open-datasets.orcid.summaries_2024,
  unnest(activities.works.groups) as grp,
  unnest(grp.external_ids.identifiers) as identifier
group by identifier.type
order by instances desc
limit 10
```

  <div id="df-62a9858a-0d8c-400d-96d8-6339c9cdfeba" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>type</th>
      <th>instances</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>doi</td>
      <td>77820619</td>
    </tr>
    <tr>
      <td>1</th>
      <td>eid</td>
      <td>40109303</td>
    </tr>
    <tr>
      <td>2</th>
      <td>wosuid</td>
      <td>13082114</td>
    </tr>
    <tr>
      <td>3</th>
      <td>source-work-id</td>
      <td>10850721</td>
    </tr>
    <tr>
      <td>4</th>
      <td>pmid</td>
      <td>8329151</td>
    </tr>
    <tr>
      <td>5</th>
      <td>other-id</td>
      <td>2997732</td>
    </tr>
    <tr>
      <td>6</th>
      <td>pmc</td>
      <td>2545463</td>
    </tr>
    <tr>
      <td>7</th>
      <td>arxiv</td>
      <td>2107965</td>
    </tr>
    <tr>
      <td>8</th>
      <td>handle</td>
      <td>1552937</td>
    </tr>
    <tr>
      <td>9</th>
      <td>isbn</td>
      <td>1054806</td>
    </tr>
  </tbody>
</table>
</div>
  </div>




### 3.6 What are the most common invited positions held by researchers with ORCIDs?


```sql
%%bigquery

select
  record.role_title,
  count(orcid_identifier.path) as orcids
from ds-open-datasets.orcid.summaries_2024,
  unnest(activities.invited_positions.records) as rec,
  unnest(rec.records) as record
where record.role_title is not null
group by record.role_title
order by orcids desc
```

  <div id="df-258df3f4-53c7-491c-9aa1-e7856ae1d82b" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>role_title</th>
      <th>orcids</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>Visiting Professor</td>
      <td>8391</td>
    </tr>
    <tr>
      <td>1</th>
      <td>Visiting Scholar</td>
      <td>4841</td>
    </tr>
    <tr>
      <td>2</th>
      <td>Member</td>
      <td>3984</td>
    </tr>
    <tr>
      <td>3</th>
      <td>Visiting Researcher</td>
      <td>3603</td>
    </tr>
    <tr>
      <td>4</th>
      <td>Reviewer</td>
      <td>3197</td>
    </tr>
    <tr>
      <td>...</th>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <td>160075</th>
      <td>Internal Medicine Chief Resident</td>
      <td>1</td>
    </tr>
    <tr>
      <td>160076</th>
      <td>Leuven Institute for Advanced Studies Fellow</td>
      <td>1</td>
    </tr>
    <tr>
      <td>160077</th>
      <td>Profesora invitada de Educación Superior de Po...</td>
      <td>1</td>
    </tr>
    <tr>
      <td>160078</th>
      <td>Director, Depression and Anxiety Disorders Pro...</td>
      <td>1</td>
    </tr>
    <tr>
      <td>160079</th>
      <td>Representance de los centros de investigacion ...</td>
      <td>1</td>
    </tr>
  </tbody>
</table>
<p>160080 rows × 2 columns</p>
</div>
  </div>




### 3.7 What are the most common membership positions held by researchers with ORCIDs?


```sql
%%bigquery

select
  record.role_title,
  count(orcid_identifier.path) as orcids
from ds-open-datasets.orcid.summaries_2024,
  unnest(activities.memberships.groups) as grp,
  unnest(grp.records) as record
where record.role_title is not null
group by record.role_title
order by orcids desc
limit 10
```

  <div id="df-d66a1b51-21d7-4577-88c2-84e68ce441c0" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>role_title</th>
      <th>orcids</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>Member</td>
      <td>78249</td>
    </tr>
    <tr>
      <td>1</th>
      <td>Fellow</td>
      <td>14622</td>
    </tr>
    <tr>
      <td>2</th>
      <td>Life Member</td>
      <td>14297</td>
    </tr>
    <tr>
      <td>3</th>
      <td>member</td>
      <td>11710</td>
    </tr>
    <tr>
      <td>4</th>
      <td>Student</td>
      <td>10547</td>
    </tr>
    <tr>
      <td>5</th>
      <td>Student Member</td>
      <td>6575</td>
    </tr>
    <tr>
      <td>6</th>
      <td>Miembro</td>
      <td>5651</td>
    </tr>
    <tr>
      <td>7</th>
      <td>Associate Member</td>
      <td>5036</td>
    </tr>
    <tr>
      <td>8</th>
      <td>Senior Member</td>
      <td>4781</td>
    </tr>
    <tr>
      <td>9</th>
      <td>Life member</td>
      <td>4575</td>
    </tr>
  </tbody>
</table>
</div>
  </div>




### 3.8 What are the most common types of qualification recorded by researchers with ORCIDs?


```sql
%%bigquery

select
  record.role_title,
  count(orcid_identifier.path) as orcids
from ds-open-datasets.orcid.summaries_2024,
  unnest(activities.qualifications.groups) as grp,
  unnest(grp.records) as record
where record.role_title is not null
  and record.role_title <> 'Student'
group by record.role_title
order by orcids desc
limit 10
```

  <div id="df-c203f9b7-3190-40f5-9d8e-0776134f0f75" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>role_title</th>
      <th>orcids</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>PhD</td>
      <td>44330</td>
    </tr>
    <tr>
      <td>1</th>
      <td>Investigador RENACYT</td>
      <td>10225</td>
    </tr>
    <tr>
      <td>2</th>
      <td>Ph.D.</td>
      <td>8451</td>
    </tr>
    <tr>
      <td>3</th>
      <td>Mestrado</td>
      <td>7355</td>
    </tr>
    <tr>
      <td>4</th>
      <td>Ph.D</td>
      <td>6843</td>
    </tr>
    <tr>
      <td>5</th>
      <td>Master</td>
      <td>5351</td>
    </tr>
    <tr>
      <td>6</th>
      <td>MSc</td>
      <td>5329</td>
    </tr>
    <tr>
      <td>7</th>
      <td>Doutorado</td>
      <td>5197</td>
    </tr>
    <tr>
      <td>8</th>
      <td>Mestre</td>
      <td>5147</td>
    </tr>
    <tr>
      <td>9</th>
      <td>PhD student</td>
      <td>5109</td>
    </tr>
  </tbody>
</table>
</div>
   </div>




### 3.9 What types of services do researchers with ORCIDs commonly say they have performed?


```sql
%%bigquery

select
  record.role_title,
  count(orcid_identifier.path) as orcids
from ds-open-datasets.orcid.summaries_2024,
  unnest(activities.services.groups) as grp,
  unnest(grp.records) as record
where record.role_title is not null
group by record.role_title
order by orcids desc
limit 10
```

  <div id="df-b0b5a4ed-3af4-4952-ab5a-48a6bcbe66c5" class="colab-df-container">
    <div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>role_title</th>
      <th>orcids</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</th>
      <td>Member</td>
      <td>11290</td>
    </tr>
    <tr>
      <td>1</th>
      <td>Reviewer</td>
      <td>5011</td>
    </tr>
    <tr>
      <td>2</th>
      <td>President</td>
      <td>4567</td>
    </tr>
    <tr>
      <td>3</th>
      <td>Associate Editor</td>
      <td>2865</td>
    </tr>
    <tr>
      <td>4</th>
      <td>Chair</td>
      <td>2463</td>
    </tr>
    <tr>
      <td>5</th>
      <td>Board Member</td>
      <td>1897</td>
    </tr>
    <tr>
      <td>6</th>
      <td>Editorial Board Member</td>
      <td>1882</td>
    </tr>
    <tr>
      <td>7</th>
      <td>Volunteer</td>
      <td>1835</td>
    </tr>
    <tr>
      <td>8</th>
      <td>Director</td>
      <td>1711</td>
    </tr>
    <tr>
      <td>9</th>
      <td>member</td>
      <td>1653</td>
    </tr>
  </tbody>
</table>
</div>
    </div>




### 3.10 What proposals for the use of specialist research facilities have involved the most researchers?


```sql
%%bigquery

select
  record.proposal.title.title,
  count(orcid_identifier.path) as orcids
from ds-open-datasets.orcid.summaries_2024,
  unnest(activities.research_resources.groups) as grp,
  unnest(grp.records) as record
group by record.proposal.title.title
order by orcids desc
limit 10
```


<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>title</th>
      <th>orcids</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>Neutron Beam Award at Spallation Neutron Sourc...</td>
      <td>858</td>
    </tr>
    <tr>
      <td>1</td>
      <td>Neutron Beam Award at High Flux Isotope Reacto...</td>
      <td>338</td>
    </tr>
    <tr>
      <td>2</th>
      <td>Neutron Beam Award at High Flux Isotope Reacto...</td>
      <td>199</td>
    </tr>
    <tr>
      <td>3</th>
      <td>Prediction of soil microbiome phenotypic respo...</td>
      <td>16</td>
    </tr>
    <tr>
      <td>4</th>
      <td>Unraveling Redox Transformation Mechanisms of ...</td>
      <td>13</td>
    </tr>
    <tr>
      <td>5</th>
      <td>The Transformation of Tetrahedral to Octahedra...</td>
      <td>12</td>
    </tr>
    <tr>
      <td>6</th>
      <td>EVALUATION OF CEMENT COMPOSITES, ROCKS, AND OT...</td>
      <td>10</td>
    </tr>
    <tr>
      <td>7</th>
      <td>Controls of bioorganic constituents of soils i...</td>
      <td>7</td>
    </tr>
    <tr>
      <td>8</th>
      <td>In situ TEM study of hierarchical nanowires gr...</td>
      <td>7</td>
    </tr>
    <tr>
      <td>9</th>
      <td>The effect of trace element content on the rat...</td>
      <td>7</td>
    </tr>
  </tbody>
</table>