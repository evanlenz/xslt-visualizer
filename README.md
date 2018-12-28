# xslt-visualizer
Home for a grand experiment in software visualization for XSLT.

[View a demo of the XSLT visualizer](http://xmlportfolio.com/xslt-visualizer-demo/)

Here are the steps to visualizing a transformation:

1. Trace-enable your XSLT (using trace-enable.xsl).
2. Apply the trace-enabled XSLT to a source document of your choice.
3. Render the resulting transformation metadata to HTML/JavaScript (using render.xsl).
4. View the HTML in your browser.

Some rudimentary shell scripts (respectively corresponding to steps 1, 2, and 3 above) are provided to show examples of how to do this.

    ./prepare.sh example
    ./trace.sh example
    ./render.sh example

Or you can run this:

    ./run-all.sh example

which will do all of the above in one script.

For now, it may be best to inspect these files directly to understand what they do, since they are only one or two lines each. You will likely need to change something; the scripts currently assume the Saxon-HE .jar file is installed at "C:/saxon/saxon9he.jar". Update them as necessary to conform to your environment.
