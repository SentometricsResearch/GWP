#' @title Fit a Generalized Word Power model.
#' @description Fit a  Generalized Word Power model on a target variable using word frequency data with an elastic-net model.
#' @param frequencies frequencies data.table generated using the function \code{\link{computeFrequencies}}.
#' @param responseData data.frame with column \code{regID} and \code{y}. 
#' \code{regID} should match with the \code{regID} of the \code{frequencies} input while \code{y} is the response variable.
#' @param alpha alpha parameter for an elastic-net model.
#' @param lowerLimit lower limit on the number of time a sentiment word must appear over all the period. 
#' If the value is above or equal to 1, this value is absolute. If the value is below 1, this value is in percentage term.
#' @return A list with the following elements:
#'         \itemize{
#'         \item scores: data.frame wiht the column \code{word}, \code{score}, and \code{importance}.
#'         the word column correspond to the sentiment words, the score column correspond to the polarity of the sentiment words,
#'         and the importance column correspond to the importance of each word withing the calbration sample.
#'         \item sentiment: data.frame with colmn \code{regID}, \code{SentimentScores}, and \code{y}. 
#'         the column regID correspond to the regID of each observation, the columne SentimentScores is the sentiment for that observation, 
#'         and the column y is the initially given reponse variable.
#'         }
#' @examples 
#' # Load example data
#' data("corpus",  package = "GWP")
#' data("vix",  package = "GWP")
#' # Setup the lexicons
#' sentimentWord <- sentometrics::list_lexicons$LM_en$x
#' shifterWord <- sentometrics::list_valence_shifters$en[, c("x", "y")]
#' 
#' # Generate the frequency data
#' frequencies <- computeFrequencies(corpus, sentimentWord, shifterWord, clusterSize = 5)
#' 
#' # Calibrate the lexicon
#' res = fitGWP(frequencies = frequencies, responseData = vix)
#' @import caret glmnet
#' @importFrom stats sd 
#' @importFrom stats var 
#' @export
fitGWP <- function(frequencies, responseData, alpha = c(0, 0.2, 0.4, 0.6, 0.8, 1), lowerLimit = 0.2) {
  aggFreq <- aggregateByRegID(frequencies)
  sparseAggFreq <- toSparseMatrix(aggFreq)
  if(lowerLimit >= 1){
    id.freq <- colSums(as.matrix(sparseAggFreq) != 0) >= lowerLimit
  } else {
    id.freq <- colSums(as.matrix(sparseAggFreq) != 0)/nrow(sparseAggFreq) >= lowerLimit
  }
  sparseAggFreq = sparseAggFreq[,id.freq]
  id.match <- match(rownames(sparseAggFreq), responseData$regID)
  
  missing.obs <- rownames(sparseAggFreq)[is.na(id.match)]
  
  if(length(missing.obs) > 0){
    warning(paste0(" Cannot match ", 
                   length(missing.obs),
                   " regIDs or ",
                   round(length(missing.obs)/nrow(sparseAggFreq),2),
                   " percent of the regIDs. Ignoring those observations for calibration."))
  }
  
  y <- responseData$y[id.match[!is.na(id.match)]]
  sparseAggFreq <- sparseAggFreq[!is.na(id.match),]
  
  flds <- caret::createFolds(y,
                             k = 10, 
                             list = TRUE, 
                             returnTrain = FALSE)
  foldids <- rep(1, length(y))
  for(i in 2:length(flds)){
    foldids[flds[[i]]] <- i
  }
  
  cv.res <- matrix(nrow = length(alpha), ncol = 3)
  for(i in 1:length(alpha)){
    reg <- glmnet::cv.glmnet(sparseAggFreq,y,
                             alpha = alpha[i],
                             standardize = TRUE,
                             foldid = foldids)
    
    cv.res[i,] <- c(alpha[i], reg$cvm[which(reg$lambda == reg$lambda.min)], reg$lambda.min)
  }
  id.best <- which.min(cv.res[1,])
  
  reg <- glmnet::cv.glmnet(sparseAggFreq,
                        y, 
                        alpha = alpha[id.best],
                        standardize = TRUE)
  
  tmp_coef <- as.matrix(coef(reg, s = "lambda.min"))
  coef <- as.vector(tmp_coef)[-1]
  names(coef) <- rownames(tmp_coef)[-1]
  
  scores <- (coef - mean(coef))/sd(coef)
  scores <- data.frame(word = names(coef), score = coef)
  rownames(scores) <- NULL
  
  importance <- NA
  for(i in 1:ncol(sparseAggFreq)){
    importance[i] <- coef[i]^2*var(sparseAggFreq[, i])
  }
  importance <- importance/sum(importance)
  scores$importance <- importance
  
  aggFrequenciesWithSentimentScores <- addSentimentScores(aggFreq, scores)
  sentiment <- computeSentimentByRegID(aggFrequenciesWithSentimentScores)
  sentiment$responseData = NA
  sentiment$responseData[!is.na(id.match)] <- y
  res <- list(scores = scores, sentiment = sentiment, param = cv.res[id.best,], reg = reg)
  return(res)
}

