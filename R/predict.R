#' @title Predict function for new data.
#' @description Ouput sentiment value given a fitted model and frequency table.
#' @param frequencies frequencies data.table generated using the function \code{\link{computeFrequencies}}.
#' @param model Score model generated with \code{\link{fitGWP}}.
#' @return A data.table with the following element:
#'         \itemize{
#'         \item regID: regression ID.
#'         \item SentimentScores: predicted sentiment scores.
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
#' frequencies <- computeFrequencies(corpus[1:991, ], sentimentWord, shifterWord, clusterSize = 5)
#' 
#' # Calibrate the lexicon
#' res <- fitGWP(frequencies = frequencies, responseData = vix)
#' 
#' newFrequencies <- computeFrequencies(corpus[-1:-991, ], sentimentWord, shifterWord, clusterSize = 5)
#' pred <- predictGWP(newFrequencies, res)
#' @import data.table tokenizers
#' @export
predictGWP = function(frequencies, model) {
  aggFreq <- aggregateByRegID(frequencies)
  aggFrequenciesWithSentimentScores <- addSentimentScores(aggFreq, model$scores)
  sentiment <- computeSentimentByRegID(aggFrequenciesWithSentimentScores)
  return(sentiment)
}