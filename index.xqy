xquery version "1.0-ml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace trace="http://lenzconsulting.com/tracexslt";

declare variable $indent external := xdmp:get-request-field("indent","yes");
declare variable $stylesheet-uri external := xdmp:get-request-field("xslt","example/example.xsl");

declare option xdmp:mapping "false";

xdmp:set-response-content-type("text/html"),

let $params := map:map()
let $_ := map:put($params,'{}indent',($indent eq 'yes'))
let $_ := map:put($params,'{}code-dir',"/transforms/"||$stylesheet-uri||"/code/trace-enabled/")

return
  xdmp:xslt-invoke(
    "render.xsl",
    (:
    xdmp:directory("/transforms/"||$stylesheet-uri
    :)
    collection()[trace:focus/@invocation-id eq 'initial'][1],
    $params
  )
