# T3-Build-Tool-Prototype

Currently this tool calculates the profit for building various T3 items based on buying the materials for a given item at the current Jita Sell rate, then building and selling the item to the same Sell rate.

Market data is from Eve-central API.
Build fee data is derived from CREST and the Eve-industry APIs. 

To use this tool:

1. Download everything into a folder
2. Open the file "Pricing.R", either in text editor or R Studio
3. Update the first five variables.  If all you are doing is using the program as configured fot Atlas, you only need to update the single "directory variable.
4. Save the program.
5. Run/source the program.  If using Rstudio, check "Source on Svae" to ensure this happens.  The program takes about 1-3 minutes to run, depending.
6. Upon completion use either of the functions printRawProfits() or printMarginProfits() to a get a list of the most profitbale items by raw or marginal isk vale.  The argument for both functions is the number of rows you want returned.  printRawProfit(20) will give the 20 most profitable items.

