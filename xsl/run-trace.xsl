<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  exclude-result-prefixes="xs map">

  <xsl:param name="trace-enabled-stylesheet-uri"/>

  <xsl:param name="transform-params" select="()"/>

  <xsl:variable name="transform-params-map"
                select="map:merge(
                          for $element in $transform-params/params/*
                          return map:entry(node-name($element), string($element))
                        )"/>

  <xsl:variable name="input-file-name" select="tokenize(base-uri(.),'/')[last()]"/>

  <xsl:template match="/">
    <xsl:variable name="results"
                  select="transform(
                            map {
                              'stylesheet-location':$trace-enabled-stylesheet-uri,
                              'stylesheet-params':$transform-params-map,
                              'source-node':.
                            }
                          )"/>

    <!-- principal output document -->
    <xsl:sequence select="$results?output"/>

    <!-- secondary output documents are assumed to comprise trace data -->
    <!-- TODO: add support for visualizing multiple output documents (not to mention temporary trees) -->
    <xsl:result-document href="trace-data/{$input-file-name}">
      <trace-data>
        <xsl:sequence select="map:keys($results)[not(. eq 'output')] ! map:get($results, .)"/>
      </trace-data>
    </xsl:result-document>

  </xsl:template>

</xsl:stylesheet>
