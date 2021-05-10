#!/bin/bash
# run mkdocs site in local
# prerequisites: chmod u+x <filename>

echo "=================="
echo "Building '/mkdocs/src-docs' into '../docs' folder..."
echo "=================="

cd mkdocs
mkdocs build --clean

echo "=================="
echo "Copying CNAME settings to '../docs' folder..."
echo "=================="

cp CNAME ../docs


echo "=================="
echo "Pushing to Github..."
echo "=================="


cd "$TARGETDIR"

git add -A

git commit -m "automated docs release"

git push



echo "=================="
echo "Completed push to https://github.com/digital-science/dimensions-gbq-lab"
echo "=================="

