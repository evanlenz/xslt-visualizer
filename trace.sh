rm -rf build/transformations/$1
java -jar "C:/saxon/saxon9he.jar" -o:build/transformations/$1/result.xml example/$1.xml build/code-trace-enabled/$1/$1.xsl
