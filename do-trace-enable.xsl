<!DOCTYPE xsl:stylesheet [
<!ENTITY INVOKER "xsl:apply-templates | xsl:next-match | xsl:apply-imports">
]>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:out="dummy"
  xmlns:trace="http://lenzconsulting.com/tracexslt"
  xmlns:xdmp="http://marklogic.com/xdmp"
  xmlns:my="http://localhost"
  exclude-result-prefixes="xs xdmp out my">

  <xsl:template mode="trace-enable" match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*"/>
      <xsl:apply-templates mode="trace-enable-insert" select="."/>
      <xsl:apply-templates mode="trace-enable-content" select="."/>
    </xsl:copy>
  </xsl:template>

          <!-- by default, process children -->
          <xsl:template mode="trace-enable-content" match="*">
            <xsl:apply-templates mode="trace-enable"/>
            <xsl:apply-templates mode="trace-enable-append" select="."/>
          </xsl:template>

                  <!-- by default, don't append any content -->
                  <xsl:template mode="trace-enable-append" match="*"/>

          <!-- by default, don't insert anything -->
          <xsl:template mode="trace-enable-insert" match="*"/>


  <xsl:template mode="trace-enable-content" match="xsl:template">
    <!-- Make the namespaces available -->
    <xsl:namespace name="trace" select="'http://lenzconsulting.com/tracexslt'"/>
    <xsl:namespace name="xdmp" select="'http://marklogic.com/xdmp'"/>

    <xsl:copy-of select="xsl:param"/>

    <out:param name="trace:rule-mode" select="'#default'"/>
    <!--
    <out:param name="trace:invocation-id" select="'initial'"/>
    -->
    <!-- "initial" is now explicitly supplied (there should only be one) -->
    <out:param name="trace:invocation-id"/>
    <out:param name="trace:invocation-expression" select="'/'"/>
    <out:param name="trace:invocation-type" select="'apply-templates'"/>
    <!-- one for each apply-templates element within this rule, monotonically increasing -->
    <!-- TODO: add support for xsl:for-each; then restrict this to non-nested invocation descendants; then the child-invocation-id-[position] variable will be sufficient (non-ambiguous), I think -->
    <xsl:for-each select=".//(&INVOKER;)">
      <out:variable name="trace:child-invocation-id-{position()}" select="trace:guid()"/>
    </xsl:for-each>
    <out:variable name="trace:focus">
      <trace:focus context-id="{{generate-id(.)}}"
                   context-position="{{position()}}"
                   context-size="{{last()}}"
                   invocation-id="{{$trace:invocation-id}}"
                   invocation-expression="{{$trace:invocation-expression}}"
                   invocation-type="{{$trace:invocation-type}}"
                   rule-id="{@trace:rule-id}"
                   rule-mode="{{$trace:rule-mode}}"
                   constructor-type="template">
        <xsl:apply-templates mode="match-content" select="node() except xsl:param"/>
      </trace:focus>
    </out:variable>
    <out:sequence select="xdmp:document-insert(concat('{$matches-db-dir}',trace:guid()),
                                               $trace:focus)"/>
    <xsl:apply-templates mode="trace-enable" select="node() except xsl:param"/>
  </xsl:template>

          <xsl:template mode="match-content" match="@* | node()">
            <xsl:copy>
              <xsl:apply-templates mode="#current" select="@* | node()"/>
            </xsl:copy>
          </xsl:template>

          <xsl:template mode="match-content" match="&INVOKER;">
            <trace:invocation invocation-id="{{{my:expression-for-invocation-id(.)}}}">
              <xsl:copy-of select="@*"/>
              <xsl:if test="not(self::xsl:apply-templates)">
                <xsl:attribute name="type" select="local-name(.)"/>
              </xsl:if>
              <!-- no need to copy the with-params here (unless we decide to trace them later) -->
            </trace:invocation>
          </xsl:template>


  <xsl:template mode="trace-enable-append" match="&INVOKER;">
    <xsl:variable name="rule-mode" as="xs:string">
      <xsl:apply-templates mode="rule-mode" select="."/>
    </xsl:variable>
    <xsl:variable name="invocation-expression" as="xs:string">
      <xsl:apply-templates mode="invocation-expression" select="."/>
    </xsl:variable>
    <out:with-param name="trace:rule-mode" select="{$rule-mode}"/>
    <out:with-param name="trace:invocation-id" select="{my:expression-for-invocation-id(.)}"/>
    <out:with-param name="trace:invocation-expression" select="{$invocation-expression}"/>
    <out:with-param name="trace:invocation-type" select="'{local-name(.)}'"/>
  </xsl:template>

          <xsl:template mode="invocation-expression" match="*">
            <xsl:variable name="select" select="if (@select eq 'child::node()' or not(@select))
                                                then 'node()'
                                                else string(@select)"/>
            <xsl:sequence select="concat('&quot;',$select,'&quot;')"/>
          </xsl:template>
          <xsl:template mode="invocation-expression" match="xsl:apply-imports | xsl:next-match">
            <xsl:sequence select="&quot;'.'&quot;"/>
          </xsl:template>

          <xsl:template mode="rule-mode" match="xsl:apply-templates[@mode eq '#current']
                                              | xsl:next-match
                                              | xsl:apply-imports">
            <xsl:sequence select="'$trace:rule-mode'"/> <!-- stay with current mode -->
          </xsl:template>
          <xsl:template mode="rule-mode" match="xsl:apply-templates[not(@mode)]">
            <xsl:sequence select="&quot;'#default'&quot;"/>
          </xsl:template>
          <xsl:template mode="rule-mode" match="xsl:apply-templates">
            <xsl:sequence select="concat('&quot;',string(@mode),'&quot;')"/>
          </xsl:template>
          <xsl:template mode="rule-mode" match="xsl:for-each"> <!-- TODO: only relevant if we support xsl:for-each as aninvoker -->
            <xsl:sequence select="&quot;''&quot;"/>
          </xsl:template>


          <!-- FIXME: This is not yet sufficient for disambiguating between invocations -->
          <xsl:function name="my:expression-for-invocation-id">
            <xsl:param name="invoker"/>
            <xsl:text>concat($trace:child-invocation-id-</xsl:text>
            <xsl:value-of select="my:position-in-template($invoker)"/>
            <xsl:text>,'_',position())</xsl:text> <!-- position at run-time
                                                       (disambiguating when inside for-each) -->
          </xsl:function>

          <xsl:function name="my:position-in-template">
            <xsl:param name="invoker"/>
            <xsl:for-each select="$invoker/ancestor::xsl:template//(&INVOKER;)">
              <xsl:if test=". is $invoker">
                <xsl:sequence select="position()"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:function>

</xsl:stylesheet>
