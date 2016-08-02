<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:out="dummy"
  xmlns:trace="http://lenzconsulting.com/tracexslt"
  xmlns:xdmp="http://marklogic.com/xdmp"
  exclude-result-prefixes="xs xdmp out">

  <xsl:import href="lib/xml-to-string.xsl"/>
  <xsl:param name="force-exclude-all-namespaces" select="true()"/>

  <xsl:include href="guid.xsl"/>
  <xsl:include href="generate-built-in-rules.xsl"/>
  <xsl:include href="do-trace-enable.xsl"/>

  <xsl:namespace-alias stylesheet-prefix="out" result-prefix="xsl"/>

  <xsl:param name="source-dir" select="''"/>
  <!--
  <xsl:param name="source-dir" select="'enrichment-tracing2/visualizer/'"/>
  -->

  <xsl:param name="output-dir" select="'trace-enabled'"/>

  <xsl:variable name="full-source-dir" select="concat(xdmp:modules-root(),$source-dir)"/>

  <!-- TODO: make this specific to a stylesheet and input document (using parent dirs) -->
  <xsl:variable name="matches-db-dir" select="'/matches/'"/>

  <xsl:variable name="document-get-options" as="element()">
    <options xmlns="xdmp:document-get">
      <format>xml</format>
    </options>
  </xsl:variable>

  <xsl:variable name="gathered-code">      <xsl:apply-templates mode="gather-code" select="."/></xsl:variable>
  <xsl:variable name="with-built-in-rules"><xsl:apply-templates mode="built-in-rules" select="$gathered-code"/></xsl:variable>
  <xsl:variable name="with-rule-ids">      <xsl:apply-templates mode="add-rule-ids" select="$with-built-in-rules"/></xsl:variable>
  <xsl:variable name="trace-enabled">      <xsl:apply-templates mode="trace-enable" select="$with-rule-ids"/></xsl:variable>
  <xsl:variable name="flattened">          <xsl:apply-templates mode="flatten"      select="$trace-enabled"/></xsl:variable>

<xsl:output indent="no"/>

  <xsl:template match="/">
    <!--
    <xsl:sequence select="$gathered-code"/>
    <xsl:sequence select="$with-built-in-rules"/>
    <xsl:sequence select="$with-rule-ids"/>
    <xsl:sequence select="$trace-enabled"/>
    -->
    <result-docs>
      <xsl:sequence select="$flattened"/>

      <xsl:variable name="all-rules" select="$trace-enabled//xsl:template"/>
      <xsl:variable name="unique-modes" select="distinct-values($all-rules/@mode)"/>
      <rule-tree>
        <xsl:for-each select="$unique-modes">
          <xsl:sort select="."/>
          <xsl:variable name="mode" select="."/>
          <mode name="{$mode}">
            <xsl:for-each select="$all-rules[@mode eq $mode]">
              <xsl:variable name="rule-id" select="string(@trace:rule-id)"/>
              <rule id="{@trace:rule-id}" match="{@match}" priority="{@priority}" file="{ancestor::trace:result-document[1][not(@built-in-rules)]/@href}">
                <!-- show the original code, not the trace-enabled code -->
                <xsl:apply-templates mode="xml-to-string" select="$with-rule-ids//xsl:template[@trace:rule-id eq $rule-id]/node()"/>
              </rule>
            </xsl:for-each>
          </mode>
        </xsl:for-each>
      </rule-tree>
    </result-docs>
  </xsl:template>

          <xsl:template mode="xml-to-string" match="@disable-output-escaping[. eq 'no']"/>
          <xsl:template mode="xml-to-string" match="@mode[. eq '#default']"/>
          <xsl:template mode="xml-to-string" match="xsl:apply-templates/@select[. eq 'child::node()']"/>

  <xsl:template mode="gather-code" match="/">
    <trace:result-document href="{substring-after(base-uri(.),$full-source-dir)}">
      <xsl:apply-templates mode="#current"/>
    </trace:result-document>
  </xsl:template>

  <xsl:template mode="gather-code" match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*"/>
      <xsl:apply-templates mode="gather-code-insert" select="."/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

          <!-- by default, don't insert anything -->
          <xsl:template mode="gather-code-insert" match="*"/>


  <xsl:template mode="gather-code" match="xsl:import | xsl:include">
    <xsl:next-match/>
    <xsl:apply-templates mode="#current" select="xdmp:document-get(concat($full-source-dir,@href),$document-get-options)"/>
  </xsl:template>

  <!-- Make the default mode explicit -->
  <xsl:template mode="gather-code-insert" match="xsl:template[not(@mode)] | xsl:apply-templates[not(@mode)]">
    <xsl:attribute name="mode" select="'#default'"/>
  </xsl:template>


  <xsl:template mode="add-rule-ids" match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*"/>
      <xsl:apply-templates mode="add-rule-ids-insert" select="."/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

          <!-- by default, don't insert anything -->
          <xsl:template mode="add-rule-ids-insert" match="*"/>


  <xsl:template mode="add-rule-ids-insert" match="xsl:template">
    <xsl:attribute name="trace:rule-id" select="generate-id(.)"/>
  </xsl:template>


  <xsl:template mode="flatten" match="/">
    <xsl:for-each select="//trace:result-document">
      <trace:result-document href="{@href}">
        <xsl:apply-templates mode="#current"/>
      </trace:result-document>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="flatten" match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="flatten" match="trace:result-document"/>

</xsl:stylesheet>
