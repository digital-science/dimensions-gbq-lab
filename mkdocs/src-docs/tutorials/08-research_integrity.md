# Usage of Trust Markers in research (ARCHIVED)

!!! warning "Archived Dataset"
    The Trust Markers dataset has been retired, and its associated tutorial is now archived.


## Use case

'Trust Markers' are indicators of integrity, professionalism and reproducibility in scientific research. They also highlight the level of research transparency within the document, and reduce the risks of allowing non-compliance to research integrity policies to go unobserved.

This notebook takes you through a few examples which address the above questions. It makes use of the [Dimensions Research Integrity Dataset](https://ripeta.com/solutions/dimensions-research-integrity/), an additional module to Dimensions on Google Big Query (GBQ).

Using the dataset, you can answer questions such as:

*   How many research articles use Trust Markers?
*   How does coverage of Trust Markers differ across publishers, funders and research organisations?
* If researchers are using Trust Markers (eg, data availability statements), how many are putting their data in repositories (and which repositories)?

!!! warning "Prerequisites"
    In order to run this tutorial, please ensure that:

    * You have a valid [Dimensions on Google BigQuery account](https://www.dimensions.ai/products/bigquery/) and have [configured a Google Cloud project](https://docs.dimensions.ai/bigquery/gcp-setup.html#). This must include access to the Dimensions Research Integrity Dataset.
    * You have some basic familiarity with Python and [Jupyter notebooks](https://jupyter.org/).

## About Trust Markers

The Trust Markers in the Dataset represent the integrity and reproducibility of scientific research. Trust Markers represent a contract between authors and readers that proper research practices have been observed. They also highlight the level of research transparency within the document, and reduce the risks of allowing non-compliance to research integrity policies to go unobserved.

To read definitions of specific Trust Markers, see the [GBQ schema documentation](https://docs.dimensions.ai/bigquery/datasource-dri-trust-markers.html).


## Method
This notebook retrieves data about trust marker and publication data from Dimensions, the world's largest linked research information datatset. In particular the Trust Markers are taken from the DRI module.

To complete the analysis the following steps are taken:


1.   Connect to the Dimensions database.
2.   Gather information about general use of Trust Markers, broken down by publisher.
3.   Look at how usage of Trust Markers breaks down by research organisations in the US, by joining on data from [GRID](https://www.digital-science.com/resource/grid/).
4. Find out some of the most commonly claimed contributions by inviduals to research across different fields.
5. Understand the usage of repositories across funders, research orgs and research articles.

## 1. Connect

You will need to be authenticated to run these queries - see the ["Verifying yout connection"](https://bigquery-lab.dimensions.ai/tutorials/01-connection/) tutorial for options.


```python
from google.colab import auth
auth.authenticate_user()
print('Authenticated')
```

    Authenticated



```python
#import other packages/modules needed for analysis
from google.cloud import bigquery
import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objs as go
```


```python
#config to avoid having to declare parameters multiple times
project_id = "ds-ripeta-gbq" #replace 'project' with the required project associate with your account

from google.cloud.bigquery import magics
magics.context.project = project_id

client = bigquery.Client(project = project_id)
```

## 2. Trust Markers by publisher

### Write and run a query
In this instance we will limit data to 2022 and 10 publishers to keep things manageable.


```python
#write the query - we're limiting results here to keep things easy to follow
qry = client.query("""
SELECT
    p.publisher.name,
    100 * COUNTIF(tm.data.data_availability_statement.present)/ COUNT(p.id) AS data_availability,
    100 * COUNTIF(tm.code.code_availability_statement.present)/COUNT(p.id) AS code_availability,
    100 * COUNTIF(tm.authors.author_contribution_statement.present)/COUNT(p.id) AS author_contributions,
    100 * COUNTIF(tm.authors.conflict_of_interest_statement.present)/COUNT(p.id) AS conflict_interest,
    100 * COUNTIF(tm.funding.funding_statement.present)/COUNT(p.id) AS funding_statement,
    #note here we are only counting articles with mesh terms of 'animal' or 'human' as if this criteria isn't met it is unlikely an ethics statement would be expected
    100 * COUNTIF((tm.ethical_approval.ethical_approval_statement.present AND (('Humans' IN UNNEST(p.mesh_terms)) OR ('Animals' IN UNNEST(p.mesh_terms)))) )/
        NULLIF(COUNTIF(('Humans' in UNNEST(p.mesh_terms)) OR ('Animals' IN unnest(p.mesh_terms))), 0) AS ethics_approval
FROM
    dimensions-ai.data_analytics.publications p
INNER JOIN `dimensions-ai-integrity.data.trust_markers` tm
    ON p.id = tm.id
WHERE p.year = 2022 AND p.document_type.classification = 'RESEARCH_ARTICLE'
GROUP BY 1
ORDER BY COUNT(p.id) DESC #order by number of publications in the trust marker dataset
--To keep things manageable for display purposes, we'll only look at 10 publishers for now
LIMIT 10
""")

#get the results
results = qry.result().to_dataframe() #may take a while depending on how much data your return

#take a peak
results
```





  <div id="df-f9c1d925-b84b-4166-93f3-6df07095fdb5">
    <div class="colab-df-container">
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
      <th>data_availability</th>
      <th>code_availability</th>
      <th>author_contributions</th>
      <th>conflict_interest</th>
      <th>funding_statement</th>
      <th>ethics_approval</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Elsevier</td>
      <td>22.890000</td>
      <td>1.597544</td>
      <td>17.378246</td>
      <td>80.405263</td>
      <td>57.918947</td>
      <td>18.943601</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Springer Nature</td>
      <td>49.878036</td>
      <td>8.742873</td>
      <td>52.908014</td>
      <td>40.728133</td>
      <td>71.049643</td>
      <td>65.175558</td>
    </tr>
    <tr>
      <th>2</th>
      <td>MDPI</td>
      <td>88.760718</td>
      <td>1.339980</td>
      <td>97.192921</td>
      <td>99.243270</td>
      <td>91.880857</td>
      <td>13.336054</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Wiley</td>
      <td>39.376133</td>
      <td>1.139870</td>
      <td>20.882104</td>
      <td>7.671746</td>
      <td>58.562563</td>
      <td>16.154602</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Frontiers</td>
      <td>97.583713</td>
      <td>1.031047</td>
      <td>99.547012</td>
      <td>6.398587</td>
      <td>79.234019</td>
      <td>75.641116</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Taylor &amp; Francis</td>
      <td>17.195639</td>
      <td>0.605616</td>
      <td>11.305576</td>
      <td>83.174962</td>
      <td>52.912265</td>
      <td>28.457937</td>
    </tr>
    <tr>
      <th>6</th>
      <td>Institute of Electrical and Electronics Engine...</td>
      <td>0.300312</td>
      <td>0.723896</td>
      <td>0.208514</td>
      <td>0.599313</td>
      <td>3.561780</td>
      <td>5.201794</td>
    </tr>
    <tr>
      <th>7</th>
      <td>American Chemical Society (ACS)</td>
      <td>2.348741</td>
      <td>0.794581</td>
      <td>42.137319</td>
      <td>1.914696</td>
      <td>75.219210</td>
      <td>4.040979</td>
    </tr>
    <tr>
      <th>8</th>
      <td>Hindawi</td>
      <td>85.378842</td>
      <td>1.029393</td>
      <td>23.275609</td>
      <td>85.217410</td>
      <td>52.681454</td>
      <td>23.068174</td>
    </tr>
    <tr>
      <th>9</th>
      <td>SAGE Publications</td>
      <td>9.527544</td>
      <td>0.604082</td>
      <td>18.841010</td>
      <td>4.317599</td>
      <td>90.031582</td>
      <td>33.596158</td>
    </tr>
  </tbody>
</table>
</div>
      <button class="colab-df-convert" onclick="convertToInteractive('df-f9c1d925-b84b-4166-93f3-6df07095fdb5')"
              title="Convert this dataframe to an interactive table."
              style="display:none;">

  <svg xmlns="http://www.w3.org/2000/svg" height="24px"viewBox="0 0 24 24"
       width="24px">
    <path d="M0 0h24v24H0V0z" fill="none"/>
    <path d="M18.56 5.44l.94 2.06.94-2.06 2.06-.94-2.06-.94-.94-2.06-.94 2.06-2.06.94zm-11 1L8.5 8.5l.94-2.06 2.06-.94-2.06-.94L8.5 2.5l-.94 2.06-2.06.94zm10 10l.94 2.06.94-2.06 2.06-.94-2.06-.94-.94-2.06-.94 2.06-2.06.94z"/><path d="M17.41 7.96l-1.37-1.37c-.4-.4-.92-.59-1.43-.59-.52 0-1.04.2-1.43.59L10.3 9.45l-7.72 7.72c-.78.78-.78 2.05 0 2.83L4 21.41c.39.39.9.59 1.41.59.51 0 1.02-.2 1.41-.59l7.78-7.78 2.81-2.81c.8-.78.8-2.07 0-2.86zM5.41 20L4 18.59l7.72-7.72 1.47 1.35L5.41 20z"/>
  </svg>
      </button>

  <style>
    .colab-df-container {
      display:flex;
      flex-wrap:wrap;
      gap: 12px;
    }

    .colab-df-convert {
      background-color: #E8F0FE;
      border: none;
      border-radius: 50%;
      cursor: pointer;
      display: none;
      fill: #1967D2;
      height: 32px;
      padding: 0 0 0 0;
      width: 32px;
    }

    .colab-df-convert:hover {
      background-color: #E2EBFA;
      box-shadow: 0px 1px 2px rgba(60, 64, 67, 0.3), 0px 1px 3px 1px rgba(60, 64, 67, 0.15);
      fill: #174EA6;
    }

    [theme=dark] .colab-df-convert {
      background-color: #3B4455;
      fill: #D2E3FC;
    }

    [theme=dark] .colab-df-convert:hover {
      background-color: #434B5C;
      box-shadow: 0px 1px 3px 1px rgba(0, 0, 0, 0.15);
      filter: drop-shadow(0px 1px 2px rgba(0, 0, 0, 0.3));
      fill: #FFFFFF;
    }
  </style>

      <script>
        const buttonEl =
          document.querySelector('#df-f9c1d925-b84b-4166-93f3-6df07095fdb5 button.colab-df-convert');
        buttonEl.style.display =
          google.colab.kernel.accessAllowed ? 'block' : 'none';

        async function convertToInteractive(key) {
          const element = document.querySelector('#df-f9c1d925-b84b-4166-93f3-6df07095fdb5');
          const dataTable =
            await google.colab.kernel.invokeFunction('convertToInteractive',
                                                     [key], {});
          if (!dataTable) return;

          const docLinkHtml = 'Like what you see? Visit the ' +
            '<a target="_blank" href=https://colab.research.google.com/notebooks/data_table.ipynb>data table notebook</a>'
            + ' to learn more about interactive tables.';
          element.innerHTML = '';
          dataTable['output_type'] = 'display_data';
          await google.colab.output.renderOutput(dataTable, element);
          const docLink = document.createElement('div');
          docLink.innerHTML = docLinkHtml;
          element.appendChild(docLink);
        }
      </script>
    </div>
  </div>




### Visualize your results


```python
#make data 'long'
long_results = pd.melt(
    results,
    id_vars = "name",
    value_vars = results.columns.tolist()[1:7],
    var_name = "trust_marker",
    value_name = "pct"
    )

#convert your data to a dictionary so plotly can handle it
result_dict = {
    "z": long_results.pct.tolist(),
    "x": long_results.trust_marker.tolist(),
    "y": long_results.name.tolist()
}

#plot
plot = go.Figure(
    data = go.Heatmap(
        result_dict,
        colorscale = "Blues"
        )
    )

plot.show()
```


<html>
<head><meta charset="utf-8" /></head>
<body>
    <div>            <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-AMS-MML_SVG"></script><script type="text/javascript">if (window.MathJax && window.MathJax.Hub && window.MathJax.Hub.Config) {window.MathJax.Hub.Config({SVG: {font: "STIX-Web"}});}</script>                <script type="text/javascript">window.PlotlyConfig = {MathJaxConfig: 'local'};</script>
        <script src="https://cdn.plot.ly/plotly-2.18.2.min.js"></script>                <div id="ddd7db84-31c9-4b4c-aa14-ad094b3a5518" class="plotly-graph-div" style="height:525px; width:100%;"></div>            <script type="text/javascript">                                    window.PLOTLYENV=window.PLOTLYENV || {};                                    if (document.getElementById("ddd7db84-31c9-4b4c-aa14-ad094b3a5518")) {                    Plotly.newPlot(                        "ddd7db84-31c9-4b4c-aa14-ad094b3a5518",                        [{"colorscale":[[0.0,"rgb(247,251,255)"],[0.125,"rgb(222,235,247)"],[0.25,"rgb(198,219,239)"],[0.375,"rgb(158,202,225)"],[0.5,"rgb(107,174,214)"],[0.625,"rgb(66,146,198)"],[0.75,"rgb(33,113,181)"],[0.875,"rgb(8,81,156)"],[1.0,"rgb(8,48,107)"]],"x":["data_availability","data_availability","data_availability","data_availability","data_availability","data_availability","data_availability","data_availability","data_availability","data_availability","code_availability","code_availability","code_availability","code_availability","code_availability","code_availability","code_availability","code_availability","code_availability","code_availability","author_contributions","author_contributions","author_contributions","author_contributions","author_contributions","author_contributions","author_contributions","author_contributions","author_contributions","author_contributions","conflict_interest","conflict_interest","conflict_interest","conflict_interest","conflict_interest","conflict_interest","conflict_interest","conflict_interest","conflict_interest","conflict_interest","funding_statement","funding_statement","funding_statement","funding_statement","funding_statement","funding_statement","funding_statement","funding_statement","funding_statement","funding_statement","ethics_approval","ethics_approval","ethics_approval","ethics_approval","ethics_approval","ethics_approval","ethics_approval","ethics_approval","ethics_approval","ethics_approval"],"y":["Elsevier","Springer Nature","MDPI","Wiley","Frontiers","Taylor & Francis","Institute of Electrical and Electronics Engineers (IEEE)","American Chemical Society (ACS)","Hindawi","SAGE Publications","Elsevier","Springer Nature","MDPI","Wiley","Frontiers","Taylor & Francis","Institute of Electrical and Electronics Engineers (IEEE)","American Chemical Society (ACS)","Hindawi","SAGE Publications","Elsevier","Springer Nature","MDPI","Wiley","Frontiers","Taylor & Francis","Institute of Electrical and Electronics Engineers (IEEE)","American Chemical Society (ACS)","Hindawi","SAGE Publications","Elsevier","Springer Nature","MDPI","Wiley","Frontiers","Taylor & Francis","Institute of Electrical and Electronics Engineers (IEEE)","American Chemical Society (ACS)","Hindawi","SAGE Publications","Elsevier","Springer Nature","MDPI","Wiley","Frontiers","Taylor & Francis","Institute of Electrical and Electronics Engineers (IEEE)","American Chemical Society (ACS)","Hindawi","SAGE Publications","Elsevier","Springer Nature","MDPI","Wiley","Frontiers","Taylor & Francis","Institute of Electrical and Electronics Engineers (IEEE)","American Chemical Society (ACS)","Hindawi","SAGE Publications"],"z":[22.89,49.878036061926394,88.76071784646062,39.376133392995925,97.58371345090703,17.19563866448223,0.3003121147743069,2.3487407459264573,85.3788418801627,9.527544034422094,1.5975438596491227,8.74287336608881,1.3399800598205385,1.1398695273309625,1.031047022470729,0.6056155019490425,0.7238964513337005,0.7945814445980713,1.02939326596503,0.6040823247631362,17.378245614035087,52.908014276443865,97.19292123629113,20.88210357740044,99.54701196056587,11.305575956160668,0.20851365174285938,42.137319075205205,23.27560904021133,18.84100977129655,80.40526315789474,40.7281334013164,99.24327018943171,7.671745837356633,6.398587434048725,83.1749618665612,0.5993128229338789,1.9146962563662775,85.21740953499099,4.317598931728099,57.91894736842105,71.04964308890331,91.88085742771685,58.5625632933751,79.23401929665987,52.912264843794134,3.561780365620164,75.21920996902182,52.68145414902092,90.03158184785603,18.943601038307243,65.17555777726507,13.336054160464782,16.154602030789388,75.64111571699571,28.457936549692217,5.201793721973094,4.040978941377348,23.06817373995877,33.5961579815067],"type":"heatmap"}],                        {"template":{"data":{"histogram2dcontour":[{"type":"histogram2dcontour","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"choropleth":[{"type":"choropleth","colorbar":{"outlinewidth":0,"ticks":""}}],"histogram2d":[{"type":"histogram2d","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"heatmap":[{"type":"heatmap","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"heatmapgl":[{"type":"heatmapgl","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"contourcarpet":[{"type":"contourcarpet","colorbar":{"outlinewidth":0,"ticks":""}}],"contour":[{"type":"contour","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"surface":[{"type":"surface","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"mesh3d":[{"type":"mesh3d","colorbar":{"outlinewidth":0,"ticks":""}}],"scatter":[{"fillpattern":{"fillmode":"overlay","size":10,"solidity":0.2},"type":"scatter"}],"parcoords":[{"type":"parcoords","line":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scatterpolargl":[{"type":"scatterpolargl","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"bar":[{"error_x":{"color":"#2a3f5f"},"error_y":{"color":"#2a3f5f"},"marker":{"line":{"color":"#E5ECF6","width":0.5},"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"bar"}],"scattergeo":[{"type":"scattergeo","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scatterpolar":[{"type":"scatterpolar","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"histogram":[{"marker":{"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"histogram"}],"scattergl":[{"type":"scattergl","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scatter3d":[{"type":"scatter3d","line":{"colorbar":{"outlinewidth":0,"ticks":""}},"marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scattermapbox":[{"type":"scattermapbox","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scatterternary":[{"type":"scatterternary","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scattercarpet":[{"type":"scattercarpet","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"carpet":[{"aaxis":{"endlinecolor":"#2a3f5f","gridcolor":"white","linecolor":"white","minorgridcolor":"white","startlinecolor":"#2a3f5f"},"baxis":{"endlinecolor":"#2a3f5f","gridcolor":"white","linecolor":"white","minorgridcolor":"white","startlinecolor":"#2a3f5f"},"type":"carpet"}],"table":[{"cells":{"fill":{"color":"#EBF0F8"},"line":{"color":"white"}},"header":{"fill":{"color":"#C8D4E3"},"line":{"color":"white"}},"type":"table"}],"barpolar":[{"marker":{"line":{"color":"#E5ECF6","width":0.5},"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"barpolar"}],"pie":[{"automargin":true,"type":"pie"}]},"layout":{"autotypenumbers":"strict","colorway":["#636efa","#EF553B","#00cc96","#ab63fa","#FFA15A","#19d3f3","#FF6692","#B6E880","#FF97FF","#FECB52"],"font":{"color":"#2a3f5f"},"hovermode":"closest","hoverlabel":{"align":"left"},"paper_bgcolor":"white","plot_bgcolor":"#E5ECF6","polar":{"bgcolor":"#E5ECF6","angularaxis":{"gridcolor":"white","linecolor":"white","ticks":""},"radialaxis":{"gridcolor":"white","linecolor":"white","ticks":""}},"ternary":{"bgcolor":"#E5ECF6","aaxis":{"gridcolor":"white","linecolor":"white","ticks":""},"baxis":{"gridcolor":"white","linecolor":"white","ticks":""},"caxis":{"gridcolor":"white","linecolor":"white","ticks":""}},"coloraxis":{"colorbar":{"outlinewidth":0,"ticks":""}},"colorscale":{"sequential":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"sequentialminus":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"diverging":[[0,"#8e0152"],[0.1,"#c51b7d"],[0.2,"#de77ae"],[0.3,"#f1b6da"],[0.4,"#fde0ef"],[0.5,"#f7f7f7"],[0.6,"#e6f5d0"],[0.7,"#b8e186"],[0.8,"#7fbc41"],[0.9,"#4d9221"],[1,"#276419"]]},"xaxis":{"gridcolor":"white","linecolor":"white","ticks":"","title":{"standoff":15},"zerolinecolor":"white","automargin":true,"zerolinewidth":2},"yaxis":{"gridcolor":"white","linecolor":"white","ticks":"","title":{"standoff":15},"zerolinecolor":"white","automargin":true,"zerolinewidth":2},"scene":{"xaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white","gridwidth":2},"yaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white","gridwidth":2},"zaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white","gridwidth":2}},"shapedefaults":{"line":{"color":"#2a3f5f"}},"annotationdefaults":{"arrowcolor":"#2a3f5f","arrowhead":0,"arrowwidth":1},"geo":{"bgcolor":"white","landcolor":"#E5ECF6","subunitcolor":"white","showland":true,"showlakes":true,"lakecolor":"white"},"title":{"x":0.05},"mapbox":{"style":"light"}}}},                        {"responsive": true}                    ).then(function(){

var gd = document.getElementById('ddd7db84-31c9-4b4c-aa14-ad094b3a5518');
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

                        })                };                            </script>        </div>
</body>
</html>


## 3. Trust Markers by research org
There are plenty of other analyses we can carry out using DRI. We are also not obliged to pull in aggregated data - we can also pull in data 'row-by-row' and analyse further in Python. We'll do this in the next example to look at the proportion of articles using Trust Markers at US universities.

Note that this example is set up to work generally. In a notebook environment (like Colab or Jupyter) you can use magic commands to reduce the code down to just the query and store as a summary dataframe. Google has [guidance on doing this](https://cloud.google.com/bigquery/docs/visualize-jupyter). We will use this magic commands in future examples.


```python
%%bigquery markers_by_us_uni

SELECT
    p.id AS pub_id,
    p.year,
    orgs AS org_id,
    CONCAT(g.name, ' (', g.address.city, ')') AS org_name,
    tm.data.data_availability_statement.present AS das,
    tm.code.code_availability_statement.present AS cas,
    tm.authors.author_contribution_statement.present AS auth_cont,
    tm.authors.conflict_of_interest_statement.present AS conflict_int,
    tm.funding.funding_statement.present AS funding,
    CASE
      WHEN tm.ethical_approval.ethical_approval_statement.present IS TRUE AND ('Humans' IN UNNEST(p.mesh_terms) OR 'Animals' IN UNNEST(p.mesh_terms)) THEN TRUE
      WHEN tm.ethical_approval.ethical_approval_statement.present IS FALSE AND ('Humans' IN UNNEST(p.mesh_terms) OR 'Animals' IN UNNEST(p.mesh_terms)) THEN FALSE
      ELSE NULL
      END AS ethics
FROM dimensions-ai.data_analytics.publications p,
     UNNEST(research_orgs) orgs
INNER JOIN `dimensions-ai-integrity.data.trust_markers` tm
    ON p.id = tm.id
INNER JOIN dimensions-ai.data_analytics.grid g
    ON orgs = g.id
    AND 'Education' IN UNNEST(g.types)
    AND g.address.country = "United States"
WHERE
    p.year = 2022
    AND p.document_type.classification = 'RESEARCH_ARTICLE'
```


    Query is running:   0%|          |



    Downloading:   0%|          |



```python
#you can see we've got the result straight to a df; take a look
markers_by_us_uni.head(5)
```





  <div id="df-35fa28d7-9722-4b74-9855-cded5ca7315b">
    <div class="colab-df-container">
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
      <th>pub_id</th>
      <th>year</th>
      <th>org_id</th>
      <th>org_name</th>
      <th>das</th>
      <th>cas</th>
      <th>auth_cont</th>
      <th>conflict_int</th>
      <th>funding</th>
      <th>ethics</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>pub.1141586193</td>
      <td>2022</td>
      <td>grid.36425.36</td>
      <td>Stony Brook University (Stony Brook)</td>
      <td>False</td>
      <td>False</td>
      <td>False</td>
      <td>False</td>
      <td>True</td>
      <td>&lt;NA&gt;</td>
    </tr>
    <tr>
      <th>1</th>
      <td>pub.1141411763</td>
      <td>2022</td>
      <td>grid.5288.7</td>
      <td>Oregon Health &amp; Science University (Portland)</td>
      <td>False</td>
      <td>False</td>
      <td>True</td>
      <td>True</td>
      <td>False</td>
      <td>False</td>
    </tr>
    <tr>
      <th>2</th>
      <td>pub.1141060825</td>
      <td>2022</td>
      <td>grid.262273.0</td>
      <td>Queens College, CUNY (New York)</td>
      <td>True</td>
      <td>False</td>
      <td>False</td>
      <td>True</td>
      <td>False</td>
      <td>False</td>
    </tr>
    <tr>
      <th>3</th>
      <td>pub.1140891786</td>
      <td>2022</td>
      <td>grid.255935.d</td>
      <td>Fisk University (Nashville)</td>
      <td>False</td>
      <td>False</td>
      <td>False</td>
      <td>True</td>
      <td>False</td>
      <td>&lt;NA&gt;</td>
    </tr>
    <tr>
      <th>4</th>
      <td>pub.1141168735</td>
      <td>2022</td>
      <td>grid.152326.1</td>
      <td>Vanderbilt University (Nashville)</td>
      <td>False</td>
      <td>False</td>
      <td>False</td>
      <td>False</td>
      <td>False</td>
      <td>True</td>
    </tr>
  </tbody>
</table>
</div>
      <button class="colab-df-convert" onclick="convertToInteractive('df-35fa28d7-9722-4b74-9855-cded5ca7315b')"
              title="Convert this dataframe to an interactive table."
              style="display:none;">

  <svg xmlns="http://www.w3.org/2000/svg" height="24px"viewBox="0 0 24 24"
       width="24px">
    <path d="M0 0h24v24H0V0z" fill="none"/>
    <path d="M18.56 5.44l.94 2.06.94-2.06 2.06-.94-2.06-.94-.94-2.06-.94 2.06-2.06.94zm-11 1L8.5 8.5l.94-2.06 2.06-.94-2.06-.94L8.5 2.5l-.94 2.06-2.06.94zm10 10l.94 2.06.94-2.06 2.06-.94-2.06-.94-.94-2.06-.94 2.06-2.06.94z"/><path d="M17.41 7.96l-1.37-1.37c-.4-.4-.92-.59-1.43-.59-.52 0-1.04.2-1.43.59L10.3 9.45l-7.72 7.72c-.78.78-.78 2.05 0 2.83L4 21.41c.39.39.9.59 1.41.59.51 0 1.02-.2 1.41-.59l7.78-7.78 2.81-2.81c.8-.78.8-2.07 0-2.86zM5.41 20L4 18.59l7.72-7.72 1.47 1.35L5.41 20z"/>
  </svg>
      </button>

  <style>
    .colab-df-container {
      display:flex;
      flex-wrap:wrap;
      gap: 12px;
    }

    .colab-df-convert {
      background-color: #E8F0FE;
      border: none;
      border-radius: 50%;
      cursor: pointer;
      display: none;
      fill: #1967D2;
      height: 32px;
      padding: 0 0 0 0;
      width: 32px;
    }

    .colab-df-convert:hover {
      background-color: #E2EBFA;
      box-shadow: 0px 1px 2px rgba(60, 64, 67, 0.3), 0px 1px 3px 1px rgba(60, 64, 67, 0.15);
      fill: #174EA6;
    }

    [theme=dark] .colab-df-convert {
      background-color: #3B4455;
      fill: #D2E3FC;
    }

    [theme=dark] .colab-df-convert:hover {
      background-color: #434B5C;
      box-shadow: 0px 1px 3px 1px rgba(0, 0, 0, 0.15);
      filter: drop-shadow(0px 1px 2px rgba(0, 0, 0, 0.3));
      fill: #FFFFFF;
    }
  </style>

      <script>
        const buttonEl =
          document.querySelector('#df-35fa28d7-9722-4b74-9855-cded5ca7315b button.colab-df-convert');
        buttonEl.style.display =
          google.colab.kernel.accessAllowed ? 'block' : 'none';

        async function convertToInteractive(key) {
          const element = document.querySelector('#df-35fa28d7-9722-4b74-9855-cded5ca7315b');
          const dataTable =
            await google.colab.kernel.invokeFunction('convertToInteractive',
                                                     [key], {});
          if (!dataTable) return;

          const docLinkHtml = 'Like what you see? Visit the ' +
            '<a target="_blank" href=https://colab.research.google.com/notebooks/data_table.ipynb>data table notebook</a>'
            + ' to learn more about interactive tables.';
          element.innerHTML = '';
          dataTable['output_type'] = 'display_data';
          await google.colab.output.renderOutput(dataTable, element);
          const docLink = document.createElement('div');
          docLink.innerHTML = docLinkHtml;
          element.appendChild(docLink);
        }
      </script>
    </div>
  </div>





```python
#now we'll manipulate as required in Python
marker_df = markers_by_us_uni

#flag marker cols
marker_cols = ["das", "cas", "auth_cont", "conflict_int", "funding", "ethics"]

#work out if there is a least one marker
marker_df["tm"] = marker_df[marker_cols].eq(1).any(axis = 1)

#institutions w/ <=1,000 publications
gt1000 = (marker_df.
          groupby(["org_id"], as_index = False).
          agg({"pub_id": "count"})
          )

gt1000 = gt1000[gt1000["pub_id"] >= 1000]["org_id"].to_list()

#summary
marker_sum = (marker_df.
              groupby(["org_id", "org_name", "tm"], as_index = False).
              agg({"pub_id": "count"})
)

#add on %
marker_sum["pct"] = 100 * marker_sum["pub_id"] / marker_sum.groupby(["org_id"])["pub_id"].transform("sum")

#remove institutions w/ <=1000 pubs and tm = False rows
marker_sum = marker_sum[(marker_sum["org_id"].isin(gt1000)) & (marker_sum["tm"] == True)]

#sort and slice to keep data manageable, pick the top 10 by number of publications...
marker_sum = marker_sum.sort_values("pub_id", ascending = False).head(10)
#...then order by pct for purposes of plot
marker_sum = marker_sum.sort_values("pct", ascending = False)

marker_sum
```





  <div id="df-4350d97e-79bb-4565-bc81-b60c112b34a6">
    <div class="colab-df-container">
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
      <th>org_id</th>
      <th>org_name</th>
      <th>tm</th>
      <th>pub_id</th>
      <th>pct</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>1730</th>
      <td>grid.38142.3c</td>
      <td>Harvard University (Cambridge)</td>
      <td>True</td>
      <td>15532</td>
      <td>85.797934</td>
    </tr>
    <tr>
      <th>1309</th>
      <td>grid.266102.1</td>
      <td>University of California, San Francisco (San F...</td>
      <td>True</td>
      <td>5955</td>
      <td>85.511200</td>
    </tr>
    <tr>
      <th>101</th>
      <td>grid.21107.35</td>
      <td>Johns Hopkins University (Baltimore)</td>
      <td>True</td>
      <td>8246</td>
      <td>84.800494</td>
    </tr>
    <tr>
      <th>3785</th>
      <td>grid.5386.8</td>
      <td>Cornell University (Ithaca)</td>
      <td>True</td>
      <td>5846</td>
      <td>83.765582</td>
    </tr>
    <tr>
      <th>1722</th>
      <td>grid.34477.33</td>
      <td>University of Washington (Seattle)</td>
      <td>True</td>
      <td>7825</td>
      <td>83.475571</td>
    </tr>
    <tr>
      <th>47</th>
      <td>grid.168010.e</td>
      <td>Stanford University (Stanford)</td>
      <td>True</td>
      <td>7731</td>
      <td>83.030824</td>
    </tr>
    <tr>
      <th>713</th>
      <td>grid.25879.31</td>
      <td>University of Pennsylvania (Philadelphia)</td>
      <td>True</td>
      <td>6571</td>
      <td>82.747765</td>
    </tr>
    <tr>
      <th>3647</th>
      <td>grid.47100.32</td>
      <td>Yale University (New Haven)</td>
      <td>True</td>
      <td>5992</td>
      <td>82.488987</td>
    </tr>
    <tr>
      <th>85</th>
      <td>grid.19006.3e</td>
      <td>University of California, Los Angeles (Los Ang...</td>
      <td>True</td>
      <td>6714</td>
      <td>82.329859</td>
    </tr>
    <tr>
      <th>115</th>
      <td>grid.214458.e</td>
      <td>University of Michigan–Ann Arbor (Ann Arbor)</td>
      <td>True</td>
      <td>7672</td>
      <td>80.301444</td>
    </tr>
  </tbody>
</table>
</div>
      <button class="colab-df-convert" onclick="convertToInteractive('df-4350d97e-79bb-4565-bc81-b60c112b34a6')"
              title="Convert this dataframe to an interactive table."
              style="display:none;">

  <svg xmlns="http://www.w3.org/2000/svg" height="24px"viewBox="0 0 24 24"
       width="24px">
    <path d="M0 0h24v24H0V0z" fill="none"/>
    <path d="M18.56 5.44l.94 2.06.94-2.06 2.06-.94-2.06-.94-.94-2.06-.94 2.06-2.06.94zm-11 1L8.5 8.5l.94-2.06 2.06-.94-2.06-.94L8.5 2.5l-.94 2.06-2.06.94zm10 10l.94 2.06.94-2.06 2.06-.94-2.06-.94-.94-2.06-.94 2.06-2.06.94z"/><path d="M17.41 7.96l-1.37-1.37c-.4-.4-.92-.59-1.43-.59-.52 0-1.04.2-1.43.59L10.3 9.45l-7.72 7.72c-.78.78-.78 2.05 0 2.83L4 21.41c.39.39.9.59 1.41.59.51 0 1.02-.2 1.41-.59l7.78-7.78 2.81-2.81c.8-.78.8-2.07 0-2.86zM5.41 20L4 18.59l7.72-7.72 1.47 1.35L5.41 20z"/>
  </svg>
      </button>

  <style>
    .colab-df-container {
      display:flex;
      flex-wrap:wrap;
      gap: 12px;
    }

    .colab-df-convert {
      background-color: #E8F0FE;
      border: none;
      border-radius: 50%;
      cursor: pointer;
      display: none;
      fill: #1967D2;
      height: 32px;
      padding: 0 0 0 0;
      width: 32px;
    }

    .colab-df-convert:hover {
      background-color: #E2EBFA;
      box-shadow: 0px 1px 2px rgba(60, 64, 67, 0.3), 0px 1px 3px 1px rgba(60, 64, 67, 0.15);
      fill: #174EA6;
    }

    [theme=dark] .colab-df-convert {
      background-color: #3B4455;
      fill: #D2E3FC;
    }

    [theme=dark] .colab-df-convert:hover {
      background-color: #434B5C;
      box-shadow: 0px 1px 3px 1px rgba(0, 0, 0, 0.15);
      filter: drop-shadow(0px 1px 2px rgba(0, 0, 0, 0.3));
      fill: #FFFFFF;
    }
  </style>

      <script>
        const buttonEl =
          document.querySelector('#df-4350d97e-79bb-4565-bc81-b60c112b34a6 button.colab-df-convert');
        buttonEl.style.display =
          google.colab.kernel.accessAllowed ? 'block' : 'none';

        async function convertToInteractive(key) {
          const element = document.querySelector('#df-4350d97e-79bb-4565-bc81-b60c112b34a6');
          const dataTable =
            await google.colab.kernel.invokeFunction('convertToInteractive',
                                                     [key], {});
          if (!dataTable) return;

          const docLinkHtml = 'Like what you see? Visit the ' +
            '<a target="_blank" href=https://colab.research.google.com/notebooks/data_table.ipynb>data table notebook</a>'
            + ' to learn more about interactive tables.';
          element.innerHTML = '';
          dataTable['output_type'] = 'display_data';
          await google.colab.output.renderOutput(dataTable, element);
          const docLink = document.createElement('div');
          docLink.innerHTML = docLinkHtml;
          element.appendChild(docLink);
        }
      </script>
    </div>
  </div>





```python
#plot the data
plot = px.bar(marker_sum, x = "pct", y = "org_name")
plot.show()
```


<html>
<head><meta charset="utf-8" /></head>
<body>
    <div>            <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-AMS-MML_SVG"></script><script type="text/javascript">if (window.MathJax && window.MathJax.Hub && window.MathJax.Hub.Config) {window.MathJax.Hub.Config({SVG: {font: "STIX-Web"}});}</script>                <script type="text/javascript">window.PlotlyConfig = {MathJaxConfig: 'local'};</script>
        <script src="https://cdn.plot.ly/plotly-2.18.2.min.js"></script>                <div id="49056c21-fc71-44d1-813f-6ac5ff6442fc" class="plotly-graph-div" style="height:525px; width:100%;"></div>            <script type="text/javascript">                                    window.PLOTLYENV=window.PLOTLYENV || {};                                    if (document.getElementById("49056c21-fc71-44d1-813f-6ac5ff6442fc")) {                    Plotly.newPlot(                        "49056c21-fc71-44d1-813f-6ac5ff6442fc",                        [{"alignmentgroup":"True","hovertemplate":"pct=%{x}<br>org_name=%{y}<extra></extra>","legendgroup":"","marker":{"color":"#636efa","pattern":{"shape":""}},"name":"","offsetgroup":"","orientation":"h","showlegend":false,"textposition":"auto","x":[85.79793404408109,85.51120045950603,84.80049362402303,83.76558246167073,83.47557072754427,83.03082375684674,82.74776476514293,82.48898678414096,82.32985898221949,80.30144442118484],"xaxis":"x","y":["Harvard University (Cambridge)","University of California, San Francisco (San Francisco)","Johns Hopkins University (Baltimore)","Cornell University (Ithaca)","University of Washington (Seattle)","Stanford University (Stanford)","University of Pennsylvania (Philadelphia)","Yale University (New Haven)","University of California, Los Angeles (Los Angeles)","University of Michigan\u2013Ann Arbor (Ann Arbor)"],"yaxis":"y","type":"bar"}],                        {"template":{"data":{"histogram2dcontour":[{"type":"histogram2dcontour","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"choropleth":[{"type":"choropleth","colorbar":{"outlinewidth":0,"ticks":""}}],"histogram2d":[{"type":"histogram2d","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"heatmap":[{"type":"heatmap","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"heatmapgl":[{"type":"heatmapgl","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"contourcarpet":[{"type":"contourcarpet","colorbar":{"outlinewidth":0,"ticks":""}}],"contour":[{"type":"contour","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"surface":[{"type":"surface","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"mesh3d":[{"type":"mesh3d","colorbar":{"outlinewidth":0,"ticks":""}}],"scatter":[{"fillpattern":{"fillmode":"overlay","size":10,"solidity":0.2},"type":"scatter"}],"parcoords":[{"type":"parcoords","line":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scatterpolargl":[{"type":"scatterpolargl","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"bar":[{"error_x":{"color":"#2a3f5f"},"error_y":{"color":"#2a3f5f"},"marker":{"line":{"color":"#E5ECF6","width":0.5},"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"bar"}],"scattergeo":[{"type":"scattergeo","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scatterpolar":[{"type":"scatterpolar","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"histogram":[{"marker":{"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"histogram"}],"scattergl":[{"type":"scattergl","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scatter3d":[{"type":"scatter3d","line":{"colorbar":{"outlinewidth":0,"ticks":""}},"marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scattermapbox":[{"type":"scattermapbox","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scatterternary":[{"type":"scatterternary","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scattercarpet":[{"type":"scattercarpet","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"carpet":[{"aaxis":{"endlinecolor":"#2a3f5f","gridcolor":"white","linecolor":"white","minorgridcolor":"white","startlinecolor":"#2a3f5f"},"baxis":{"endlinecolor":"#2a3f5f","gridcolor":"white","linecolor":"white","minorgridcolor":"white","startlinecolor":"#2a3f5f"},"type":"carpet"}],"table":[{"cells":{"fill":{"color":"#EBF0F8"},"line":{"color":"white"}},"header":{"fill":{"color":"#C8D4E3"},"line":{"color":"white"}},"type":"table"}],"barpolar":[{"marker":{"line":{"color":"#E5ECF6","width":0.5},"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"barpolar"}],"pie":[{"automargin":true,"type":"pie"}]},"layout":{"autotypenumbers":"strict","colorway":["#636efa","#EF553B","#00cc96","#ab63fa","#FFA15A","#19d3f3","#FF6692","#B6E880","#FF97FF","#FECB52"],"font":{"color":"#2a3f5f"},"hovermode":"closest","hoverlabel":{"align":"left"},"paper_bgcolor":"white","plot_bgcolor":"#E5ECF6","polar":{"bgcolor":"#E5ECF6","angularaxis":{"gridcolor":"white","linecolor":"white","ticks":""},"radialaxis":{"gridcolor":"white","linecolor":"white","ticks":""}},"ternary":{"bgcolor":"#E5ECF6","aaxis":{"gridcolor":"white","linecolor":"white","ticks":""},"baxis":{"gridcolor":"white","linecolor":"white","ticks":""},"caxis":{"gridcolor":"white","linecolor":"white","ticks":""}},"coloraxis":{"colorbar":{"outlinewidth":0,"ticks":""}},"colorscale":{"sequential":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"sequentialminus":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"diverging":[[0,"#8e0152"],[0.1,"#c51b7d"],[0.2,"#de77ae"],[0.3,"#f1b6da"],[0.4,"#fde0ef"],[0.5,"#f7f7f7"],[0.6,"#e6f5d0"],[0.7,"#b8e186"],[0.8,"#7fbc41"],[0.9,"#4d9221"],[1,"#276419"]]},"xaxis":{"gridcolor":"white","linecolor":"white","ticks":"","title":{"standoff":15},"zerolinecolor":"white","automargin":true,"zerolinewidth":2},"yaxis":{"gridcolor":"white","linecolor":"white","ticks":"","title":{"standoff":15},"zerolinecolor":"white","automargin":true,"zerolinewidth":2},"scene":{"xaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white","gridwidth":2},"yaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white","gridwidth":2},"zaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white","gridwidth":2}},"shapedefaults":{"line":{"color":"#2a3f5f"}},"annotationdefaults":{"arrowcolor":"#2a3f5f","arrowhead":0,"arrowwidth":1},"geo":{"bgcolor":"white","landcolor":"#E5ECF6","subunitcolor":"white","showland":true,"showlakes":true,"lakecolor":"white"},"title":{"x":0.05},"mapbox":{"style":"light"}}},"xaxis":{"anchor":"y","domain":[0.0,1.0],"title":{"text":"pct"}},"yaxis":{"anchor":"x","domain":[0.0,1.0],"title":{"text":"org_name"}},"legend":{"tracegroupgap":0},"margin":{"t":60},"barmode":"relative"},                        {"responsive": true}                    ).then(function(){

var gd = document.getElementById('49056c21-fc71-44d1-813f-6ac5ff6442fc');
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

                        })                };                            </script>        </div>
</body>
</html>


## 4. Author contributions to articles
You can go beyond just the 'basic' Trust Markers with Dimensions Research Integrity. You can also look at related data, such as recorded contributions to papers by individuals, or at which repositories data is being deposited in.

Let's take a look at author contributions by research categorisation (note: articles falling under multiple categories will be counted once in each category. Articles mentioning the same verb more than once are only counted once per category). This will help understand acknowledgement patterns in research and possibly identify discipline areas where practice is 'ahead of the curve'.


```python
%%bigquery cont_df

SELECT
    p.year,
    cat.name,
    contributor_verbs,
    COUNT(DISTINCT p.id) publications
FROM dimensions-ai.data_analytics.publications p,
    UNNEST(category_for.first_level.full) cat
INNER JOIN `dimensions-ai-integrity.data.trust_markers` tm
    ON p.id = tm.id,
    UNNEST(tm.authors.author_roles.keywords) contributor_verbs
WHERE  p.type= 'article' and p.year between 2011 and 2022
group by 1, 2, 3
```


    Query is running:   0%|          |



    Downloading:   0%|          |



```python
#see what we get
cont_df.head(5)
```





  <div id="df-945121b3-d838-4e96-882e-6afa1413ca58">
    <div class="colab-df-container">
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
      <th>name</th>
      <th>contributor_verbs</th>
      <th>publications</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>2021</td>
      <td>Biomedical And Clinical Sciences</td>
      <td>using</td>
      <td>2733</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2016</td>
      <td>Biomedical And Clinical Sciences</td>
      <td>using</td>
      <td>1108</td>
    </tr>
    <tr>
      <th>2</th>
      <td>2022</td>
      <td>Psychology</td>
      <td>using</td>
      <td>315</td>
    </tr>
    <tr>
      <th>3</th>
      <td>2015</td>
      <td>Biomedical And Clinical Sciences</td>
      <td>using</td>
      <td>723</td>
    </tr>
    <tr>
      <th>4</th>
      <td>2021</td>
      <td>Agricultural, Veterinary And Food Sciences</td>
      <td>using</td>
      <td>456</td>
    </tr>
  </tbody>
</table>
</div>
      <button class="colab-df-convert" onclick="convertToInteractive('df-945121b3-d838-4e96-882e-6afa1413ca58')"
              title="Convert this dataframe to an interactive table."
              style="display:none;">

  <svg xmlns="http://www.w3.org/2000/svg" height="24px"viewBox="0 0 24 24"
       width="24px">
    <path d="M0 0h24v24H0V0z" fill="none"/>
    <path d="M18.56 5.44l.94 2.06.94-2.06 2.06-.94-2.06-.94-.94-2.06-.94 2.06-2.06.94zm-11 1L8.5 8.5l.94-2.06 2.06-.94-2.06-.94L8.5 2.5l-.94 2.06-2.06.94zm10 10l.94 2.06.94-2.06 2.06-.94-2.06-.94-.94-2.06-.94 2.06-2.06.94z"/><path d="M17.41 7.96l-1.37-1.37c-.4-.4-.92-.59-1.43-.59-.52 0-1.04.2-1.43.59L10.3 9.45l-7.72 7.72c-.78.78-.78 2.05 0 2.83L4 21.41c.39.39.9.59 1.41.59.51 0 1.02-.2 1.41-.59l7.78-7.78 2.81-2.81c.8-.78.8-2.07 0-2.86zM5.41 20L4 18.59l7.72-7.72 1.47 1.35L5.41 20z"/>
  </svg>
      </button>

  <style>
    .colab-df-container {
      display:flex;
      flex-wrap:wrap;
      gap: 12px;
    }

    .colab-df-convert {
      background-color: #E8F0FE;
      border: none;
      border-radius: 50%;
      cursor: pointer;
      display: none;
      fill: #1967D2;
      height: 32px;
      padding: 0 0 0 0;
      width: 32px;
    }

    .colab-df-convert:hover {
      background-color: #E2EBFA;
      box-shadow: 0px 1px 2px rgba(60, 64, 67, 0.3), 0px 1px 3px 1px rgba(60, 64, 67, 0.15);
      fill: #174EA6;
    }

    [theme=dark] .colab-df-convert {
      background-color: #3B4455;
      fill: #D2E3FC;
    }

    [theme=dark] .colab-df-convert:hover {
      background-color: #434B5C;
      box-shadow: 0px 1px 3px 1px rgba(0, 0, 0, 0.15);
      filter: drop-shadow(0px 1px 2px rgba(0, 0, 0, 0.3));
      fill: #FFFFFF;
    }
  </style>

      <script>
        const buttonEl =
          document.querySelector('#df-945121b3-d838-4e96-882e-6afa1413ca58 button.colab-df-convert');
        buttonEl.style.display =
          google.colab.kernel.accessAllowed ? 'block' : 'none';

        async function convertToInteractive(key) {
          const element = document.querySelector('#df-945121b3-d838-4e96-882e-6afa1413ca58');
          const dataTable =
            await google.colab.kernel.invokeFunction('convertToInteractive',
                                                     [key], {});
          if (!dataTable) return;

          const docLinkHtml = 'Like what you see? Visit the ' +
            '<a target="_blank" href=https://colab.research.google.com/notebooks/data_table.ipynb>data table notebook</a>'
            + ' to learn more about interactive tables.';
          element.innerHTML = '';
          dataTable['output_type'] = 'display_data';
          await google.colab.output.renderOutput(dataTable, element);
          const docLink = document.createElement('div');
          docLink.innerHTML = docLinkHtml;
          element.appendChild(docLink);
        }
      </script>
    </div>
  </div>




There are a lot of variables (field and verbs) here and we can't visualise them all in one go. Instead, let's identify the top five verbs and six fields (by number of publications) and stick with just those for now.


```python
#get the most common verbs
common_verbs = (cont_df.
                groupby(["contributor_verbs"], as_index = False).
                agg({"publications": "sum"}).
                sort_values("publications", ascending = False).
                head(5)
                )["contributor_verbs"].to_list()

common_verbs
```




    ['performed', 'wrote', 'designed', 'contributed', 'approved']




```python
#and the most common fields
common_fields = (cont_df.
                groupby(["name"], as_index = False).
                agg({"publications": "sum"}).
                sort_values("publications", ascending = False).
                head(6)
                )["name"].to_list()

common_fields
```




    ['Biomedical And Clinical Sciences',
     'Biological Sciences',
     'Engineering',
     'Health Sciences',
     'Chemical Sciences',
     'Agricultural, Veterinary And Food Sciences']




```python
#filter the data accordingly and sort
cont_df = cont_df[(cont_df["contributor_verbs"].isin(common_verbs)) & (cont_df["name"].isin(common_fields))].sort_values("year")

#and now plot the results
plot = px.line(
    cont_df,
    x = "year",
    y = "publications",
    color = "contributor_verbs",
    facet_col = "name",
    facet_col_wrap = 3
)
plot.show()
```


<html>
<head><meta charset="utf-8" /></head>
<body>
    <div>            <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-AMS-MML_SVG"></script><script type="text/javascript">if (window.MathJax && window.MathJax.Hub && window.MathJax.Hub.Config) {window.MathJax.Hub.Config({SVG: {font: "STIX-Web"}});}</script>                <script type="text/javascript">window.PlotlyConfig = {MathJaxConfig: 'local'};</script>
        <script src="https://cdn.plot.ly/plotly-2.18.2.min.js"></script>                <div id="25efd650-69bd-4c0c-a99a-0ac3b03e67cd" class="plotly-graph-div" style="height:525px; width:100%;"></div>            <script type="text/javascript">                                    window.PLOTLYENV=window.PLOTLYENV || {};                                    if (document.getElementById("25efd650-69bd-4c0c-a99a-0ac3b03e67cd")) {                    Plotly.newPlot(                        "25efd650-69bd-4c0c-a99a-0ac3b03e67cd",                        [{"hovertemplate":"contributor_verbs=designed<br>name=Engineering<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"designed","line":{"color":"#636efa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"designed","orientation":"v","showlegend":true,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x4","y":[861,1380,2414,3311,5723,8607,12057,13758,11558,12595,12113,12479],"yaxis":"y4","type":"scatter"},{"hovertemplate":"contributor_verbs=designed<br>name=Biomedical And Clinical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"designed","line":{"color":"#636efa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"designed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x5","y":[15171,22400,30336,32837,37739,37973,38436,42895,47782,57381,65233,65204],"yaxis":"y5","type":"scatter"},{"hovertemplate":"contributor_verbs=designed<br>name=Chemical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"designed","line":{"color":"#636efa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"designed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x6","y":[1126,1743,2589,3321,5394,7098,8799,10463,10236,10785,11830,12239],"yaxis":"y6","type":"scatter"},{"hovertemplate":"contributor_verbs=designed<br>name=Biological Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"designed","line":{"color":"#636efa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"designed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x","y":[15418,20917,26693,27837,33440,35520,33729,35763,38780,42364,46366,44778],"yaxis":"y","type":"scatter"},{"hovertemplate":"contributor_verbs=designed<br>name=Agricultural, Veterinary And Food Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"designed","line":{"color":"#636efa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"designed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x2","y":[998,1911,2786,3491,4636,5069,4840,5801,7137,8841,10029,10311],"yaxis":"y2","type":"scatter"},{"hovertemplate":"contributor_verbs=designed<br>name=Health Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"designed","line":{"color":"#636efa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"designed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x3","y":[2394,3761,5639,6487,7754,7309,6200,7204,8133,10177,11662,12023],"yaxis":"y3","type":"scatter"},{"hovertemplate":"contributor_verbs=performed<br>name=Engineering<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"performed","line":{"color":"#EF553B","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"performed","orientation":"v","showlegend":true,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x4","y":[961,1530,2679,3744,6452,9616,13196,14835,13299,15179,16083,18236],"yaxis":"y4","type":"scatter"},{"hovertemplate":"contributor_verbs=performed<br>name=Biomedical And Clinical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"performed","line":{"color":"#EF553B","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"performed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x5","y":[17357,25847,33683,36752,41700,41245,40210,44682,49842,59821,70488,71837],"yaxis":"y5","type":"scatter"},{"hovertemplate":"contributor_verbs=performed<br>name=Chemical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"performed","line":{"color":"#EF553B","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"performed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x6","y":[1184,1853,2807,3790,6142,8160,10075,11978,12247,13366,15509,17093],"yaxis":"y6","type":"scatter"},{"hovertemplate":"contributor_verbs=performed<br>name=Biological Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"performed","line":{"color":"#EF553B","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"performed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x","y":[16162,21609,27545,29167,34976,36986,34816,37081,40259,44639,49756,49706],"yaxis":"y","type":"scatter"},{"hovertemplate":"contributor_verbs=performed<br>name=Agricultural, Veterinary And Food Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"performed","line":{"color":"#EF553B","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"performed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x2","y":[1064,1995,2844,3506,4427,4807,4434,5127,6570,8393,9769,10397],"yaxis":"y2","type":"scatter"},{"hovertemplate":"contributor_verbs=performed<br>name=Health Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"performed","line":{"color":"#EF553B","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"performed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x3","y":[2624,3730,5232,5948,7099,6253,4717,5256,5796,7532,9487,9987],"yaxis":"y3","type":"scatter"},{"hovertemplate":"contributor_verbs=wrote<br>name=Engineering<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"wrote","line":{"color":"#00cc96","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"wrote","orientation":"v","showlegend":true,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x4","y":[830,1383,2444,3238,6378,9477,13145,15224,13598,15177,15348,16069],"yaxis":"y4","type":"scatter"},{"hovertemplate":"contributor_verbs=wrote<br>name=Biomedical And Clinical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"wrote","line":{"color":"#00cc96","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"wrote","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x5","y":[15203,22498,29903,29987,37720,37785,37132,40874,45452,55566,65083,67174],"yaxis":"y5","type":"scatter"},{"hovertemplate":"contributor_verbs=wrote<br>name=Chemical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"wrote","line":{"color":"#00cc96","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"wrote","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x6","y":[1133,1751,2617,3312,5785,7688,9153,10519,10474,11559,13148,14371],"yaxis":"y6","type":"scatter"},{"hovertemplate":"contributor_verbs=wrote<br>name=Biological Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"wrote","line":{"color":"#00cc96","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"wrote","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x","y":[15621,20979,26568,25920,34827,37581,35844,36387,39422,44009,48868,47377],"yaxis":"y","type":"scatter"},{"hovertemplate":"contributor_verbs=wrote<br>name=Agricultural, Veterinary And Food Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"wrote","line":{"color":"#00cc96","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"wrote","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x2","y":[964,1812,2643,2888,4420,4878,4635,5201,6455,8261,9783,10320],"yaxis":"y2","type":"scatter"},{"hovertemplate":"contributor_verbs=wrote<br>name=Health Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"wrote","line":{"color":"#00cc96","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"wrote","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x3","y":[2297,3741,5426,5821,7485,6832,5438,6185,7138,9203,10768,11829],"yaxis":"y3","type":"scatter"},{"hovertemplate":"contributor_verbs=contributed<br>name=Engineering<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"contributed","line":{"color":"#ab63fa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"contributed","orientation":"v","showlegend":true,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x4","y":[995,1713,2709,3959,6390,8435,10894,13186,13676,16534,19145,22579],"yaxis":"y4","type":"scatter"},{"hovertemplate":"contributor_verbs=contributed<br>name=Biomedical And Clinical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"contributed","line":{"color":"#ab63fa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"contributed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x5","y":[12848,18930,25410,29421,32439,31477,29526,34023,39920,55927,75971,85951],"yaxis":"y5","type":"scatter"},{"hovertemplate":"contributor_verbs=contributed<br>name=Chemical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"contributed","line":{"color":"#ab63fa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"contributed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x6","y":[1434,2485,3571,4661,5942,7461,9046,10895,12024,13883,16138,17814],"yaxis":"y6","type":"scatter"},{"hovertemplate":"contributor_verbs=contributed<br>name=Biological Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"contributed","line":{"color":"#ab63fa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"contributed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x","y":[10670,14811,18439,19533,21110,20114,16549,18066,20228,24463,31007,33158],"yaxis":"y","type":"scatter"},{"hovertemplate":"contributor_verbs=contributed<br>name=Agricultural, Veterinary And Food Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"contributed","line":{"color":"#ab63fa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"contributed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x2","y":[843,1509,2189,2818,3509,3298,2742,3384,4490,6012,8048,9865],"yaxis":"y2","type":"scatter"},{"hovertemplate":"contributor_verbs=contributed<br>name=Health Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"contributed","line":{"color":"#ab63fa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"contributed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x3","y":[2893,4238,5994,7205,8505,8427,7747,9034,10432,14314,18237,21096],"yaxis":"y3","type":"scatter"},{"hovertemplate":"contributor_verbs=approved<br>name=Engineering<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"approved","line":{"color":"#FFA15A","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"approved","orientation":"v","showlegend":true,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x4","y":[535,917,1184,1490,2032,2656,3346,4466,5064,6484,9216,12405],"yaxis":"y4","type":"scatter"},{"hovertemplate":"contributor_verbs=approved<br>name=Biomedical And Clinical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"approved","line":{"color":"#FFA15A","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"approved","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x5","y":[11419,15061,19200,23989,28659,31555,36414,44515,54008,74022,100388,111296],"yaxis":"y5","type":"scatter"},{"hovertemplate":"contributor_verbs=approved<br>name=Chemical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"approved","line":{"color":"#FFA15A","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"approved","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x6","y":[146,302,475,514,1351,1784,2314,3821,4435,5092,6057,6490],"yaxis":"y6","type":"scatter"},{"hovertemplate":"contributor_verbs=approved<br>name=Biological Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"approved","line":{"color":"#FFA15A","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"approved","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x","y":[5317,5633,7234,8743,11703,14447,16099,19437,23871,29746,38263,39753],"yaxis":"y","type":"scatter"},{"hovertemplate":"contributor_verbs=approved<br>name=Agricultural, Veterinary And Food Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"approved","line":{"color":"#FFA15A","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"approved","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x2","y":[392,664,884,1241,1793,2486,2965,3977,5552,7611,10349,12235],"yaxis":"y2","type":"scatter"},{"hovertemplate":"contributor_verbs=approved<br>name=Health Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"approved","line":{"color":"#FFA15A","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"approved","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x3","y":[4196,5338,6965,8417,9807,10504,11975,13948,16201,20847,26067,30030],"yaxis":"y3","type":"scatter"}],                        {"template":{"data":{"histogram2dcontour":[{"type":"histogram2dcontour","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"choropleth":[{"type":"choropleth","colorbar":{"outlinewidth":0,"ticks":""}}],"histogram2d":[{"type":"histogram2d","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"heatmap":[{"type":"heatmap","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"heatmapgl":[{"type":"heatmapgl","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"contourcarpet":[{"type":"contourcarpet","colorbar":{"outlinewidth":0,"ticks":""}}],"contour":[{"type":"contour","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"surface":[{"type":"surface","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"mesh3d":[{"type":"mesh3d","colorbar":{"outlinewidth":0,"ticks":""}}],"scatter":[{"fillpattern":{"fillmode":"overlay","size":10,"solidity":0.2},"type":"scatter"}],"parcoords":[{"type":"parcoords","line":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scatterpolargl":[{"type":"scatterpolargl","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"bar":[{"error_x":{"color":"#2a3f5f"},"error_y":{"color":"#2a3f5f"},"marker":{"line":{"color":"#E5ECF6","width":0.5},"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"bar"}],"scattergeo":[{"type":"scattergeo","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scatterpolar":[{"type":"scatterpolar","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"histogram":[{"marker":{"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"histogram"}],"scattergl":[{"type":"scattergl","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scatter3d":[{"type":"scatter3d","line":{"colorbar":{"outlinewidth":0,"ticks":""}},"marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scattermapbox":[{"type":"scattermapbox","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scatterternary":[{"type":"scatterternary","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scattercarpet":[{"type":"scattercarpet","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"carpet":[{"aaxis":{"endlinecolor":"#2a3f5f","gridcolor":"white","linecolor":"white","minorgridcolor":"white","startlinecolor":"#2a3f5f"},"baxis":{"endlinecolor":"#2a3f5f","gridcolor":"white","linecolor":"white","minorgridcolor":"white","startlinecolor":"#2a3f5f"},"type":"carpet"}],"table":[{"cells":{"fill":{"color":"#EBF0F8"},"line":{"color":"white"}},"header":{"fill":{"color":"#C8D4E3"},"line":{"color":"white"}},"type":"table"}],"barpolar":[{"marker":{"line":{"color":"#E5ECF6","width":0.5},"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"barpolar"}],"pie":[{"automargin":true,"type":"pie"}]},"layout":{"autotypenumbers":"strict","colorway":["#636efa","#EF553B","#00cc96","#ab63fa","#FFA15A","#19d3f3","#FF6692","#B6E880","#FF97FF","#FECB52"],"font":{"color":"#2a3f5f"},"hovermode":"closest","hoverlabel":{"align":"left"},"paper_bgcolor":"white","plot_bgcolor":"#E5ECF6","polar":{"bgcolor":"#E5ECF6","angularaxis":{"gridcolor":"white","linecolor":"white","ticks":""},"radialaxis":{"gridcolor":"white","linecolor":"white","ticks":""}},"ternary":{"bgcolor":"#E5ECF6","aaxis":{"gridcolor":"white","linecolor":"white","ticks":""},"baxis":{"gridcolor":"white","linecolor":"white","ticks":""},"caxis":{"gridcolor":"white","linecolor":"white","ticks":""}},"coloraxis":{"colorbar":{"outlinewidth":0,"ticks":""}},"colorscale":{"sequential":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"sequentialminus":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"diverging":[[0,"#8e0152"],[0.1,"#c51b7d"],[0.2,"#de77ae"],[0.3,"#f1b6da"],[0.4,"#fde0ef"],[0.5,"#f7f7f7"],[0.6,"#e6f5d0"],[0.7,"#b8e186"],[0.8,"#7fbc41"],[0.9,"#4d9221"],[1,"#276419"]]},"xaxis":{"gridcolor":"white","linecolor":"white","ticks":"","title":{"standoff":15},"zerolinecolor":"white","automargin":true,"zerolinewidth":2},"yaxis":{"gridcolor":"white","linecolor":"white","ticks":"","title":{"standoff":15},"zerolinecolor":"white","automargin":true,"zerolinewidth":2},"scene":{"xaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white","gridwidth":2},"yaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white","gridwidth":2},"zaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white","gridwidth":2}},"shapedefaults":{"line":{"color":"#2a3f5f"}},"annotationdefaults":{"arrowcolor":"#2a3f5f","arrowhead":0,"arrowwidth":1},"geo":{"bgcolor":"white","landcolor":"#E5ECF6","subunitcolor":"white","showland":true,"showlakes":true,"lakecolor":"white"},"title":{"x":0.05},"mapbox":{"style":"light"}}},"xaxis":{"anchor":"y","domain":[0.0,0.31999999999999995],"title":{"text":"year"}},"yaxis":{"anchor":"x","domain":[0.0,0.46499999999999997],"title":{"text":"publications"}},"xaxis2":{"anchor":"y2","domain":[0.33999999999999997,0.6599999999999999],"matches":"x","title":{"text":"year"}},"yaxis2":{"anchor":"x2","domain":[0.0,0.46499999999999997],"matches":"y","showticklabels":false},"xaxis3":{"anchor":"y3","domain":[0.6799999999999999,0.9999999999999999],"matches":"x","title":{"text":"year"}},"yaxis3":{"anchor":"x3","domain":[0.0,0.46499999999999997],"matches":"y","showticklabels":false},"xaxis4":{"anchor":"y4","domain":[0.0,0.31999999999999995],"matches":"x","showticklabels":false},"yaxis4":{"anchor":"x4","domain":[0.5349999999999999,0.9999999999999999],"matches":"y","title":{"text":"publications"}},"xaxis5":{"anchor":"y5","domain":[0.33999999999999997,0.6599999999999999],"matches":"x","showticklabels":false},"yaxis5":{"anchor":"x5","domain":[0.5349999999999999,0.9999999999999999],"matches":"y","showticklabels":false},"xaxis6":{"anchor":"y6","domain":[0.6799999999999999,0.9999999999999999],"matches":"x","showticklabels":false},"yaxis6":{"anchor":"x6","domain":[0.5349999999999999,0.9999999999999999],"matches":"y","showticklabels":false},"annotations":[{"font":{},"showarrow":false,"text":"name=Biological Sciences","x":0.15999999999999998,"xanchor":"center","xref":"paper","y":0.46499999999999997,"yanchor":"bottom","yref":"paper"},{"font":{},"showarrow":false,"text":"name=Agricultural, Veterinary And Food Sciences","x":0.49999999999999994,"xanchor":"center","xref":"paper","y":0.46499999999999997,"yanchor":"bottom","yref":"paper"},{"font":{},"showarrow":false,"text":"name=Health Sciences","x":0.8399999999999999,"xanchor":"center","xref":"paper","y":0.46499999999999997,"yanchor":"bottom","yref":"paper"},{"font":{},"showarrow":false,"text":"name=Engineering","x":0.15999999999999998,"xanchor":"center","xref":"paper","y":0.9999999999999999,"yanchor":"bottom","yref":"paper"},{"font":{},"showarrow":false,"text":"name=Biomedical And Clinical Sciences","x":0.49999999999999994,"xanchor":"center","xref":"paper","y":0.9999999999999999,"yanchor":"bottom","yref":"paper"},{"font":{},"showarrow":false,"text":"name=Chemical Sciences","x":0.8399999999999999,"xanchor":"center","xref":"paper","y":0.9999999999999999,"yanchor":"bottom","yref":"paper"}],"legend":{"title":{"text":"contributor_verbs"},"tracegroupgap":0},"margin":{"t":60}},                        {"responsive": true}                    ).then(function(){

var gd = document.getElementById('25efd650-69bd-4c0c-a99a-0ac3b03e67cd');
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

                        })                };                            </script>        </div>
</body>
</html>


## 5. Repository usage
Now we'll take a look at how we can access the repositories data. Suppose we want to see the breadth of usage of specific repositories across work across funders and research orgs, to understand how wide the usage of the most common repositories is.


```python
%%bigquery repo_df

--the first two tables created by the WITH statements are needed to get full count of repositories based on names and URLs found
WITH
  common_keywords AS(
  SELECT
    kw,
    COUNT(DISTINCT id) AS pubs
  FROM `dimensions-ai-integrity.data.trust_markers` tm,
    UNNEST(tm.data.data_locations.repositories) kw
  GROUP BY 1
),
repositories AS(
  SELECT
  id,
  kw,
  'url' isin
    FROM `dimensions-ai-integrity.data.trust_markers` tm,
      UNNEST(tm.data.data_locations.repository_urls) url
    INNER JOIN common_keywords
      ON REGEXP_CONTAINS(REPLACE(url,'10.17632','mendeley'), LOWER(kw))
    UNION DISTINCT
      SELECT
        id,
          replace(
            replace(
              #replace(
                replace(kw,'open science framework','osf'),
              #'gene','geo'),
              'gene expression omnibus','geo'),
            'sequence read archive','sra') kw,
        'keyword' isin
        FROM `dimensions-ai-integrity.data.trust_markers` tm,
          UNNEST(tm.data.data_locations.repositories) kw
        WHERE kw != 'board'
        ),
  funders AS(
    SELECT
    pubs.id AS pub_id,
    fund.grid_id AS funder_id
    FROM `dimensions-ai.data_analytics.publications` pubs,
      UNNEST(funding_details) fund
    WHERE pubs.year = 2021
  ),
  orgs AS(
    SELECT
      pubs.id AS pub_id,
      org
    FROM `dimensions-ai.data_analytics.publications` pubs,
      UNNEST(research_orgs) org
    WHERE pubs.year = 2021
  ), combined AS(
  SELECT
    rep.id,
     CASE
        WHEN REGEXP_CONTAINS(rep.kw, 'github') THEN 'github'
        WHEN REGEXP_CONTAINS(rep.kw, 'osf') THEN 'osf'
        WHEN REGEXP_CONTAINS(rep.kw, 'ncbi') THEN 'ncbi'
        ELSE rep.kw
      END AS kw,
    f.funder_id AS funder,
    o.org AS ro
  FROM repositories rep
  INNER JOIN funders f
    ON rep.id = f.pub_id
  INNER JOIN orgs o
    ON rep.id = o.pub_id
  )
  SELECT
  kw,
  COUNT(DISTINCT funder) AS funders,
  COUNT(DISTINCT ro) AS orgs,
  COUNT(DISTINCT id) AS pubs
  FROM combined
  GROUP BY 1
  ORDER BY pubs DESC
  LIMIT 10
```


    Query is running:   0%|          |



    Downloading:   0%|          |



```python
#see what we've got
repo_df
```





  <div id="df-338dc8f7-c935-4eb7-b522-3c2c231be6f7">
    <div class="colab-df-container">
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
      <th>kw</th>
      <th>funders</th>
      <th>orgs</th>
      <th>pubs</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>ncbi</td>
      <td>1858</td>
      <td>7378</td>
      <td>16104</td>
    </tr>
    <tr>
      <th>1</th>
      <td>github</td>
      <td>1680</td>
      <td>6787</td>
      <td>13160</td>
    </tr>
    <tr>
      <th>2</th>
      <td>geo</td>
      <td>1456</td>
      <td>5115</td>
      <td>8802</td>
    </tr>
    <tr>
      <th>3</th>
      <td>zenodo</td>
      <td>1175</td>
      <td>4828</td>
      <td>6757</td>
    </tr>
    <tr>
      <th>4</th>
      <td>gene</td>
      <td>1429</td>
      <td>5311</td>
      <td>6441</td>
    </tr>
    <tr>
      <th>5</th>
      <td>bioproject</td>
      <td>1136</td>
      <td>4369</td>
      <td>5925</td>
    </tr>
    <tr>
      <th>6</th>
      <td>sra</td>
      <td>1172</td>
      <td>4292</td>
      <td>5817</td>
    </tr>
    <tr>
      <th>7</th>
      <td>genbank</td>
      <td>1025</td>
      <td>4123</td>
      <td>5019</td>
    </tr>
    <tr>
      <th>8</th>
      <td>figshare</td>
      <td>1164</td>
      <td>4422</td>
      <td>4683</td>
    </tr>
    <tr>
      <th>9</th>
      <td>impact</td>
      <td>1176</td>
      <td>4649</td>
      <td>3659</td>
    </tr>
  </tbody>
</table>
</div>
      <button class="colab-df-convert" onclick="convertToInteractive('df-338dc8f7-c935-4eb7-b522-3c2c231be6f7')"
              title="Convert this dataframe to an interactive table."
              style="display:none;">

  <svg xmlns="http://www.w3.org/2000/svg" height="24px"viewBox="0 0 24 24"
       width="24px">
    <path d="M0 0h24v24H0V0z" fill="none"/>
    <path d="M18.56 5.44l.94 2.06.94-2.06 2.06-.94-2.06-.94-.94-2.06-.94 2.06-2.06.94zm-11 1L8.5 8.5l.94-2.06 2.06-.94-2.06-.94L8.5 2.5l-.94 2.06-2.06.94zm10 10l.94 2.06.94-2.06 2.06-.94-2.06-.94-.94-2.06-.94 2.06-2.06.94z"/><path d="M17.41 7.96l-1.37-1.37c-.4-.4-.92-.59-1.43-.59-.52 0-1.04.2-1.43.59L10.3 9.45l-7.72 7.72c-.78.78-.78 2.05 0 2.83L4 21.41c.39.39.9.59 1.41.59.51 0 1.02-.2 1.41-.59l7.78-7.78 2.81-2.81c.8-.78.8-2.07 0-2.86zM5.41 20L4 18.59l7.72-7.72 1.47 1.35L5.41 20z"/>
  </svg>
      </button>

  <style>
    .colab-df-container {
      display:flex;
      flex-wrap:wrap;
      gap: 12px;
    }

    .colab-df-convert {
      background-color: #E8F0FE;
      border: none;
      border-radius: 50%;
      cursor: pointer;
      display: none;
      fill: #1967D2;
      height: 32px;
      padding: 0 0 0 0;
      width: 32px;
    }

    .colab-df-convert:hover {
      background-color: #E2EBFA;
      box-shadow: 0px 1px 2px rgba(60, 64, 67, 0.3), 0px 1px 3px 1px rgba(60, 64, 67, 0.15);
      fill: #174EA6;
    }

    [theme=dark] .colab-df-convert {
      background-color: #3B4455;
      fill: #D2E3FC;
    }

    [theme=dark] .colab-df-convert:hover {
      background-color: #434B5C;
      box-shadow: 0px 1px 3px 1px rgba(0, 0, 0, 0.15);
      filter: drop-shadow(0px 1px 2px rgba(0, 0, 0, 0.3));
      fill: #FFFFFF;
    }
  </style>

      <script>
        const buttonEl =
          document.querySelector('#df-338dc8f7-c935-4eb7-b522-3c2c231be6f7 button.colab-df-convert');
        buttonEl.style.display =
          google.colab.kernel.accessAllowed ? 'block' : 'none';

        async function convertToInteractive(key) {
          const element = document.querySelector('#df-338dc8f7-c935-4eb7-b522-3c2c231be6f7');
          const dataTable =
            await google.colab.kernel.invokeFunction('convertToInteractive',
                                                     [key], {});
          if (!dataTable) return;

          const docLinkHtml = 'Like what you see? Visit the ' +
            '<a target="_blank" href=https://colab.research.google.com/notebooks/data_table.ipynb>data table notebook</a>'
            + ' to learn more about interactive tables.';
          element.innerHTML = '';
          dataTable['output_type'] = 'display_data';
          await google.colab.output.renderOutput(dataTable, element);
          const docLink = document.createElement('div');
          docLink.innerHTML = docLinkHtml;
          element.appendChild(docLink);
        }
      </script>
    </div>
  </div>





```python
#plot
plot = px.scatter(
    repo_df,
    x = "funders",
    y = "orgs",
    hover_data = ["kw"]
)

plot.show()
```


<html>
<head><meta charset="utf-8" /></head>
<body>
    <div>            <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-AMS-MML_SVG"></script><script type="text/javascript">if (window.MathJax && window.MathJax.Hub && window.MathJax.Hub.Config) {window.MathJax.Hub.Config({SVG: {font: "STIX-Web"}});}</script>                <script type="text/javascript">window.PlotlyConfig = {MathJaxConfig: 'local'};</script>
        <script src="https://cdn.plot.ly/plotly-2.18.2.min.js"></script>                <div id="6ec355be-87fa-4847-a2bb-2ce8b77e8d44" class="plotly-graph-div" style="height:525px; width:100%;"></div>            <script type="text/javascript">                                    window.PLOTLYENV=window.PLOTLYENV || {};                                    if (document.getElementById("6ec355be-87fa-4847-a2bb-2ce8b77e8d44")) {                    Plotly.newPlot(                        "6ec355be-87fa-4847-a2bb-2ce8b77e8d44",                        [{"customdata":[["ncbi"],["github"],["geo"],["zenodo"],["gene"],["bioproject"],["sra"],["genbank"],["figshare"],["impact"]],"hovertemplate":"funders=%{x}<br>orgs=%{y}<br>kw=%{customdata[0]}<extra></extra>","legendgroup":"","marker":{"color":"#636efa","symbol":"circle"},"mode":"markers","name":"","orientation":"v","showlegend":false,"x":[1858,1680,1456,1175,1429,1136,1172,1025,1164,1176],"xaxis":"x","y":[7378,6787,5115,4828,5311,4369,4292,4123,4422,4649],"yaxis":"y","type":"scatter"}],                        {"template":{"data":{"histogram2dcontour":[{"type":"histogram2dcontour","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"choropleth":[{"type":"choropleth","colorbar":{"outlinewidth":0,"ticks":""}}],"histogram2d":[{"type":"histogram2d","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"heatmap":[{"type":"heatmap","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"heatmapgl":[{"type":"heatmapgl","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"contourcarpet":[{"type":"contourcarpet","colorbar":{"outlinewidth":0,"ticks":""}}],"contour":[{"type":"contour","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"surface":[{"type":"surface","colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]}],"mesh3d":[{"type":"mesh3d","colorbar":{"outlinewidth":0,"ticks":""}}],"scatter":[{"fillpattern":{"fillmode":"overlay","size":10,"solidity":0.2},"type":"scatter"}],"parcoords":[{"type":"parcoords","line":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scatterpolargl":[{"type":"scatterpolargl","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"bar":[{"error_x":{"color":"#2a3f5f"},"error_y":{"color":"#2a3f5f"},"marker":{"line":{"color":"#E5ECF6","width":0.5},"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"bar"}],"scattergeo":[{"type":"scattergeo","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scatterpolar":[{"type":"scatterpolar","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"histogram":[{"marker":{"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"histogram"}],"scattergl":[{"type":"scattergl","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scatter3d":[{"type":"scatter3d","line":{"colorbar":{"outlinewidth":0,"ticks":""}},"marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scattermapbox":[{"type":"scattermapbox","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scatterternary":[{"type":"scatterternary","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"scattercarpet":[{"type":"scattercarpet","marker":{"colorbar":{"outlinewidth":0,"ticks":""}}}],"carpet":[{"aaxis":{"endlinecolor":"#2a3f5f","gridcolor":"white","linecolor":"white","minorgridcolor":"white","startlinecolor":"#2a3f5f"},"baxis":{"endlinecolor":"#2a3f5f","gridcolor":"white","linecolor":"white","minorgridcolor":"white","startlinecolor":"#2a3f5f"},"type":"carpet"}],"table":[{"cells":{"fill":{"color":"#EBF0F8"},"line":{"color":"white"}},"header":{"fill":{"color":"#C8D4E3"},"line":{"color":"white"}},"type":"table"}],"barpolar":[{"marker":{"line":{"color":"#E5ECF6","width":0.5},"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"barpolar"}],"pie":[{"automargin":true,"type":"pie"}]},"layout":{"autotypenumbers":"strict","colorway":["#636efa","#EF553B","#00cc96","#ab63fa","#FFA15A","#19d3f3","#FF6692","#B6E880","#FF97FF","#FECB52"],"font":{"color":"#2a3f5f"},"hovermode":"closest","hoverlabel":{"align":"left"},"paper_bgcolor":"white","plot_bgcolor":"#E5ECF6","polar":{"bgcolor":"#E5ECF6","angularaxis":{"gridcolor":"white","linecolor":"white","ticks":""},"radialaxis":{"gridcolor":"white","linecolor":"white","ticks":""}},"ternary":{"bgcolor":"#E5ECF6","aaxis":{"gridcolor":"white","linecolor":"white","ticks":""},"baxis":{"gridcolor":"white","linecolor":"white","ticks":""},"caxis":{"gridcolor":"white","linecolor":"white","ticks":""}},"coloraxis":{"colorbar":{"outlinewidth":0,"ticks":""}},"colorscale":{"sequential":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"sequentialminus":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"diverging":[[0,"#8e0152"],[0.1,"#c51b7d"],[0.2,"#de77ae"],[0.3,"#f1b6da"],[0.4,"#fde0ef"],[0.5,"#f7f7f7"],[0.6,"#e6f5d0"],[0.7,"#b8e186"],[0.8,"#7fbc41"],[0.9,"#4d9221"],[1,"#276419"]]},"xaxis":{"gridcolor":"white","linecolor":"white","ticks":"","title":{"standoff":15},"zerolinecolor":"white","automargin":true,"zerolinewidth":2},"yaxis":{"gridcolor":"white","linecolor":"white","ticks":"","title":{"standoff":15},"zerolinecolor":"white","automargin":true,"zerolinewidth":2},"scene":{"xaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white","gridwidth":2},"yaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white","gridwidth":2},"zaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white","gridwidth":2}},"shapedefaults":{"line":{"color":"#2a3f5f"}},"annotationdefaults":{"arrowcolor":"#2a3f5f","arrowhead":0,"arrowwidth":1},"geo":{"bgcolor":"white","landcolor":"#E5ECF6","subunitcolor":"white","showland":true,"showlakes":true,"lakecolor":"white"},"title":{"x":0.05},"mapbox":{"style":"light"}}},"xaxis":{"anchor":"y","domain":[0.0,1.0],"title":{"text":"funders"}},"yaxis":{"anchor":"x","domain":[0.0,1.0],"title":{"text":"orgs"}},"legend":{"tracegroupgap":0},"margin":{"t":60}},                        {"responsive": true}                    ).then(function(){

var gd = document.getElementById('6ec355be-87fa-4847-a2bb-2ce8b77e8d44');
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

                        })                };                            </script>        </div>
</body>
</html>

