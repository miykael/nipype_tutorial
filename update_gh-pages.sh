#!/bin/bash

while true; do
    read -p "Did you submit all other changes and are you ready to update the pages? " yn
    case $yn in
        [Yy]* )



TIMESTAMP=`date +'%Y-%m-%d %H:%M:%S'`

# Reset the counts of all notebook cells
for h in `find -name "*.ipynb"`
do
    sed -i 's/^.*\execution_count\b.*$/   "execution_count": null,/'  $h
done
git add *
git commit -m "reset counts of all notebook cells - ${TIMESTAMP}"
git push

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

# Add Footer to all html-notebooks
for h in `find notebooks/ -name "*html"`
do
    sed -i 's/<\/body>/<\/body><div class="h3" style="right:0;bottom:0;left:0;padding:1rem;text-align:center;"><p style="white-space:pre"><a href="https:\/\/miykael.github.io\/nipype_tutorial\/">Home<\/a>\&emsp;|\&emsp;<a href="https:\/\/github.com\/miykael\/nipype_tutorial">github<\/a>\&emsp;|\&emsp;<a href="http:\/\/nipype.readthedocs.io">Nipype<\/a><\/p><\/div>/' $h

done

# Submit changes with current timestamp
git add *
git commit -a -m "Update gh-pages - ${TIMESTAMP}"
git push origin gh-pages

# Remove temporary folder
rm -rf "$TMP_DIR"

# Go back to the master branch
git checkout master



                break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
