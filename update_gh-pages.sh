#!/bin/bash

# Create a temporary folder
TMP_DIR=`mktemp -d`

# Convert the notebooks to HTML
jupyter nbconvert --to html --template full index.ipynb --output-dir=$TMP_DIR
jupyter nbconvert --to html --template full notebooks/*ipynb \
    --output-dir=$TMP_DIR/notebooks/

# Copy static and reveal.js folder to TMP_DIR, plus some additional files
cp -r static $TMP_DIR/.
cp -r notebooks/reveal.js $TMP_DIR/notebooks/.
cp -r notebooks/*.html $TMP_DIR/notebooks/.

# Switch to gh-pages branch
git checkout gh-pages

# Clean out branch and copy content from TMP_DIR to here
rm -rf *
cp -r $TMP_DIR/* .

# Replace all .ipynb-links with .html-liks
find . -type f -name "*.html" -exec sed -i 's/ipynb\&/html\&/g' {} +
find . -type f -name "*.html" -exec sed -i 's/ipynb#/html#/g' {} +
find . -type f -name "*.html" -exec sed -i 's/ipynb\"/html\"/g' {} +

# Delete the Button "Show HTML code" from index.html
sed -i '/Show HTML code/d' index.html

# Add Google Analytics script to each homepage
for h in `find -maxdepth 2 -name "*html"`
do
    sed '/<\/head>/ {r static/template_google_analytics.rst
    d}' $h > tmp.rst

    mv tmp.rst $h
done
rm static/template_google_analytics.rst

# Submit changes with current timestamp
TIMESTAMP=`date +'%Y-%m-%d %H:%M:%S'`
git add *
git commit -a -m "Update gh-pages - ${TIMESTAMP}"
git push origin gh-pages

# Remove temporary folder
rm -rf "$TMP_DIR"

# Go back to the master branch
git checkout master
