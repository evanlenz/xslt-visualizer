<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:trace="http://lenzconsulting.com/tracexslt"
  xmlns:my="http://localhost"
  exclude-result-prefixes="xs trace my">

  <xsl:import href="html-rule-tree.xsl"/>

  <xsl:output method="html" indent="no"/>

  <xsl:param name="indent" select="true()"/>

  <xsl:variable name="input-file-name" select="tokenize(base-uri(.),'/')[last()]"/>

  <!-- ASSUMPTION: the primary input document is the initial focus and is a sibling of the matches directory -->
  <xsl:variable name="rule-tree"   select="document  (resolve-uri(concat($input-file-name,'.rule-tree/rule-tree.xml'), base-uri(.)))"/>
  <xsl:variable name="source-tree" select="collection(resolve-uri(concat($input-file-name,'.sources'),                 base-uri(.)))"/>
  <xsl:variable name="all-matches" select="collection(resolve-uri(concat($input-file-name,'.matches'),                 base-uri(.)))
                                         | ."/>  <!-- primary input document is the initial match -->

  <xsl:template match="/">
    <xsl:variable name="foci-array-objects"><!-- as="element()*">-->
      <xsl:apply-templates mode="focus-object" select="trace:focus"/>
    </xsl:variable>
    <xsl:variable name="slider-array-arrays" as="element()*">
      <xsl:apply-templates mode="focus-array" select="$foci-array-objects//object"/>
    </xsl:variable>
    <xsl:variable name="breadth-first-array">
      <xsl:apply-templates mode="focus-array" select="$foci-array-objects//object">
        <xsl:sort select="count(ancestor::group)"/>
        <xsl:sort select="position()"/>
      </xsl:apply-templates>
    </xsl:variable>
    <html>
      <head>
        <title>XSLT Visualizer</title>
        <script src="assets/jquery/jquery-3.1.0.min.js"/>
        <script src="assets/jquery-ui/jquery-ui.min.js"/>
        <link rel="stylesheet" href="assets/jquery-ui/jquery-ui.css"/>
        <!--
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.1.0/jquery.min.js"/>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.12.0/jquery-ui.js"/>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.12.0/jquery-ui.css"/>
        -->
        <script src="assets/belay.js"/>
        <style>
          body { overflow: hidden }
          #sliderWidget { position: fixed; width: 80% }
          #columns { margin: 0; height: 100vh; width: 100vw; }
          #sourceTree, #resultTree, #rules { height: 100vh; width: 33vw; overflow: scroll }
          #sourceTree, #rules, #resultTree { float: left; }
          pre { margin:0; }
          .unmanifested { font-style: italic }
          svg { pointer-events: none; }
        </style>
        <script>
          var slider;
          var foci = [
            <xsl:apply-templates mode="object-list-syntax" select="$foci-array-objects"/>
          ];
          var sliderDepthFirst = [
            <xsl:apply-templates mode="array-list-syntax" select="$slider-array-arrays"/>
          ];
          var sliderBreadthFirst = [
            <xsl:apply-templates mode="array-list-syntax" select="$breadth-first-array"/>
          ];
        </script>
        <script>
          <!--
          $(function(){
             $('#slider').drag(function(){
               var focus = foci[$(this).val()];
               console.log(focus.outputId);
             });
          });
          -->

          var drawConnectors;
          var sliderPosition = 0;
          var currentOutput;
          //var currentFoci;
          var colors = {};
          var accumulateLines;

          var drawConnectors = function() {
            Belay.off();

            $(".start,.end").css("visibility","hidden");

            //console.log(sliderPosition);

            var showFoci = function(index) {
              var currentFoci = slider[index];
              for (var i=0; currentFoci.length > i; i++) {
                //console.log("processing focus "+i);
                //console.log(focus);
                var focus = foci[currentFoci[i]];

                var invocationId = focus.invocationId;

                //initializeColors(invocationId);

                Belay.set('strokeColor', colors[invocationId]);

                <!-- Using a different color for each focus --><!--
                if (focus.color == undefined)
                  focus.color = getRandomColor();
                Belay.set('strokeColor', focus.color);
                -->

                /*
                $("#"+focus.outputId).css("display","inline");
                $("#"+focus.outputId).css("background-color",colors[invocationId]);
                */

                drawLine(focus.contextId, focus.ruleId);
                drawLine(focus.ruleId, focus.outputStart);
                drawLine(focus.ruleId, focus.outputEnd);
                //drawLine(focus.ruleId, focus.outputStart, "down");
                //drawLine(focus.ruleId, focus.outputEnd, "up");
              }
            };
            if (accumulateLines) {
              for (var i=0; sliderPosition >= i; i++) {
                showFoci(i);
              }
            }
            else
              if (sliderPosition != -1)
                showFoci(sliderPosition);
          };

          function drawLine(fromId, toId, hookDirection){
            <!--
            var from = document.getElementById(foci[1].outputStart);
            var to   = document.getElementById(foci[5].outputStart);
            -->
            <!--
            var from = document.getElementById(fromId);
            var to   = document.getElementById(toId);
            -->

            /*
            console.log(fromId);
            console.log(toId);
            */

            var from = $("#"+fromId)[0];
            var to   = $("#"+toId);
            to.css("visibility","visible");
            to = to[0];

            <!--
            var from = $("#"+foci[1].outputStart)[0];
            var to   = $("#"+foci[5].outputStart)[0];
            -->

            Belay.on(from, to, hookDirection);
            /*
            console.log(from);
            console.log(to);
            */
            <!--
            console.log(foci[1].outputStart);
            console.log(foci[5].outputStart);
            -->
          }

          // http://stackoverflow.com/questions/1484506/random-color-generator-in-javascript
          function getRandomColor() {
              var letters = '0123456789ABCDEF'.split('');
              var color = '#';
              for (var i = 0; i &lt; 6; i++ ) {
                  color += letters[Math.floor(Math.random() * 16)];
              }
              return color;
          }

          $(function(){

            var initializeColors = function(invocationId) {
              if (colors[invocationId] == undefined) {
                colors[invocationId] = getRandomColor();
                var color = colors[invocationId];
                var fociToColor = foci.filter(
                  function(focus) {
                    return focus.invocationId == invocationId
                  }
                );
                for (var i = 0; fociToColor.length > i; i++) {
                  $("#"+fociToColor[i].outputStart).css("color",color);
                  $("#"+fociToColor[i].outputEnd).css("color",color);
                  $("#"+fociToColor[i].outputId+" > .unmanifested > .rightArrow").css("color",color);
                }
              }
            };
            // Initialize all the colors up front
            for (var i = 0; foci.length > i; i++) {
              var invocationId = foci[i].invocationId;
              initializeColors(invocationId);
            }

            var showAndHide = function() {
              // Show everything so far
              for (var i=0; sliderPosition >= i; i++) {
                var currentFoci = slider[i];
                for (var j=0; currentFoci.length > j; j++) {
                  showResults(foci[currentFoci[j]])
                }
              }
              // And hide the rest
              for (var i=sliderPosition+1; foci.length > i; i++) {
                var currentFoci = slider[i];
                for (var j=0; currentFoci.length > j; j++) {
                  hideResults(foci[currentFoci[j]])
                }
              }
            };

            var scrollTo = function(target, container, doAnimate) {
              var scrollAdjustment = $(window).height() / 2;
              var targetTop = target.offset().top - container.offset().top + container.scrollTop() - scrollAdjustment;

              if (doAnimate)
                container.animate({scrollTop: targetTop}, 500);
              else
                container.scrollTop(targetTop);
            };

            var scrollTrees = function(doAnimate) {
              var firstFocus = foci[slider[sliderPosition][0]];

              var sourceNode  = $("#"+firstFocus.contextId);
              var rule        = $("#"+firstFocus.ruleId);
              var resultChunk = $("#"+firstFocus.outputStart);

              var sourceTree = $("#sourceTree");
              var rules      = $("#rules");
              var resultTree = $("#resultTree");

              if (sourceNode.is(":visible"))  scrollTo(sourceNode, sourceTree, doAnimate);
              if (rule.is(":visible"))        scrollTo(rule, rules, doAnimate);
              if (resultChunk.is(":visible")) scrollTo(resultChunk, resultTree, doAnimate);
            };

            $("#sourceTree").scroll(function(){ drawConnectors(); });
            $("#rules").scroll(function(){ drawConnectors(); });
            $("#resultTree").scroll(function(){ drawConnectors(); });

            var sliderHandler = function(newPosition, doAnimate) {
                sliderPosition = newPosition;
                showAndHide();
                drawConnectors();
                if (sliderPosition != -1)
                  scrollTrees(doAnimate);
            };

            $("#sliderWidget").slider({
              min: -1,
              max: <xsl:value-of select="count($slider-array-arrays) - 1"/>,
              value: -1,
              slide: function(event, ui) { sliderHandler(ui.value, false) }
            });

            $("span[data-rule-id]").click(function(e) {
              var span = $(e.target).closest("span[data-rule-id]");
              var outputId = span.attr("id");
              var newPosition = findSliderPosition(outputId);
              $("#sliderWidget").slider("value", newPosition);
              sliderHandler(newPosition, true);
              e.stopPropagation();
            });

            var findSliderPosition = function(outputId) {
              var i;
              for (i = 0, len = foci.length; len > i; i++) {
                if (foci[i].outputId == outputId)
                  break;
              }
              var focusPosition = i;
              var j;
              for (j = 0, len = slider.length; len > j; j++) {
                if (slider[j][0] == focusPosition)
                  break;
              }
              var sliderPos = j;
              return sliderPos;
            };

            var showResults = function(focus) {
              $("#"+focus.outputId + " > .manifested"  ).show();
              $("#"+focus.outputId + " > .unmanifested").hide();
            };

            var hideResults = function(focus) {
              $("#"+focus.outputId + " > .unmanifested").show();
              $("#"+focus.outputId + " > .manifested"  ).hide();
            };

            Belay.init({strokeWidth: 1, animate: false});

/*

                  currentOutput.css("display","none");
                currentOutput = $("#"+focus.outputId);
                currentOutput.css("display","inline");
                */

            //drawConnectors();

            $(window).resize(function(){
              drawConnectors();
            });

            accumulateLines = $("#accumulateLines").is(":checked");
            $("#accumulateLines").change(function() {
              accumulateLines = $(this).is(":checked");
              drawConnectors();
            });

            var initSlider = function() {
              slider = breadthFirst ? sliderBreadthFirst : sliderDepthFirst;
            };

            var breadthFirst = $("#breadthFirst").is(":checked");
            initSlider();

            $("#breadthFirst").change(function() {
              var outputId = foci[slider[sliderPosition][0]].outputId;
              breadthFirst = $(this).is(":checked");
              initSlider();
              var newPosition = findSliderPosition(outputId);
              $("#sliderWidget").slider("value", newPosition);
              sliderHandler(newPosition, false);
              showAndHide();
              drawConnectors();
            });

          });
        </script>
        <!-- tooltip configuration -->
        <script>
					$(function() {

						$( document ).tooltip({
							items: ".rule, .stageRoot, .ruleMode",
							show: false,
							content: function() {
								var element = $(this);
								if (element.is(".rule")) {
									var span = $(this);
									var pre = $("#"+span.attr("data-id"));
									var priority = pre.attr("data-priority");
									var priorityNote = (typeof(priority) != "undefined") ?
																		 "<div> " +
																				"<tt>priority=\"" + priority + "\"</tt>" +
																		 "</div>" :
																		 "";
									var content = pre.html();
									var contentLength = content.length;
									var preString = "&lt;pre>" + content + "&lt;/pre>";
										/*
										(contentLength > 2000)
										? "&lt;pre style='font-size:8px'>" + content.substring(1,2000) + "&lt;/pre>"
										: "&lt;pre>" + content + "&lt;/pre>";
										*/

									return "<div>Module: " + pre.attr("data-file") + "</div>" + priorityNote + preString;
								}
<!--
								if (element.is(".stageRoot")) {
									var position = $(this).attr("data-stage-position");
									return $("#stage-"+position+"-tooltip").html();
								}
-->
								if (element.is(".ruleMode")) {
									return $("#"+$(this).attr("data-tooltip-id")).html();
								}
							},
							position: { my: "left top+15", at: "left bottom", collision: "flipfit" },
							show: 2500
						});
					});
				</script>
        <xsl:call-template name="jstree-head-stuff"/>
      </head>
      <body>
        <xsl:apply-templates mode="jstree-xslt-snippets" select="$rule-tree"/>
        <div>
          <div id="sliderWidget"/>
          <div style="position: fixed; right: 30px; font-size: smaller">
            <input id="accumulateLines" type="checkbox"/>
            Cumulative?
            <br/>
            <input id="breadthFirst" type="checkbox"/>
            Breadth first?
          </div>
        </div>
        <div id="columns">
          <div id="sourceTree">
            <br/>
            <pre>
              <xsl:apply-templates mode="source-tree" select="$source-tree"/>
            </pre>
              <!--
              <xsl:for-each select="distinct-values($foci-array-objects//contextId)">
                <xsl:sort select="."/> <!- - arbitrary stable order for now - ->
                <div id="{.}">
                  <xsl:value-of select="."/>
                </div>
              </xsl:for-each>
              -->
          </div>
          <div id="rules">
            <br/>
            <xsl:apply-templates mode="mode-tree" select="$rule-tree"/>
              <!--
              <xsl:for-each select="distinct-values($foci-array-objects//ruleId)">
                <xsl:sort select="."/> <!- - arbitrary stable order for now - ->
                <div id="{.}">
                  <xsl:value-of select="."/>
                </div>
              </xsl:for-each>
              -->
          </div>
          <div id="resultTree">
            <br/>
            <pre>
              <xsl:apply-templates>
                <xsl:with-param name="depth" select="0" tunnel="yes"/>
              </xsl:apply-templates>
            </pre>
          </div>
        </div>
        <!--
        <pre>
          <xsl:value-of select="xdmp:quote($slider-array-arrays)"/>
        </pre>
        <pre>
          <xsl:value-of select="xdmp:quote(/)"/>
        </pre>
        -->
      </body>
    </html>
  </xsl:template>

          <xsl:template mode="source-tree" match="/source-doc">
            <span id="{@id}">Ⓓ</span>
            <xsl:apply-templates mode="#current"/>
          </xsl:template>

          <xsl:template mode="source-tree" match="@* | node()">
            <xsl:copy>
              <xsl:apply-templates mode="#current" select="@* | node()"/>
            </xsl:copy>
          </xsl:template>


  <xsl:template mode="array-list-syntax" match="array">
    [
      <xsl:apply-templates mode="#current" select="item[. >= 0]"/>
    ]
    <xsl:if test="position() ne last()">, </xsl:if>
  </xsl:template>

          <xsl:template mode="array-list-syntax" match="item">
            <xsl:value-of select="."/>
            <xsl:if test="position() ne last()">, </xsl:if>
          </xsl:template>

  <xsl:template mode="object-list-syntax" match="object">
    {
      <xsl:apply-templates mode="#current" select="*"/>
    }
    <xsl:if test="position() ne last()">,</xsl:if>
  </xsl:template>

          <xsl:template mode="object-list-syntax" match="group">
            <xsl:apply-templates mode="#current"/>
            <xsl:if test="position() ne last()">,</xsl:if>
          </xsl:template>

          <xsl:template mode="object-list-syntax" match="*">
            <xsl:value-of select="local-name()"/>: '<xsl:value-of select="."/>'
            <xsl:if test="position() ne last()">, </xsl:if>
          </xsl:template>

  <xsl:template mode="focus-array" match="object">
    <array>
      <!-- all at once
      <xsl:for-each select="1 to last()">
        <item>
          <xsl:value-of select=". - 1"/>
        </item>
      </xsl:for-each>
      -->
      <!-- 3-focus window; maybe a bit broken right now (after adding the -1 spot on the slider?)
      <item>
        <xsl:value-of select="position() - 3"/>
      </item>
      <item>
        <xsl:value-of select="position() - 2"/>
      </item>
      <item>
        <xsl:value-of select="position() - 1"/>
      </item>
      -->
      <!-- one-focus window -->
      <item>
        <xsl:value-of select="count(preceding::object)"/>
      </item>
      <!--
      <item>
        <xsl:value-of select="position() - 1"/>
      </item>
      -->
    </array>
  </xsl:template>

  <xsl:template mode="focus-object" match="trace:focus">
   <group>
    <object>
      <invocationId>
        <xsl:value-of select="@invocation-id"/>
      </invocationId>
      <!-- TODO: is this needed? If so, make sure it's escaped so apostrophes in the expression don't create JS parsing problems
      <invocationExpression>
        <xsl:value-of select="@invocation-expression"/>
      </invocationExpression>
      -->
      <contextId>
        <xsl:value-of select="@context-id"/>
      </contextId>
      <ruleId>
        <xsl:value-of select="@rule-id"/>
      </ruleId>
      <ruleMode>
        <xsl:value-of select="@rule-mode"/>
      </ruleMode>
      <constructorType>
        <xsl:value-of select="@constructor-type"/>
      </constructorType>
      <outputId>
        <xsl:value-of select="my:output-id(.)"/>
      </outputId>
      <outputStart>
        <xsl:value-of select="my:start-id(.)"/>
      </outputStart>
      <outputEnd>
        <xsl:value-of select="my:end-id(.)"/>
      </outputEnd>
    </object>
    <xsl:apply-templates mode="#current" select=".//trace:invocation"/>
   </group>
  </xsl:template>

  <xsl:template mode="focus-object" match="trace:invocation">
    <xsl:param name="depth" tunnel="yes" select="0"/>
    <xsl:apply-templates mode="#current" select="$all-matches ! trace:focus[@invocation-id eq current()/@invocation-id]">
      <xsl:sort select="@context-position" data-type="number"/>
      <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>

          <xsl:function name="my:output-id">
            <xsl:param name="focus"/>
            <xsl:sequence select="concat($focus/@invocation-id,'_',
                                         $focus/@context-position)"/>
          </xsl:function>
          <xsl:function name="my:start-id">
            <xsl:param name="focus"/>
            <xsl:sequence select="concat(my:output-id($focus),'_start')"/>
          </xsl:function>

          <xsl:function name="my:end-id">
            <xsl:param name="focus"/>
            <xsl:sequence select="concat(my:output-id($focus),'_end')"/>
          </xsl:function>

  <xsl:template match="trace:focus">
    <span id="{my:output-id(.)}" data-rule-id="{@rule-id}">
      <xsl:if test="$indent">
        <br/>
      </xsl:if>
      <xsl:apply-templates mode="indent" select="."/>
      <span class="manifested" style="display:none">
        <span class="start" id="{my:start-id(.)}"><!--▾-->▼<!--&#160;--></span>
        <xsl:if test="$indent">
          <br/>
        </xsl:if>
        <xsl:apply-templates mode="indent" select="."/>
        <xsl:apply-templates mode="to-string"/>
          <!--
          <xsl:with-param name="already-indented" select="true()"/>
        </xsl:apply-templates>
        -->
        <xsl:if test="$indent">
          <br/>
        </xsl:if>
        <xsl:apply-templates mode="indent" select="."/>
        <span class="end" id="{my:end-id(.)}"><!--▴-->▲<!--&#160;--></span>
      </span>
      <span class="unmanifested">
        <span class="rightArrow">
          <xsl:text>►</xsl:text>
          <!--
          <xsl:text>▸</xsl:text>
          -->
        </span>
        <xsl:text>&lt;xsl:</xsl:text><!--►-->
        <xsl:value-of select="@invocation-type"/>
        <xsl:apply-templates mode="show-mode" select="."/>
        <xsl:apply-templates mode="show-select" select="."/>
        <xsl:if test="not(@invocation-type eq 'for-each')">/</xsl:if>
        <xsl:text>&gt; (</xsl:text>
        <xsl:value-of select="@context-position"/>
        <xsl:text> of </xsl:text>
        <xsl:value-of select="@context-size"/>
        <xsl:text>)</xsl:text>
        <!--
        <xsl:value-of select="@context-size - @context-position + 1"/>
        <xsl:text> more)</xsl:text>
        -->
      </span>
    </span>
  </xsl:template>

          <xsl:template mode="show-mode" match="trace:focus"/>
          <xsl:template mode="show-mode" match="trace:focus[@invocation-type eq 'apply-templates']">
            <xsl:if test="not(@rule-mode eq '#default')">
              <xsl:text> mode="</xsl:text>
              <xsl:value-of select="@rule-mode"/>
              <xsl:text>"</xsl:text>
            </xsl:if>
          </xsl:template>

          <xsl:template mode="show-select" match="trace:focus[@invocation-type = ('next-match','apply-imports')]"/>
          <xsl:template mode="show-select" match="trace:focus[@invocation-type eq 'apply-templates']
                                                             [@invocation-expression eq 'node()']"/>
          <xsl:template mode="show-select" match="trace:focus">
            <xsl:text> select="</xsl:text>
            <xsl:value-of select="@invocation-expression"/>
            <xsl:text>"</xsl:text>
          </xsl:template>

  <xsl:template mode="to-string" match="trace:invocation">
    <xsl:apply-templates select="$all-matches ! trace:focus[@invocation-id eq current()/@invocation-id]">
      <xsl:sort select="@context-position" data-type="number"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="to-string" match="*">
<xsl:param name="already-indented"/>
<xsl:param name="depth" tunnel="yes"/>
<xsl:if test="$indent">
<xsl:if test="not($already-indented)">
  <xsl:text>&#xA;</xsl:text>
  <xsl:apply-templates mode="indent" select="."/>
</xsl:if>
</xsl:if>
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:apply-templates mode="#current" select="@*"/>
    <xsl:text>></xsl:text>
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="depth" select="$depth + 1" tunnel="yes"/>
    </xsl:apply-templates>
<xsl:if test="$indent">
<xsl:if test="*">
<xsl:text>&#xA;</xsl:text>
<xsl:apply-templates mode="indent" select="."/>
</xsl:if>
</xsl:if>
    <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>></xsl:text>
  </xsl:template>

  <xsl:template mode="to-string" match="text()">
    <!--
    <xsl:param name="depth"/>
    <xsl:apply-templates mode="indent" select=".">
      <xsl:with-param name="depth" select="$depth"/>
    </xsl:apply-templates>
    -->
    <xsl:value-of select="replace(replace(.,'&lt;','&amp;lt;'),'&amp;','&amp;amp;')"/>
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
    <xsl:param name="depth" tunnel="yes"/>
    <xsl:if test="$indent">
      <xsl:value-of select="string-join(for $n in (1 to $depth) return '  ','')"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
