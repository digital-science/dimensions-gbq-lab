# Retrieve patents linked to a set of grants

**Use case**: How many patents were generated following a set of grants?

**Intended audience**: Funders who wish to have gain different insights on the impact of their funding

Aside from the research publications, patent data could also provide insights on how research funding impacts the generation of invention.

This notebook shows you how to **retrieve patents that are linked to a given list of grants**. More specifically, two types of linkages are considered here:

* **patents that directly acknowledge grants** (Since the enactment of [the Bayh-Dole Act](https://https://en.wikipedia.org/wiki/Bayh%E2%80%93Dole_Act) in 1980, all recipients of US federal funding are legally obligated to disclose government support that led to any inventions they produce). This is useful when funders are most interested in the patents directly supported by the grants;
* **patents that cite publications supported by grants** (note that non-patent literatures in the patent references section are not only provided by inventor, but also added by patent examiner during the patent examination process). This can be considered when the funders are interested in understanding the patents that relate with the publications supported by the grants;



## Prerequisites

This section shows you how to import python packages, and authenticate your BigQuery connection. In order to run this tutorial, please ensure that you have a valid **Dimensions on Google BigQuery** account and have configured a **Google Cloud project**

```python
# general import
import pandas as pd
import numpy as np
import sys, time, json
import plotly.express as px

# authentication happens via your browser
from google.colab import auth
auth.authenticate_user()
print('Authenticated')
```

    Authenticated


```python
# GBQ import
from google.cloud import bigquery

BQ_PROJECT_ID = "ds-gov-funder-gbq"  # remember to change this to your project ID
client = bigquery.Client(project=BQ_PROJECT_ID)
```

## An example

For this example, we will be using the Dimensions database to extract patents that are linked to the grants funded by [**NSF Directorate for Engineering**](https://www.nsf.gov/dir/index.jsp?org=ENG) and started in **2015**.

The **patents**, **publications**, and **grants** datasets will be used in the example to retrieve patents through two types of linkages.

### Retrieve patents that directly acknowledged grants

First, let's get all patents that directly acknowledged the NSF Directorate for Engineering grants that started in 2015

!!! tip "Tips"
    * Unnest the `funding_details` in `dimensions-ai.data_analytics.patents` table to get the funder's **GRID ID** and Dimensions **Grant ID**
    * Join with `dimensions-ai.data_analytics.grants` table and limit to the grants that started in 2015
    * The **GRID ID** of NSF Directorate for Engineering can be found in [Global Research Identifier Database](https://www.grid.ac/)


```python
# build the search string
search_string = """
SELECT
  DISTINCT pat.id AS patent_id,
  f.grant_id,
  pat.family_id,
  CAST(pat.priority_year AS string) priority_year,
  'supported' AS link_type
FROM
  `dimensions-ai.data_analytics.patents` pat
CROSS JOIN
  UNNEST(funding_details) f     -- unnest the field to get the funder and grant number acknowledged by the patent
JOIN
  `dimensions-ai.data_analytics.grants` g
ON
  g.id = f.grant_id
WHERE
  f.grid_id = 'grid.457810.f'    -- specify funder's GRID ID
  AND g.start_year = 2015        -- specify the grant start year
"""

# retrieve from BigQuery and make it a pandas dataframe
nsf_grant_patents = client.query(search_string).to_dataframe()
```


```python
# get a quick preview of the patents directly linked to the grants
nsf_grant_patents.head()
```

<table>
  <thead>
    <tr>
      <th>Row</th>
      <th>patent_id</th>
      <th>grant_id</th>
      <th>family_id</th>
      <th>priority_year</th>
      <th>link_type</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>US-20200303900-A1</td>
      <td>grant.4179692</td>
      <td>60479104</td>
      <td>2016</td>
      <td>supported</td>
    </tr>
    <tr>
      <td>1</td>
      <td>US-20190224370-A1</td>
      <td>grant.4178213</td>
      <td>61562333</td>
      <td>2016</td>
      <td>supported</td>
    </tr>
    <tr>
      <td>2</td>
      <td>US-20160236141-A1</td>
      <td>grant.3852639</td>
      <td>56620694</td>
      <td>2014</td>
      <td>supported</td>
    </tr>
    <tr>
      <td>3</td>
      <td>US-20190193116-A1</td>
      <td>grant.3982138</td>
      <td>60663733</td>
      <td>2016</td>
      <td>supported</td>
    </tr>
    <tr>
      <td>4</td>
      <td>US-20200061618-A1</td>
      <td>grant.4318677</td>
      <td>69584146</td>
      <td>2018</td>
      <td>supported</td>
    </tr>
  </tbody>
</table>


```python
# get a quick count of how many patents were retrieved
print(nsf_grant_patents['patent_id'].nunique())

```

    581


### Retrieve patents that cited the publications funded by the same set of grants ##

Then, we can get all patents that cited publications which were funded by the same set of grants (i.e. grants funded by NSF Directorate for Engineering started in 2015)

!!! tip "Tips"
    * unnest the `resulting_publication_ids` in `dimensions-ai.data_analytics.grants` table to get the publication ids funded by a set of grants, setting the funder's **GRID ID** and **Start year** the same as the above query
    * unnest the `publication_ids` in `dimensions-ai.data_analytics.patents` table which contains publication ids cited by patents
    * the publication_ids unnested from the above are used as an intermediate link between **patents** and **grants**

```python
# build the search string
search_string = """
WITH
  grant_pubs AS (
  SELECT
    DISTINCT pub_id,
    g.id AS grant_id
  FROM
    `dimensions-ai.data_analytics.grants` g
  CROSS JOIN
    UNNEST(resulting_publication_ids) pub_id   -- unnest the publication ids resulting from grants
  WHERE
    g.funder_org = 'grid.457810.f'     -- specify funder grid id
    AND g.start_year = 2015)           -- specify grant start year
SELECT
  DISTINCT pat.id AS patent_id,
  gp.grant_id,
  pat.family_id,
  CAST(pat.priority_year AS string) priority_year,
  'pub_reference' AS link_type
FROM
  `dimensions-ai.data_analytics.patents` pat
CROSS JOIN
  UNNEST(publication_ids) pub_ref     -- unnest the publication ids cited by patents
JOIN
  grant_pubs gp
ON
  gp.pub_id = pub_ref                 -- join on publicaiton id
"""

# retrieve from BigQuery and make it a pandas dataframe
nsf_pub_ref_patents = client.query(search_string).to_dataframe()

# get a quick preview of the patents that cited publications which were funded by NSF grants
nsf_pub_ref_patents.head()
```

<table>
  <thead>
    <tr>
      <th>Row</th>
      <th>patent_id</th>
      <th>grant_id</th>
      <th>family_id</th>
      <th>priority_year</th>
      <th>link_type</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>WO-2019202933-A1</td>
      <td>grant.4179511</td>
      <td>68239624</td>
      <td>2018</td>
      <td>pub_reference</td>
    </tr>
    <tr>
      <td>1</td>
      <td>US-10528687-B2</td>
      <td>grant.3861071</td>
      <td>60158395</td>
      <td>2016</td>
      <td>pub_reference</td>
    </tr>
    <tr>
      <td>2</td>
      <td>DE-102017002874-A1</td>
      <td>grant.3981846</td>
      <td>61731654</td>
      <td>2017</td>
      <td>pub_reference</td>
    </tr>
    <tr>
      <td>3</td>
      <td>US-10725209-B2</td>
      <td>grant.4312170</td>
      <td>62908810</td>
      <td>2017</td>
      <td>pub_reference</td>
    </tr>
    <tr>
      <td>4</td>
      <td>US-10196708-B2</td>
      <td>grant.4312419</td>
      <td>62782292</td>
      <td>2017</td>
      <td>pub_reference</td>
    </tr>
  </tbody>
</table>


```python
# get a quick count of how many patents were retrieved
print(nsf_pub_ref_patents['patent_id'].nunique())

```

    224


### Merge results
Now we will merge two data frames to have a complete set of patents that are directly and indirectly linked to the set of grants

```python
nsf_patents = pd.concat([nsf_grant_patents, nsf_pub_ref_patents]).reset_index()

# get a quick count of how many patents in total
print(nsf_patents['patent_id'].nunique())
```

    799


### Quick overview of patents

Lastly, we can examine the trends in the patents by priority year

!!! tip "Tips"
    * `family_id` was used to deduplicate the patent documents, one patent family is a collection of patent documents that are considered to cover a single invention [(see definition in DOCDB Simple patent family)](https://www.epo.org/searching-for-patents/helpful-resources/first-time-here/patent-families/docdb.html)
    * `priority_year` was used to aggregate the patents, since it indicates the time when the invention was established. All patent documents in one patent family share the same priority date


```python
nsf_patents.groupby(['link_type','priority_year'], as_index = False).agg({'family_id':'nunique'})\
           .rename(columns={'family_id':'n_pat_families'})\
           .pivot (values = 'n_pat_families', index = 'priority_year', columns = 'link_type')
```

<table>
  <thead>
    <tr>
      <th>link_type</th>
      <th>pub_reference</th>
      <th>supported</th>
    </tr>
    <tr>
      <th>priority_year</th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>2004</td>
      <td>3.0</td>
      <td>NaN</td>
    </tr>
    <tr>
      <td>2005</td>
      <td>1.0</td>
      <td>NaN</td>
    </tr>
    <tr>
      <td>2009</td>
      <td>1.0</td>
      <td>NaN</td>
    </tr>
    <tr>
      <td>2010</td>
      <td>NaN</td>
      <td>1.0</td>
    </tr>
    <tr>
      <td>2011</td>
      <td>1.0</td>
      <td>NaN</td>
    </tr>
    <tr>
      <td>2012</td>
      <td>1.0</td>
      <td>1.0</td>
    </tr>
    <tr>
      <td>2013</td>
      <td>4.0</td>
      <td>5.0</td>
    </tr>
    <tr>
      <td>2014</td>
      <td>8.0</td>
      <td>15.0</td>
    </tr>
    <tr>
      <td>2015</td>
      <td>10.0</td>
      <td>42.0</td>
    </tr>
    <tr>
      <td>2016</td>
      <td>41.0</td>
      <td>90.0</td>
    </tr>
    <tr>
      <td>2017</td>
      <td>57.0</td>
      <td>123.0</td>
    </tr>
    <tr>
      <td>2018</td>
      <td>57.0</td>
      <td>63.0</td>
    </tr>
    <tr>
      <td>2019</td>
      <td>15.0</td>
      <td>42.0</td>
    </tr>
    <tr>
      <td>2020</td>
      <td>1.0</td>
      <td>1.0</td>
    </tr>
  </tbody>
</table>

In addition, we can also create a quick visualization of the trends


```python
plot_data = nsf_patents.groupby(['link_type','priority_year'], as_index = False)\
           .agg({'family_id':'nunique'})\
           .rename(columns={'family_id':'n_patent_families'})

# create line plot by using plotly express
fig = px.line(plot_data, x="priority_year", y="n_patent_families", color = "link_type", title='Trends in patents supported by NSF Directorate for Engineering grants starting 2015')
fig.show()
```

<html>
<head><meta charset="utf-8" /></head>
<body>
    <div>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-AMS-MML_SVG"></script><script type="text/javascript">if (window.MathJax) {MathJax.Hub.Config({SVG: {font: "STIX-Web"}});}</script>
                <script type="text/javascript">window.PlotlyConfig = {MathJaxConfig: 'local'};</script>
        <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
            <div id="d2f6fb5d-2291-4ffe-8c38-48c5cd14abda" class="plotly-graph-div" style="height:525px; width:100%;"></div>
            <script type="text/javascript">

                    window.PLOTLYENV=window.PLOTLYENV || {};

                if (document.getElementById("d2f6fb5d-2291-4ffe-8c38-48c5cd14abda")) {
                    Plotly.newPlot(
                        'd2f6fb5d-2291-4ffe-8c38-48c5cd14abda',
                        [{"hoverlabel": {"namelength": 0}, "hovertemplate": "link_type=pub_reference<br>priority_year=%{x}<br>n_patent_families=%{y}", "legendgroup": "link_type=pub_reference", "line": {"color": "#636efa", "dash": "solid"}, "mode": "lines", "name": "link_type=pub_reference", "showlegend": true, "type": "scatter", "x": ["2004", "2005", "2009", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020"], "xaxis": "x", "y": [3, 1, 1, 1, 1, 4, 8, 10, 41, 57, 57, 15, 1], "yaxis": "y"}, {"hoverlabel": {"namelength": 0}, "hovertemplate": "link_type=supported<br>priority_year=%{x}<br>n_patent_families=%{y}", "legendgroup": "link_type=supported", "line": {"color": "#EF553B", "dash": "solid"}, "mode": "lines", "name": "link_type=supported", "showlegend": true, "type": "scatter", "x": ["2010", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020"], "xaxis": "x", "y": [1, 1, 5, 15, 42, 90, 123, 63, 42, 1], "yaxis": "y"}],
                        {"legend": {"tracegroupgap": 0}, "template": {"data": {"bar": [{"error_x": {"color": "#2a3f5f"}, "error_y": {"color": "#2a3f5f"}, "marker": {"line": {"color": "#E5ECF6", "width": 0.5}}, "type": "bar"}], "barpolar": [{"marker": {"line": {"color": "#E5ECF6", "width": 0.5}}, "type": "barpolar"}], "carpet": [{"aaxis": {"endlinecolor": "#2a3f5f", "gridcolor": "white", "linecolor": "white", "minorgridcolor": "white", "startlinecolor": "#2a3f5f"}, "baxis": {"endlinecolor": "#2a3f5f", "gridcolor": "white", "linecolor": "white", "minorgridcolor": "white", "startlinecolor": "#2a3f5f"}, "type": "carpet"}], "choropleth": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "type": "choropleth"}], "contour": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "colorscale": [[0.0, "#0d0887"], [0.1111111111111111, "#46039f"], [0.2222222222222222, "#7201a8"], [0.3333333333333333, "#9c179e"], [0.4444444444444444, "#bd3786"], [0.5555555555555556, "#d8576b"], [0.6666666666666666, "#ed7953"], [0.7777777777777778, "#fb9f3a"], [0.8888888888888888, "#fdca26"], [1.0, "#f0f921"]], "type": "contour"}], "contourcarpet": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "type": "contourcarpet"}], "heatmap": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "colorscale": [[0.0, "#0d0887"], [0.1111111111111111, "#46039f"], [0.2222222222222222, "#7201a8"], [0.3333333333333333, "#9c179e"], [0.4444444444444444, "#bd3786"], [0.5555555555555556, "#d8576b"], [0.6666666666666666, "#ed7953"], [0.7777777777777778, "#fb9f3a"], [0.8888888888888888, "#fdca26"], [1.0, "#f0f921"]], "type": "heatmap"}], "heatmapgl": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "colorscale": [[0.0, "#0d0887"], [0.1111111111111111, "#46039f"], [0.2222222222222222, "#7201a8"], [0.3333333333333333, "#9c179e"], [0.4444444444444444, "#bd3786"], [0.5555555555555556, "#d8576b"], [0.6666666666666666, "#ed7953"], [0.7777777777777778, "#fb9f3a"], [0.8888888888888888, "#fdca26"], [1.0, "#f0f921"]], "type": "heatmapgl"}], "histogram": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "histogram"}], "histogram2d": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "colorscale": [[0.0, "#0d0887"], [0.1111111111111111, "#46039f"], [0.2222222222222222, "#7201a8"], [0.3333333333333333, "#9c179e"], [0.4444444444444444, "#bd3786"], [0.5555555555555556, "#d8576b"], [0.6666666666666666, "#ed7953"], [0.7777777777777778, "#fb9f3a"], [0.8888888888888888, "#fdca26"], [1.0, "#f0f921"]], "type": "histogram2d"}], "histogram2dcontour": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "colorscale": [[0.0, "#0d0887"], [0.1111111111111111, "#46039f"], [0.2222222222222222, "#7201a8"], [0.3333333333333333, "#9c179e"], [0.4444444444444444, "#bd3786"], [0.5555555555555556, "#d8576b"], [0.6666666666666666, "#ed7953"], [0.7777777777777778, "#fb9f3a"], [0.8888888888888888, "#fdca26"], [1.0, "#f0f921"]], "type": "histogram2dcontour"}], "mesh3d": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "type": "mesh3d"}], "parcoords": [{"line": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "parcoords"}], "pie": [{"automargin": true, "type": "pie"}], "scatter": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scatter"}], "scatter3d": [{"line": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scatter3d"}], "scattercarpet": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scattercarpet"}], "scattergeo": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scattergeo"}], "scattergl": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scattergl"}], "scattermapbox": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scattermapbox"}], "scatterpolar": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scatterpolar"}], "scatterpolargl": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scatterpolargl"}], "scatterternary": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scatterternary"}], "surface": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "colorscale": [[0.0, "#0d0887"], [0.1111111111111111, "#46039f"], [0.2222222222222222, "#7201a8"], [0.3333333333333333, "#9c179e"], [0.4444444444444444, "#bd3786"], [0.5555555555555556, "#d8576b"], [0.6666666666666666, "#ed7953"], [0.7777777777777778, "#fb9f3a"], [0.8888888888888888, "#fdca26"], [1.0, "#f0f921"]], "type": "surface"}], "table": [{"cells": {"fill": {"color": "#EBF0F8"}, "line": {"color": "white"}}, "header": {"fill": {"color": "#C8D4E3"}, "line": {"color": "white"}}, "type": "table"}]}, "layout": {"annotationdefaults": {"arrowcolor": "#2a3f5f", "arrowhead": 0, "arrowwidth": 1}, "coloraxis": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "colorscale": {"diverging": [[0, "#8e0152"], [0.1, "#c51b7d"], [0.2, "#de77ae"], [0.3, "#f1b6da"], [0.4, "#fde0ef"], [0.5, "#f7f7f7"], [0.6, "#e6f5d0"], [0.7, "#b8e186"], [0.8, "#7fbc41"], [0.9, "#4d9221"], [1, "#276419"]], "sequential": [[0.0, "#0d0887"], [0.1111111111111111, "#46039f"], [0.2222222222222222, "#7201a8"], [0.3333333333333333, "#9c179e"], [0.4444444444444444, "#bd3786"], [0.5555555555555556, "#d8576b"], [0.6666666666666666, "#ed7953"], [0.7777777777777778, "#fb9f3a"], [0.8888888888888888, "#fdca26"], [1.0, "#f0f921"]], "sequentialminus": [[0.0, "#0d0887"], [0.1111111111111111, "#46039f"], [0.2222222222222222, "#7201a8"], [0.3333333333333333, "#9c179e"], [0.4444444444444444, "#bd3786"], [0.5555555555555556, "#d8576b"], [0.6666666666666666, "#ed7953"], [0.7777777777777778, "#fb9f3a"], [0.8888888888888888, "#fdca26"], [1.0, "#f0f921"]]}, "colorway": ["#636efa", "#EF553B", "#00cc96", "#ab63fa", "#FFA15A", "#19d3f3", "#FF6692", "#B6E880", "#FF97FF", "#FECB52"], "font": {"color": "#2a3f5f"}, "geo": {"bgcolor": "white", "lakecolor": "white", "landcolor": "#E5ECF6", "showlakes": true, "showland": true, "subunitcolor": "white"}, "hoverlabel": {"align": "left"}, "hovermode": "closest", "mapbox": {"style": "light"}, "paper_bgcolor": "white", "plot_bgcolor": "#E5ECF6", "polar": {"angularaxis": {"gridcolor": "white", "linecolor": "white", "ticks": ""}, "bgcolor": "#E5ECF6", "radialaxis": {"gridcolor": "white", "linecolor": "white", "ticks": ""}}, "scene": {"xaxis": {"backgroundcolor": "#E5ECF6", "gridcolor": "white", "gridwidth": 2, "linecolor": "white", "showbackground": true, "ticks": "", "zerolinecolor": "white"}, "yaxis": {"backgroundcolor": "#E5ECF6", "gridcolor": "white", "gridwidth": 2, "linecolor": "white", "showbackground": true, "ticks": "", "zerolinecolor": "white"}, "zaxis": {"backgroundcolor": "#E5ECF6", "gridcolor": "white", "gridwidth": 2, "linecolor": "white", "showbackground": true, "ticks": "", "zerolinecolor": "white"}}, "shapedefaults": {"line": {"color": "#2a3f5f"}}, "ternary": {"aaxis": {"gridcolor": "white", "linecolor": "white", "ticks": ""}, "baxis": {"gridcolor": "white", "linecolor": "white", "ticks": ""}, "bgcolor": "#E5ECF6", "caxis": {"gridcolor": "white", "linecolor": "white", "ticks": ""}}, "title": {"x": 0.05}, "xaxis": {"automargin": true, "gridcolor": "white", "linecolor": "white", "ticks": "", "title": {"standoff": 15}, "zerolinecolor": "white", "zerolinewidth": 2}, "yaxis": {"automargin": true, "gridcolor": "white", "linecolor": "white", "ticks": "", "title": {"standoff": 15}, "zerolinecolor": "white", "zerolinewidth": 2}}}, "title": {"text": "Trends in patents supported by NSF Directorate for Engineering grants starting 2015"}, "xaxis": {"anchor": "y", "domain": [0.0, 1.0], "title": {"text": "priority_year"}}, "yaxis": {"anchor": "x", "domain": [0.0, 1.0], "title": {"text": "n_patent_families"}}},
                        {"responsive": true}
                    ).then(function(){

var gd = document.getElementById('d2f6fb5d-2291-4ffe-8c38-48c5cd14abda');
var x = new MutationObserver(function (mutations, observer) {{
        var display = window.getComputedStyle(gd).display;
        if (!display || display === 'none') {{
            console.log([gd, 'removed!']);
            Plotly.purge(gd);
            observer.disconnect();
        }}
}});

// Listen for the removal of the full notebook cells
var notebookContainer = gd.closest('#notebook-container');
if (notebookContainer) {{
    x.observe(notebookContainer, {childList: true});
}}

// Listen for the clearing of the current output cell
var outputEl = gd.closest('.output');
if (outputEl) {{
    x.observe(outputEl, {childList: true});
}}

                        })
                };

            </script>
        </div>
</body>
</html>
