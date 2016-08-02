xquery version "1.0-ml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace trace="http://lenzconsulting.com/tracexslt";

declare option xdmp:mapping "false";

xdmp:set-response-content-type("text/xml"),

xdmp:xslt-invoke(
  "show-tree.xsl",
  collection()[trace:focus/@invocation-id eq 'initial'][1]
)
