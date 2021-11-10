<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:out="dummy"
  xmlns:trace="http://lenzconsulting.com/tracexslt"
  exclude-result-prefixes="xs out">

  <xsl:import href="lib/xml-to-string.xsl"/>

  <xsl:param name="force-exclude-all-namespaces" select="true()"/>

  <xsl:include href="guid.xsl"/>
  <xsl:include href="generate-built-in-rules.xsl"/>
  <xsl:include href="do-trace-enable.xsl"/>

  <xsl:namespace-alias stylesheet-prefix="out" result-prefix="xsl"/>

  <xsl:variable name="full-source-dir" select="resolve-uri('.', base-uri(.))"/>

  <xsl:variable name="gathered-code">
    <xsl:apply-templates mode="gather-code" select=".">
      <!-- For the top-level module, start with just the filename in case a relative URI was supplied
           (such that the base URI still contains dots as in "file:/foo/bar/bang/../../bat/baz.xml") -->
      <xsl:with-param name="result-href" select="tokenize(base-uri(.),'/')[last()]"/>
    </xsl:apply-templates>
  </xsl:variable>
  <xsl:variable name="with-built-in-rules"><xsl:apply-templates mode="built-in-rules" select="$gathered-code"/></xsl:variable>
  <xsl:variable name="with-rule-ids">      <xsl:apply-templates mode="add-rule-ids" select="$with-built-in-rules"/></xsl:variable>
  <xsl:variable name="trace-enabled">      <xsl:apply-templates mode="trace-enable" select="$with-rule-ids"/></xsl:variable>
  <xsl:variable name="flattened">          <xsl:apply-templates mode="flatten"      select="$trace-enabled"/></xsl:variable>

<xsl:output indent="no"/>

  <!-- Set some tunnel parameters (can't be global variables, because current-output-uri() is cleared when evaluating those) -->
  <xsl:template match="/" priority="1">
    <xsl:variable name="output-stylesheet-file-name" select="tokenize(current-output-uri(),'/')[last()]"/>
    <!-- This will just be .modules if the base output URI was not set.
         That should be okay, but it's best to set it (e.g. using Saxon's -o flag) -->
    <xsl:variable name="output-dir"  select="concat($output-stylesheet-file-name, '.modules/')"/>
    <xsl:next-match>
      <xsl:with-param name="output-dir" select="$output-dir" tunnel="yes"/>
    </xsl:next-match>
  </xsl:template>

  <xsl:template match="/">
    <xsl:param name="output-dir" tunnel="yes"/>

    <!-- Output top-level stylesheet -->
    <xsl:call-template name="top-module"/>

    <!-- Output trace-enabled versions of all the original XSLT modules -->
    <xsl:for-each select="$all-results/result-docs/trace:result-document[not(@href = preceding-sibling::trace:result-document/@href)]">
      <xsl:result-document href="{$output-dir}/{@href}">
        <xsl:copy-of select="node()"/>
      </xsl:result-document>
    </xsl:for-each>

    <!-- Output the rule tree -->
    <xsl:result-document href="{$output-dir}/rule-tree.xml">
      <xsl:sequence select="$all-results/result-docs/rule-tree"/>
    </xsl:result-document>

  </xsl:template>

  <xsl:variable name="all-results">
    <!--
    <xsl:sequence select="$gathered-code"/>
    <xsl:comment>BEGIN $with-built-in-rules</xsl:comment>
    <xsl:sequence select="$with-built-in-rules"/>
    <xsl:comment>END $with-built-in-rules</xsl:comment>
    <xsl:sequence select="$with-rule-ids"/>
    <xsl:sequence select="$trace-enabled"/>
    -->
    <result-docs>
      <xsl:sequence select="$flattened"/>

      <!--
      <trace:result-document href="top_{trace:guid()}.xsl">
        <xsl:call-template name="top-module"/>
      </trace:result-document>
      -->

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
  </xsl:variable>

          <xsl:template mode="xml-to-string" match="@disable-output-escaping[. eq 'no']"/>
          <xsl:template mode="xml-to-string" match="@mode[. eq '#default']"/>
          <xsl:template mode="xml-to-string" match="xsl:apply-templates/@select[. eq 'child::node()']"/>
          <xsl:template mode="xml-to-string" match="xsl:copy/@inherit-namespaces[. eq 'yes']
                                                  | xsl:copy/@copy-namespaces[. eq 'yes']"/>

          <!-- Insert a line break before every sequence of two or more contigous spaces in attribute values.
               This is a heuristic/guess as to what line breaks were present in the original, non-normalized value. -->
          <xsl:template mode="xml-to-string" match="@*">
            <xsl:next-match>
              <xsl:with-param name="att-value" select="replace(., '( {4,})', '&#xA;  $1')"/>
            </xsl:next-match>
          </xsl:template>


  <xsl:template name="top-module">
    <xsl:param name="output-dir" tunnel="yes"/>

    <out:stylesheet
      version="2.0"
      trace:is-top="yes"
      exclude-result-prefixes="trace">

      <out:import href="{$output-dir}{$flattened/trace:result-document[1]/@href}"/>

      <out:param name="trace:indent" select="false()"/>
      <!--
      <out:param name="trace:indent" select="true()"/>
      -->

      <out:template match="/">
        <out:variable name="source-with-ids">
          <source-doc id="{{generate-id(.)}}">
            <out:apply-templates mode="to-string" select="."/>
          </source-doc>
        </out:variable>
        <out:result-document href="sources/{{trace:guid()}}.xml" method="xml" indent="no" omit-xml-declaration="yes">
          <out:sequence select="$source-with-ids"/>
        </out:result-document>
        <!-- Copy rule-tree.xml as is for downstream use in rendering -->
        <out:result-document href="rule-tree/rule-tree.xml" method="xml" omit-xml-declaration="yes">
          <out:copy-of select="document('{$output-dir}rule-tree.xml')"/>
        </out:result-document>
        <out:next-match>
          <out:with-param name="trace:invocation-id" select="'initial'"/>
        </out:next-match>
      </out:template>

      <xsl:copy-of select="document('to-string.xsl')/*/*" copy-namespaces="no"/>

    </out:stylesheet>
  </xsl:template>

          <xsl:template mode="source-with-ids" match="*">
            <trace:document-node id="{{generate-id(.)}}">
              <out:apply-templates mode="#current"/>
            </trace:document-node>
          </xsl:template>
          <!--
          <xsl:template mode="source-with-ids" match="/">
            <trace:document-node id="{{generate-id(.)}}">
              <out:apply-templates mode="#current"/>
            </trace:document-node>
          </xsl:template>

          <xsl:template mode="source-with-ids" match="">
          </xsl:template>
          -->


  <xsl:template mode="gather-code" match="/">
    <xsl:param name="result-href" select="substring-after(base-uri(.),$full-source-dir)"/>
    <trace:result-document href="{$result-href}">
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
    <!--
    <xsl:next-match/>
    -->
    <xsl:variable name="module-uri" select="resolve-uri(@href,base-uri(.))"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="trace:module-uri" select="$module-uri"/>
    </xsl:copy>
    <xsl:apply-templates mode="#current" select="document($module-uri)"/>
  </xsl:template>

  <!-- Make the default mode explicit -->
  <xsl:template mode="gather-code-insert" match="xsl:template[@match][not(@mode)] | xsl:apply-templates[not(@mode)]">
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
