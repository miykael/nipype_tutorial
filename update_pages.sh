#!/bin/bash

while true; do
    read -p "Did you submit all other changes and are you ready to update the pages? " yn
    case $yn in
        [Yy]* )

TIMESTAMP=`date +'%Y-%m-%d %H:%M:%S'`

# Clean out .ipynb_checkpoints in folder structure
rm -rf `find -name ".ipynb_checkpoints"`

# Reset the counts of all notebook cells
find . -type f -name "*.ipynb" \
    -exec sed -i 's/execution_count\b.*$/execution_count": null,/' {} +

# Convert the notebooks to HTML
jupyter nbconvert --to html --template full index.ipynb --output-dir=docs
jupyter nbconvert --to html --template full notebooks/*ipynb \
    --output-dir=docs/notebooks/

# Replace all .ipynb-links with .html-liks
find docs -type f -name "*.html" -exec sed -i 's/ipynb\&/html\&/g' {} +
find docs -type f -name "*.html" -exec sed -i 's/ipynb#/html#/g' {} +
find docs -type f -name "*.html" -exec sed -i 's/ipynb\"/html\"/g' {} +

# Delete the Button "Show HTML code" from index.html
sed -i '/Show HTML code/d' docs/index.html

# Add Google Analytics script to each homepage
for h in `find docs -maxdepth 2 -name "*html"`
do
    sed '/<\/head>/ {r static/template_google_analytics.rst
    d}' $h > tmp.rst

    mv tmp.rst $h
done

# Add Footer to all html-notebooks
for h in `find docs -maxdepth 2 -name "*html"`
do
    sed -i 's/<\/body>/<\/body><div class="h3" style="right:0;bottom:0;left:0;padding:1rem;text-align:center;"><p style="white-space:pre"><a href="https:\/\/miykael.github.io\/nipype_tutorial\/">Home<\/a>\&emsp;|\&emsp;<a href="https:\/\/github.com\/miykael\/nipype_tutorial">github<\/a>\&emsp;|\&emsp;<a href="http:\/\/nipype.readthedocs.io">Nipype<\/a><\/p><\/div>/' $h

done

# Copy static folder to docs/, plus some additional files
cp -r static docs/.
cp -r notebooks/*.html docs/notebooks/.

# Submit changes with current timestamp
git add docs
git commit -a -m "Update pages - ${TIMESTAMP}"

                break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
