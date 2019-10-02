require(GWP)
require(sentometrics)

data("corpus",package = "GWP")
sentimentWord = list_lexicons$LM_en$x
shifterWord = list_valence_shifters$en[,c("x","y")]
frequencies <- computeFrequencies(corpus, sentimentWord, shifterWord, clusterSize = 3)

data("vix",package = "GWP")
data("epu",package = "GWP")

# Sample size
IS = 200
vix_res = fitGWP(frequencies = frequencies, responseData = vix[1:IS,], lowerLimit = 0.2)
epu_res = fitGWP(frequencies = frequencies, responseData = epu[1:IS,], lowerLimit = 0.2)


epu_pos_score = epu_res$scores[epu_res$scores$score > 0, ]
epu_neg_score = epu_res$scores[epu_res$scores$score < 0, ]


vix_pos_score = vix_res$scores[vix_res$scores$score > 0, ]
vix_neg_score = vix_res$scores[vix_res$scores$score < 0, ]

id = match(epu_res$scores$word,vix_res$scores$word)

cor(epu_res$scores$score,vix_res$scores$score[id])

cbind(head(epu_pos_score[order(epu_pos_score$importance,decreasing = TRUE), ], 10),
      head(vix_pos_score[order(vix_pos_score$importance,decreasing = TRUE), ], 10))

cbind(head(epu_neg_score[order(epu_neg_score$importance,decreasing = TRUE), ], 10),
      head(vix_neg_score[order(vix_neg_score$importance,decreasing = TRUE), ], 10))


pred = predictGWP(frequencies = frequencies, model = epu_res)

# OOS regression testing

y_test = epu[-1:-IS,]
match.id = match(pred$regID,y_test$regID)
y_pred = pred[!is.na(match.id)]
y_test = y_test[match.id[!is.na(match.id)],]

y = y_test$y[1:nrow(y_test)]
x = y_pred$SentimentScores[1:(nrow(y_test))]

oos_reg = lm(y ~ x)

plot(x, y)
abline(oos_reg)

vix_pred = predictGWP(frequencies = frequencies, model = vix_res)

vix_y_test = vix[-1:-IS,]
match.id = match(vix_pred$regID,vix_y_test$regID)
y_pred = pred[!is.na(match.id)]
vix_y_test = vix_y_test[match.id[!is.na(match.id)],]

y = vix_y_test$y[1:nrow(vix_y_test)]
x = y_pred$SentimentScores[1:(nrow(vix_y_test))]

oos_reg = lm(y ~ x)

plot(x, y)
abline(oos_reg)

