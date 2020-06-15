[![Build Status](https://travis-ci.org/keblu/MSGARCH.svg?branch=master)](https://travis-ci.org/keblu/MSGARCH)

# Installation 
```
library(devtools)
install_github("keblu/GWP")
```

# Disclaimer

This is currently the first version of the package. Expect bugs and issues, as well as future changes.
# What does the package do

The GWP package implements the Generalized Word Power method for lexicon calibration on continuous variables as in Ardia et al. (2019). The Generalized Word Power method is a generalization of the Jegadeesh and Wu (2013) Word Power methodology. 

The choice of an extraction method for the sentiment or tone of textual documents is an important consideration. In finance, for example, the reference lexicon is the dictionary developed by Loughran and McDonald (2011). Depending on the type of document targetted and what we want to extract from the textual data, certain lexicon may not be adequate. The Generalized Word Power methodology is a data–driven tone computation methodology which relates the tone to an underlying variable of interest with regards to an entity.

The goal is to compute the predictive value of words in a written publication for explaining a variable of interest. This variable can be the accounting performance, stock return of a firm, or even the volatility of the financial market. Besides a careful selection of the relevant texts, this requires a definition of the intratextual and across–text aggregation method. Under The Generalized Word Power approach, the aggregated tone is a weighted sum of the relative frequency of the written words in selected texts for a given period. The weight or scores are calibrated to a target variables of interest.

# Example
```
require(GWP)
require(sentometrics)

set.seed(1234)
data("corpus", package = "GWP")
sentimentWord <- list_lexicons$LM_en$x
shifterWord <- list_valence_shifters$en[, c("x", "y")]
frequencies <- computeFrequencies(corpus, sentimentWord, shifterWord, clusterSize = 3)

data("vix", package = "GWP")

trainSize <- 200
vix_res <- fitGWP(frequencies = frequencies, responseData = vix[1:trainSize, ], lowerLimit = 0.2)

vix_pos_score <- vix_res$scores[vix_res$scores$score > 0, ]
vix_neg_score <- vix_res$scores[vix_res$scores$score < 0, ]

head(vix_pos_score[order(vix_pos_score$importance, decreasing = TRUE), ], n = 10)

         word     score   importance
84      serious 1.3438446 0.06058422
117       worst 1.7045277 0.05392553
103     turmoil 2.1888455 0.04140686
22  corrections 1.7389983 0.04110145
78   prosperity 2.6576827 0.03160762
62      layoffs 2.0040448 0.03098079
76     problems 1.1443497 0.03085612
23       crisis 0.8344749 0.02985422
4         argue 2.6082979 0.02690353
113         win 2.1320836 0.02501395

head(vix_neg_score[order(vix_neg_score$importance, decreasing = TRUE), ], n = 10)

            word      score   importance
49        gained -1.5363383 0.033567095
73       popular -1.9013067 0.029118293
30     declining -1.9954715 0.025050171
31       deficit -0.7756264 0.023149365
94     stability -2.4402642 0.020659488
35 disappointing -2.0476249 0.011179275
68          lost -1.1161363 0.010862270
57      improved -1.5827683 0.009501680
97        strong -0.6844674 0.008692322
70   opportunity -1.6583928 0.006876048

# OOS regression testing

y_pred <- predictGWP(frequencies = frequencies, model = vix_res)

y_test <- vix[-1:-trainSize, ]
match.id <- match(y_pred$regID, y_test$regID)
y_pred <- y_pred[!is.na(match.id)]
y_test <- y_test[match.id[!is.na(match.id)], ]

y <- y_test$y[1:nrow(y_test)]
x <- y_pred$SentimentScores[1:(nrow(y_test))]

oos_reg <- lm(y ~ x)

plot(x, y)
abline(oos_reg)
```

![alt text](https://github.com/keblu/GWP/blob/master/OOS_Scatterplot.png)

# Reference

 **Ardia, D., Bluteau, K., Boudt, (2019).**  
*Media and the Stock Market: Their Relationship and Abnormal Dynamics Around Earnings Announcements</em>.*  
Working Paper.   
http://dx.doi.org/10.2139/ssrn.3192064

 **Jegadeesh, N. and Wu, D., (2013).**  
*Word power: A new approach for content analysis</em>.*  
Journal of Financial Economics, 110(3), pp.712-729.   
https://doi.org/10.1016/j.jfineco.2013.08.018

 **Loughran, T. and McDonald, B., (2011).**  
*When is a liability not a liability? Textual analysis, dictionaries, and 10‐Ks</em>.*  
Journal of Finance, 66(1), pp.35-65.   
https://doi.org/10.1111/j.1540-6261.2010.01625.x
