<!-- copied & pasted from render.xsl, with modifications -->
<!-- the contents are actually inserted to a generated stylesheet -->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:my="http://localhost"
  exclude-result-prefixes="xs my">

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

  <xsl:template mode="to-string" match="text()" xs:ns-hack="" my:ns-hack="">
    <xsl:param name="depth"/>
    <xsl:text>&#xA;</xsl:text>
    <xsl:variable name="indent" as="xs:string">
      <xsl:apply-templates mode="indent" select=".">
        <xsl:with-param name="depth" select="$depth"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:value-of select="$indent"/>
    <span id="{generate-id(.)}">
      <xsl:value-of select="replace(replace(string(.),'&lt;','&amp;lt;'),'&amp;','&amp;amp;')
                          ! (if (contains(.,' ')) then my:splitAtWords(., 40, concat('&#xA;',$indent)) else .)
                          "/>
    </span>
  </xsl:template>

          <!-- Grabbed from here (thanks Dimitre): https://stackoverflow.com/a/12352955/98316 -->
          <xsl:function name="my:splitAtWords" as="xs:string?" xmlns:my="http://localhost" my:ns-hack="" xs:ns-hack="">
           <xsl:param name="pText" as="xs:string?"/>
           <xsl:param name="pMaxLen" as="xs:integer"/>
           <xsl:param name="pRep" as="xs:string"/>

           <xsl:sequence select=
           "if($pText)
             then
              (for $line in replace($pText, concat('(^.{1,', $pMaxLen,'})\W.*'), '$1')
                return
                   concat($line, $pRep,
                          my:splitAtWords(substring-after($pText,$line),$pMaxLen,$pRep))
               )
             else ()
           "/>
          </xsl:function>


  <xsl:template mode="to-string" match="@*">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>="</xsl:text>
    <xsl:value-of select="replace(replace(replace(string(.),'&lt;','&amp;lt;'),'&amp;','&amp;amp;'),'&quot;','&amp;quot;')"/>
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

  <xsl:template mode="to-string" match="xsl:stylesheet/@default-validation | xsl:stylesheet/@input-type-annotations"/>

</xsl:stylesheet>
