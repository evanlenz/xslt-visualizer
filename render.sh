mkdir -p build/$1/visualized/assets
cp -ru assets/* build/$1/visualized/assets

# Create the rendered results (Saxon forces .xml prefix in the output files)
java -jar "C:/saxon/saxon9he.jar" -s:build/$1/results/trace-data -o:build/$1/visualized -xsl:xsl/render.xsl

# Copy the files to .html versions (just using Saxon - as a proof of concept for use in difficult build tools)
java -jar "C:/saxon/saxon9he.jar" -s:util/copy-to-html.xsl -o:build/$1/visualized/dummy.xml -xsl:util/copy-to-html.xsl
