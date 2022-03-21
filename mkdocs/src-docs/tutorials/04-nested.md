# Working with nested and repeated fields

A prominent feature of Google BigQuery is their addition of nested and repeated fields to what may otherwise be a familiar SQL paradigm. Both present opportunities to reorganize data within single tables in novel ways, but they can take some time to get used to. Below, we explain the basics of nested and repeated fields, work through several examples, and provide links to external resources that we've found helpful.

!!! warning "Prerequisites"
    In order to run this tutorial, please ensure that:

    * You have a valid [Dimensions on Google BigQuery account](https://www.dimensions.ai/products/bigquery/) and have [configured a Google Cloud project](https://docs.dimensions.ai/bigquery/gcp-setup.html#).

    The online [Google BigQuery console](https://console.cloud.google.com/bigquery) can be used to test the queries below.

## What are they?

### Repeated fields

Repeated fields approximate a "one-to-many" relationship and provide an opportunity to define **a field that can hold multiple values per row**. We can demonstrate this by running a query against [the `publications` table](https://docs.dimensions.ai/bigquery/datasource-publications.html) for values in the `clinical_trial_ids` field:

```sql
SELECT
  id, LEFT(title.preferred, 25) AS title, clinical_trial_ids
FROM `dimensions-ai.data_analytics.publications`
WHERE ARRAY_LENGTH(clinical_trial_ids) > 0
LIMIT 10
```

The (heavily truncated) results look something like this:

<table>
    <thead>
        <tr>
            <th>Row</th>
            <th>id</th>
            <th>title</th>
            <th>clinical_trial_ids</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>1</td>
            <td>pub.1003360568</td>
            <td>A Randomized, Controlled...</td>
            <td>NCT00014989</td>
        </tr>
        <tr>
            <td>2</td>
            <td>pub.1003935609</td>
            <td>8568 Prophylactic swallow...</td>
            <td>NCT00332865</td>
        </tr>
        <tr>
            <td rowspan=5>3</td>
            <td>pub.1004269292</td>
            <td>Clinical Trial Alert...</td>
            <td>NCT00953940</td>
        </tr>
        <tr>
          <td></td>
          <td></td>
          <td>NCT00970073</td>
        </tr>
        <tr>
          <td></td>
          <td></td>
          <td>NCT00994253</td>
        </tr>
        <tr>
          <td></td>
          <td></td>
          <td>NCT00987103</td>
        </tr>
        <tr>
          <td></td>
          <td></td>
          <td>NCT00974636</td>
        </tr>
        <tr>
            <td rowspan=2>4</td>
            <td>pub.1004095142</td>
            <td>6502 A double-blinded, pl...</td>
            <td>NCT00219557</td>
        </tr>
        <tr>
          <td></td>
          <td></td>
          <td>NCT00428597</td>
        </tr>
        <tr>
            <td>5</td>
            <td>pub.1004119511</td>
            <td>Intrathecal morphine in a...</td>
            <td>NCT00119184</td>
        </tr>
    </tbody>
</table>

You can see that rows 3 and 4 have multiple values in the `clinical_trial_ids` field, despite all values getting listed **within a single row number**.


### Nested fields

Nested fields, on their own, are much simpler: They are fields that are linked together as a single entity, like a struct or an object. The `title` field in the `publications` table is a good example of this: Rather than a single string indicating the title of the publication, it is a nested field that has two strings within it: `"original"` and `"preferred"`, mostly to accommodate titles expressed in multiple languages. Querying nested fields looks almost identical to querying more conventional ones. For example, with the title field:

```sql
SELECT id, title
FROM `dimensions-ai.data_analytics.publications`
LIMIT 4
```

Results:

| Row | id | title.preferred | title.original |
| --- | -- | --------------- | -------------- |
| 1   | pub.1123921006 | Effects of "1+N" extended nursing on medication comp... | "1+N"延伸护理模式对2型糖尿病患者用药依从性及自我管理能力的影响 |
| 2   | pub.1123897378 | Clinical observation of the prevention of pressu... | 龙血竭预防恶性肿瘤强迫体位患者压疮的临床观察 |
| 3   | pub.1039091814 | IV. A new improved silk-reel. | *null* |
| 4    | pub.1123920716 | Effect of resina draconis for external applica... | 龙血竭胶囊粉外敷治疗压疮疗效的Meta分析 |

### Repeated nested fields

This is where things get a little more complicated: One of the main ways nested fields make themselves useful is when they're *repeated*: So while a repeated field might be an array of strings (clinical trial IDs, for example), they can also be an array of objects. The `authors` field of the publications table is a good example of this:

```sql
SELECT id, title.preferred, authors
FROM `dimensions-ai.data_analytics.publications`
LIMIT 3
```

Results:

<table>
    <thead>
        <tr>
            <th>Row</th>
            <th>id</th>
            <th>title.preferred</th>
            <th>authors.first_name</th>
            <th>authors.last_name</th>
            <th>authors.researcher_id</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan=4>1</td>
            <td>pub.1001350088</td>
            <td>The T-120/130-12.8 and PT...</td>
            <td>G.D.</td>
            <td>Barinberg</td>
            <td>ur.012510636551.40</td>
        </tr>
        <tr>
          <td></td>
          <td></td>
          <td>A.E.</td>
          <td>Valamin</td>
          <td>ur.012211770163.32</td>
        </tr>
        <tr>
          <td></td>
          <td></td>
          <td>Yu. A.</td>
          <td>Sakhnin</td>
          <td>ur.010306240353.29</td>
        </tr>
        <tr>
          <td></td>
          <td></td>
          <td>A. Yu.</td>
          <td>Kultyshev</td>
          <td>ur.014402311563.25</td>
        </tr>
        <tr>
            <td rowspan=2>2</td>
            <td>pub.1000116807</td>
            <td>Application of Electrorhe...</td>
            <td>Ken'ichi</td>
            <td>Koyanagi</td>
            <td>ur.013307555250.87</td>
        </tr>
        <tr>
          <td></td>
          <td></td>
          <td>Yasuhiro</td>
          <td>Kakinuma</td>
          <td>ur.013275435603.18</td>
        </tr>
    </tbody>
</table>

You can see here that the author information appears the same way as the clinical trial IDs above, except each repeated entry within a row has multiple fields about each author. (There are many more fields that will appear if you query authors; they've been removed here for clarity.) The useful part about using nested fields for the authors, rather than a bunch of repeated fields alone (one for `first_name`, another repeated field for `last_name`, etc) is because *those nested fields will stay together*: For the publication in row 1, the `"A.E."` first name will always appear alongside the `"Valamin"` last name, rather than shuffling them around like what may happen if you queried them separately.

## Querying nested fields

We'll start writing queries with nested fields alone first, since it's the simplest to do. We actually did it several times in the above examples: The `title` field in the publications table is a nested field with two fields in it: `original` and `preferred`. If you don't specify which values you want, *you'll get them all*, like this:

```sql
SELECT id, title
FROM `dimensions-ai.data_analytics.publications`
LIMIT 4
```

Results:

| Row | id | title.preferred | title.original |
| --- | -- | --------------- | -------------- |
| 1   | pub.1123921006 | Effects of "1+N" extended nursing on medication comp... | "1+N"延伸护理模式对2型糖尿病患者用药依从性及自我管理能力的影响 |
| 2   | pub.1123897378 | Clinical observation of the prevention of pressu... | 龙血竭预防恶性肿瘤强迫体位患者压疮的临床观察 |
| 3   | pub.1039091814 | IV. A new improved silk-reel. | *null* |
| 4    | pub.1123920716 | Effect of resina draconis for external applica... | 龙血竭胶囊粉外敷治疗压疮疗效的Meta分析 |

If you wanted only the `preferred` field of the `title`, you can specify that using periods. Nested fields can have *more* nested fields within them, so there may be multiple entries. Luckily, we only need one period for the title:

```sql
SELECT id, title.preferred
FROM `dimensions-ai.data_analytics.publications`
LIMIT 4
```

Results:

| Row | id | title.preferred |
| --- | -- | --------------- |
| 1   | pub.1123921006 | Effects of "1+N" extended nursing on medication comp... |
| 2   | pub.1123897378 | Clinical observation of the prevention of pressu... |
| 3   | pub.1039091814 | IV. A new improved silk-reel. |
| 4    | pub.1123920716 | Effect of resina draconis for external applica... |


## Querying repeated fields

Repeated fields are where we need to start using more exotic patterns to extract information. [The `UNNEST` function](https://cloud.google.com/bigquery/docs/reference/standard-sql/arrays#flattening_arrays) is the primary tool for the job here—it converts an array of values into rows in a table, which, if necessary, can then be joined to the original table you're querying.

### Example 1: Checking contents of array
We'll start with a simple one: the `funder_orgs` field in the `publications` table, which lists GRID IDs indicating which organizations funded the research in the publication. IF we wanted to find publications funded by the Brazilian Agricultural Research Corporation, for example, we can use its GRID ID (grid.460200.0) in a `WHERE` clause:

```sql
SELECT type, COUNT(id) AS funded_pubs
FROM `dimensions-ai.data_analytics.publications`
WHERE 'grid.460200.0' IN UNNEST(funder_orgs)
GROUP BY type
```

Results

| Row | type | funded_pubs |
| --- | ---- | ----------- |
| 1   | preceeding | 23 |
| 2   | article | 6042 |
| 3   | preprint | 21 |
| 4   | chapter | 33 |



### Example 2: Joining tables using a repeated field

Queries can also return the contents of repeated fields. Using a `CROSS JOIN`, the information can be distributed into separate rows, rather than arrays inside single rows. For this example, we'll look at organizations that have funded recent articles published in *eLife*, a life sciences journal. We'll start by selecting the information we can get from the publications table:

```sql
SELECT p.id, forg
FROM `dimensions-ai.data_analytics.publications` AS p
CROSS JOIN UNNEST(funder_orgs) AS forg -- This is the important line
WHERE type='article'
  AND journal.id='jour.1046517' -- eLife
```

| Row | id | forg |
| --- | ---- | ----------- |
| 1   | pub.1000035854 | grid.14105.31 |
| 2   | pub.1000321327 | grid.48336.3a |
| 3   | pub.1000131550 | grid.422384.b |
| 4   | pub.1000131550 | grid.419475.a |
| 5   | pub.1000131550 | grid.453152.4 |
| 6   | pub.1000131550 | grid.280362.d |
| 7   | pub.1000131550 | grid.416870.c |

There are a few things to point out here: First, notice that we're querying a nested field within the `journal` field on the final line—we want only publications in which the `journal` field lists an `id` that matches the one assigned to *eLife*. We're also using a `CROSS JOIN` with the `funder_orgs` field. A cross join [returns the Cartesian product](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#cross_join) of the two tables being joined—to wit, every value on one side of the join (in this case, the `publications` table) will appear with every matching value from the right side of the join (the "table" created by the call to `UNNEST(funder_orgs)`). This is demonstrated in lines 3 through 7 of the results above—publication id "pub.1000131550" has five different strings in its `funder_orgs` field, so when we unnest that field, **the results contain multiple rows for "pub.1000131550," one for each value unnested from `funder_orgs`.**

We're not done yet, however—we have a table that associates every *eLife* paper with each of its funders, but that's not really useful on its own. If we use group by the `forg` field (the values unnested from `funder_orgs`), we can get a count for each organization, like this:

```sql
SELECT forg, COUNT(p.id) AS funded_pubs
FROM `dimensions-ai.data_analytics.publications` AS p
CROSS JOIN UNNEST(funder_orgs) AS forg -- This is the important line
WHERE type='article'
  AND journal.id='jour.1046517' -- eLife
GROUP BY forg
ORDER BY funded_pubs DESC
LIMIT 5
```

Results:

| Row | forg | funded_pubs |
| --- | ---- | ----------- |
| 1   | grid.280785.0 | 2329 |
| 2   | grid.416870.c | 1090 |
| 3   | grid.413575.1 | 1078 |
| 4   | grid.452896.4 | 976 |
| 5   | grid.48336.3a | 893 |

This is getting better! Now we have the GRID ID of each funder, paired with the number of *eLife* publications it's funded. However, GRID IDs aren't very readable. We can get organization names by pulling them in from [the `grid` table of organizations data](https://docs.dimensions.ai/bigquery/datasource-organizations.html):

```sql
SELECT forg, grid.name, COUNT(p.id) AS funded_pubs
FROM `dimensions-ai.data_analytics.publications` AS p
CROSS JOIN UNNEST(funder_orgs) AS forg
INNER JOIN `dimensions-ai.data_analytics.grid` AS grid -- THIS IS NEW!
  ON forg=grid.id
WHERE type='article'
  AND journal.id='jour.1046517'
GROUP BY forg, grid.name
ORDER BY funded_pubs DESC
LIMIT 5
```

Results:

| Row | forg | name | funded_pubs |
| --- | ---- | ---- | ----------- |
| 1   | grid.280785.0 | National Institute of General Medical Sciences | 2329 |
| 2   | grid.416870.c | National Institute of Neurological Disorders and Stroke | 1090 |
| 3   | grid.413575.1 | Howard Hughes Medical Institute | 1078 |
| 4   | grid.452896.4 | European Research Council | 976 |
| 5   | grid.48336.3a | National Cancer Institute | 893 |

Now we have the table we wanted: We unnest the values in the `funder_orgs` field, use those to join the `grid` table, and return the name of each funder and how many publications it's funded in *eLife*.



### Example 3: Querying repeated nested fields

Let's pull everything together using the task outlined in [example 3 from the query library](../queries/03.md): combining all author names of a paper into a single string. As described above, the `authors` field is complicated because it's a repeated field in which each value is a nested field: Each repeat of `authors` has its own `first_name` field, its own `last_name`, and so on. It's easier to see the structure if we start with a simpler query:

```sql
  SELECT id, authors
  FROM `dimensions-ai.data_analytics.publications`
  WHERE id = 'pub.1132070778'
```

Results (truncated for simplicity):

<table>
    <thead>
        <tr>
            <th>Row</th>
            <th>id</th>
            <th>authors.first_name</th>
            <th>authors.last_name</th>
            <th>authors.researcher_id</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan=7>1</td>
            <td>pub.1132070778</td>
            <td>O</td>
            <td>Grånäs</td>
            <td>ur.01027021415.21</td>
        </tr>
        <tr>
            <td></td>
            <td>A</td>
            <td>Mocellin</td>
            <td>ur.01316620417.40</td>
        </tr>
        <tr>
            <td></td>
            <td>E S</td>
            <td>Cardoso</td>
            <td><i>null</i></td>
        </tr>
        <tr>
            <td></td>
            <td>F</td>
            <td>Burmeister</td>
            <td>ur.0631574677.49</td>
        </tr>
        <tr>
            <td></td>
            <td>C</td>
            <td>Caleman</td>
            <td>ur.0745346134.45</td>
        </tr>
        <tr>
            <td></td>
            <td>O</td>
            <td>Björneholm</td>
            <td>ur.0603171002.99</td>
        </tr>
        <tr>
            <td></td>
            <td>A Naves</td>
            <td>de Brito</td>
            <td>ur.01206174227.82</td>
        </tr>
    </tbody>
</table>

So if we want to bring all the authors together into a single string, there are a lot of discrete steps to take care of:

1. Pull out the `first_name` and `last_name` fields for each author in the `authors` repeated field.
1. Make a new string for each author that combines their first and last name together.
1. Pull together each of these full author names *into a new array* we'll call `author_names`. So we go from an array of `author` objects, each with its own collection of nested fields, into **an array of strings**, each one representing a single author.
1. Combine all elements in the `author_names` into **one long string**.

First, we try to make things more readable by using a `WITH` clause to emulate a temporary table: Within this query, there's a "table" called `author_array` filled with the results of this subquery:

```sql
SELECT
  id,
  ARRAY(
    SELECT CONCAT(first_name, " ", last_name)
    FROM UNNEST(authors)
  ) AS authors
FROM `dimensions-ai.data_analytics.publications`
WHERE id = 'pub.1132070778'
```

This is important, because it's where most of the work happens. We start in the middle and work our way outward.

This piece takes an array (`authors`) and uses the `UNNEST` function to create a new table in which each row is a separate author. Then, we take each row of this temporary "authors" table and combine each first name with each last name:

```sql
SELECT CONCAT(first_name, " ", last_name)
FROM UNNEST(authors)
```

So we now have a table with a single field—a full name—and each row is one author. We then convert this *back into an array*:

```sql
ARRAY(
    SELECT CONCAT(first_name, " ", last_name)
    FROM UNNEST(authors)
) AS authors
```

The outermost piece of this subquery is just to tie each array of author names to the publication that they authored:
```sql
WITH author_array AS (
  SELECT
    id,
    ARRAY(
      SELECT CONCAT(first_name, " ", last_name)
      FROM UNNEST(authors)
    ) AS author_names
  FROM `dimensions-ai.data_analytics.publications`
  WHERE id = 'pub.1132070778'
)
```

So now we have a table called `author_array` in which each publication ID is associated with an array of author names. It looks like this):

<table>
    <thead>
        <tr>
            <th>Row</th>
            <th>id</th>
            <th>author_names</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan=7>1</td>
            <td>pub.1132070778</td>
            <td>O Grånäs</td>
        </tr>
        <tr>
            <td></td>
            <td>A Mocellin</td>
        </tr>
        <tr>
            <td></td>
            <td>E S Cardoso</td>
        </tr>
        <tr>
            <td></td>
            <td>F Burmeister</td>
        </tr>
        <tr>
            <td></td>
            <td>C Caleman</td>
        </tr>
        <tr>
            <td></td>
            <td>O Björneholm</td>
        </tr>
        <tr>
            <td></td>
            <td>A Naves de Brito</td>
        </tr>
    </tbody>
</table>

Now that we have the author names pulled out of the author objects, we're almost done. The last step is to iterate through each publication ID, take each entry in the `author_names` array, and push them all together using [the `ARRAY_TO_STRING` function](https://cloud.google.com/bigquery/docs/reference/standard-sql/array_functions#array_to_string):

```sql
SELECT
  id,
  ARRAY_TO_STRING(author_names, '; ') AS authors_list
FROM author_array
```

Results

<table>
    <thead>
        <tr>
            <th>Row</th>
            <th>id</th>
            <th>authors_list</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>1</td>
            <td>pub.1132070778</td>
            <td>O Grånäs; A Mocellin; E S Cardoso; F Burmeister; C Caleman; O Björneholm; A Naves de Brito</td>
        </tr>
    </tbody>
</table>



## Be careful

There are a few pitfalls to be aware of when working with nested and repeated fields; we outline some of the most common below.

### Example 4: Repeated fields with null values

The trouble with using `CROSS JOIN` clauses in queries is that *they omit all records for which the repeated field has no values*: If a paper has zero authors listed, for example, including `CROSS JOIN UNNEST(authors)` in your query means there won't be any rows for that paper. We can examine this further using the `research_org_country_names` repeated field:

```sql
SELECT COUNT(DISTINCT p.id) AS tot_articles
FROM
  `dimensions-ai.data_analytics.publications` p
CROSS JOIN UNNEST(research_org_country_names) AS unnested_countries
WHERE year = 2000
```

Results

| Row | tot_articles |
| --- | ------------ |
| 1   | 1063394 |


We then run the same query without the `UNNEST` clause:

```sql
SELECT COUNT(DISTINCT p.id) AS tot_articles
FROM
  `dimensions-ai.data_analytics.publications` p
WHERE year = 2000
```

Results

| Row | tot_articles |
| --- | ------------ |
| 1   | 1760397 |

So without the `UNNEST`, the total publication count is just over 1.7 million. With the unnest, however, it's less than 1.1 million. The gap is explained by publications that have an ID (that's what we're counting), but that do not have any values in the `research_org_country_names` field.

So how can we be sure we aren't excluding records we actually want? In this case, a **`LEFT JOIN` is the way to go**:

```sql
SELECT
  COUNT(DISTINCT p.id) AS tot_articles
FROM
  `dimensions-ai.data_analytics.publications` p
LEFT JOIN UNNEST(research_org_country_names) AS unnested_countries
WHERE year = 2000
```

Results

| Row | tot_articles |
| --- | ------------ |
| 1   | 1760397 |

Using `LEFT JOIN UNNEST(x)` instead of `CROSS JOIN UNNEST(x)` ensures that entries in which `x` is `NULL` will still be returned—those will simply have *null* listed in the `unnested_countries` field.


### Example 5: Counting entries too many times

While it's helpful that `CROSS JOIN UNNEST()` gives us all relevant combinations of the selected fields, it can also present hazards if you don't account for which fields may have multiple entries. For this example, we want to examine how many papers were published in *PLOS ONE* that include an author with the surname "Smith."

This query will get us most of the way there:

```sql
SELECT
  p.year, COUNT(p.id) AS totcount
FROM `dimensions-ai.data_analytics.publications` p
CROSS JOIN UNNEST(authors) author
WHERE
  journal.id='jour.1037553' -- PLOS ONE
  AND year >= 2018
  AND year <= 2020
  AND author.last_name='Smith'
GROUP BY year
ORDER BY year
```

Results:

| Row | year | totcount |
| --- | ---- | -------- |
| 1   | 2018 | 196 |
| 2   | 2019 | 151 |
| 3   | 2020 | 155 |

We start with all publications published in *PLOS ONE* between 2018 and 2020, then unnest the `authors` field so we can get to the `last_name` field. We then include only entries in which `last_name='Smith'`.

However, these yearly totals aren't correct: We're counting the number of entries in the table, and we only have entries in which an author's last name is "Smith." But **some papers may have been written by more than one Smith**. We can account for this by adding a `DISTINCT` clause, like this:

```sql
SELECT
  p.year, COUNT(DISTINCT p.id) AS totcount -- CHANGE IS HERE!
FROM `dimensions-ai.data_analytics.publications` p
CROSS JOIN UNNEST(authors) author
WHERE
  journal.id='jour.1037553'
  AND year >= 2018
  AND year <= 2020
  AND author.last_name='Smith'
GROUP BY year
ORDER BY year
```

Results:

| Row | year | totcount |
| --- | ---- | -------- |
| 1   | 2018 | 189 |
| 2   | 2019 | 144 |
| 3   | 2020 | 154 |

Comparing these results to the previous ones, we can see that there are usually more than 140 papers published with "Smith" authors every year, and several papers per year authored by multiple Smiths. This was a straightforward example, but `DISTINCT` clauses can be a valuable check in more convoluted queries in which you may have multiple cross joins, or you have a cross join in a subquery that is later joined to another table.
