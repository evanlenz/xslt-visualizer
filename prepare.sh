rm -rf build/code-trace-enabled/$1
java -jar "C:/saxon/saxon9he.jar" -o:build/code-trace-enabled/$1/$1.xsl example/$1.xsl trace-enable.xsl
