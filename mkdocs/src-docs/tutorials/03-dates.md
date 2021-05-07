# Working with dates

Each publication has various dates available.

* `date`, `year`, `date_normal`, `date_online`, `date_print` refer to the publication object. See the [documentation](https://docs.dimensions.ai/bigquery/datasource-publications.html) to find out more about their meaning.
* `date_imported_gbq` refers to when this record was last added to GBQ - this date can be handy if you want to synchronize an external data source to GBQ.
* `date_inserted`: this refers to when this records was originally added to Dimensions. This date does not change, even if the record is later adjusted.

The following examples show how to work with publications dates.

!!! warning "Prerequisites"
    In order to run this tutorial, please ensure that: 

    * You have a valid [Dimensions on Google BigQuery account](https://www.dimensions.ai/products/bigquery/) and have [configured a Google Cloud project](https://docs.dimensions.ai/bigquery/gcp-setup.html#).
    
    The online [GBQ console](https://console.cloud.google.com/bigquery) can be used to test the queries below.


## Comparing date fields

### Description

We'll get started by pulling a selection of the date fields to see their formats:
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
WHERE year = 2010
      AND journal.id = "jour.1115214"
ORDER BY citations_count DESC
LIMIT 10
```

Results

<table>
  <thead>
    <tr style="text-align: right;">
      <th>Row</th>
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
      <td>0</td>
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
      <td>1</td>
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
      <td>2</td>
      <td>10.1038/nbt.1614</td>
      <td>2010-03</td>
      <td>2010-03-01</td>
      <td>2010</td>
      <td><i>null</i></td>
      <td>2010-03</td>
      <td>2021-02-10 01:09:29+00:00</td>
      <td>2017-08-31 12:50:56+00:00</td>
    </tr>
    <tr>
      <td>3</td>
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
      <td>4</td>
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
      <td>5</td>
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
      <td>6</td>
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
      <td>7</td>
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
      <td>8</td>
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
      <td>9</td>
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

The first thing to stick out is that some of the dates are actually *timestamps*: `date_imported_gbq` and `date_inserted` have times attached to the dates. The other important caveat is that some dates aren't actually whole dates: Some values in the `date` and `date_print` fields have only a year and month. One of the reasons these different types are important is because can add an extra step when you compare fields to each other. For example, if we wanted to count how many publications were added to Dimensions before their "publication" date, it would be intuitive to write a query like this:

```sql
SELECT COUNT(id)
FROM `dimensions-ai.data_analytics.publications`
WHERE
  year = 2020
  AND date > date_inserted
```

However, we get an error from BigQuery: `No matching signature for operator > for argument types: STRING, TIMESTAMP. Supported signature: ANY > ANY at [12:11]`. BigQuery won't do the comparison because both sides of the comparison aren't of the same type: The `date` field is of type `STRING`, since it doesn't always have a day (or month) attached. The `date_normal` field solves this for us: It uses the same information as the `date` field, but it fills in the gaps to make a full `DATE` entry—so `"2010-03"` in the `date` field becomes `2010-03-01` in `date_normal`. But swapping that in doesn't fix our problems either:

```sql
SELECT COUNT(id)
FROM `dimensions-ai.data_analytics.publications`
WHERE
  year = 2020
  AND date_normal > date_inserted
```

We run into a new variant of the issue now: `No matching signature for operator > for argument types: DATE, TIMESTAMP. Supported signature: ANY > ANY at [5:7]`. Now `date_normal` gives us a `DATE`, but we can't compare that to a `TIMESTAMP`. Generally, you can mitigate most issues with comparing date fields by **converting one of them to match the other**, and BigQuery supports multiple functions for manipulating [dates](https://cloud.google.com/bigquery/docs/reference/standard-sql/date_functions) and [datetimes](https://cloud.google.com/bigquery/docs/reference/standard-sql/datetime_functions). This one should do the trick:

```sql
SELECT COUNT(id)
FROM `dimensions-ai.data_analytics.publications`
WHERE
  year = 2020
  AND date_normal > DATE(date_inserted)
```

Results:

| Row | f0_ |
| --- | --- |
| 1   | 859011 |


## Number of publications added to Dimensions by month

### Description

Next, we'll use the `date_inserted` field to count the number of publications added to the Dimensions database per month. `date_inserted` is of type `DATETIME`, so we choose from the [datetime manipulation functions](https://cloud.google.com/bigquery/docs/reference/standard-sql/datetime_functions) to round down all dates to the first of the month:

```sql
SELECT
  DATETIME_TRUNC(date_inserted, MONTH) as added_date,
  COUNT(id) as countDim
FROM
  `dimensions-ai.data_analytics.publications`
GROUP BY added_date
ORDER BY added_date DESC
LIMIT 5
```

Results

| Row | added_date | countDim |
| --- | ---- | -------- |
| 1   | 2021-04-01 00:00:00 UTC | 534043 |
| 2   | 2021-03-01 00:00:00 UTC | 746963 |
| 3   | 2021-02-01 00:00:00 UTC | 661575 |
| 4   | 2021-01-01 00:00:00 UTC | 687764 |
| 5   | 2020-12-01 00:00:00 UTC | 828307 |

We can see the dates have all been collapsed into the first of the month for each paper, but those timestamps that are attached are unhelpful. We can get rid of them by converting `date_inserted` to a `DATE` first, and switch to using the `DATE_TRUNC` function instead:

```sql
SELECT
  DATE_TRUNC(DATE(date_inserted), MONTH) as added_date,
  COUNT(id) as countDim
FROM
  `dimensions-ai.data_analytics.publications`
GROUP BY added_date
ORDER BY added_date DESC
LIMIT 5
```

Results

| Row | added_date | countDim |
| --- | ---- | -------- |
| 1   | 2021-04-01 | 534043 |
| 2   | 2021-03-01 | 746963 |
| 3   | 2021-02-01 | 661575 |
| 4   | 2021-01-01 | 687764 |
| 5   | 2020-12-01 | 828307 |

That looks much better. If we want to manipulate different parts of the dates separately, we can also use `EXTRACT` to split things up:

```sql
SELECT
  EXTRACT(MONTH FROM date_inserted) as added_month,
  EXTRACT(YEAR FROM date_inserted) as added_year,
  COUNT(id) as countDim
FROM
  `dimensions-ai.data_analytics.publications`
GROUP BY added_month, added_year
ORDER BY added_year DESC, added_month DESC
LIMIT 5
```

Results

| Row | added_month | added_year | countDim |
| --- | ----------- | ---------- | -------- |
| 1   | 4 | 2021 | 534043 |
| 2   | 3 | 2021 | 746963 |
| 3   | 2 | 2021 | 661575 |
| 4   | 1 | 2021 | 687764 |
| 5   | 12 | 2020 | 828307 |
