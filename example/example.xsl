<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs">

  <xsl:import href="inline.xsl"/>

  <xsl:template match="/">
	  <html>
	    <head>
        <xsl:apply-templates select="/doc/heading"/>
      </head>
      <body>
        <xsl:apply-templates select="/doc/para"/>
      </body>
	  </html>
  </xsl:template>

	<xsl:template match="heading">
		<title>
			<xsl:value-of select="."/>
		</title>
	</xsl:template>

  <xsl:template match="para">
    <p>
      <xsl:apply-templates mode="inline"/>
    </p>
  </xsl:template>

</xsl:stylesheet>
