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

# Example
```
require(GWP)
require(sentometrics)

data("corpus",package = "GWP")
sentimentWord = list_lexicons$LM_en$x
shifterWord = list_valence_shifters$en[,c("x","y")]
frequencies <- computeFrequencies(corpus, sentimentWord, shifterWord, clusterSize = 3)

data("vix",package = "GWP")

trainSize = 200
vix_res = fitGWP(frequencies = frequencies, responseData = vix[1:trainSize,], lowerLimit = 0.2)

vix_pos_score = vix_res$scores[vix_res$scores$score > 0, ]
vix_neg_score = vix_res$scores[vix_res$scores$score < 0, ]

head(vix_pos_score, n = 10)

         word     score   importance
1        able 1237.1446 0.0112956097
2   advantage  178.3803 0.0001479612
4       argue 2602.9026 0.0269922946
5  attractive  270.4411 0.0007360339
6         bad  695.0248 0.0105310248
7  bankruptcy  328.6081 0.0015704980
8     benefit  190.0120 0.0006114199
11       boom  695.0205 0.0040355737
14      break  105.8136 0.0000997360
15     claims  777.9828 0.0097338901

head(vix_neg_score, n = 10)

        word      score   importance
3    against  -157.9453 0.0023409941
9       best  -381.4988 0.0044982427
10    better  -263.7785 0.0025846030
12     boost  -330.5932 0.0019790153
13   boosted  -172.0231 0.0002451579
20 concerned  -161.2575 0.0002092667
26    damage  -648.9494 0.0033457575
27   decline  -339.2800 0.0067142277
30 declining -1264.8044 0.0169084542
31   deficit  -414.9471 0.0234562348

# OOS regression testing

y_pred = predictGWP(frequencies = frequencies, model = vix_res)

y_test = vix[-1:-trainSize,]
match.id = match(y_pred$regID, y_test$regID)
y_pred = y_pred[!is.na(match.id)]
y_test = y_test[match.id[!is.na(match.id)],]

y = y_test$y[1:nrow(y_test)]
x = y_pred$SentimentScores[1:(nrow(y_test))]

oos_reg = lm(y ~ x)

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
