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

The choice of an extraction method for the sentiment or tone of textual documents is an important consideration. In finance, for example, the reference lexicon is the dictionary developed by Loughran and McDonald (2011). Depending on the type of document targetted and what we want to extract from the textual data, certain lexicon may not be adequate. The generalized Word Power methodology is a data–driven tone computation methodology which relates the tone to an underlying variable of interest with regards to an entity.

The goal is to compute the predictive value of words in a written publication for explaining a variable of interest. This variable can be the accounting performance, stock return of a firm, or even the volatility of the financial market. Besides a careful selection of the relevant texts, this requires a definition of the intratextual and across–text aggregation method. Under The Generalized Word Power approach, the aggregated tone is a weighted sum of the relative frequency of the written words in selected texts for a given period. The weight or scores are calibrated to a target variables of interest.

# Example
```
require(GWP)
require(sentometrics)

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
103     turmoil 2541.679 0.05749040
84      serious 1329.114 0.05109177
62      layoffs 2351.353 0.04239444
22  corrections 1795.144 0.04000567
23       crisis 1069.124 0.03634386
76     problems 1312.542 0.03262211
117       worst 1350.210 0.02996969
4         argue 2602.903 0.02699229
78   prosperity 2435.842 0.02684949
79     question 1624.434 0.02670011

head(vix_neg_score[order(vix_neg_score$importance, decreasing = TRUE), ], n = 10)

            word      score   importance
73        popular -1403.0374 0.027765037
49         gained  -974.5107 0.025780736
31        deficit  -414.9471 0.023456235
30      declining -1264.8044 0.016908454
68           lost  -840.9247 0.015320989
114       worries -1016.0232 0.013063305
35  disappointing -1510.2902 0.010845441
57       improved -1055.1569 0.007897588
64           lose -1249.8410 0.007802614
93       sluggish -1309.0142 0.007112272

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

 **Loughran, T. and McDonald, B., 2011., (2011).**  
*When is a liability not a liability? Textual analysis, dictionaries, and 10‐Ks</em>.*  
Journal of Finance, 66(1), pp.35-65.   
https://doi.org/10.1111/j.1540-6261.2010.01625.x
