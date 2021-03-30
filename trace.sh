rm -rf build/$1/results
mkdir -p build/$1/results

# Saxon will process every document in the input directory; the trace-enabled XSLT plays nicely with this approach
java -jar "C:/saxon/saxon9he.jar" -s:examples/$1.input-docs -o:build/$1/results -xsl:xsl/run-trace.xsl trace-enabled-stylesheet-uri=../build/$1/code-trace-enabled/$1.xsl
