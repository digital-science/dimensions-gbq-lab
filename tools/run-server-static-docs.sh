#!/bin/bash
# run mkdocs site in local
# prerequisites: chmod u+x <filename>

echo "=================="
echo "Running /mkdocs ..."
echo "=================="

cd docs
python -m http.server 8000