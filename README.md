# Dimensions BigQuery LAB

This GitHub repository contains code samples and Jupyter notebooks for scholarly data analytics using the [Dimensions on Google BigQuery](https://www.dimensions.ai/products/bigquery/).

Please see the [BigQuery Lab website](https://bigquery-lab.dimensions.ai/) for a more user-friendly and searchable version of the materials included here.

![screenshot](https://raw.githubusercontent.com/digital-science/dimensions-gbq-lab/master/extras/img/gbq-lab-screenshot.png)


[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/digital-science/dimensions-gbq-lab/master) [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/digital-science/dimensions-gbq-lab/)


## Background

If you've never heard of Dimensions.ai or Jupyter notebooks, then this section if for you.

### What is Dimensions?

Digital Science's Dimensions is a dynamic, easy to use, linked-research data platform that re-imagines the way research can be discovered, accessed and analyzed.  Within Dimensions, users can explore the connections between grants, publications, clinical trials, patents and policy documents.

For more information, see https://www.dimensions.ai/

For a detailed breakdown of the Dimensions on BigQuery product, see the [technical documentation](https://docs.dimensions.ai/bigquery)


### What is Google BigQuery?

Google [BigQuery](https://cloud.google.com/bigquery/) is a scalable multi-cloud data warehouse environment that lowers the bar to professional-level data manipulation and analytics.

Google BigQuery allows users to combine Dimensions data with other proprietary and public data sources, without our involvement, in a completely private and secure way.


## Comments, bug reports

This project lives on [Github](https://github.com/digital-science/dimensions-gbq-lab). You can file [issues]([issues](https://github.com/digital-science/dimensions-gbq-lab/issues/new)) or ask questions there. Suggestions and improvements welcome!

## Local testing

Files can be edited directly in the `mkdocs/src-docs` directory, but several steps are required to convert these files into the website in the `docs` directory:

```sh
python3 -m venv . # start a virtual environment
source bin/activate
pip3 install -r requirements.txt
bash tools/run-build.sh
deactivate
```

## See also

https://bigquery-lab.dimensions.ai