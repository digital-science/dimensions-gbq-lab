# 1. Top publications by Altmetric score and research organization 




```sql

-- Top 5 pubs by Altmetric Score for GRID ID grid.4991.5 in the year 2020

SELECT
  id,
  title.preferred as title,
  ARRAY_LENGTH(authors) as authors,
  altmetrics.score as altmetrics_score
FROM
  `dimensions-ai.data_analytics.publications`
WHERE
  year = 2020 AND 'grid.4991.5' in UNNEST(research_orgs)
ORDER BY
  altmetrics.score desc
LIMIT 5
```

    Query complete after 0.07s: 100%|██████████| 2/2 [00:00<00:00, 908.64query/s]                         
    Downloading: 100%|██████████| 5/5 [00:02<00:00,  1.99rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>id</th>
      <th>title</th>
      <th>authors</th>
      <th>altmetrics_score</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>pub.1130340155</td>
      <td>Two metres or one: what is the evidence for ph...</td>
      <td>6</td>
      <td>15626</td>
    </tr>
    <tr>
      <th>1</th>
      <td>pub.1129493369</td>
      <td>Safety and immunogenicity of the ChAdOx1 nCoV-...</td>
      <td>366</td>
      <td>15382</td>
    </tr>
    <tr>
      <th>2</th>
      <td>pub.1127239818</td>
      <td>Remdesivir in adults with severe COVID-19: a r...</td>
      <td>46</td>
      <td>12139</td>
    </tr>
    <tr>
      <th>3</th>
      <td>pub.1133359801</td>
      <td>Safety and efficacy of the ChAdOx1 nCoV-19 vac...</td>
      <td>766</td>
      <td>11111</td>
    </tr>
    <tr>
      <th>4</th>
      <td>pub.1131721397</td>
      <td>Scientific consensus on the COVID-19 pandemic:...</td>
      <td>31</td>
      <td>10429</td>
    </tr>
  </tbody>
</table>
</div>



# 1. Working with Publications dates 

Each publication has various dates available. 

* `date`, `year`, `date_normal`, `date_online`, `date_print` refer to the publication object. See the [documentation](https://docs.dimensions.ai/bigquery/datasource-publications.html) to find out more about their meaning. 
* `date_imported_gbq` refers to when this record was last added to GBQ - this date can be handy if you want to synchronize an external data source to GBQ. 
* `date_inserted`: this refers to when this records was originally added to Dimensions (if the records gets adjusted later, it doesn't change). 

## Comparing date fields


```sql

SELECT doi,
       date,
       date_normal,
       year,
       date_online,
       date_print,
       date_imported_gbq,
       date_inserted
FROM   `dimensions-ai.data_analytics.publications`
WHERE  year = 2010
       AND journal.id = "jour.1115214"
ORDER  BY citations_count DESC
LIMIT  10 
```

    Query complete after 0.10s: 100%|██████████| 2/2 [00:00<00:00, 859.84query/s]                         
    Downloading: 100%|██████████| 10/10 [00:02<00:00,  3.86rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>doi</th>
      <th>date</th>
      <th>date_normal</th>
      <th>year</th>
      <th>date_online</th>
      <th>date_print</th>
      <th>date_imported_gbq</th>
      <th>date_inserted</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>10.1038/nbt.1621</td>
      <td>2010-05-02</td>
      <td>2010-05-02</td>
      <td>2010</td>
      <td>2010-05-02</td>
      <td>2010-05</td>
      <td>2021-02-10 01:09:29+00:00</td>
      <td>2017-08-31 12:50:56+00:00</td>
    </tr>
    <tr>
      <th>1</th>
      <td>10.1038/nbt.1630</td>
      <td>2010-05-02</td>
      <td>2010-05-02</td>
      <td>2010</td>
      <td>2010-05-02</td>
      <td>2010-05</td>
      <td>2021-02-10 01:09:29+00:00</td>
      <td>2017-08-31 12:50:56+00:00</td>
    </tr>
    <tr>
      <th>2</th>
      <td>10.1038/nbt.1614</td>
      <td>2010-03</td>
      <td>2010-03-01</td>
      <td>2010</td>
      <td>None</td>
      <td>2010-03</td>
      <td>2021-02-10 01:09:29+00:00</td>
      <td>2017-08-31 12:50:56+00:00</td>
    </tr>
    <tr>
      <th>3</th>
      <td>10.1038/nbt.1685</td>
      <td>2010-10-13</td>
      <td>2010-10-13</td>
      <td>2010</td>
      <td>2010-10-13</td>
      <td>2010-10</td>
      <td>2021-02-10 00:53:56+00:00</td>
      <td>2017-08-31 12:50:56+00:00</td>
    </tr>
    <tr>
      <th>4</th>
      <td>10.1038/nbt1210-1248</td>
      <td>2010-12-07</td>
      <td>2010-12-07</td>
      <td>2010</td>
      <td>2010-12-07</td>
      <td>2010-12</td>
      <td>2021-02-10 00:53:56+00:00</td>
      <td>2017-08-31 12:50:56+00:00</td>
    </tr>
    <tr>
      <th>5</th>
      <td>10.1038/nbt.1755</td>
      <td>2010-12-22</td>
      <td>2010-12-22</td>
      <td>2010</td>
      <td>2010-12-22</td>
      <td>2011-02</td>
      <td>2021-02-10 01:09:29+00:00</td>
      <td>2017-08-31 12:50:56+00:00</td>
    </tr>
    <tr>
      <th>6</th>
      <td>10.1038/nbt1010-1045</td>
      <td>2010-10-13</td>
      <td>2010-10-13</td>
      <td>2010</td>
      <td>2010-10-13</td>
      <td>2010-10</td>
      <td>2021-02-10 00:53:56+00:00</td>
      <td>2017-08-31 12:50:56+00:00</td>
    </tr>
    <tr>
      <th>7</th>
      <td>10.1038/nbt.1633</td>
      <td>2010-05-02</td>
      <td>2010-05-02</td>
      <td>2010</td>
      <td>2010-05-02</td>
      <td>2010-05</td>
      <td>2021-02-10 00:53:56+00:00</td>
      <td>2017-08-31 12:50:56+00:00</td>
    </tr>
    <tr>
      <th>8</th>
      <td>10.1038/nbt.1667</td>
      <td>2010-07-19</td>
      <td>2010-07-19</td>
      <td>2010</td>
      <td>2010-07-19</td>
      <td>2010-08</td>
      <td>2021-02-10 01:09:29+00:00</td>
      <td>2017-08-31 12:50:56+00:00</td>
    </tr>
    <tr>
      <th>9</th>
      <td>10.1038/nbt.1641</td>
      <td>2010-05-23</td>
      <td>2010-05-23</td>
      <td>2010</td>
      <td>2010-05-23</td>
      <td>2010-06</td>
      <td>2021-02-10 00:53:56+00:00</td>
      <td>2017-08-31 12:50:56+00:00</td>
    </tr>
  </tbody>
</table>
</div>



## Number of publications added to Dimensions by month


```sql

SELECT 
  DATETIME_TRUNC(DATETIME(date_inserted), MONTH) as date,
  COUNT(id) as countDim
FROM
  `dimensions-ai.data_analytics.publications`
GROUP BY date  
ORDER BY date DESC
LIMIT 5



```

    Query complete after 0.00s: 100%|██████████| 3/3 [00:00<00:00, 970.90query/s]                         
    Downloading: 100%|██████████| 5/5 [00:02<00:00,  2.13rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>date</th>
      <th>countDim</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>2021-02-01</td>
      <td>174570</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2021-01-01</td>
      <td>685667</td>
    </tr>
    <tr>
      <th>2</th>
      <td>2020-12-01</td>
      <td>820007</td>
    </tr>
    <tr>
      <th>3</th>
      <td>2020-11-01</td>
      <td>573519</td>
    </tr>
    <tr>
      <th>4</th>
      <td>2020-10-01</td>
      <td>718132</td>
    </tr>
  </tbody>
</table>
</div>



# 2. Working with NESTED fields 

UNNEST are implicit 'cross-join' queries, hence only records that have some value in the nested column are represented

For example, the query below return less publications that then ones available, because only the ones with `research_org_country_names` are included (= cross join)


```sql

SELECT
  COUNT(DISTINCT p.id) AS tot_articles
FROM
  `dimensions-ai.data_analytics.publications` p,
  UNNEST(research_org_country_names) AS research_org_country_names
WHERE
  year = 2000
```

    Query complete after 0.00s: 100%|██████████| 3/3 [00:00<00:00, 2579.52query/s]                        
    Downloading: 100%|██████████| 1/1 [00:04<00:00,  4.60s/rows]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>tot_articles</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1060342</td>
    </tr>
  </tbody>
</table>
</div>



As a test, we can run the query without the UNNEST clause


```sql

SELECT
  COUNT(DISTINCT p.id) AS tot_articles
FROM
  `dimensions-ai.data_analytics.publications` p
WHERE
  year = 2000
```

    Query complete after 0.00s: 100%|██████████| 3/3 [00:00<00:00, 2101.00query/s]                        
    Downloading: 100%|██████████| 1/1 [00:02<00:00,  2.97s/rows]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>tot_articles</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1759389</td>
    </tr>
  </tbody>
</table>
</div>



So how can we get all the records out? 

If you want to get all records, then **LEFT JOIN is the way to go** in this case


```sql

SELECT
  COUNT(DISTINCT p.id) AS tot_articles
FROM
  `dimensions-ai.data_analytics.publications` p
LEFT JOIN
  UNNEST(research_org_country_names) AS research_org_country_names
WHERE
  year = 2000
```

    Query complete after 0.00s: 100%|██████████| 3/3 [00:00<00:00, 1364.45query/s]                        
    Downloading: 100%|██████████| 1/1 [00:02<00:00,  2.56s/rows]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>tot_articles</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1759389</td>
    </tr>
  </tbody>
</table>
</div>



# 3. Generate a list of publication authors by flattening/concatenating nested data

IE Flattening an array of objects into a string


```sql

SELECT p.id,
       ARRAY_TO_STRING(
       (
              SELECT ARRAY
                     (
                            select CONCAT(first_name, " ", last_name)
                            from   UNNEST(p.authors)) ), '; ') AS authors_list
FROM   `dimensions-ai.data_analytics.publications` p
WHERE  p.id = 'pub.1132070778'
```

    Query complete after 0.00s: 100%|██████████| 1/1 [00:00<00:00, 680.67query/s]                          
    Downloading: 100%|██████████| 1/1 [00:02<00:00,  2.53s/rows]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>id</th>
      <th>authors_list</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>pub.1132070778</td>
      <td>O Grånäs; A Mocellin; E S Cardoso; F Burmeiste...</td>
    </tr>
  </tbody>
</table>
</div>



# 4. Generate a list of publication categories by flattening/concatenating nested data



```sql

SELECT p.id,
       ARRAY_TO_STRING(
       (
              SELECT ARRAY
                     (
                            SELECT name
                            FROM   UNNEST(p.category_for.first_level.FULL)) ), '; ') AS categories_list
FROM   `dimensions-ai.data_analytics.publications` p
WHERE  p.id = 'pub.1132070778'
```

    Query complete after 0.00s: 100%|██████████| 1/1 [00:00<00:00, 413.56query/s]                          
    Downloading: 100%|██████████| 1/1 [00:02<00:00,  2.55s/rows]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>id</th>
      <th>categories_list</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>pub.1132070778</td>
      <td>Physical Sciences; Chemical Sciences</td>
    </tr>
  </tbody>
</table>
</div>



# 5. Number of publications per SDG category


```sql

SELECT
  COUNT(DISTINCT p.id) AS tot,
  sdg.name
FROM `dimensions-ai.data_analytics.publications` p,
  UNNEST(category_sdg.full) sdg
GROUP BY sdg.name
LIMIT
  5
```

    Query complete after 0.00s: 100%|██████████| 4/4 [00:00<00:00, 2150.37query/s]                        
    Downloading: 100%|██████████| 5/5 [00:02<00:00,  2.11rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>tot</th>
      <th>name</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>184789</td>
      <td>Reduced Inequalities</td>
    </tr>
    <tr>
      <th>1</th>
      <td>610656</td>
      <td>Quality Education</td>
    </tr>
    <tr>
      <th>2</th>
      <td>137256</td>
      <td>Zero Hunger</td>
    </tr>
    <tr>
      <th>3</th>
      <td>24975</td>
      <td>Gender Equality</td>
    </tr>
    <tr>
      <th>4</th>
      <td>11830</td>
      <td>Partnerships for the Goals</td>
    </tr>
  </tbody>
</table>
</div>



# 6. Publications count per FoR category, total and percentage against total


```sql

SELECT
  cat.name,
  COUNT(DISTINCT p.id) AS pubs_global,
  ROUND ((COUNT(DISTINCT p.id) * 100 /(
      SELECT
        COUNT(*)
      FROM
        `dimensions-ai.data_analytics.publications`)), 2 ) AS pubs_global_pc
FROM
  `dimensions-ai.data_analytics.publications` p,
  UNNEST(category_for.first_level.full) cat
GROUP BY
  cat.name
```

    Query complete after 0.00s: 100%|██████████| 5/5 [00:00<00:00, 2593.56query/s]                        
    Downloading: 100%|██████████| 22/22 [00:02<00:00,  9.38rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>name</th>
      <th>pubs_global</th>
      <th>pubs_global_pc</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Language, Communication and Culture</td>
      <td>2494744</td>
      <td>2.15</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Earth Sciences</td>
      <td>2027739</td>
      <td>1.75</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Agricultural and Veterinary Sciences</td>
      <td>2085752</td>
      <td>1.80</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Philosophy and Religious Studies</td>
      <td>1662674</td>
      <td>1.43</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Medical and Health Sciences</td>
      <td>29853801</td>
      <td>25.74</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Economics</td>
      <td>1722795</td>
      <td>1.49</td>
    </tr>
    <tr>
      <th>6</th>
      <td>Commerce, Management, Tourism and Services</td>
      <td>1792537</td>
      <td>1.55</td>
    </tr>
    <tr>
      <th>7</th>
      <td>History and Archaeology</td>
      <td>2333998</td>
      <td>2.01</td>
    </tr>
    <tr>
      <th>8</th>
      <td>Technology</td>
      <td>1932511</td>
      <td>1.67</td>
    </tr>
    <tr>
      <th>9</th>
      <td>Biological Sciences</td>
      <td>8922205</td>
      <td>7.69</td>
    </tr>
    <tr>
      <th>10</th>
      <td>Psychology and Cognitive Sciences</td>
      <td>3822870</td>
      <td>3.30</td>
    </tr>
    <tr>
      <th>11</th>
      <td>Studies in Human Society</td>
      <td>3362309</td>
      <td>2.90</td>
    </tr>
    <tr>
      <th>12</th>
      <td>Mathematical Sciences</td>
      <td>4979926</td>
      <td>4.29</td>
    </tr>
    <tr>
      <th>13</th>
      <td>Environmental Sciences</td>
      <td>1349369</td>
      <td>1.16</td>
    </tr>
    <tr>
      <th>14</th>
      <td>Studies in Creative Arts and Writing</td>
      <td>639952</td>
      <td>0.55</td>
    </tr>
    <tr>
      <th>15</th>
      <td>Built Environment and Design</td>
      <td>480440</td>
      <td>0.41</td>
    </tr>
    <tr>
      <th>16</th>
      <td>Chemical Sciences</td>
      <td>7766182</td>
      <td>6.70</td>
    </tr>
    <tr>
      <th>17</th>
      <td>Law and Legal Studies</td>
      <td>883855</td>
      <td>0.76</td>
    </tr>
    <tr>
      <th>18</th>
      <td>Information and Computing Sciences</td>
      <td>5118832</td>
      <td>4.41</td>
    </tr>
    <tr>
      <th>19</th>
      <td>Physical Sciences</td>
      <td>6092552</td>
      <td>5.25</td>
    </tr>
    <tr>
      <th>20</th>
      <td>Engineering</td>
      <td>12168683</td>
      <td>10.49</td>
    </tr>
    <tr>
      <th>21</th>
      <td>Education</td>
      <td>1804004</td>
      <td>1.56</td>
    </tr>
  </tbody>
</table>
</div>



# 7. Finding Journals using string matching


```sql

SELECT COUNT(*) AS pubs,
  journal.id,
  journal.title,
  journal.issn,
  journal.eissn,
  publisher.name
FROM
  `dimensions-ai.data_analytics.publications`
WHERE
  LOWER( journal.title ) LIKE CONCAT('%medicine%')
GROUP BY 2, 3, 4, 5, 6
ORDER BY pubs DESC
LIMIT 20
```

    Query complete after 0.00s: 100%|██████████| 3/3 [00:00<00:00, 1307.32query/s]                        
    Downloading: 100%|██████████| 20/20 [00:02<00:00,  8.17rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>pubs</th>
      <th>id</th>
      <th>title</th>
      <th>issn</th>
      <th>eissn</th>
      <th>name</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>168620</td>
      <td>jour.1014075</td>
      <td>New England Journal of Medicine</td>
      <td>0028-4793</td>
      <td>1533-4406</td>
      <td>Massachusetts Medical Society</td>
    </tr>
    <tr>
      <th>1</th>
      <td>83860</td>
      <td>jour.1011551</td>
      <td>Medicine &amp; Science in Sports &amp; Exercise</td>
      <td>0195-9131</td>
      <td>1530-0315</td>
      <td>Wolters Kluwer</td>
    </tr>
    <tr>
      <th>2</th>
      <td>58617</td>
      <td>jour.1017222</td>
      <td>Annals of Internal Medicine</td>
      <td>0003-4819</td>
      <td>1539-3704</td>
      <td>American College of Physicians</td>
    </tr>
    <tr>
      <th>3</th>
      <td>52792</td>
      <td>jour.1312267</td>
      <td>Journal of the Royal Society of Medicine</td>
      <td>0141-0768</td>
      <td>1758-1095</td>
      <td>SAGE Publications</td>
    </tr>
    <tr>
      <th>4</th>
      <td>52248</td>
      <td>jour.1017256</td>
      <td>JAMA Internal Medicine</td>
      <td>2168-6106</td>
      <td>2168-6114</td>
      <td>American Medical Association (AMA)</td>
    </tr>
    <tr>
      <th>5</th>
      <td>47104</td>
      <td>jour.1027092</td>
      <td>Experimental Biology and Medicine</td>
      <td>1535-3702</td>
      <td>1535-3699</td>
      <td>SAGE Publications</td>
    </tr>
    <tr>
      <th>6</th>
      <td>46274</td>
      <td>jour.1016342</td>
      <td>Critical Care Medicine</td>
      <td>0090-3493</td>
      <td>1530-0293</td>
      <td>Wolters Kluwer</td>
    </tr>
    <tr>
      <th>7</th>
      <td>37632</td>
      <td>jour.1057918</td>
      <td>Journal of Molecular Medicine</td>
      <td>0946-2716</td>
      <td>1432-1440</td>
      <td>Springer Nature</td>
    </tr>
    <tr>
      <th>8</th>
      <td>34891</td>
      <td>jour.1017275</td>
      <td>Arizona Medicine</td>
      <td>0093-0415</td>
      <td>1476-2978</td>
      <td>None</td>
    </tr>
    <tr>
      <th>9</th>
      <td>31068</td>
      <td>jour.1014535</td>
      <td>The American Journal of Medicine</td>
      <td>0002-9343</td>
      <td>1555-7162</td>
      <td>Elsevier</td>
    </tr>
    <tr>
      <th>10</th>
      <td>29708</td>
      <td>jour.1017863</td>
      <td>Oral Surgery Oral Medicine Oral Pathology and ...</td>
      <td>2212-4403</td>
      <td>2212-4411</td>
      <td>Elsevier</td>
    </tr>
    <tr>
      <th>11</th>
      <td>28472</td>
      <td>jour.1090935</td>
      <td>Annals of Emergency Medicine</td>
      <td>0196-0644</td>
      <td>1097-6760</td>
      <td>Elsevier</td>
    </tr>
    <tr>
      <th>12</th>
      <td>26224</td>
      <td>jour.1077253</td>
      <td>Medicine</td>
      <td>0025-7974</td>
      <td>1536-5964</td>
      <td>Wolters Kluwer</td>
    </tr>
    <tr>
      <th>13</th>
      <td>25653</td>
      <td>jour.1017316</td>
      <td>Bulletin of Experimental Biology and Medicine</td>
      <td>0007-4888</td>
      <td>1573-8221</td>
      <td>Springer Nature</td>
    </tr>
    <tr>
      <th>14</th>
      <td>24781</td>
      <td>jour.1077126</td>
      <td>Journal of Experimental Medicine</td>
      <td>0022-1007</td>
      <td>1540-9538</td>
      <td>Rockefeller University Press</td>
    </tr>
    <tr>
      <th>15</th>
      <td>24339</td>
      <td>jour.1319882</td>
      <td>Journal of Internal Medicine</td>
      <td>0954-6820</td>
      <td>1365-2796</td>
      <td>Wiley</td>
    </tr>
    <tr>
      <th>16</th>
      <td>23511</td>
      <td>jour.1017748</td>
      <td>Academic Medicine</td>
      <td>1040-2446</td>
      <td>1938-808X</td>
      <td>Wolters Kluwer</td>
    </tr>
    <tr>
      <th>17</th>
      <td>22601</td>
      <td>jour.1017031</td>
      <td>American Journal of Respiratory and Critical C...</td>
      <td>1073-449X</td>
      <td>1535-4970</td>
      <td>American Thoracic Society</td>
    </tr>
    <tr>
      <th>18</th>
      <td>22220</td>
      <td>jour.1036793</td>
      <td>Military Medicine</td>
      <td>0026-4075</td>
      <td>1930-613X</td>
      <td>Oxford University Press (OUP)</td>
    </tr>
    <tr>
      <th>19</th>
      <td>21695</td>
      <td>jour.1017021</td>
      <td>American Journal of Tropical Medicine and Hygiene</td>
      <td>0002-9637</td>
      <td>1476-1645</td>
      <td>American Society of Tropical Medicine and Hygiene</td>
    </tr>
  </tbody>
</table>
</div>



# 8. Finding articles matching a specific affiliation string


```sql

SELECT id,
       aff.grid_id,
       aff.raw_affiliation
FROM   `dimensions-ai.data_analytics.publications`,
       UNNEST(authors) auth,
       UNNEST(auth.affiliations_address) AS aff
WHERE  year = 2020
AND    aff.grid_id = "grid.69566.3a"
AND    LOWER(aff.raw_affiliation) LIKE "%school of medicine%"
```

    Query complete after 0.00s: 100%|██████████| 2/2 [00:00<00:00, 758.74query/s]                         
    Downloading: 100%|██████████| 5920/5920 [00:02<00:00, 2233.04rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>id</th>
      <th>grid_id</th>
      <th>raw_affiliation</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>pub.1112041600</td>
      <td>grid.69566.3a</td>
      <td>5Department of Neurosurgery, Tohoku University...</td>
    </tr>
    <tr>
      <th>1</th>
      <td>pub.1112041600</td>
      <td>grid.69566.3a</td>
      <td>6Division of Epidemiology, Department of Healt...</td>
    </tr>
    <tr>
      <th>2</th>
      <td>pub.1117164397</td>
      <td>grid.69566.3a</td>
      <td>Division of Cardiovascular Surgery, Tohoku Uni...</td>
    </tr>
    <tr>
      <th>3</th>
      <td>pub.1119863526</td>
      <td>grid.69566.3a</td>
      <td>Division of Emergency and Critical Care Medici...</td>
    </tr>
    <tr>
      <th>4</th>
      <td>pub.1122526898</td>
      <td>grid.69566.3a</td>
      <td>Department of Neurological Science, Tohoku Uni...</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>5915</th>
      <td>pub.1128974183</td>
      <td>grid.69566.3a</td>
      <td>Department of Organ Anatomy, Tohoku University...</td>
    </tr>
    <tr>
      <th>5916</th>
      <td>pub.1128974183</td>
      <td>grid.69566.3a</td>
      <td>Department of Organ Anatomy, Tohoku University...</td>
    </tr>
    <tr>
      <th>5917</th>
      <td>pub.1128974183</td>
      <td>grid.69566.3a</td>
      <td>Department of Organ Anatomy, Tohoku University...</td>
    </tr>
    <tr>
      <th>5918</th>
      <td>pub.1128977047</td>
      <td>grid.69566.3a</td>
      <td>Department of Molecular Pathology, Tohoku Univ...</td>
    </tr>
    <tr>
      <th>5919</th>
      <td>pub.1128977047</td>
      <td>grid.69566.3a</td>
      <td>Department of Molecular Pathology, Tohoku Univ...</td>
    </tr>
  </tbody>
</table>
<p>5920 rows × 3 columns</p>
</div>



## 8.1 Variant: get unique publication records with affiliation count 


```sql

SELECT
  COUNT(aff) AS matching_affiliations,
  id,
  title.preferred AS title
FROM
  `dimensions-ai.data_analytics.publications`,
  UNNEST(authors) auth,
  UNNEST(auth.affiliations_address) AS aff
WHERE
  year = 2020
  AND aff.grid_id = "grid.69566.3a"
  AND LOWER(aff.raw_affiliation) LIKE "%school of medicine%"
GROUP BY
  id,
  title
```

    Query complete after 0.00s: 100%|██████████| 2/2 [00:00<00:00, 701.04query/s]                         
    Downloading: 100%|██████████| 1492/1492 [00:02<00:00, 531.33rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>matching_affiliations</th>
      <th>id</th>
      <th>title</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>9</td>
      <td>pub.1124154670</td>
      <td>P822 Genetic analysis of ulcerative colitis in...</td>
    </tr>
    <tr>
      <th>1</th>
      <td>8</td>
      <td>pub.1124073702</td>
      <td>Exploring the Novel Susceptibility Gene Varian...</td>
    </tr>
    <tr>
      <th>2</th>
      <td>1</td>
      <td>pub.1124562761</td>
      <td>Prediction of the Probability of Malignancy in...</td>
    </tr>
    <tr>
      <th>3</th>
      <td>2</td>
      <td>pub.1124468935</td>
      <td>Usefulness of a Kampo Medicine on Stress-Induc...</td>
    </tr>
    <tr>
      <th>4</th>
      <td>1</td>
      <td>pub.1124922689</td>
      <td>Qualitative investigation of the factors that ...</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>1487</th>
      <td>5</td>
      <td>pub.1131095571</td>
      <td>Hypoketotic hypoglycemia in citrin deficiency:...</td>
    </tr>
    <tr>
      <th>1488</th>
      <td>2</td>
      <td>pub.1133151054</td>
      <td>Electronic phenotyping of heart failure from a...</td>
    </tr>
    <tr>
      <th>1489</th>
      <td>1</td>
      <td>pub.1132062513</td>
      <td>Retrospective details of false-positive and fa...</td>
    </tr>
    <tr>
      <th>1490</th>
      <td>12</td>
      <td>pub.1132032426</td>
      <td>Identification of the Novel Variants in Patien...</td>
    </tr>
    <tr>
      <th>1491</th>
      <td>1</td>
      <td>pub.1132020326</td>
      <td>Radiographic features and poor prognostic fact...</td>
    </tr>
  </tbody>
</table>
<p>1492 rows × 3 columns</p>
</div>



# 9. Select publications matching selected concepts


```sql

WITH tropical_diseases AS
(
       SELECT *
       FROM   `dimensions-ai.data_analytics.publications` )
SELECT   publisher.NAME AS publisher,
         year,
         count(*) AS num_pub
FROM     tropical_diseases,
         UNNEST(tropical_diseases.concepts) c
WHERE    (
                  LOWER(c.concept) IN UNNEST(["buruli ulcer", "mycobacterium", "mycolactone", "bairnsdale ulcer"])
         OR       REGEXP_CONTAINS(title.preferred, r"(?i)/buruli ulcer|mycobacterium|mycolactone|bairnsdale ulcer/"))
AND      year >= 2010
AND      publisher IS NOT NULL
GROUP BY publisher, year
ORDER BY num_pub DESC,
         year,
         publisher LIMIT 10
```

    Query complete after 0.00s: 100%|██████████| 3/3 [00:00<00:00, 1390.68query/s]                        
    Downloading: 100%|██████████| 10/10 [00:02<00:00,  3.98rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>publisher</th>
      <th>year</th>
      <th>num_pub</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Elsevier</td>
      <td>2020</td>
      <td>31812</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Elsevier</td>
      <td>2018</td>
      <td>29580</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Elsevier</td>
      <td>2019</td>
      <td>28941</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Elsevier</td>
      <td>2017</td>
      <td>28415</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Elsevier</td>
      <td>2015</td>
      <td>27301</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Elsevier</td>
      <td>2011</td>
      <td>25758</td>
    </tr>
    <tr>
      <th>6</th>
      <td>Elsevier</td>
      <td>2016</td>
      <td>25149</td>
    </tr>
    <tr>
      <th>7</th>
      <td>Elsevier</td>
      <td>2013</td>
      <td>23209</td>
    </tr>
    <tr>
      <th>8</th>
      <td>Elsevier</td>
      <td>2014</td>
      <td>23100</td>
    </tr>
    <tr>
      <th>9</th>
      <td>Springer Nature</td>
      <td>2019</td>
      <td>22072</td>
    </tr>
  </tbody>
</table>
</div>



# 10. Count of corresponding authors by publisher 


```sql

SELECT
  COUNT(DISTINCT id) AS tot,
  publisher.name
FROM
  `dimensions-ai.data_analytics.publications`,
  UNNEST(authors) aff
WHERE
  aff.corresponding IS TRUE
  AND publisher.name IS NOT NULL
GROUP BY
  publisher.name
ORDER BY
  tot DESC
```

    Query complete after 0.00s: 100%|██████████| 4/4 [00:00<00:00, 1306.84query/s]                        
    Downloading: 100%|██████████| 421/421 [00:02<00:00, 208.14rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>tot</th>
      <th>name</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>8733776</td>
      <td>Elsevier</td>
    </tr>
    <tr>
      <th>1</th>
      <td>5885408</td>
      <td>Springer Nature</td>
    </tr>
    <tr>
      <th>2</th>
      <td>813007</td>
      <td>Institute of Electrical and Electronics Engine...</td>
    </tr>
    <tr>
      <th>3</th>
      <td>683093</td>
      <td>SAGE Publications</td>
    </tr>
    <tr>
      <th>4</th>
      <td>380636</td>
      <td>MDPI</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>416</th>
      <td>1</td>
      <td>New York Entomological Society</td>
    </tr>
    <tr>
      <th>417</th>
      <td>1</td>
      <td>Kansas Academy of Science</td>
    </tr>
    <tr>
      <th>418</th>
      <td>1</td>
      <td>Gorgias Press LLC</td>
    </tr>
    <tr>
      <th>419</th>
      <td>1</td>
      <td>Journal of the North Atlantic</td>
    </tr>
    <tr>
      <th>420</th>
      <td>1</td>
      <td>Institute of Lifestyle Medicine</td>
    </tr>
  </tbody>
</table>
<p>421 rows × 2 columns</p>
</div>



# 11. Counting new vs recurring authors, for a specific journal


```sql


WITH
  authoryear AS (
  SELECT pubs.year, author.researcher_id, COUNT(pubs.id) AS numpubs
  FROM
    `dimensions-ai.data_analytics.publications` AS pubs
  CROSS JOIN
    UNNEST(pubs.authors) AS author
  WHERE
    author.researcher_id IS NOT NULL
    AND journal.id= "jour.1115214"
  GROUP BY
    author.researcher_id, pubs.year ),

authorfirst AS (
  SELECT researcher_id, MIN(year) AS minyear
  FROM
    authoryear
  GROUP BY
    researcher_id ),

authorsummary AS (
  SELECT ay.*,
  IF
    (ay.year=af.minyear,
      TRUE,
      FALSE) AS firstyear
  FROM
    authoryear ay
  JOIN
    authorfirst af
  ON
    af.researcher_id=ay.researcher_id
  ORDER BY
    ay.researcher_id, year ),

numauthors AS (
  SELECT year, firstyear, COUNT(DISTINCT researcher_id) AS numresearchers
  FROM
    authorsummary
  WHERE
    year>2010
  GROUP BY year, firstyear )

SELECT
  year,
  SUM(CASE
      WHEN firstyear THEN numresearchers
    ELSE
    0
  END
    ) AS num_first,
  SUM(CASE
      WHEN NOT firstyear THEN numresearchers
    ELSE
    0
  END
    ) AS num_recurring
FROM numauthors
GROUP BY year
ORDER BY year

```

    Query complete after 0.00s: 100%|██████████| 10/10 [00:00<00:00, 5414.10query/s]                       
    Downloading: 100%|██████████| 10/10 [00:02<00:00,  4.29rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>year</th>
      <th>num_first</th>
      <th>num_recurring</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>2011</td>
      <td>1040</td>
      <td>352</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2012</td>
      <td>858</td>
      <td>373</td>
    </tr>
    <tr>
      <th>2</th>
      <td>2013</td>
      <td>926</td>
      <td>345</td>
    </tr>
    <tr>
      <th>3</th>
      <td>2014</td>
      <td>1088</td>
      <td>338</td>
    </tr>
    <tr>
      <th>4</th>
      <td>2015</td>
      <td>1044</td>
      <td>392</td>
    </tr>
    <tr>
      <th>5</th>
      <td>2016</td>
      <td>1313</td>
      <td>350</td>
    </tr>
    <tr>
      <th>6</th>
      <td>2017</td>
      <td>1072</td>
      <td>404</td>
    </tr>
    <tr>
      <th>7</th>
      <td>2018</td>
      <td>1104</td>
      <td>419</td>
    </tr>
    <tr>
      <th>8</th>
      <td>2019</td>
      <td>1184</td>
      <td>442</td>
    </tr>
    <tr>
      <th>9</th>
      <td>2020</td>
      <td>1579</td>
      <td>568</td>
    </tr>
  </tbody>
</table>
</div>



# 12. Funding by journal


```sql

WITH funding AS
(
         SELECT   funding.grid_id         AS funders,
                  COUNT(id)               AS pubs,
                  COUNT(funding.grant_id) AS grants
         FROM     `dimensions-ai.data_analytics.publications`,
                  UNNEST(funding_details) AS funding
         WHERE    journal.id = "jour.1113716" -- nature medicine
         GROUP BY funders)

SELECT   funding.*,
         grid.NAME
FROM     funding
JOIN     `dimensions-ai.data_analytics.grid` grid
ON       funding.funders = grid.id
ORDER BY pubs DESC,
         grants DESC
LIMIT 10
```

    Query complete after 0.00s: 100%|██████████| 5/5 [00:00<00:00, 2520.01query/s]                        
    Downloading: 100%|██████████| 10/10 [00:02<00:00,  4.11rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>funders</th>
      <th>pubs</th>
      <th>grants</th>
      <th>NAME</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>grid.48336.3a</td>
      <td>2699</td>
      <td>2484</td>
      <td>National Cancer Institute</td>
    </tr>
    <tr>
      <th>1</th>
      <td>grid.419681.3</td>
      <td>2008</td>
      <td>1878</td>
      <td>National Institute of Allergy and Infectious D...</td>
    </tr>
    <tr>
      <th>2</th>
      <td>grid.419635.c</td>
      <td>1620</td>
      <td>1564</td>
      <td>National Institute of Diabetes and Digestive a...</td>
    </tr>
    <tr>
      <th>3</th>
      <td>grid.279885.9</td>
      <td>1612</td>
      <td>1525</td>
      <td>National Heart Lung and Blood Institute</td>
    </tr>
    <tr>
      <th>4</th>
      <td>grid.416870.c</td>
      <td>712</td>
      <td>668</td>
      <td>National Institute of Neurological Disorders a...</td>
    </tr>
    <tr>
      <th>5</th>
      <td>grid.419475.a</td>
      <td>569</td>
      <td>537</td>
      <td>National Institute on Aging</td>
    </tr>
    <tr>
      <th>6</th>
      <td>grid.54432.34</td>
      <td>510</td>
      <td>447</td>
      <td>Japan Society for the Promotion of Science</td>
    </tr>
    <tr>
      <th>7</th>
      <td>grid.280785.0</td>
      <td>460</td>
      <td>441</td>
      <td>National Institute of General Medical Sciences</td>
    </tr>
    <tr>
      <th>8</th>
      <td>grid.14105.31</td>
      <td>452</td>
      <td>344</td>
      <td>Medical Research Council</td>
    </tr>
    <tr>
      <th>9</th>
      <td>grid.270680.b</td>
      <td>400</td>
      <td>183</td>
      <td>European Commission</td>
    </tr>
  </tbody>
</table>
</div>



# 13. Citations queries

## 13.1 Top N publications by citations percentile


```sql

WITH pubs AS (
  SELECT
    p.id as id, 
    p.title.preferred as title,
    p.citations_count as citations,
  FROM
    `dimensions-ai.data_analytics.publications` p
  WHERE year = 2020 AND "09" IN UNNEST(category_for.first_level.codes)
),
ranked_pubs AS (
  SELECT
    p.*,
    PERCENT_RANK() OVER (ORDER BY p.citations DESC) citation_percentile
  FROM
    pubs p
)
SELECT * FROM ranked_pubs
WHERE citation_percentile <= 0.01
ORDER BY citation_percentile asc
```

    Query complete after 0.00s: 100%|██████████| 3/3 [00:00<00:00, 1800.65query/s]                        
    Downloading: 100%|██████████| 7034/7034 [00:02<00:00, 2555.04rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>id</th>
      <th>title</th>
      <th>citations</th>
      <th>citation_percentile</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>pub.1129408972</td>
      <td>Estimation of total flavonoid content in propo...</td>
      <td>881</td>
      <td>0.000000</td>
    </tr>
    <tr>
      <th>1</th>
      <td>pub.1122861707</td>
      <td>Mercury 4.0: from visualization to analysis, d...</td>
      <td>393</td>
      <td>0.000001</td>
    </tr>
    <tr>
      <th>2</th>
      <td>pub.1125814051</td>
      <td>Analysis and forecast of COVID-19 spreading in...</td>
      <td>286</td>
      <td>0.000003</td>
    </tr>
    <tr>
      <th>3</th>
      <td>pub.1126110231</td>
      <td>Covid-19: automatic detection from X-ray image...</td>
      <td>255</td>
      <td>0.000004</td>
    </tr>
    <tr>
      <th>4</th>
      <td>pub.1125821215</td>
      <td>The Role of Telehealth in Reducing the Mental ...</td>
      <td>234</td>
      <td>0.000006</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>7029</th>
      <td>pub.1127509406</td>
      <td>Hydrothermal carbonization of sewage digestate...</td>
      <td>14</td>
      <td>0.008954</td>
    </tr>
    <tr>
      <th>7030</th>
      <td>pub.1127507337</td>
      <td>Flow and heat transfer of hybrid nanofluid ove...</td>
      <td>14</td>
      <td>0.008954</td>
    </tr>
    <tr>
      <th>7031</th>
      <td>pub.1127511048</td>
      <td>Reinforcement learning for building controls: ...</td>
      <td>14</td>
      <td>0.008954</td>
    </tr>
    <tr>
      <th>7032</th>
      <td>pub.1126596495</td>
      <td>Integrated Multi-satellite Retrievals for the ...</td>
      <td>14</td>
      <td>0.008954</td>
    </tr>
    <tr>
      <th>7033</th>
      <td>pub.1125954927</td>
      <td>An Innovative Air Conditioning System for Chan...</td>
      <td>14</td>
      <td>0.008954</td>
    </tr>
  </tbody>
</table>
<p>7034 rows × 4 columns</p>
</div>



## 13.2 Citations by journal, for a specific publisher 


```sql

WITH publisher_pubs AS (
  SELECT id FROM `dimensions-ai.data_analytics.publications`
  WHERE publisher.id = "pblshr.1000340" AND type = "article"
)

SELECT 
  COUNT(p.id) as tot,
  p.journal.title as journal
FROM `dimensions-ai.data_analytics.publications` p, UNNEST(p.reference_ids) r
WHERE 
  p.year = 2020 AND p.type = "article"      -- restrict to articles with a published year of 2020
  AND p.publisher.id <> "pblshr.1000340"    -- where the publisher is not the same as the pusblisher above
  AND r IN (SELECT * FROM publisher_pubs)   -- the publication must reference a publishers publication
GROUP BY journal
ORDER BY tot DESC
LIMIT 10
```

    Query complete after 0.00s: 100%|██████████| 5/5 [00:00<00:00, 2635.28query/s]                        
    Downloading: 100%|██████████| 10/10 [00:02<00:00,  3.92rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>tot</th>
      <th>journal</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>26147</td>
      <td>Scientific Reports</td>
    </tr>
    <tr>
      <th>1</th>
      <td>18794</td>
      <td>International Journal of Molecular Sciences</td>
    </tr>
    <tr>
      <th>2</th>
      <td>8647</td>
      <td>Frontiers in Microbiology</td>
    </tr>
    <tr>
      <th>3</th>
      <td>8620</td>
      <td>None</td>
    </tr>
    <tr>
      <th>4</th>
      <td>7695</td>
      <td>Frontiers in Immunology</td>
    </tr>
    <tr>
      <th>5</th>
      <td>6960</td>
      <td>International Journal of Environmental Researc...</td>
    </tr>
    <tr>
      <th>6</th>
      <td>6421</td>
      <td>Nature Communications</td>
    </tr>
    <tr>
      <th>7</th>
      <td>6145</td>
      <td>Cells</td>
    </tr>
    <tr>
      <th>8</th>
      <td>5687</td>
      <td>Cancers</td>
    </tr>
    <tr>
      <th>9</th>
      <td>5006</td>
      <td>Microorganisms</td>
    </tr>
  </tbody>
</table>
</div>



## 13.3 One-degree citation network for a single publication


```sql

WITH level1 AS (
  select "pub.1099396382" as citation_from, citations.id as citation_to, 1 as level, citations.year as citation_year
  from `dimensions-ai.data_analytics.publications` p, unnest(citations) as citations
  where p.id="pub.1099396382"
),

level2 AS (
  select l.citation_to as citation_from, citations.id as citation_to, 2 as level, citations.year as citation_year
  from `dimensions-ai.data_analytics.publications` p, unnest(citations) as citations, level1 l
  where p.id = l.citation_to
)

SELECT * from level1 
UNION ALL
SELECT * from level2 
```

    Query complete after 0.00s: 100%|██████████| 4/4 [00:00<00:00, 1554.02query/s]                        
    Downloading: 100%|██████████| 187/187 [00:02<00:00, 79.75rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>citation_from</th>
      <th>citation_to</th>
      <th>level</th>
      <th>citation_year</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>pub.1114028205</td>
      <td>pub.1131160226</td>
      <td>2</td>
      <td>2020</td>
    </tr>
    <tr>
      <th>1</th>
      <td>pub.1023754996</td>
      <td>pub.1111137794</td>
      <td>2</td>
      <td>2019</td>
    </tr>
    <tr>
      <th>2</th>
      <td>pub.1023754996</td>
      <td>pub.1119901753</td>
      <td>2</td>
      <td>2019</td>
    </tr>
    <tr>
      <th>3</th>
      <td>pub.1023754996</td>
      <td>pub.1020574513</td>
      <td>2</td>
      <td>2010</td>
    </tr>
    <tr>
      <th>4</th>
      <td>pub.1023754996</td>
      <td>pub.1022815437</td>
      <td>2</td>
      <td>2010</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>182</th>
      <td>pub.1043374025</td>
      <td>pub.1110816413</td>
      <td>2</td>
      <td>2019</td>
    </tr>
    <tr>
      <th>183</th>
      <td>pub.1043374025</td>
      <td>pub.1090432296</td>
      <td>2</td>
      <td>2017</td>
    </tr>
    <tr>
      <th>184</th>
      <td>pub.1043374025</td>
      <td>pub.1112307407</td>
      <td>2</td>
      <td>2019</td>
    </tr>
    <tr>
      <th>185</th>
      <td>pub.1043374025</td>
      <td>pub.1028868656</td>
      <td>2</td>
      <td>2006</td>
    </tr>
    <tr>
      <th>186</th>
      <td>pub.1043374025</td>
      <td>pub.1084164363</td>
      <td>2</td>
      <td>2017</td>
    </tr>
  </tbody>
</table>
<p>187 rows × 4 columns</p>
</div>



## 13.4 Incoming citations for a journal


```sql

SELECT
  COUNT(DISTINCT id) AS totcount,  year, type
FROM
  `dimensions-ai.data_analytics.publications`
WHERE
  id IN (
  SELECT citing_pubs.id
  FROM
    `dimensions-ai.data_analytics.publications`,
    UNNEST(citations) AS citing_pubs
  WHERE journal.id = "jour.1115214" )  -- Nature Biotechnology
GROUP BY year, type
ORDER BY year, type
```

    Query complete after 0.00s: 100%|██████████| 7/7 [00:00<00:00, 3549.77query/s]                        
    Downloading: 100%|██████████| 201/201 [00:02<00:00, 82.07rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>totcount</th>
      <th>year</th>
      <th>type</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>9</td>
      <td>NaN</td>
      <td>article</td>
    </tr>
    <tr>
      <th>1</th>
      <td>1</td>
      <td>1924.0</td>
      <td>article</td>
    </tr>
    <tr>
      <th>2</th>
      <td>1</td>
      <td>1942.0</td>
      <td>article</td>
    </tr>
    <tr>
      <th>3</th>
      <td>1</td>
      <td>1963.0</td>
      <td>article</td>
    </tr>
    <tr>
      <th>4</th>
      <td>1</td>
      <td>1964.0</td>
      <td>article</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>196</th>
      <td>1</td>
      <td>2021.0</td>
      <td>book</td>
    </tr>
    <tr>
      <th>197</th>
      <td>612</td>
      <td>2021.0</td>
      <td>chapter</td>
    </tr>
    <tr>
      <th>198</th>
      <td>26</td>
      <td>2021.0</td>
      <td>monograph</td>
    </tr>
    <tr>
      <th>199</th>
      <td>894</td>
      <td>2021.0</td>
      <td>preprint</td>
    </tr>
    <tr>
      <th>200</th>
      <td>3</td>
      <td>2021.0</td>
      <td>proceeding</td>
    </tr>
  </tbody>
</table>
<p>201 rows × 3 columns</p>
</div>



## 13.5 Outgoing citations to a journal


```sql

SELECT
  COUNT(DISTINCT id) AS totcount,  year, type
FROM
  `dimensions-ai.data_analytics.publications`
WHERE
  id IN (
  SELECT
    DISTINCT reference_pubs
  FROM
    `dimensions-ai.data_analytics.publications`,
    UNNEST(reference_ids) AS reference_pubs
  WHERE
    journal.id = "jour.1115214" ) -- Nature Biotechnology
GROUP BY year, type
ORDER BY year, type
```

    Query complete after 0.00s: 100%|██████████| 8/8 [00:00<00:00, 3442.19query/s]                        
    Downloading: 100%|██████████| 356/356 [00:02<00:00, 141.93rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>totcount</th>
      <th>year</th>
      <th>type</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>NaN</td>
      <td>article</td>
    </tr>
    <tr>
      <th>1</th>
      <td>1</td>
      <td>1825.0</td>
      <td>article</td>
    </tr>
    <tr>
      <th>2</th>
      <td>1</td>
      <td>1828.0</td>
      <td>article</td>
    </tr>
    <tr>
      <th>3</th>
      <td>1</td>
      <td>1853.0</td>
      <td>article</td>
    </tr>
    <tr>
      <th>4</th>
      <td>1</td>
      <td>1855.0</td>
      <td>monograph</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>351</th>
      <td>3</td>
      <td>2019.0</td>
      <td>proceeding</td>
    </tr>
    <tr>
      <th>352</th>
      <td>409</td>
      <td>2020.0</td>
      <td>article</td>
    </tr>
    <tr>
      <th>353</th>
      <td>5</td>
      <td>2020.0</td>
      <td>chapter</td>
    </tr>
    <tr>
      <th>354</th>
      <td>34</td>
      <td>2020.0</td>
      <td>preprint</td>
    </tr>
    <tr>
      <th>355</th>
      <td>1</td>
      <td>2021.0</td>
      <td>article</td>
    </tr>
  </tbody>
</table>
<p>356 rows × 3 columns</p>
</div>



# 14. Extracting complex publications records 

The query below combines various techniques presented in this notebook in order to extract full publication records that include both single-value metadata and unpacked lists. 

We use LEFT JOIN in order to ensure we obtain all records, not just the ones that have some value in the nested objects. 


```sql

SELECT
 p.id,
 p.title.preferred AS title,
 p.doi,
 p.year,
 COALESCE(p.journal.title, p.proceedings_title.preferred, p.book_title.preferred, p.book_series_title.preferred) AS venue,
 p.type,
 p.date AS date_publication,
 p.date_inserted,
 p.altmetrics.score AS altmetrics_score,
 p.metrics.times_cited,
 grid.id AS gridid,
 grid.name AS gridname,
 grid.address.country AS gridcountry,
 grid.address.city AS gridcity,
 open_access_categories,
 cat_for.name AS category_for,
FROM
 `dimensions-ai.data_analytics.publications` p
LEFT JOIN
  UNNEST(research_orgs) AS research_orgs_grids
LEFT JOIN
 `dimensions-ai.data_analytics.grid` grid
ON
 grid.id=research_orgs_grids
LEFT JOIN
 UNNEST(p.open_access_categories) AS open_access_categories
LEFT JOIN
 UNNEST(p.category_for.first_level.full) AS cat_for
WHERE
 EXTRACT(YEAR
 FROM
   date_inserted) >= 2020

LIMIT 100
```

    Query complete after 0.00s: 100%|██████████| 3/3 [00:00<00:00, 1729.37query/s]                        
    Downloading: 100%|██████████| 100/100 [00:02<00:00, 41.14rows/s]





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
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>id</th>
      <th>title</th>
      <th>doi</th>
      <th>year</th>
      <th>venue</th>
      <th>type</th>
      <th>date_publication</th>
      <th>date_inserted</th>
      <th>altmetrics_score</th>
      <th>times_cited</th>
      <th>gridid</th>
      <th>gridname</th>
      <th>gridcountry</th>
      <th>gridcity</th>
      <th>open_access_categories</th>
      <th>category_for</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>pub.1124854815</td>
      <td>Chanoyu sandenshū</td>
      <td>10.5479/sil.893207.39088019038405</td>
      <td>1691</td>
      <td>None</td>
      <td>monograph</td>
      <td>1691</td>
      <td>2020-02-15 01:10:52+00:00</td>
      <td>NaN</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>closed</td>
      <td>None</td>
    </tr>
    <tr>
      <th>1</th>
      <td>pub.1124853520</td>
      <td>Mag[istr]i Arn[al]di Devillan[ov]a Liber dictu...</td>
      <td>10.5479/sil.169309.39088003312089</td>
      <td>1666</td>
      <td>None</td>
      <td>monograph</td>
      <td>1666</td>
      <td>2020-02-15 01:10:52+00:00</td>
      <td>NaN</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>oa_all</td>
      <td>None</td>
    </tr>
    <tr>
      <th>2</th>
      <td>pub.1124853520</td>
      <td>Mag[istr]i Arn[al]di Devillan[ov]a Liber dictu...</td>
      <td>10.5479/sil.169309.39088003312089</td>
      <td>1666</td>
      <td>None</td>
      <td>monograph</td>
      <td>1666</td>
      <td>2020-02-15 01:10:52+00:00</td>
      <td>NaN</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>gold_bronze</td>
      <td>None</td>
    </tr>
    <tr>
      <th>3</th>
      <td>pub.1127222143</td>
      <td>A New Method of a Common-Place-Book</td>
      <td>10.1093/oseo/instance.00263866</td>
      <td>1706</td>
      <td>The Clarendon Edition of the Works of John Loc...</td>
      <td>chapter</td>
      <td>1706</td>
      <td>2020-04-30 18:45:39+00:00</td>
      <td>NaN</td>
      <td>2</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>closed</td>
      <td>None</td>
    </tr>
    <tr>
      <th>4</th>
      <td>pub.1127222159</td>
      <td>A Letter from the First Earl of Shaftesbury to...</td>
      <td>10.1093/oseo/instance.00263882</td>
      <td>1706</td>
      <td>The Clarendon Edition of the Works of John Loc...</td>
      <td>chapter</td>
      <td>1706</td>
      <td>2020-04-30 18:45:39+00:00</td>
      <td>NaN</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>closed</td>
      <td>None</td>
    </tr>
    <tr>
      <th>...</th>
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
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>95</th>
      <td>pub.1124464089</td>
      <td>ESSCIRC '88 Program Committee</td>
      <td>10.1109/esscirc.1988.5468234</td>
      <td>1988</td>
      <td>ESSCIRC '88: Fourteenth European Solid-State C...</td>
      <td>proceeding</td>
      <td>1988-09</td>
      <td>2020-02-02 00:24:01+00:00</td>
      <td>NaN</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>closed</td>
      <td>None</td>
    </tr>
    <tr>
      <th>96</th>
      <td>pub.1124464093</td>
      <td>Fourteenth European Solid-State Circuits Confe...</td>
      <td>10.1109/esscirc.1988.5468246</td>
      <td>1988</td>
      <td>ESSCIRC '88: Fourteenth European Solid-State C...</td>
      <td>proceeding</td>
      <td>1988-09</td>
      <td>2020-02-02 00:24:01+00:00</td>
      <td>NaN</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>closed</td>
      <td>None</td>
    </tr>
    <tr>
      <th>97</th>
      <td>pub.1124464091</td>
      <td>ESSDERC/ESSCIRC Organising Committee</td>
      <td>10.1109/esscirc.1988.5468240</td>
      <td>1988</td>
      <td>ESSCIRC '88: Fourteenth European Solid-State C...</td>
      <td>proceeding</td>
      <td>1988-09</td>
      <td>2020-02-02 00:24:01+00:00</td>
      <td>NaN</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>closed</td>
      <td>None</td>
    </tr>
    <tr>
      <th>98</th>
      <td>pub.1124464130</td>
      <td>Integrated Circuits Digital Network (ISDN)</td>
      <td>10.1109/esscirc.1988.5468346</td>
      <td>1988</td>
      <td>ESSCIRC '88: Fourteenth European Solid-State C...</td>
      <td>proceeding</td>
      <td>1988-09</td>
      <td>2020-02-02 00:24:01+00:00</td>
      <td>NaN</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>closed</td>
      <td>None</td>
    </tr>
    <tr>
      <th>99</th>
      <td>pub.1124464167</td>
      <td>1 Micron CMOS Technology</td>
      <td>10.1109/esscirc.1988.5468459</td>
      <td>1988</td>
      <td>ESSCIRC '88: Fourteenth European Solid-State C...</td>
      <td>proceeding</td>
      <td>1988-09</td>
      <td>2020-02-02 00:24:01+00:00</td>
      <td>NaN</td>
      <td>0</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>closed</td>
      <td>None</td>
    </tr>
  </tbody>
</table>
<p>100 rows × 16 columns</p>
</div>




```python

```
