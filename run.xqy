xquery version "1.0-ml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace trace="http://lenzconsulting.com/tracexslt";

declare option xdmp:mapping "false";
declare option xdmp:update "true";

declare variable $stylesheet-file external := xdmp:get-request-field("xslt","example.xsl");
declare variable $input-file external      := xdmp:get-request-field("xml","example.xml");

declare variable $document-get-options :=
    <options xmlns="xdmp:document-get">
      <format>xml</format>
    </options>;

declare variable $code-dir := "example/"||$stylesheet-file;

declare variable $trace-db-name := "xslt-visualizer";
declare variable $compiled-dir := "/transforms/"||$code-dir||"/code/trace-enabled/";

declare variable $top-xslt := xdmp:directory($compiled-dir)[*/@trace:is-top eq 'yes'];

declare variable $stylesheet-uri := substring-after(base-uri($top-xslt),($compiled-dir));

declare variable $ruleset-modules-options :=
  <options xmlns="xdmp:eval">
    <root>{$compiled-dir}</root>
    <modules>{xdmp:database($trace-db-name)}</modules>
    <isolation>same-statement</isolation>
  </options>
;

xdmp:set-response-content-type("text/xml"),

xdmp:log(base-uri($top-xslt)),
xdmp:xslt-invoke(
  $stylesheet-uri,
  xdmp:document-get(concat(xdmp:modules-root(),"example/"||$input-file)),
  (),
  $ruleset-modules-options
)
