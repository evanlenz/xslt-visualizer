<!-- Copy all the .xml files in a directory -->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs">

  <xsl:template match="/">
    <xsl:variable name="output-dir" select="resolve-uri('.', current-output-uri())"/>
    <xsl:for-each select="uri-collection(concat($output-dir,'?select=*.xml'))">
      <xsl:variable name="file" select="unparsed-text(.)"/>
      <xsl:result-document href="{substring-before(.,'.xml')}.html" method="text">
        <xsl:copy-of select="$file"/>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
