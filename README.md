[![Build Status](https://travis-ci.org/keblu/MSGARCH.svg?branch=master)](https://travis-ci.org/keblu/MSGARCH)

# Installation 
```
library(devtools)
install_github("keblu/GWP")
```
# What does the package do

The GWP package implements the Generalized Word Power method for lexicon calibration on continuous variables as in Ardia et al. (2019). The Generalized Word Power method is a generalization of the Jegadeesh and Wu (2013) Word Power methodology. 

The choice of an extraction method for the sentiment or tone of textual documents is an important consideration. In finance, for example, the reference lexicon is the dictionary developed by Loughran and McDonald (2011). Depending on the type of document targetted and what we want to extract from the textual data, certain lexicon may not be adequate. The generalized Word Power methodology is a data–driven tone computation methodology which relates the tone to an underlying variable of interest with regards to an entity.

The goal is to compute the predictive value of words in a written publication for explaining a variable of interest. This variable can be the accounting performance, stock return of a firm, or even the volatility of the financial market. Besides a careful selection of the relevant texts, this requires a definition of the intratextual and across–text aggregation method. Under The Generalized Word Power approach, the aggregated tone is a weighted sum of the relative frequency of the written words in selected texts for a given period. The weight or scores are calibrated to a target variables of interest.

# Reference

 **Ardia, D., Bluteau, K., Boudt, (2019).**  
*Media and the Stock Market: Their Relationship and Abnormal Dynamics Around Earnings Announcements</em>.*  
Working Paper.   
http://dx.doi.org/10.2139/ssrn.3192064

 **Jegadeesh, N. and Wu, D., (2013).**  
*Word power: A new approach for content analysis</em>.*  
Journal of Financial Economics, 110(3), pp.712-729.   
https://doi.org/10.1016/j.jfineco.2013.08.018

 **Loughran, T. and McDonald, B., 2011., (2011).**  
*When is a liability not a liability? Textual analysis, dictionaries, and 10‐Ks</em>.*  
Journal of Finance, 66(1), pp.35-65.   
https://doi.org/10.1111/j.1540-6261.2010.01625.x
