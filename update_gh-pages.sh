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
cp -r template_google_analytics.rst $TMP_DIR/.

# Switch to gh-pages branch
git checkout gh-pages

# Clean out branch and copy content from TMP_DIR to here
rm -rf *
cp -r $TMP_DIR/* .

# Replace all .ipynb-links with .html-liks
find . -type f -name "*.html" -exec sed -i 's/ipynb\&/html\&/g' {} +
find . -type f -name "*.html" -exec sed -i 's/ipynb#/html#/g' {} +
find . -type f -name "*.html" -exec sed -i 's/ipynb\"/html\"/g' {} +

# Add Google Analytics script to each homepage
for h in `find -maxdepth 2 -name "*html"`
do
    sed '/<\/head>/ {r template_google_analytics.rst.rst
    d}' $h > tmp.rst

    mv tmp.rst $h
done

# Submit changes with current timestamp
TIMESTAMP=`date +'%Y-%m-%d %H:%M:%S'`
git add *
git commit -a -m "Update gh-pages - ${TIMESTAMP}"
git push origin gh-pages

# Remove temporary folder and google analytics template
rm -rf "$TMP_DIR"
rm template_google_analytics.rst

# Go back to the master branch
git checkout master
