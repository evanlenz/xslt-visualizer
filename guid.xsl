<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:trace="http://lenzconsulting.com/tracexslt"
  exclude-result-prefixes="xs">

  <xsl:function name="trace:guid" as="xs:string">
    <xsl:variable name="temp" as="document-node()">
      <xsl:document/>
    </xsl:variable>
    <xsl:sequence select="generate-id($temp)"/>
  </xsl:function>

</xsl:stylesheet>
