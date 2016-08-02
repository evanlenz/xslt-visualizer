(: See: https://help.marklogic.com/knowledgebase/article/View/7/15/generating-unique-ids-guids :)
xquery version "1.0-ml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

declare function local:random-hex($seq as xs:integer*) as xs:string+ {
  for $i in $seq return 
    fn:string-join(for $n in 1 to $i
      return xdmp:integer-to-hex(xdmp:random(15)), "")
};

declare function local:guid() as xs:string {
  fn:string-join(local:random-hex((8,4,4,4,12)),"-")
};

xdmp:xslt-invoke("test.xsl",document{<foo>1234</foo>}),
local:guid()
