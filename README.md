# xslt-visualizer
Home for a grand experiment in software visualization for XSLT

[View a demo of the XSLT visualizer](http://xmlportfolio.com/xslt-visualizer-demo/) (or [read the paper](https://www.balisage.net/Proceedings/vol17/html/Lenz01/BalisageVol17-Lenz01.html) and [view the slides](https://www.slideshare.net/evanlenz/the-mystical-principles-of-xslt-enlightenment-through-software-visualization))

Here are the steps to visualizing a transformation:

0. Install [Saxon-HE](http://saxon.sourceforge.net/#F9.9HE) or better.
1. Trace-enable your XSLT (using trace-enable.xsl).
2. Apply the trace-enabled XSLT to a source document of your choice.
3. Render the resulting transformation metadata to HTML/JavaScript (using render.xsl).
4. View the HTML in your browser.

Some very rudimentary shell scripts (respectively corresponding to steps 1, 2, and 3 above) are provided to show examples of how to do this.

    ./prepare.sh example
    ./trace.sh example
    ./render.sh example

Or you can run this:

    ./run-all.sh example

to run all three steps with one command.

To view the results (step 4), open build/example/visualized/example.html in your browser.

You will likely need to change something in the shell scripts; they currently assume the Saxon-HE .jar file is installed at "C:/saxon/saxon9he.jar". Update them as necessary to conform to your environment.

For now, it may be best to inspect these shell scripts directly to better understand the steps; each is only a few lines long. 
