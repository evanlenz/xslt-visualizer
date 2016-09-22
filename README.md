# xslt-visualizer
Home for a grand experiment in software visualization for XSLT.

[View a demo of the XSLT visualizer](http://xmlportfolio.com/xslt-visualizer-demo/)

The initial version is very much slapped together with hard-coded file names, etc.

You should be able to run this demo if you:

1. Install MarkLogic if you don't already have it.
2. Create a new database (and a forest), named "xslt-visualizer".
3. Create an app server associated to that database and with the
   app server root set to your local checkout of this git project
   and port 8005 (or any other port).
4. Clear the database (won't be necessary the first time) by clicking
   [http://localhost:8005/clear-db.xqy](http://localhost:8005/clear-db.xqy)
5. Trace-enable the example XSLT by clicking
   [http://localhost:8005/trace.xqy](http://localhost:8005/trace.xqy)
6. Run the trace-enabled XSLT against the sample input document:
   [http://localhost:8005/run.xqy](http://localhost:8005/run.xqy)
7. Finally, view the result: [http://localhost:8005/](http://localhost:8005/)

For development so far, I repeat steps 4 through 7 each time I make a code change.

Assuming further development, this hacked-together routine will get replaced
with a more general framework.
