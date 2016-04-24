# T3-Build-Tool-Prototype

# Dependencies

The following packages are required:

XML

dplyr

Jsonlite

# Overview
Currently this tool calculates the profit for building various T3 items based on buying the materials for a given item at the current Jita Sell rate, then building and selling the item to the same Sell rate.

Market data is from Eve-central API.
Build fee data is derived from CREST and the Eve-industry APIs. 

# Instructions

To use this tool:

1. Download everything into a folder
2. Open the file "Pricing.R", either in text editor or R Studio.
3. Mke sure you have the libraries specified.  If using R Studio, go to Tools > Install packages to do this.
3. Update the first five variables.  If all you are doing is using the program as configured for Atlas, you only need to update the single "directory" variable.  If on windows, you will have to convert the file path to a Unix-like string.  For example "C:\thing\place" is "C:/thing/place".
4. Save the program.
5. Run/source the program.  If using Rstudio, check "Source on Save" to ensure this happens.  The program takes about 1-3 minutes to run, depending.
6. Upon completion use either of the functions printRawProfits() or printMarginProfits() to a get a list of the most profitable items by raw or marginal isk value.  The argument for both functions is the number of rows you want returned.  For example, "> printRawProfits(20)" will give the 20 most profitable items.

# Notes

The profits are only calculated on a single build step.  If all items in the build step are also profitbale, then you stand to make MORE profit if you go further back in the build chain.

The sell values are the 5% field from eve-central.  In theory this should buffer out super low sell orders.

# To Do

Build in stepwise profitablity.

Build in profit tables for each class of item (hull, subs, materials).

Add support for gas reactions.

Expand support for T2/T1 items.

