# Usage of trust markers in research

## Use case

'Trust markers' are indicators of integrity, professionalism and reproducibility in scientific research. They also highlight the level of research transparency within the document, and reduce the risks of allowing non-compliance to research integrity policies to go unobserved.

This notebook takes you through a few examples which address the above questions. It makes use of the [Dimensions Research Integrity Dataset](https://ripeta.com/solutions/dimensions-research-integrity/), an additional module to Dimensions on Google Big Query (GBQ).

Using the dataset, you can answer questions such as:

*   How many research articles use trust markers? 
*   How does coverage of trust markers differ across publishers, funders and research organisations?
* If researchers are using trust markers (eg, data availability statements), how many are putting their data in repositories (and which repositories)?

!!! warning "Prerequisites"
    In order to run this tutorial, please ensure that:

    * You have a valid [Dimensions on Google BigQuery account](https://www.dimensions.ai/products/bigquery/) and have [configured a Google Cloud project](https://docs.dimensions.ai/bigquery/gcp-setup.html#). This must include access to the Dimensions Research Integrity Dataset.
    * You have some basic familiarity with Python and [Jupyter notebooks](https://jupyter.org/).

## About trust markers

The trust markers in the Dataset represent the integrity and reproducibility of scientific research. Trust markers represent a contract between authors and readers that proper research practices have been observed. They also highlight the level of research transparency within the document, and reduce the risks of allowing non-compliance to research integrity policies to go unobserved.

Currently, the following trust markers are available via the dataset:

*   __Funding statement__: States if the author(s) of the paper were granted funding in order to conduct their research.
*   __Ethical approval statement__: _Standalone_ statement affirming that the conducted research has been carried out in an ethical fashion with proper consent from all participating parties.
*   __Competing interests statement__: Declares possible sources of bias, based on personal interests of the author(s) in the findings of the research. For example, the source of funding, past or present employers of the author(s), or the author(s) financial interests.
*   __Author contributions statement__: Details of each author’s role in the development and publication of the manuscript.
*   __Repositories__: The names of any research data repositories used by the author(s) to preserve, organize and facilitate access to study data.
*   __Data locations__: Locations where research data (raw or processed) can be accessed.
*   __Data availability statement__: A dedicated section of a scientific work indicating whether data from the research is available and where it can be found.
*   __Code availability statement__: States if and how one could gain access to the code used to conduct the study/research.


## Method
This notebook retrieves data about trust marker and publication data from Dimensions, the world's largest linked research information datatset. In particular the trust markers are taken from the DRI module.

To complete the analysis the following steps are taken:


1.   Connect to the Dimensions database.
2.   Gather information about general use of trust markers, broken down by publisher.
3.   Look at how usage of trust markers breaks down by research organisations in the US, by joining on data from [GRID](https://www.digital-science.com/resource/grid/).
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

#set up client
client = bigquery.Client(project = 'ds-ripeta-gbq') #replace 'project' with the required project associate with your account
```

## 2. Trust markers by publisher

### Write and run a query
In this instance we will limit data to 2022 and 10 publishers to keep things manageable.


```python
#write the query - we're limiting results here to keep things easy to follow
qry = client.query("""
SELECT
    p.publisher.name, 
    100 * COUNTIF(tm.data.data_availability_statement)/ COUNT(p.id) AS data_availability,
    100 * COUNTIF(tm.code.code_availability_statement)/COUNT(p.id) AS code_availability,
    100 * COUNTIF(tm.author_contributions.author_contributions_statement)/COUNT(p.id) AS author_contributions,
    100 * COUNTIF(tm.competing_interests.competing_interests_statement)/COUNT(p.id) AS competing_interests,
    100 * COUNTIF(tm.funding.funding_statement)/COUNT(p.id) AS funding_statement,
    #note here we are only counting articles with mesh terms of 'animal' or 'human' as if this criteria isn't met it is unlikely an ethics statement would be expected
    100 * COUNTIF((tm.ethics.ethics_approval_statement AND (('Humans' IN UNNEST(p.mesh_terms)) OR ('Animals' IN UNNEST(p.mesh_terms)))) )/
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





  <div id="df-7fc01556-b6dd-4467-a22b-6fd2ca929fe4">
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
      <th>competing_interests</th>
      <th>funding_statement</th>
      <th>ethics_approval</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Elsevier</td>
      <td>23.220141</td>
      <td>1.255325</td>
      <td>9.852915</td>
      <td>85.654392</td>
      <td>55.983485</td>
      <td>20.768440</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Springer Nature</td>
      <td>47.947094</td>
      <td>5.239463</td>
      <td>51.224349</td>
      <td>63.354514</td>
      <td>70.045505</td>
      <td>66.610701</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Wiley</td>
      <td>41.088111</td>
      <td>0.609560</td>
      <td>18.156035</td>
      <td>42.476518</td>
      <td>54.245125</td>
      <td>18.035888</td>
    </tr>
    <tr>
      <th>3</th>
      <td>MDPI</td>
      <td>90.374943</td>
      <td>0.825924</td>
      <td>98.102639</td>
      <td>92.952828</td>
      <td>96.745167</td>
      <td>14.255689</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Frontiers</td>
      <td>97.561644</td>
      <td>0.484786</td>
      <td>99.626311</td>
      <td>57.620222</td>
      <td>78.402516</td>
      <td>75.672164</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Institute of Electrical and Electronics Engine...</td>
      <td>0.423834</td>
      <td>0.548492</td>
      <td>0.265446</td>
      <td>4.599117</td>
      <td>3.783712</td>
      <td>5.615234</td>
    </tr>
    <tr>
      <th>6</th>
      <td>American Chemical Society (ACS)</td>
      <td>2.445753</td>
      <td>0.355457</td>
      <td>51.336057</td>
      <td>75.126886</td>
      <td>71.855271</td>
      <td>4.811294</td>
    </tr>
    <tr>
      <th>7</th>
      <td>Hindawi</td>
      <td>86.262373</td>
      <td>1.167437</td>
      <td>21.282875</td>
      <td>44.916294</td>
      <td>50.766539</td>
      <td>23.535921</td>
    </tr>
    <tr>
      <th>8</th>
      <td>Royal Society of Chemistry (RSC)</td>
      <td>6.180646</td>
      <td>0.328791</td>
      <td>44.383674</td>
      <td>79.058519</td>
      <td>76.175271</td>
      <td>14.142808</td>
    </tr>
    <tr>
      <th>9</th>
      <td>IOP Publishing</td>
      <td>28.083510</td>
      <td>0.314284</td>
      <td>2.292990</td>
      <td>38.624848</td>
      <td>43.797704</td>
      <td>19.267139</td>
    </tr>
  </tbody>
</table>
</div>
      <button class="colab-df-convert" onclick="convertToInteractive('df-7fc01556-b6dd-4467-a22b-6fd2ca929fe4')"
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
          document.querySelector('#df-7fc01556-b6dd-4467-a22b-6fd2ca929fe4 button.colab-df-convert');
        buttonEl.style.display =
          google.colab.kernel.accessAllowed ? 'block' : 'none';

        async function convertToInteractive(key) {
          const element = document.querySelector('#df-7fc01556-b6dd-4467-a22b-6fd2ca929fe4');
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
    value_vars = results.columns.tolist()[1:6],
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
    <div>            <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-AMS-MML_SVG"></script><script type="text/javascript">if (window.MathJax) {MathJax.Hub.Config({SVG: {font: "STIX-Web"}});}</script>                <script type="text/javascript">window.PlotlyConfig = {MathJaxConfig: 'local'};</script>
        <script src="https://cdn.plot.ly/plotly-2.8.3.min.js"></script>                <div id="8aa04bfe-d3f5-46fd-97c8-36539411f1cd" class="plotly-graph-div" style="height:525px; width:100%;"></div>            <script type="text/javascript">                                    window.PLOTLYENV=window.PLOTLYENV || {};                                    if (document.getElementById("8aa04bfe-d3f5-46fd-97c8-36539411f1cd")) {                    Plotly.newPlot(                        "8aa04bfe-d3f5-46fd-97c8-36539411f1cd",                        [{"colorscale":[[0.0,"rgb(247,251,255)"],[0.125,"rgb(222,235,247)"],[0.25,"rgb(198,219,239)"],[0.375,"rgb(158,202,225)"],[0.5,"rgb(107,174,214)"],[0.625,"rgb(66,146,198)"],[0.75,"rgb(33,113,181)"],[0.875,"rgb(8,81,156)"],[1.0,"rgb(8,48,107)"]],"x":["data_availability","data_availability","data_availability","data_availability","data_availability","data_availability","data_availability","data_availability","data_availability","data_availability","code_availability","code_availability","code_availability","code_availability","code_availability","code_availability","code_availability","code_availability","code_availability","code_availability","author_contributions","author_contributions","author_contributions","author_contributions","author_contributions","author_contributions","author_contributions","author_contributions","author_contributions","author_contributions","competing_interests","competing_interests","competing_interests","competing_interests","competing_interests","competing_interests","competing_interests","competing_interests","competing_interests","competing_interests","funding_statement","funding_statement","funding_statement","funding_statement","funding_statement","funding_statement","funding_statement","funding_statement","funding_statement","funding_statement"],"y":["Elsevier","Springer Nature","Wiley","MDPI","Frontiers","Institute of Electrical and Electronics Engineers (IEEE)","American Chemical Society (ACS)","Hindawi","Royal Society of Chemistry (RSC)","IOP Publishing","Elsevier","Springer Nature","Wiley","MDPI","Frontiers","Institute of Electrical and Electronics Engineers (IEEE)","American Chemical Society (ACS)","Hindawi","Royal Society of Chemistry (RSC)","IOP Publishing","Elsevier","Springer Nature","Wiley","MDPI","Frontiers","Institute of Electrical and Electronics Engineers (IEEE)","American Chemical Society (ACS)","Hindawi","Royal Society of Chemistry (RSC)","IOP Publishing","Elsevier","Springer Nature","Wiley","MDPI","Frontiers","Institute of Electrical and Electronics Engineers (IEEE)","American Chemical Society (ACS)","Hindawi","Royal Society of Chemistry (RSC)","IOP Publishing","Elsevier","Springer Nature","Wiley","MDPI","Frontiers","Institute of Electrical and Electronics Engineers (IEEE)","American Chemical Society (ACS)","Hindawi","Royal Society of Chemistry (RSC)","IOP Publishing"],"z":[23.220140624853713,47.94709400557669,41.088111375709836,90.37494338903058,97.56164423090796,0.4238344552480678,2.4457530903496205,86.26237300530178,6.180645569220069,28.083509717144505,1.2553249258021328,5.239462509372225,0.6095596642052669,0.8259242485638691,0.48478552568930444,0.5484916479680878,0.35545652289246116,1.1674371229334797,0.3287913755493029,0.3142838817266372,9.852915016524825,51.224349472564,18.15603464067563,98.10263866707983,99.62631115728117,0.26544649273321896,51.336056731568426,21.282874977147483,44.38367424362176,2.292989545250465,85.6543924201144,63.354513698133154,42.476517740397064,92.95282816485114,57.62022248192876,4.5991171337645005,75.12688559958973,44.91629449711405,79.0585185419367,38.62484766852671,55.98348453781985,70.04550495993698,54.24512510185647,96.74516721092651,78.40251626772857,3.783712437854723,71.85527083664915,50.76653869257489,76.17527109481205,43.79770380347637],"type":"heatmap"}],                        {"template":{"data":{"bar":[{"error_x":{"color":"#2a3f5f"},"error_y":{"color":"#2a3f5f"},"marker":{"line":{"color":"#E5ECF6","width":0.5},"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"bar"}],"barpolar":[{"marker":{"line":{"color":"#E5ECF6","width":0.5},"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"barpolar"}],"carpet":[{"aaxis":{"endlinecolor":"#2a3f5f","gridcolor":"white","linecolor":"white","minorgridcolor":"white","startlinecolor":"#2a3f5f"},"baxis":{"endlinecolor":"#2a3f5f","gridcolor":"white","linecolor":"white","minorgridcolor":"white","startlinecolor":"#2a3f5f"},"type":"carpet"}],"choropleth":[{"colorbar":{"outlinewidth":0,"ticks":""},"type":"choropleth"}],"contour":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"contour"}],"contourcarpet":[{"colorbar":{"outlinewidth":0,"ticks":""},"type":"contourcarpet"}],"heatmap":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"heatmap"}],"heatmapgl":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"heatmapgl"}],"histogram":[{"marker":{"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"histogram"}],"histogram2d":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"histogram2d"}],"histogram2dcontour":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"histogram2dcontour"}],"mesh3d":[{"colorbar":{"outlinewidth":0,"ticks":""},"type":"mesh3d"}],"parcoords":[{"line":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"parcoords"}],"pie":[{"automargin":true,"type":"pie"}],"scatter":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatter"}],"scatter3d":[{"line":{"colorbar":{"outlinewidth":0,"ticks":""}},"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatter3d"}],"scattercarpet":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scattercarpet"}],"scattergeo":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scattergeo"}],"scattergl":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scattergl"}],"scattermapbox":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scattermapbox"}],"scatterpolar":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatterpolar"}],"scatterpolargl":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatterpolargl"}],"scatterternary":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatterternary"}],"surface":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"surface"}],"table":[{"cells":{"fill":{"color":"#EBF0F8"},"line":{"color":"white"}},"header":{"fill":{"color":"#C8D4E3"},"line":{"color":"white"}},"type":"table"}]},"layout":{"annotationdefaults":{"arrowcolor":"#2a3f5f","arrowhead":0,"arrowwidth":1},"autotypenumbers":"strict","coloraxis":{"colorbar":{"outlinewidth":0,"ticks":""}},"colorscale":{"diverging":[[0,"#8e0152"],[0.1,"#c51b7d"],[0.2,"#de77ae"],[0.3,"#f1b6da"],[0.4,"#fde0ef"],[0.5,"#f7f7f7"],[0.6,"#e6f5d0"],[0.7,"#b8e186"],[0.8,"#7fbc41"],[0.9,"#4d9221"],[1,"#276419"]],"sequential":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"sequentialminus":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]},"colorway":["#636efa","#EF553B","#00cc96","#ab63fa","#FFA15A","#19d3f3","#FF6692","#B6E880","#FF97FF","#FECB52"],"font":{"color":"#2a3f5f"},"geo":{"bgcolor":"white","lakecolor":"white","landcolor":"#E5ECF6","showlakes":true,"showland":true,"subunitcolor":"white"},"hoverlabel":{"align":"left"},"hovermode":"closest","mapbox":{"style":"light"},"paper_bgcolor":"white","plot_bgcolor":"#E5ECF6","polar":{"angularaxis":{"gridcolor":"white","linecolor":"white","ticks":""},"bgcolor":"#E5ECF6","radialaxis":{"gridcolor":"white","linecolor":"white","ticks":""}},"scene":{"xaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","gridwidth":2,"linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white"},"yaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","gridwidth":2,"linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white"},"zaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","gridwidth":2,"linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white"}},"shapedefaults":{"line":{"color":"#2a3f5f"}},"ternary":{"aaxis":{"gridcolor":"white","linecolor":"white","ticks":""},"baxis":{"gridcolor":"white","linecolor":"white","ticks":""},"bgcolor":"#E5ECF6","caxis":{"gridcolor":"white","linecolor":"white","ticks":""}},"title":{"x":0.05},"xaxis":{"automargin":true,"gridcolor":"white","linecolor":"white","ticks":"","title":{"standoff":15},"zerolinecolor":"white","zerolinewidth":2},"yaxis":{"automargin":true,"gridcolor":"white","linecolor":"white","ticks":"","title":{"standoff":15},"zerolinecolor":"white","zerolinewidth":2}}}},                        {"responsive": true}                    ).then(function(){

var gd = document.getElementById('8aa04bfe-d3f5-46fd-97c8-36539411f1cd');
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


## 3. Trust markers by research org
There are plenty of other analyses we can carry out using DRI. We are also not obliged to pull in aggregated data - we can also pull in data 'row-by-row' and analyse further in Python. We'll do this in the next example to look at the proportion of articles using trust markers at US universities.

Note that this example is set up to work generally. In a notebook environment (like Colab or Jupyter) you can use magic commands to reduce the code down to just the query and store as a summary dataframe. Google has [guidance on doing this](https://cloud.google.com/bigquery/docs/visualize-jupyter). We will use this magic commands in future examples.


```python
%%bigquery markers_by_us_uni --project ds-ripeta-gbq 

SELECT
    p.id AS pub_id,
    p.year, 
    orgs AS org_id,
    CONCAT(g.name, ' (', g.address.city, ')') AS org_name,
    tm.data.data_availability_statement AS das,  
    tm.code.code_availability_statement AS cas,
    tm.author_contributions.author_contributions_statement AS auth_cont,
    tm.competing_interests.competing_interests_statement AS comp_int,
    tm.funding.funding_statement AS funding,
    CASE
      WHEN tm.ethics.ethics_approval_statement IS TRUE AND ('Humans' IN UNNEST(p.mesh_terms) OR 'Animals' IN UNNEST(p.mesh_terms)) THEN TRUE
      WHEN tm.ethics.ethics_approval_statement IS FALSE AND ('Humans' IN UNNEST(p.mesh_terms) OR 'Animals' IN UNNEST(p.mesh_terms)) THEN FALSE
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





  <div id="df-038be605-1d93-41d7-98ea-148d6944debf">
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
      <th>comp_int</th>
      <th>funding</th>
      <th>ethics</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>pub.1128274945</td>
      <td>2022</td>
      <td>grid.131063.6</td>
      <td>University of Notre Dame (Notre Dame)</td>
      <td>False</td>
      <td>False</td>
      <td>False</td>
      <td>False</td>
      <td>False</td>
      <td>&lt;NA&gt;</td>
    </tr>
    <tr>
      <th>1</th>
      <td>pub.1131474369</td>
      <td>2022</td>
      <td>grid.267627.0</td>
      <td>University of the Sciences (Philadelphia)</td>
      <td>False</td>
      <td>False</td>
      <td>True</td>
      <td>True</td>
      <td>False</td>
      <td>False</td>
    </tr>
    <tr>
      <th>2</th>
      <td>pub.1131474369</td>
      <td>2022</td>
      <td>grid.33489.35</td>
      <td>University of Delaware (Newark)</td>
      <td>False</td>
      <td>False</td>
      <td>True</td>
      <td>True</td>
      <td>False</td>
      <td>False</td>
    </tr>
    <tr>
      <th>3</th>
      <td>pub.1126087463</td>
      <td>2022</td>
      <td>grid.147455.6</td>
      <td>Carnegie Mellon University (Pittsburgh)</td>
      <td>False</td>
      <td>False</td>
      <td>False</td>
      <td>False</td>
      <td>False</td>
      <td>&lt;NA&gt;</td>
    </tr>
    <tr>
      <th>4</th>
      <td>pub.1107329658</td>
      <td>2022</td>
      <td>grid.266097.c</td>
      <td>University of California, Riverside (Riverside)</td>
      <td>True</td>
      <td>False</td>
      <td>False</td>
      <td>False</td>
      <td>True</td>
      <td>&lt;NA&gt;</td>
    </tr>
  </tbody>
</table>
</div>
      <button class="colab-df-convert" onclick="convertToInteractive('df-038be605-1d93-41d7-98ea-148d6944debf')"
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
          document.querySelector('#df-038be605-1d93-41d7-98ea-148d6944debf button.colab-df-convert');
        buttonEl.style.display =
          google.colab.kernel.accessAllowed ? 'block' : 'none';

        async function convertToInteractive(key) {
          const element = document.querySelector('#df-038be605-1d93-41d7-98ea-148d6944debf');
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
marker_cols = ["das", "cas", "auth_cont", "comp_int", "funding", "ethics"]

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





  <div id="df-71c3e3b7-fb46-4980-ac87-8568a72b2371">
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
      <th>1688</th>
      <td>grid.38142.3c</td>
      <td>Harvard University (Cambridge)</td>
      <td>True</td>
      <td>12198</td>
      <td>86.028634</td>
    </tr>
    <tr>
      <th>1275</th>
      <td>grid.266102.1</td>
      <td>University of California, San Francisco (San F...</td>
      <td>True</td>
      <td>4623</td>
      <td>85.865527</td>
    </tr>
    <tr>
      <th>101</th>
      <td>grid.21107.35</td>
      <td>Johns Hopkins University (Baltimore)</td>
      <td>True</td>
      <td>6354</td>
      <td>84.259382</td>
    </tr>
    <tr>
      <th>1680</th>
      <td>grid.34477.33</td>
      <td>University of Washington (Seattle)</td>
      <td>True</td>
      <td>6070</td>
      <td>84.025471</td>
    </tr>
    <tr>
      <th>3424</th>
      <td>grid.5386.8</td>
      <td>Cornell University (Ithaca)</td>
      <td>True</td>
      <td>4660</td>
      <td>83.363148</td>
    </tr>
    <tr>
      <th>47</th>
      <td>grid.168010.e</td>
      <td>Stanford University (Stanford)</td>
      <td>True</td>
      <td>6128</td>
      <td>82.979012</td>
    </tr>
    <tr>
      <th>85</th>
      <td>grid.19006.3e</td>
      <td>University of California, Los Angeles (Los Ang...</td>
      <td>True</td>
      <td>5245</td>
      <td>82.820148</td>
    </tr>
    <tr>
      <th>3295</th>
      <td>grid.47100.32</td>
      <td>Yale University (New Haven)</td>
      <td>True</td>
      <td>4667</td>
      <td>82.484977</td>
    </tr>
    <tr>
      <th>699</th>
      <td>grid.25879.31</td>
      <td>University of Pennsylvania (Philadelphia)</td>
      <td>True</td>
      <td>5177</td>
      <td>82.279085</td>
    </tr>
    <tr>
      <th>115</th>
      <td>grid.214458.e</td>
      <td>University of Michigan–Ann Arbor (Ann Arbor)</td>
      <td>True</td>
      <td>6045</td>
      <td>81.043035</td>
    </tr>
  </tbody>
</table>
</div>
      <button class="colab-df-convert" onclick="convertToInteractive('df-71c3e3b7-fb46-4980-ac87-8568a72b2371')"
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
          document.querySelector('#df-71c3e3b7-fb46-4980-ac87-8568a72b2371 button.colab-df-convert');
        buttonEl.style.display =
          google.colab.kernel.accessAllowed ? 'block' : 'none';

        async function convertToInteractive(key) {
          const element = document.querySelector('#df-71c3e3b7-fb46-4980-ac87-8568a72b2371');
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
    <div>            <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-AMS-MML_SVG"></script><script type="text/javascript">if (window.MathJax) {MathJax.Hub.Config({SVG: {font: "STIX-Web"}});}</script>                <script type="text/javascript">window.PlotlyConfig = {MathJaxConfig: 'local'};</script>
        <script src="https://cdn.plot.ly/plotly-2.8.3.min.js"></script>                <div id="c8524327-0236-436a-ac6f-022fc6b1c508" class="plotly-graph-div" style="height:525px; width:100%;"></div>            <script type="text/javascript">                                    window.PLOTLYENV=window.PLOTLYENV || {};                                    if (document.getElementById("c8524327-0236-436a-ac6f-022fc6b1c508")) {                    Plotly.newPlot(                        "c8524327-0236-436a-ac6f-022fc6b1c508",                        [{"alignmentgroup":"True","hovertemplate":"pct=%{x}<br>org_name=%{y}<extra></extra>","legendgroup":"","marker":{"color":"#636efa","pattern":{"shape":""}},"name":"","offsetgroup":"","orientation":"h","showlegend":false,"textposition":"auto","x":[86.02863389519712,85.86552748885588,84.25938204482163,84.02547065337762,83.36314847942755,82.9790115098172,82.82014842886468,82.48497702368329,82.27908455181182,81.04303525941815],"xaxis":"x","y":["Harvard University (Cambridge)","University of California, San Francisco (San Francisco)","Johns Hopkins University (Baltimore)","University of Washington (Seattle)","Cornell University (Ithaca)","Stanford University (Stanford)","University of California, Los Angeles (Los Angeles)","Yale University (New Haven)","University of Pennsylvania (Philadelphia)","University of Michigan\u2013Ann Arbor (Ann Arbor)"],"yaxis":"y","type":"bar"}],                        {"template":{"data":{"bar":[{"error_x":{"color":"#2a3f5f"},"error_y":{"color":"#2a3f5f"},"marker":{"line":{"color":"#E5ECF6","width":0.5},"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"bar"}],"barpolar":[{"marker":{"line":{"color":"#E5ECF6","width":0.5},"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"barpolar"}],"carpet":[{"aaxis":{"endlinecolor":"#2a3f5f","gridcolor":"white","linecolor":"white","minorgridcolor":"white","startlinecolor":"#2a3f5f"},"baxis":{"endlinecolor":"#2a3f5f","gridcolor":"white","linecolor":"white","minorgridcolor":"white","startlinecolor":"#2a3f5f"},"type":"carpet"}],"choropleth":[{"colorbar":{"outlinewidth":0,"ticks":""},"type":"choropleth"}],"contour":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"contour"}],"contourcarpet":[{"colorbar":{"outlinewidth":0,"ticks":""},"type":"contourcarpet"}],"heatmap":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"heatmap"}],"heatmapgl":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"heatmapgl"}],"histogram":[{"marker":{"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"histogram"}],"histogram2d":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"histogram2d"}],"histogram2dcontour":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"histogram2dcontour"}],"mesh3d":[{"colorbar":{"outlinewidth":0,"ticks":""},"type":"mesh3d"}],"parcoords":[{"line":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"parcoords"}],"pie":[{"automargin":true,"type":"pie"}],"scatter":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatter"}],"scatter3d":[{"line":{"colorbar":{"outlinewidth":0,"ticks":""}},"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatter3d"}],"scattercarpet":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scattercarpet"}],"scattergeo":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scattergeo"}],"scattergl":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scattergl"}],"scattermapbox":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scattermapbox"}],"scatterpolar":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatterpolar"}],"scatterpolargl":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatterpolargl"}],"scatterternary":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatterternary"}],"surface":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"surface"}],"table":[{"cells":{"fill":{"color":"#EBF0F8"},"line":{"color":"white"}},"header":{"fill":{"color":"#C8D4E3"},"line":{"color":"white"}},"type":"table"}]},"layout":{"annotationdefaults":{"arrowcolor":"#2a3f5f","arrowhead":0,"arrowwidth":1},"autotypenumbers":"strict","coloraxis":{"colorbar":{"outlinewidth":0,"ticks":""}},"colorscale":{"diverging":[[0,"#8e0152"],[0.1,"#c51b7d"],[0.2,"#de77ae"],[0.3,"#f1b6da"],[0.4,"#fde0ef"],[0.5,"#f7f7f7"],[0.6,"#e6f5d0"],[0.7,"#b8e186"],[0.8,"#7fbc41"],[0.9,"#4d9221"],[1,"#276419"]],"sequential":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"sequentialminus":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]},"colorway":["#636efa","#EF553B","#00cc96","#ab63fa","#FFA15A","#19d3f3","#FF6692","#B6E880","#FF97FF","#FECB52"],"font":{"color":"#2a3f5f"},"geo":{"bgcolor":"white","lakecolor":"white","landcolor":"#E5ECF6","showlakes":true,"showland":true,"subunitcolor":"white"},"hoverlabel":{"align":"left"},"hovermode":"closest","mapbox":{"style":"light"},"paper_bgcolor":"white","plot_bgcolor":"#E5ECF6","polar":{"angularaxis":{"gridcolor":"white","linecolor":"white","ticks":""},"bgcolor":"#E5ECF6","radialaxis":{"gridcolor":"white","linecolor":"white","ticks":""}},"scene":{"xaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","gridwidth":2,"linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white"},"yaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","gridwidth":2,"linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white"},"zaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","gridwidth":2,"linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white"}},"shapedefaults":{"line":{"color":"#2a3f5f"}},"ternary":{"aaxis":{"gridcolor":"white","linecolor":"white","ticks":""},"baxis":{"gridcolor":"white","linecolor":"white","ticks":""},"bgcolor":"#E5ECF6","caxis":{"gridcolor":"white","linecolor":"white","ticks":""}},"title":{"x":0.05},"xaxis":{"automargin":true,"gridcolor":"white","linecolor":"white","ticks":"","title":{"standoff":15},"zerolinecolor":"white","zerolinewidth":2},"yaxis":{"automargin":true,"gridcolor":"white","linecolor":"white","ticks":"","title":{"standoff":15},"zerolinecolor":"white","zerolinewidth":2}}},"xaxis":{"anchor":"y","domain":[0.0,1.0],"title":{"text":"pct"}},"yaxis":{"anchor":"x","domain":[0.0,1.0],"title":{"text":"org_name"}},"legend":{"tracegroupgap":0},"margin":{"t":60},"barmode":"relative"},                        {"responsive": true}                    ).then(function(){

var gd = document.getElementById('c8524327-0236-436a-ac6f-022fc6b1c508');
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
You can go beyond just the 'basic' trust markers with Dimensions Research Integrity. You can also look at related data, such as recorded contributions to papers by individuals, or at which repositories data is being deposited in.

Let's take a look at author contributions by research categorisation (note: articles falling under multiple categories will be counted once in each category. Articles mentioning the same verb more than once are only counted once per category). This will help understand acknowledgement patterns in research and possibly identify discipline areas where practice is 'ahead of the curve'.


```python
%%bigquery cont_df --project ds-ripeta-gbq

SELECT
    p.year, 
    cat.name,
    contributor_verbs,
    COUNT(DISTINCT p.id) publications      
FROM dimensions-ai.data_analytics.publications p,
    UNNEST(category_for.first_level.full) cat
INNER JOIN `dimensions-ai-integrity.data.trust_markers` tm
    ON p.id = tm.id,
    UNNEST(author_contributions.activity_keywords) contributor_verbs
WHERE  p.type= 'article' and p.year between 2011 and 2022
group by 1, 2, 3
```


    Query is running:   0%|          |



    Downloading:   0%|          |



```python
#see what we get
cont_df.head(5)
```





  <div id="df-17573fab-1eb4-4307-9524-de2e1334d9a0">
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
      <td>2022</td>
      <td>Chemical Sciences</td>
      <td>using</td>
      <td>1322</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2021</td>
      <td>Health Sciences</td>
      <td>using</td>
      <td>442</td>
    </tr>
    <tr>
      <th>2</th>
      <td>2022</td>
      <td>Environmental Sciences</td>
      <td>using</td>
      <td>309</td>
    </tr>
    <tr>
      <th>3</th>
      <td>2018</td>
      <td>Built Environment And Design</td>
      <td>using</td>
      <td>29</td>
    </tr>
    <tr>
      <th>4</th>
      <td>2020</td>
      <td>Mathematical Sciences</td>
      <td>using</td>
      <td>82</td>
    </tr>
  </tbody>
</table>
</div>
      <button class="colab-df-convert" onclick="convertToInteractive('df-17573fab-1eb4-4307-9524-de2e1334d9a0')"
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
          document.querySelector('#df-17573fab-1eb4-4307-9524-de2e1334d9a0 button.colab-df-convert');
        buttonEl.style.display =
          google.colab.kernel.accessAllowed ? 'block' : 'none';

        async function convertToInteractive(key) {
          const element = document.querySelector('#df-17573fab-1eb4-4307-9524-de2e1334d9a0');
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
     'Health Sciences',
     'Engineering',
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
    <div>            <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-AMS-MML_SVG"></script><script type="text/javascript">if (window.MathJax) {MathJax.Hub.Config({SVG: {font: "STIX-Web"}});}</script>                <script type="text/javascript">window.PlotlyConfig = {MathJaxConfig: 'local'};</script>
        <script src="https://cdn.plot.ly/plotly-2.8.3.min.js"></script>                <div id="11122941-4dd9-4709-bed1-fb4567fdb543" class="plotly-graph-div" style="height:525px; width:100%;"></div>            <script type="text/javascript">                                    window.PLOTLYENV=window.PLOTLYENV || {};                                    if (document.getElementById("11122941-4dd9-4709-bed1-fb4567fdb543")) {                    Plotly.newPlot(                        "11122941-4dd9-4709-bed1-fb4567fdb543",                        [{"hovertemplate":"contributor_verbs=performed<br>name=Biomedical And Clinical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"performed","line":{"color":"#636efa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"performed","orientation":"v","showlegend":true,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x4","y":[17630,26182,34102,37270,42279,41772,40713,45232,50467,60341,70587,55832],"yaxis":"y4","type":"scatter"},{"hovertemplate":"contributor_verbs=performed<br>name=Biological Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"performed","line":{"color":"#636efa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"performed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x5","y":[16563,22027,28008,29614,35459,37564,35297,37638,40787,45019,49721,38686],"yaxis":"y5","type":"scatter"},{"hovertemplate":"contributor_verbs=performed<br>name=Agricultural, Veterinary And Food Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"performed","line":{"color":"#636efa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"performed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x6","y":[1088,2028,2890,3558,4485,4869,4482,5207,6638,8526,9679,7769],"yaxis":"y6","type":"scatter"},{"hovertemplate":"contributor_verbs=performed<br>name=Chemical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"performed","line":{"color":"#636efa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"performed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x","y":[1236,1941,2897,3874,6247,8269,10184,12095,12336,13476,15415,14757],"yaxis":"y","type":"scatter"},{"hovertemplate":"contributor_verbs=performed<br>name=Health Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"performed","line":{"color":"#636efa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"performed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x2","y":[2633,3758,5282,5990,7170,6315,4771,5296,5883,7620,9443,7522],"yaxis":"y2","type":"scatter"},{"hovertemplate":"contributor_verbs=performed<br>name=Engineering<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"performed","line":{"color":"#636efa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"performed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x3","y":[1026,1629,2780,3831,6554,9710,13288,14977,13369,15339,15830,15186],"yaxis":"y3","type":"scatter"},{"hovertemplate":"contributor_verbs=approved<br>name=Biomedical And Clinical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"approved","line":{"color":"#EF553B","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"approved","orientation":"v","showlegend":true,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x4","y":[11140,14758,18975,23637,28379,31203,36089,44194,53679,73676,99315,83525],"yaxis":"y4","type":"scatter"},{"hovertemplate":"contributor_verbs=approved<br>name=Biological Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"approved","line":{"color":"#EF553B","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"approved","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x5","y":[5191,5563,7152,8624,11624,14332,16016,19361,23796,29768,38004,30468],"yaxis":"y5","type":"scatter"},{"hovertemplate":"contributor_verbs=approved<br>name=Agricultural, Veterinary And Food Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"approved","line":{"color":"#EF553B","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"approved","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x6","y":[380,646,860,1221,1773,2456,2946,3959,5520,7630,10295,9283],"yaxis":"y6","type":"scatter"},{"hovertemplate":"contributor_verbs=approved<br>name=Chemical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"approved","line":{"color":"#EF553B","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"approved","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x","y":[144,302,469,518,1360,1787,2314,3808,4427,5130,6082,5629],"yaxis":"y","type":"scatter"},{"hovertemplate":"contributor_verbs=approved<br>name=Health Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"approved","line":{"color":"#EF553B","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"approved","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x2","y":[4068,5207,6820,8252,9662,10325,11808,13749,16002,20737,25659,21903],"yaxis":"y2","type":"scatter"},{"hovertemplate":"contributor_verbs=approved<br>name=Engineering<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"approved","line":{"color":"#EF553B","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"approved","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x3","y":[530,908,1179,1469,2019,2657,3327,4451,5015,6527,9133,9870],"yaxis":"y3","type":"scatter"},{"hovertemplate":"contributor_verbs=contributed<br>name=Biomedical And Clinical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"contributed","line":{"color":"#00cc96","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"contributed","orientation":"v","showlegend":true,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x4","y":[13224,19367,26087,30055,33053,31952,29849,34416,40356,56473,75818,64849],"yaxis":"y4","type":"scatter"},{"hovertemplate":"contributor_verbs=contributed<br>name=Biological Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"contributed","line":{"color":"#00cc96","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"contributed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x5","y":[10848,15027,18665,19784,21377,20291,16697,18296,20428,24661,30986,25294],"yaxis":"y5","type":"scatter"},{"hovertemplate":"contributor_verbs=contributed<br>name=Agricultural, Veterinary And Food Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"contributed","line":{"color":"#00cc96","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"contributed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x6","y":[859,1532,2216,2883,3565,3344,2775,3449,4555,6105,7957,7294],"yaxis":"y6","type":"scatter"},{"hovertemplate":"contributor_verbs=contributed<br>name=Chemical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"contributed","line":{"color":"#00cc96","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"contributed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x","y":[1450,2528,3619,4719,6010,7517,9075,10942,12076,13959,16062,16264],"yaxis":"y","type":"scatter"},{"hovertemplate":"contributor_verbs=contributed<br>name=Health Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"contributed","line":{"color":"#00cc96","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"contributed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x2","y":[2889,4257,6046,7292,8609,8467,7803,9101,10526,14487,18054,15337],"yaxis":"y2","type":"scatter"},{"hovertemplate":"contributor_verbs=contributed<br>name=Engineering<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"contributed","line":{"color":"#00cc96","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"contributed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x3","y":[1027,1775,2772,4048,6485,8503,10959,13274,13688,16668,18797,19065],"yaxis":"y3","type":"scatter"},{"hovertemplate":"contributor_verbs=wrote<br>name=Biomedical And Clinical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"wrote","line":{"color":"#ab63fa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"wrote","orientation":"v","showlegend":true,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x4","y":[15447,22784,30284,30404,38188,38264,37535,41341,45955,55943,64972,51432],"yaxis":"y4","type":"scatter"},{"hovertemplate":"contributor_verbs=wrote<br>name=Biological Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"wrote","line":{"color":"#ab63fa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"wrote","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x5","y":[16024,21381,27003,26319,35254,38035,36192,36782,39758,44230,48677,36700],"yaxis":"y5","type":"scatter"},{"hovertemplate":"contributor_verbs=wrote<br>name=Agricultural, Veterinary And Food Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"wrote","line":{"color":"#ab63fa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"wrote","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x6","y":[988,1840,2690,2946,4477,4924,4669,5275,6479,8361,9611,7616],"yaxis":"y6","type":"scatter"},{"hovertemplate":"contributor_verbs=wrote<br>name=Chemical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"wrote","line":{"color":"#ab63fa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"wrote","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x","y":[1175,1832,2700,3381,5848,7758,9229,10588,10525,11583,12993,12278],"yaxis":"y","type":"scatter"},{"hovertemplate":"contributor_verbs=wrote<br>name=Health Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"wrote","line":{"color":"#ab63fa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"wrote","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x2","y":[2299,3768,5459,5852,7555,6880,5498,6208,7208,9278,10687,8615],"yaxis":"y2","type":"scatter"},{"hovertemplate":"contributor_verbs=wrote<br>name=Engineering<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"wrote","line":{"color":"#ab63fa","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"wrote","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x3","y":[882,1454,2532,3307,6455,9538,13202,15309,13595,15290,14975,12987],"yaxis":"y3","type":"scatter"},{"hovertemplate":"contributor_verbs=designed<br>name=Biomedical And Clinical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"designed","line":{"color":"#FFA15A","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"designed","orientation":"v","showlegend":true,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x4","y":[15364,22651,30698,33266,38224,38414,38880,43357,48323,57799,65232,50448],"yaxis":"y4","type":"scatter"},{"hovertemplate":"contributor_verbs=designed<br>name=Biological Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"designed","line":{"color":"#FFA15A","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"designed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x5","y":[15790,21265,27132,28240,33863,36023,34160,36281,39254,42756,46344,34804],"yaxis":"y5","type":"scatter"},{"hovertemplate":"contributor_verbs=designed<br>name=Agricultural, Veterinary And Food Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"designed","line":{"color":"#FFA15A","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"designed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x6","y":[1025,1944,2826,3551,4694,5119,4888,5895,7204,8979,9919,7614],"yaxis":"y6","type":"scatter"},{"hovertemplate":"contributor_verbs=designed<br>name=Chemical Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"designed","line":{"color":"#FFA15A","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"designed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x","y":[1171,1812,2668,3392,5472,7188,8875,10553,10318,10861,11733,10511],"yaxis":"y","type":"scatter"},{"hovertemplate":"contributor_verbs=designed<br>name=Health Sciences<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"designed","line":{"color":"#FFA15A","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"designed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x2","y":[2403,3789,5688,6542,7854,7380,6269,7289,8270,10288,11632,9014],"yaxis":"y2","type":"scatter"},{"hovertemplate":"contributor_verbs=designed<br>name=Engineering<br>year=%{x}<br>publications=%{y}<extra></extra>","legendgroup":"designed","line":{"color":"#FFA15A","dash":"solid"},"marker":{"symbol":"circle"},"mode":"lines","name":"designed","orientation":"v","showlegend":false,"x":[2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022],"xaxis":"x3","y":[926,1459,2500,3381,5814,8684,12135,13874,11619,12712,11933,10291],"yaxis":"y3","type":"scatter"}],                        {"template":{"data":{"bar":[{"error_x":{"color":"#2a3f5f"},"error_y":{"color":"#2a3f5f"},"marker":{"line":{"color":"#E5ECF6","width":0.5},"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"bar"}],"barpolar":[{"marker":{"line":{"color":"#E5ECF6","width":0.5},"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"barpolar"}],"carpet":[{"aaxis":{"endlinecolor":"#2a3f5f","gridcolor":"white","linecolor":"white","minorgridcolor":"white","startlinecolor":"#2a3f5f"},"baxis":{"endlinecolor":"#2a3f5f","gridcolor":"white","linecolor":"white","minorgridcolor":"white","startlinecolor":"#2a3f5f"},"type":"carpet"}],"choropleth":[{"colorbar":{"outlinewidth":0,"ticks":""},"type":"choropleth"}],"contour":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"contour"}],"contourcarpet":[{"colorbar":{"outlinewidth":0,"ticks":""},"type":"contourcarpet"}],"heatmap":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"heatmap"}],"heatmapgl":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"heatmapgl"}],"histogram":[{"marker":{"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"histogram"}],"histogram2d":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"histogram2d"}],"histogram2dcontour":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"histogram2dcontour"}],"mesh3d":[{"colorbar":{"outlinewidth":0,"ticks":""},"type":"mesh3d"}],"parcoords":[{"line":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"parcoords"}],"pie":[{"automargin":true,"type":"pie"}],"scatter":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatter"}],"scatter3d":[{"line":{"colorbar":{"outlinewidth":0,"ticks":""}},"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatter3d"}],"scattercarpet":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scattercarpet"}],"scattergeo":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scattergeo"}],"scattergl":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scattergl"}],"scattermapbox":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scattermapbox"}],"scatterpolar":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatterpolar"}],"scatterpolargl":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatterpolargl"}],"scatterternary":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatterternary"}],"surface":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"surface"}],"table":[{"cells":{"fill":{"color":"#EBF0F8"},"line":{"color":"white"}},"header":{"fill":{"color":"#C8D4E3"},"line":{"color":"white"}},"type":"table"}]},"layout":{"annotationdefaults":{"arrowcolor":"#2a3f5f","arrowhead":0,"arrowwidth":1},"autotypenumbers":"strict","coloraxis":{"colorbar":{"outlinewidth":0,"ticks":""}},"colorscale":{"diverging":[[0,"#8e0152"],[0.1,"#c51b7d"],[0.2,"#de77ae"],[0.3,"#f1b6da"],[0.4,"#fde0ef"],[0.5,"#f7f7f7"],[0.6,"#e6f5d0"],[0.7,"#b8e186"],[0.8,"#7fbc41"],[0.9,"#4d9221"],[1,"#276419"]],"sequential":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"sequentialminus":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]},"colorway":["#636efa","#EF553B","#00cc96","#ab63fa","#FFA15A","#19d3f3","#FF6692","#B6E880","#FF97FF","#FECB52"],"font":{"color":"#2a3f5f"},"geo":{"bgcolor":"white","lakecolor":"white","landcolor":"#E5ECF6","showlakes":true,"showland":true,"subunitcolor":"white"},"hoverlabel":{"align":"left"},"hovermode":"closest","mapbox":{"style":"light"},"paper_bgcolor":"white","plot_bgcolor":"#E5ECF6","polar":{"angularaxis":{"gridcolor":"white","linecolor":"white","ticks":""},"bgcolor":"#E5ECF6","radialaxis":{"gridcolor":"white","linecolor":"white","ticks":""}},"scene":{"xaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","gridwidth":2,"linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white"},"yaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","gridwidth":2,"linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white"},"zaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","gridwidth":2,"linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white"}},"shapedefaults":{"line":{"color":"#2a3f5f"}},"ternary":{"aaxis":{"gridcolor":"white","linecolor":"white","ticks":""},"baxis":{"gridcolor":"white","linecolor":"white","ticks":""},"bgcolor":"#E5ECF6","caxis":{"gridcolor":"white","linecolor":"white","ticks":""}},"title":{"x":0.05},"xaxis":{"automargin":true,"gridcolor":"white","linecolor":"white","ticks":"","title":{"standoff":15},"zerolinecolor":"white","zerolinewidth":2},"yaxis":{"automargin":true,"gridcolor":"white","linecolor":"white","ticks":"","title":{"standoff":15},"zerolinecolor":"white","zerolinewidth":2}}},"xaxis":{"anchor":"y","domain":[0.0,0.31999999999999995],"title":{"text":"year"}},"yaxis":{"anchor":"x","domain":[0.0,0.46499999999999997],"title":{"text":"publications"}},"xaxis2":{"anchor":"y2","domain":[0.33999999999999997,0.6599999999999999],"matches":"x","title":{"text":"year"}},"yaxis2":{"anchor":"x2","domain":[0.0,0.46499999999999997],"matches":"y","showticklabels":false},"xaxis3":{"anchor":"y3","domain":[0.6799999999999999,0.9999999999999999],"matches":"x","title":{"text":"year"}},"yaxis3":{"anchor":"x3","domain":[0.0,0.46499999999999997],"matches":"y","showticklabels":false},"xaxis4":{"anchor":"y4","domain":[0.0,0.31999999999999995],"matches":"x","showticklabels":false},"yaxis4":{"anchor":"x4","domain":[0.5349999999999999,0.9999999999999999],"matches":"y","title":{"text":"publications"}},"xaxis5":{"anchor":"y5","domain":[0.33999999999999997,0.6599999999999999],"matches":"x","showticklabels":false},"yaxis5":{"anchor":"x5","domain":[0.5349999999999999,0.9999999999999999],"matches":"y","showticklabels":false},"xaxis6":{"anchor":"y6","domain":[0.6799999999999999,0.9999999999999999],"matches":"x","showticklabels":false},"yaxis6":{"anchor":"x6","domain":[0.5349999999999999,0.9999999999999999],"matches":"y","showticklabels":false},"annotations":[{"font":{},"showarrow":false,"text":"name=Chemical Sciences","x":0.15999999999999998,"xanchor":"center","xref":"paper","y":0.46499999999999997,"yanchor":"bottom","yref":"paper"},{"font":{},"showarrow":false,"text":"name=Health Sciences","x":0.49999999999999994,"xanchor":"center","xref":"paper","y":0.46499999999999997,"yanchor":"bottom","yref":"paper"},{"font":{},"showarrow":false,"text":"name=Engineering","x":0.8399999999999999,"xanchor":"center","xref":"paper","y":0.46499999999999997,"yanchor":"bottom","yref":"paper"},{"font":{},"showarrow":false,"text":"name=Biomedical And Clinical Sciences","x":0.15999999999999998,"xanchor":"center","xref":"paper","y":0.9999999999999999,"yanchor":"bottom","yref":"paper"},{"font":{},"showarrow":false,"text":"name=Biological Sciences","x":0.49999999999999994,"xanchor":"center","xref":"paper","y":0.9999999999999999,"yanchor":"bottom","yref":"paper"},{"font":{},"showarrow":false,"text":"name=Agricultural, Veterinary And Food Sciences","x":0.8399999999999999,"xanchor":"center","xref":"paper","y":0.9999999999999999,"yanchor":"bottom","yref":"paper"}],"legend":{"title":{"text":"contributor_verbs"},"tracegroupgap":0},"margin":{"t":60}},                        {"responsive": true}                    ).then(function(){

var gd = document.getElementById('11122941-4dd9-4709-bed1-fb4567fdb543');
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
%%bigquery repo_df --project ds-ripeta-gbq

--the first two tables created by the WITH statements are needed (for now) to tidy up repository data
WITH
  common_keywords AS(
  SELECT
    kw, 
    COUNT(DISTINCT id) AS pubs
  FROM `dimensions-ai-integrity.data.trust_markers` tm,
    UNNEST(tm.data.repository_keywords) kw
  GROUP BY 1
),
repositories AS(
  SELECT
  id,
  kw, 
  'url' isin
    FROM `dimensions-ai-integrity.data.trust_markers` tm,
      UNNEST(tm.data.data_repository_urls) url
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
          UNNEST(tm.data.repository_keywords) kw
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
    rep.kw,
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





  <div id="df-802fbe73-1429-4fa7-adad-7674680971b2">
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
      <td>github</td>
      <td>1688</td>
      <td>6915</td>
      <td>13760</td>
    </tr>
    <tr>
      <th>1</th>
      <td>ncbi</td>
      <td>1630</td>
      <td>6586</td>
      <td>12219</td>
    </tr>
    <tr>
      <th>2</th>
      <td>geo</td>
      <td>1478</td>
      <td>5323</td>
      <td>9777</td>
    </tr>
    <tr>
      <th>3</th>
      <td>gene</td>
      <td>1578</td>
      <td>6037</td>
      <td>9023</td>
    </tr>
    <tr>
      <th>4</th>
      <td>zenodo</td>
      <td>1201</td>
      <td>4922</td>
      <td>7041</td>
    </tr>
    <tr>
      <th>5</th>
      <td>bioproject</td>
      <td>1148</td>
      <td>4442</td>
      <td>6138</td>
    </tr>
    <tr>
      <th>6</th>
      <td>sra</td>
      <td>1176</td>
      <td>4351</td>
      <td>6020</td>
    </tr>
    <tr>
      <th>7</th>
      <td>genbank</td>
      <td>1067</td>
      <td>4295</td>
      <td>5289</td>
    </tr>
    <tr>
      <th>8</th>
      <td>figshare</td>
      <td>1144</td>
      <td>4433</td>
      <td>4828</td>
    </tr>
    <tr>
      <th>9</th>
      <td>map</td>
      <td>1002</td>
      <td>3893</td>
      <td>3315</td>
    </tr>
  </tbody>
</table>
</div>
      <button class="colab-df-convert" onclick="convertToInteractive('df-802fbe73-1429-4fa7-adad-7674680971b2')"
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
          document.querySelector('#df-802fbe73-1429-4fa7-adad-7674680971b2 button.colab-df-convert');
        buttonEl.style.display =
          google.colab.kernel.accessAllowed ? 'block' : 'none';

        async function convertToInteractive(key) {
          const element = document.querySelector('#df-802fbe73-1429-4fa7-adad-7674680971b2');
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
    <div>            <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-AMS-MML_SVG"></script><script type="text/javascript">if (window.MathJax) {MathJax.Hub.Config({SVG: {font: "STIX-Web"}});}</script>                <script type="text/javascript">window.PlotlyConfig = {MathJaxConfig: 'local'};</script>
        <script src="https://cdn.plot.ly/plotly-2.8.3.min.js"></script>                <div id="f70fe498-f0cd-440f-9d59-4c8d62c9d285" class="plotly-graph-div" style="height:525px; width:100%;"></div>            <script type="text/javascript">                                    window.PLOTLYENV=window.PLOTLYENV || {};                                    if (document.getElementById("f70fe498-f0cd-440f-9d59-4c8d62c9d285")) {                    Plotly.newPlot(                        "f70fe498-f0cd-440f-9d59-4c8d62c9d285",                        [{"customdata":[["github"],["ncbi"],["geo"],["gene"],["zenodo"],["bioproject"],["sra"],["genbank"],["figshare"],["map"]],"hovertemplate":"funders=%{x}<br>orgs=%{y}<br>kw=%{customdata[0]}<extra></extra>","legendgroup":"","marker":{"color":"#636efa","symbol":"circle"},"mode":"markers","name":"","orientation":"v","showlegend":false,"x":[1688,1630,1478,1578,1201,1148,1176,1067,1144,1002],"xaxis":"x","y":[6915,6586,5323,6037,4922,4442,4351,4295,4433,3893],"yaxis":"y","type":"scatter"}],                        {"template":{"data":{"bar":[{"error_x":{"color":"#2a3f5f"},"error_y":{"color":"#2a3f5f"},"marker":{"line":{"color":"#E5ECF6","width":0.5},"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"bar"}],"barpolar":[{"marker":{"line":{"color":"#E5ECF6","width":0.5},"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"barpolar"}],"carpet":[{"aaxis":{"endlinecolor":"#2a3f5f","gridcolor":"white","linecolor":"white","minorgridcolor":"white","startlinecolor":"#2a3f5f"},"baxis":{"endlinecolor":"#2a3f5f","gridcolor":"white","linecolor":"white","minorgridcolor":"white","startlinecolor":"#2a3f5f"},"type":"carpet"}],"choropleth":[{"colorbar":{"outlinewidth":0,"ticks":""},"type":"choropleth"}],"contour":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"contour"}],"contourcarpet":[{"colorbar":{"outlinewidth":0,"ticks":""},"type":"contourcarpet"}],"heatmap":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"heatmap"}],"heatmapgl":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"heatmapgl"}],"histogram":[{"marker":{"pattern":{"fillmode":"overlay","size":10,"solidity":0.2}},"type":"histogram"}],"histogram2d":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"histogram2d"}],"histogram2dcontour":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"histogram2dcontour"}],"mesh3d":[{"colorbar":{"outlinewidth":0,"ticks":""},"type":"mesh3d"}],"parcoords":[{"line":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"parcoords"}],"pie":[{"automargin":true,"type":"pie"}],"scatter":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatter"}],"scatter3d":[{"line":{"colorbar":{"outlinewidth":0,"ticks":""}},"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatter3d"}],"scattercarpet":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scattercarpet"}],"scattergeo":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scattergeo"}],"scattergl":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scattergl"}],"scattermapbox":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scattermapbox"}],"scatterpolar":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatterpolar"}],"scatterpolargl":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatterpolargl"}],"scatterternary":[{"marker":{"colorbar":{"outlinewidth":0,"ticks":""}},"type":"scatterternary"}],"surface":[{"colorbar":{"outlinewidth":0,"ticks":""},"colorscale":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"type":"surface"}],"table":[{"cells":{"fill":{"color":"#EBF0F8"},"line":{"color":"white"}},"header":{"fill":{"color":"#C8D4E3"},"line":{"color":"white"}},"type":"table"}]},"layout":{"annotationdefaults":{"arrowcolor":"#2a3f5f","arrowhead":0,"arrowwidth":1},"autotypenumbers":"strict","coloraxis":{"colorbar":{"outlinewidth":0,"ticks":""}},"colorscale":{"diverging":[[0,"#8e0152"],[0.1,"#c51b7d"],[0.2,"#de77ae"],[0.3,"#f1b6da"],[0.4,"#fde0ef"],[0.5,"#f7f7f7"],[0.6,"#e6f5d0"],[0.7,"#b8e186"],[0.8,"#7fbc41"],[0.9,"#4d9221"],[1,"#276419"]],"sequential":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]],"sequentialminus":[[0.0,"#0d0887"],[0.1111111111111111,"#46039f"],[0.2222222222222222,"#7201a8"],[0.3333333333333333,"#9c179e"],[0.4444444444444444,"#bd3786"],[0.5555555555555556,"#d8576b"],[0.6666666666666666,"#ed7953"],[0.7777777777777778,"#fb9f3a"],[0.8888888888888888,"#fdca26"],[1.0,"#f0f921"]]},"colorway":["#636efa","#EF553B","#00cc96","#ab63fa","#FFA15A","#19d3f3","#FF6692","#B6E880","#FF97FF","#FECB52"],"font":{"color":"#2a3f5f"},"geo":{"bgcolor":"white","lakecolor":"white","landcolor":"#E5ECF6","showlakes":true,"showland":true,"subunitcolor":"white"},"hoverlabel":{"align":"left"},"hovermode":"closest","mapbox":{"style":"light"},"paper_bgcolor":"white","plot_bgcolor":"#E5ECF6","polar":{"angularaxis":{"gridcolor":"white","linecolor":"white","ticks":""},"bgcolor":"#E5ECF6","radialaxis":{"gridcolor":"white","linecolor":"white","ticks":""}},"scene":{"xaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","gridwidth":2,"linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white"},"yaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","gridwidth":2,"linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white"},"zaxis":{"backgroundcolor":"#E5ECF6","gridcolor":"white","gridwidth":2,"linecolor":"white","showbackground":true,"ticks":"","zerolinecolor":"white"}},"shapedefaults":{"line":{"color":"#2a3f5f"}},"ternary":{"aaxis":{"gridcolor":"white","linecolor":"white","ticks":""},"baxis":{"gridcolor":"white","linecolor":"white","ticks":""},"bgcolor":"#E5ECF6","caxis":{"gridcolor":"white","linecolor":"white","ticks":""}},"title":{"x":0.05},"xaxis":{"automargin":true,"gridcolor":"white","linecolor":"white","ticks":"","title":{"standoff":15},"zerolinecolor":"white","zerolinewidth":2},"yaxis":{"automargin":true,"gridcolor":"white","linecolor":"white","ticks":"","title":{"standoff":15},"zerolinecolor":"white","zerolinewidth":2}}},"xaxis":{"anchor":"y","domain":[0.0,1.0],"title":{"text":"funders"}},"yaxis":{"anchor":"x","domain":[0.0,1.0],"title":{"text":"orgs"}},"legend":{"tracegroupgap":0},"margin":{"t":60}},                        {"responsive": true}                    ).then(function(){

var gd = document.getElementById('f70fe498-f0cd-440f-9d59-4c8d62c9d285');
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