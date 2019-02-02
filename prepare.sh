rm -rf build/$1/code-trace-enabled
java -jar "C:/saxon/saxon9he.jar" -s:examples/$1.xsl -o:build/$1/code-trace-enabled/$1.xsl -xsl:xsl/trace-enable.xsl
