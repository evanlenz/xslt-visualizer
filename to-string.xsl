<!-- copied & pasted from render.xsl, with modifications -->
<!-- the contents are actually inserted to a generated stylesheet -->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs">

  <xsl:template mode="to-string" match="*">
<xsl:param name="already-indented"/>
<xsl:param name="depth" tunnel="yes" select="0"/>
<xsl:if test="$trace:indent">
<xsl:if test="not($already-indented)">
  <xsl:text>&#xA;</xsl:text>
  <xsl:apply-templates mode="indent" select="."/>
</xsl:if>
</xsl:if>
  <span id="{generate-id(.)}">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:apply-templates mode="#current" select="@*"/>
    <xsl:text>></xsl:text>
  </span>
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
    </xsl:apply-templates>
<xsl:if test="$trace:indent">
<!--
<xsl:if test="*">
-->
<xsl:text>&#xA;</xsl:text>
<xsl:apply-templates mode="indent" select="."/>
<!--
</xsl:if>
-->
</xsl:if>
    <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>></xsl:text>
  </xsl:template>

  <xsl:template mode="to-string" match="text()">
    <xsl:param name="depth"/>
    <xsl:text>&#xA;</xsl:text>
    <xsl:apply-templates mode="indent" select=".">
      <xsl:with-param name="depth" select="$depth"/>
    </xsl:apply-templates>
    <span id="{generate-id(.)}">
      <xsl:value-of select="replace(replace(.,'&lt;','&amp;lt;'),'&amp;','&amp;amp;')"/>
    </span>
  </xsl:template>

  <xsl:template mode="to-string" match="@*">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>="</xsl:text>
    <xsl:value-of select="replace(replace(replace(.,'&lt;','&amp;lt;'),'&amp;','&amp;amp;'),'&quot;','&amp;quot;')"/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template mode="to-string" match="comment()">
    <xsl:text>&lt;--</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>--></xsl:text>
  </xsl:template>

  <xsl:template mode="to-string" match="processing-instruction()">
    <xsl:text>&lt;?</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="."/> <!-- need any escaping here? -->
    <xsl:text>?&gt;</xsl:text>
  </xsl:template>

  <xsl:template mode="indent" match="node()">
    <xsl:param name="depth" tunnel="yes" select="0"/>
    <xsl:if test="$trace:indent">
      <xsl:value-of select="string-join(for $n in (1 to $depth) return '  ','')"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
