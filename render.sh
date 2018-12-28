mkdir -p build/rendered/assets
cp -ru assets/* build/rendered/assets
java -jar "C:/saxon/saxon9he.jar" -o:build/rendered/$1.html build/transformations/$1/matches/initial.xml xsl/render.xsl
