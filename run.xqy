xquery version "1.0-ml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

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
declare variable $compiled-dir := "/transforms/"||$code-dir||"/code/trace-enabled";

declare variable $ruleset-modules-options :=
  <options xmlns="xdmp:eval">
    <root>{$compiled-dir}/</root>
    <modules>{xdmp:database($trace-db-name)}</modules>
    <isolation>same-statement</isolation>
  </options>
;

xdmp:set-response-content-type("text/xml"),

xdmp:xslt-invoke(
  $stylesheet-file,
  xdmp:document-get(concat(xdmp:modules-root(),"example/"||$input-file)),
  (:
  document{
    <doc>
      <heading>This is the title</heading>
      <para>This is the first paragraph.</para>
      <para>This is the <emphasis>second</emphasis> paragraph.</para>
    </doc>
  },
  :)
  (),
  $ruleset-modules-options
)
