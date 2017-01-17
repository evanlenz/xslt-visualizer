xquery version "1.0-ml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";
declare option xdmp:output "indent-untyped=no";
declare option xdmp:output "indent=no";

declare variable $stylesheet-file external := xdmp:get-request-field("xslt","example.xsl");

declare variable $document-get-options :=
    <options xmlns="xdmp:document-get">
      <format>xml</format>
    </options>;

xdmp:set-response-content-type("text/xml"),

let $source-dir := "example/"
let $stylesheet-uri := $source-dir||$stylesheet-file

let $params := map:map()
let $_ := map:put($params,"{}source-dir",$source-dir)
let $trace-enabled :=
  xdmp:xslt-invoke(
    "trace-enable.xsl",
    xdmp:document-get(concat(xdmp:modules-root(),$stylesheet-uri), $document-get-options),
    $params
  )

let $code-dir := "/transforms/"||$stylesheet-uri||"/code/trace-enabled/"
let $main-uri := $code-dir||$trace-enabled/result-docs/*[1]/@href/string(.)
let $_ := $trace-enabled/result-docs/*:result-document[not(@href = preceding-sibling::*:result-document/@href)]
                                                 ! xdmp:document-insert($code-dir||@href, document{*})
let $_ := $trace-enabled/result-docs/*:rule-tree ! xdmp:document-insert($code-dir||'rule-tree.xml', document{.})

return
$trace-enabled
