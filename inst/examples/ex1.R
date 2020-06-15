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


head(vix_neg_score[order(vix_neg_score$importance, decreasing = TRUE), ], n = 10)


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
