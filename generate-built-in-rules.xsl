<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:trace="http://lenzconsulting.com/tracexslt"
  xmlns:xdmp="http://marklogic.com/xdmp"
  xmlns:out="dummy"
  exclude-result-prefixes="xs out">

  <xsl:variable name="built-in-rules-xsl" select="concat('built-in-rules-',trace:guid(),'.xsl')"/>

  <xsl:variable name="mode-names" as="xs:QName*">
    <!-- check the apply-templates calls too, in case there's a mode that depends only on the built-in rules -->
    <xsl:variable name="all-mode-names"
                  select="$gathered-code//(xsl:template|xsl:apply-templates)/@mode/trace:extract-mode-qnames(.)"/>
    <xsl:sequence select="distinct-values($all-mode-names)"/>
  </xsl:variable>

  <!-- Insert the built-in rules where they'll have the lowest import precedence -->
  <xsl:template mode="built-in-rules" match="trace:result-document">
    <xsl:next-match>
      <xsl:with-param name="insert-import" select="not(preceding-sibling::trace:result-document)" tunnel="yes"/>
    </xsl:next-match>
  </xsl:template>

  <!-- This alternative version exploits a MarkLogic bug; hence the above workaround
  <xsl:template mode="built-in-rules" match="trace:result-document[1]">
    <xsl:next-match>
      <xsl:with-param name="insert-import" select="true()" tunnel="yes"/>
    </xsl:next-match>
  </xsl:template>
  -->

  <xsl:template mode="built-in-rules-insert" match="xsl:stylesheet[not(xsl:import)]
                                                  | xsl:transform [not(xsl:import)]">
    <xsl:param name="insert-import" select="false()" tunnel="yes"/>
    <xsl:if test="$insert-import">
      <out:import href="{$built-in-rules-xsl}"/>
      <trace:result-document href="{$built-in-rules-xsl}" built-in-rules="yes">
        <out:stylesheet version="2.0">
          <xsl:namespace name="trace" select="'http://lenzconsulting.com/tracexslt'"/>

          <xsl:for-each select="('#default',$mode-names)">

            <xsl:variable name="this-mode" select="."/>

            <!-- The built-in rules automatically forward non-tunnel parameters, so we've got to cover them all. -->
            <xsl:variable name="parameter-names" as="xs:QName*">
              <xsl:variable name="all-param-names"
                            select="$gathered-code//( xsl:apply-templates[trace:has-mode(.,$this-mode)]
                                                    | xsl:template       [trace:has-mode(.,$this-mode)]
                                                      //( xsl:apply-templates[@mode eq '#current']
                                                        | xsl:apply-imports
                                                        | xsl:next-match
                                                        )
                                                    )
                                                   /xsl:with-param[not(@tunnel eq 'yes')]
                                                   /@name
                                                   /resolve-QName(.,..)"/>
              <xsl:sequence select="distinct-values($all-param-names)"/>
            </xsl:variable>
            <out:template match="/|*">
              <xsl:sequence select="trace:mode-att(.)"/>
              <xsl:for-each select="$parameter-names">
                <out:param>
                  <xsl:sequence select="trace:qname-valued-att('name', ., false())"/>
                </out:param>
              </xsl:for-each>
              <out:apply-templates mode="#current">
                <xsl:for-each select="$parameter-names">
                  <out:with-param>
                    <xsl:sequence select="trace:qname-valued-att('name', ., true())"/>
                  </out:with-param>
                </xsl:for-each>
              </out:apply-templates>
            </out:template>

            <out:template match="text()|@*">
              <xsl:sequence select="trace:mode-att(.)"/>
              <out:value-of select="string(.)"/>
            </out:template>

            <out:template match="processing-instruction()|comment()">
              <xsl:sequence select="trace:mode-att(.)"/>
            </out:template>

          </xsl:for-each>

          <!-- Might as well insert the needed library code here too -->
          <!-- This is duplicated from guid.xsl; sue me -->
          <out:function name="trace:random-hex" as="xs:string+" trace:ns-hack="" xdmp:ns-hack="" xs:ns-hack="">
            <out:param name="seq" as="xs:integer*"/>
            <out:sequence select="
              for $i in $seq return 
                string-join(for $n in 1 to $i
                  return xdmp:integer-to-hex(xdmp:random(15)), '')
            "/>
          </out:function>

          <out:function name="trace:guid" as="xs:string" trace:ns-hack="" xdmp:ns-hack="" xs:ns-hack="">
            <out:sequence select="
              string-join(trace:random-hex((8,4,4,4,12)),'-')
            "/>
          </out:function>

        </out:stylesheet>
      </trace:result-document>
    </xsl:if>
  </xsl:template>

          <xsl:function name="trace:tokenize" as="xs:string*">
            <xsl:param name="string" as="xs:string"/>
            <xsl:sequence select="tokenize(normalize-space($string),' ')"/>
          </xsl:function>

          <xsl:function name="trace:extract-mode-qnames" as="xs:QName*">
            <xsl:param name="mode-att" as="attribute(mode)"/>
            <xsl:variable name="tokens" select="trace:tokenize($mode-att)"/>
            <xsl:sequence select="for $token in $tokens[not(starts-with(.,'#'))]
                                  return resolve-QName($token, $mode-att/..)"/>
          </xsl:function>

          <xsl:function name="trace:has-mode" as="xs:boolean">
            <xsl:param name="element" as="element()"/>
            <xsl:param name="mode" as="item()"/>
            <xsl:variable name="mode-att" select="$element/@mode"/>
            <xsl:sequence select="$mode-att eq '#all'
                               or (if ($mode instance of xs:QName) then $mode = trace:extract-mode-qnames($mode-att)
                                                                   else trace:tokenize($mode-att) = '#default'
                                  )"/>
          </xsl:function>

          <xsl:function name="trace:mode-att" as="node()+">
            <xsl:param name="mode"/> 
            <xsl:choose>
              <xsl:when test="$mode instance of xs:string">
                <xsl:attribute name="mode" select="'#default'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="trace:qname-valued-att('mode', $mode, false())"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:function>

          <xsl:function name="trace:qname-valued-att" as="node()+">
            <xsl:param name="att-name" as="xs:string"/>
            <xsl:param name="qname" as="xs:QName"/>
            <xsl:param name="also-select-att" as="xs:boolean"/>
            <xsl:variable name="ns-uri" select="namespace-uri-from-QName($qname)"/>
            <xsl:variable name="lexical-qname"
                          select="concat(if ($ns-uri) then 'x:' else '', local-name-from-QName($qname))"/>
            <xsl:if test="$ns-uri">
              <xsl:namespace name="x" select="$ns-uri"/>
            </xsl:if>
            <xsl:attribute name="{$att-name}" select="$lexical-qname"/>
            <xsl:if test="$also-select-att">
              <xsl:attribute name="select" select="concat('$',$lexical-qname)"/>
            </xsl:if>
          </xsl:function>


  <xsl:template mode="built-in-rules" match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*"/>
      <xsl:apply-templates mode="built-in-rules-insert" select="."/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

          <!-- by default, don't insert anything -->
          <xsl:template mode="built-in-rules-insert" match="*"/>

</xsl:stylesheet>
