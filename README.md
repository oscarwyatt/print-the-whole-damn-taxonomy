# README

This tool can be used to make a giant printout of the taxonomy, or just to see it in all it's splendour

### Running it

Just do `rails server` and go to `localhost:3000` and wait for it to load (can take a while)

### Exporting to PDF

You can export to a PDF by using the system print dialog to export to a PDF. Steps for Mac are as follows:
* Press `alt` + `cmd` + `p` to open the system print dialog
* The taxonomy will be a _little_ larger than A4 so click the Paper Size dropdown and then Manage Custom Sizes
* Click the `+` button to create a new size, enter the width and height (which I've conveniently included in the top right of the document), these can be a little on the optimistic side so you may need to increase them slightly to make everything fit on one page.
* Click OK
* In the bottom left corner of the Print dialog, click the PDF dropdown and then Save To PDF
* Enjoy!

### Printing it

Realistically, the only way of printing it is to create subsets of the `tree.csv` file with taxons of similar length that can be printed on a sheet roll plotter, otherwise you'll use tens of squared metres of paper

### Where do I get the Tree.csv file from

The entire taxon tree can be downloaded from Content Tagger, the requisite page on integration is `https://content-tagger.integration.publishing.service.gov.uk/taxons/f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a` and then click "Download tree as CSV".

This won't include custom metrics that I've devised, ways to include those will be added soon. 
 

