#!/bin/bash
# run mkdocs site in local
# prerequisites: chmod u+x <filename>

./tools/run-build.sh

echo "=================="
echo "Pushing to Github..."
echo "=================="

git add -A

git commit -m "automated docs release"

git push



echo "=================="
echo "Completed push to https://github.com/digital-science/dimensions-gbq-lab"
echo "=================="

