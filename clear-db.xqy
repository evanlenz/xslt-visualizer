xquery version "1.0-ml";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

(: clear database first :)
if (not(xdmp:database-name(xdmp:database()) eq 'xslt-visualizer'))
then
  error(xs:QName("WRONG_DB"),"Run this only against xslt-visualizer database")
else
  xdmp:directory-delete("/")
