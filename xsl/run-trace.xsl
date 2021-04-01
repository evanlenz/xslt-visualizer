<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  exclude-result-prefixes="xs map">

  <xsl:param name="trace-enabled-stylesheet-uri"/>

  <xsl:param name="principal-output-method" select="'xml'"/>

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
    <xsl:result-document method="{$principal-output-method}">
      <xsl:sequence select="$results?output"/>
    </xsl:result-document>

    <!-- secondary output documents are assumed to comprise trace data -->
    <!-- TODO: add support for visualizing multiple output documents (not to mention temporary trees) -->
    <xsl:result-document href="trace-data/{$input-file-name}">
      <trace-data>
        <xsl:sequence select="map:keys($results)[not(. eq 'output')] ! map:get($results, .)"/>
      </trace-data>
    </xsl:result-document>

  </xsl:template>

  <!--
    The following alternative implementation obviates the need for the "principal-output-method" parameter.
    However, it runs afoul of an apparent Saxon bug (https://saxonica.plan.io/issues/4959). Once that bug
    has been fixed for a while, we could reintroduce this approach (and get rid of the workaround parameter).
  -->
  <!--
  <xsl:template match="/">
    <xsl:variable name="results"
                  select="transform(
                            map {
                              'stylesheet-location':$trace-enabled-stylesheet-uri,
                              'stylesheet-params':$transform-params-map,
                              'source-node':.,
                              'delivery-format':'serialized'
                            }
                          )"/>

    <!- - Principal output document already serialized according to the user's desire (XML or text or...) - ->
    <xsl:result-document method="text">
      <xsl:sequence select="$results?output"/>
    </xsl:result-document>

    <!- - Secondary output documents are assumed to comprise trace data, already serialized as XML
         without an XML declaration so that we can concatenate them into one document. - ->
    <!- - TODO: add support for visualizing multiple output documents (not to mention temporary trees) - ->
    <xsl:result-document href="trace-data/{$input-file-name}" method="text">
      <xsl:text>&lt;trace-data></xsl:text>
      <xsl:sequence select="map:keys($results)[not(. eq 'output')] ! map:get($results, .)"/>
      <xsl:text>&lt;/trace-data></xsl:text>
    </xsl:result-document>

  </xsl:template>
  -->

</xsl:stylesheet>
