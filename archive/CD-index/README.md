# CD Index calculations

The notebooks in this folder present a method to compute the CD index via a short SQL query on [Dimensions on Google BigQuery](https://www.dimensions.ai/products/bigquery/). This approach makes it possible to calculate e.g. $CD_5$ index for all journal articles with references in Dimensions in less than 5 hours.

## Content
- **README.md**: This file
- **secrets.py**: In order to run the Jupyter notebook you need to create a file "secrets.py" with information on your GBQ connection. The file must define the following variables:
```gbq_project_id = "[your GBQ billing project ID]"
gbq_table_prefix = "[your GBQ project].[GBQ dataset].[prefix for tables with CD indices]"
gbq_gbq_table_prefix = "[your GBQ project].[GBQ dataset].[prefix for tables with CD indices]"
cdindex_gbq_table_name = "[your GBQ project].[GBQ dataset].[prefix for tables with CD indices]"
```
- **CD_index_1_calculations.ipynb**: a notebook with examples how to calculate the $CD$ index with our method.
- **CD_index_2_compare_Funk_to_our_results.ipynb**: a notebook that is used to compare our results for the CD-index with results by R. Funk who used different citation graphs (e.g. PubMed) and his Python library. Please note that this notebook requires this data to be uploaded to Google Big Query. R. Funk's results are not included in this repository. 
- **CD_histogram_data.csv**: the data for the histogram of $CD_5$ for several methods by us and funk in 0.1-buckets. This is the raw data for a figure in our manuscript mentioned below. It is created by the above notebook.
- **CD_index_3_performance_comparison.ipynb**: this notebook runs different methods (SQL on GBQ, Python packages cd_index and fast_cd_index) for ever increasing citation networks and measures the speed of all three methods
- **fig_perf.png**: figure comparing the speed of different methods of computing $CD_5$ used in our manuscript mentioned below.
- **CD_index_4_alternative_indices.ipynb**: this notebook illustrates how you can also calculate other disruption indices (mostly variants of the $CD$ index) using our method. Of course there are many more.
- **CD_index_query1_all.sql**: the SQL query to calculate all $CD$-indices for all publications in the Dimensions GoogleBigQuery table. In order to run it you need to edit the query and add the destination table for the calculation in your GBQ project.			
- **CDindex_query2_journals.sql**: a similar query but this time only for the citation-publication network of journal articles.			
- **CDindex_query3_pubmed.sql**: a similar query but this time only for the citation-publication network of publications in PubMed.				
		


## Note

These notebooks and SQL queries are supplementary materials to the paper (soon to be released):

* A fast way to compute the CD index, Joerg Sixt, Michele Pasin, 2024. (https://arxiv.org/abs/2309.06120, latest version)