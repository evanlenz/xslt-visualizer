<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:trace="http://lenzconsulting.com/tracexslt"
  xmlns:xdmp="http://marklogic.com/xdmp"
  xmlns:my="http://localhost"
  exclude-result-prefixes="xs trace my xdmp">

  <xsl:output indent="no"/>

  <xsl:template match="trace:invocation">
    <xsl:apply-templates mode="#current" select="collection()/trace:focus[@invocation-id eq current()/@invocation-id]">
      <xsl:sort select="@context-position"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
