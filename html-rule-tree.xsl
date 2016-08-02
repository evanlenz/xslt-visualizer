<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xdmp="http://marklogic.com/xdmp"
  xmlns:trace="http://lenzconsulting.com/tracexslt"
  exclude-result-prefixes="xs trace xdmp">

  <xsl:template name="jstree-head-stuff">
    <link rel="stylesheet" href="assets/jstree/dist/themes/default/style.css" />

    <!-- Bootstrap core CSS -->
    <!--
    <link href="assets/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    -->

    <style>
      body { /*font-size: 10px;*/ font-family: Arial,Segoe UI,Tahoma,Arial Narrow }
      .ui-tooltip { max-width: 100%; background: black; color: white; padding-bottom: 0 }
      .green { color: green; }
      .nomatch { color: #FFCCCC; opacity: .5 }
      .notMatched { opacity: .5 }
    </style>

    <style>
      /* Thanks to: https://gist.github.com/pontikis/1097570 */
      .modeTree a {
          white-space: normal !important;
          height: auto !important;
          padding: 1px 2px;
          font-size: .9em;
      }

      .modeTree li > ins {
          vertical-align: top;
      }

      .modeTree .jstree-hovered, .modeTree .jstree-clicked {
          border: 0;
      }
    </style>

    <!--
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
    -->
    <script src="assets/jstree/dist/jstree.min.js"></script>
    <!--
    <script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
    -->
  </xsl:template>

  <xsl:template mode="jstree-xslt-snippets" match="/">
    <div style="display:none;">
      <xsl:apply-templates mode="source-code" select="//rule"/>
    </div>
  </xsl:template>


  <!--
  <xsl:template mode="mode-tree" match="stages">
    <ul>
      <xsl:apply-templates mode="#current" select="*"/>
    </ul>
  </xsl:template>
  -->

  <xsl:template mode="mode-tree" match="rule-tree">
    <!--
    <xsl:variable name="position" select="1 + count(preceding-sibling::stage)"/>
    -->
    <xsl:apply-templates mode="mode-tooltip" select="mode"/>

    <!-- Stage tooltips -->
    <!--
    <div id="stage-{$position}-tooltip" class="stageTooltip" style="display:none;">
      <div style="max-width: 500px">
        <xsl:copy-of select="$t:rule-tree/stages/stage[$position]/documentation/node()"/>
      </div>
    </div>
    -->

    <div class="modeTree" id="modeTree">
    <!--
    <div class="modeTree" id="modeTree-{$position}">
    -->
      <!--
      <ul>
        <li data-jstree='{{ "opened" : true }}'>
          <span class="stageRoot">
          <!- -
          <span class="stageRoot" data-stage-position="{$position}">
          - ->
            <xsl:text>[main result]</xsl:text>
            <!- -
            <xsl:value-of select="@label"/>
            - ->
          </span>
          -->
          <ul>
            <xsl:apply-templates mode="#current" select="*"/>
          </ul>
        <!--
        </li>
      </ul>
      -->
    </div>
    <script>
      $(function(){
        var modeTree = $('#modeTree');
        <!--
        var modeTree = $('#modeTree-<xsl:value-of select="$position"/>');
        -->
        modeTree.jstree({"core": { "multiple":false, "animation":false, "themes":{"icons":false}}})
                .bind("open_node.jstree close_node.jstree", function() {drawConnectors()})
                .bind("select_node.jstree", function (e, data) {
                    modeTree.jstree(true).deselect_node(data.node);                    
                    modeTree.jstree(true).toggle_node(data.node);                    
                })
                .bind("hover_node.jstree", function (e, data) {
                    modeTree.jstree(true).dehover_node(data.node);                    
                })
                .bind("dblclick.jstree", function (event) {
                    var node = $(event.target).closest("li");
                    if (node.is(".jstree-leaf")) {
                      alert(node.attr("data-rule-id"));
                    }
                    else if ($(node).is(".jstree-closed"))
                      modeTree.jstree(true).open_all(node);
                    else
                      modeTree.jstree(true).close_all(node); // this part doesn't seem to work, oh well
                })
      });
    </script>
  </xsl:template>

  <xsl:template mode="mode-tooltip" match="mode">
    <div id="{generate-id(.)}" style="display:none">
      <div style="max-width: 500px">
        <xsl:copy-of select="documentation/node()"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template mode="mode-tree" match="mode">
    <li data-jstree='{{ "opened":true }}'>
      <span class="ruleMode" data-tooltip-id="{generate-id(.)}">
        <xsl:value-of select="@name"/>
        <!--
        <xsl:if test="@outputs-to-stage-result">
          <xsl:text>&#160;</xsl:text>
          <span class="glyphicon glyphicon-arrow-right"/>
        </xsl:if>
        -->
      </span>
      <ul>
        <xsl:apply-templates mode="#current" select="*"/>
      </ul>
    </li>
  </xsl:template>

  <xsl:template mode="mode-tree" match="rule">
    <!--
    <xsl:variable name="stage" select="../../@label"/>
    -->
    <xsl:variable name="rule-id" select="@id"/>
    <!--
    <xsl:variable name="matches" select="$t:trace-doc/*/trace:matches/match[@rule-id eq $rule-id]
                                                                           [@stage   eq $stage]"/>
                                                                           -->
    <xsl:variable name="matches" select="xdmp:estimate(xdmp:directory('/matches/')/trace:focus[@rule-id eq $rule-id])"/>
    <!--
    <xsl:variable name="jstree-config">
      <xsl:text>{ "icon":"glyphicon glyphicon-</xsl:text>
      <xsl:choose>
        <xsl:when test="$matches">ok green</xsl:when>
        <xsl:otherwise>ban-circle nomatch</xsl:otherwise>
      </xsl:choose>
      <xsl:text>"</xsl:text>
      <xsl:text>}</xsl:text>
    </xsl:variable>
    -->
    <xsl:variable name="jstree-config">{}</xsl:variable>
    <xsl:variable name="span-classes">
      <xsl:text>rule </xsl:text> <!-- needed for tooltip -->
      <!--
      <xsl:apply-templates mode="rule-color" select="../@type"/>
      <xsl:if test="not($matches)"> notMatched</xsl:if>
      -->
    </xsl:variable>
    <xsl:if test="$matches or string(@file)">
      <li data-jstree="{$jstree-config}" data-rule-id="{$rule-id}">
        <!--
        <xsl:if test="$matches">
          <xsl:attribute name="class" select="'fromRule'"/>
        </xsl:if>
        -->
        <!--
        <xsl:if test=". is /stages/stage[10]/mode[2]/rule[1]">
          <xsl:attribute name="id" select="'toTest'"/>
        </xsl:if>
        -->
        <!--
        <xsl:if test="$matches">
          <span class="toRule"/>
        </xsl:if>
        -->
        <span class="{$span-classes}" id="{@id}" data-id="{@id}_snippet">
        <!--
        <span class="{$span-classes}" data-id="{@id}">
        -->
        <!--
        <span class="{$span-classes}" data-id="{generate-id(.)}">
        -->
          <xsl:value-of select="@match"/>
        </span>
        <!--
        <xsl:for-each select="$matches">
          <span class="nodeMatch"
                data-node-path="{@node-path}"
                data-rule-id="{$rule-id}"/>
        </xsl:for-each>
        -->
      </li>
    </xsl:if>
  </xsl:template>

  <!--
  <xsl:template mode="rule-color" match="@type[. eq 'original-source']">originalSource</xsl:template>
  <xsl:template mode="rule-color" match="@type[. eq 'enriched-object']">enrichedObject</xsl:template>
  <xsl:template mode="rule-color" match="@type[. eq 'term-type']">termType</xsl:template>
  <xsl:template mode="rule-color" match="@type[. eq 'term']">term</xsl:template>
  -->

  <xsl:template mode="source-code" match="rule">
    <pre id="{@id}_snippet" data-file="{(@file[string(.)],'&lt;em>[built-in rule]&lt;/em>')[1]}">
      <xsl:if test="@priority">
        <xsl:attribute name="data-priority" select="@priority"/>
      </xsl:if>
      <xsl:value-of select="."/>
    </pre>
  </xsl:template>

  <!--
  <xsl:template mode="documentation" match="stage/documentation">
    <div id="{generate-id(.)}">
      <xsl:copy-of select="
    </div>
  </xsl:template>
  -->

</xsl:stylesheet>
