<!-- See: https://help.marklogic.com/knowledgebase/article/View/7/15/generating-unique-ids-guids -->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:trace="http://lenzconsulting.com/tracexslt"
  xmlns:xdmp="http://marklogic.com/xdmp"
  exclude-result-prefixes="xs xdmp">

  <xsl:function name="trace:random-hex" as="xs:string+">
    <xsl:param name="seq" as="xs:integer*"/>
    <xsl:sequence select="
      for $i in $seq return 
        string-join(for $n in 1 to $i
          return xdmp:integer-to-hex(xdmp:random(15)), '')
    "/>
  </xsl:function>

  <xsl:function name="trace:guid" as="xs:string">
    <xsl:sequence select="
      string-join(trace:random-hex((8,4,4,4,12)),'-')
    "/>
  </xsl:function>

</xsl:stylesheet>
