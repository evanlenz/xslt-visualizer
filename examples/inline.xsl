<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs">

  <xsl:template mode="inline" match="emphasis">
    <em>
      <xsl:apply-templates mode="#current"/>
    </em>
  </xsl:template>

</xsl:stylesheet>
