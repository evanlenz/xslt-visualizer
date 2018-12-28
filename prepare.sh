rm -rf build/code-trace-enabled/$1
java -jar "C:/saxon/saxon9he.jar" -o:build/code-trace-enabled/$1/$1.xsl examples/$1.xsl xsl/trace-enable.xsl
