#' @import data.table
aggregateByDocAndRegID <- function(frequencies){
  
  #Step to avoid CRAN check error with data.table selection
  docID <- regID <- word <- NULL
  
  agg <- frequencies[, lapply(.SD,sum), by = list(docID, regID, word)]
  return(agg[,c("docID", "regID", "word", "NormalizedScore", "NormalizedFrequencyPerRegID")])
}

#' @import data.table
aggregateByRegID <- function(frequencies){
  
  #Step to avoid CRAN check error with data.table selection
  regID <- word <- NULL
  
  frequencies <- frequencies[, c("regID", "word", "NormalizedFrequencyPerRegID")]
  agg <- frequencies[, lapply(.SD,sum), by = list(regID, word)]
  agg$NormalizedScorePerRegID <- as.numeric(agg$NormalizedFrequencyPerRegID)
  agg$NormalizedScorePerRegID <- as.numeric(agg$NormalizedScorePerRegID)
  return(agg[, c("regID", "word", "NormalizedFrequencyPerRegID")])
}

#' @import Matrix
toSparseMatrix <- function(frequencies){
  row <- factor(frequencies$regID)
  col <- factor(frequencies$word)
  regIDNormalizedDfm = Matrix::sparseMatrix(i = as.integer(row),
                                            j = as.integer(col), 
                                            x = as.vector(frequencies$NormalizedFrequencyPerRegID))
  rownames(regIDNormalizedDfm) <- levels(row)
  colnames(regIDNormalizedDfm) <- levels(col)
  return(regIDNormalizedDfm)
}

addSentimentScores <- function(frequencies, scores) {
  frequencies$SentimentScores <- frequencies$NormalizedFrequencyPerRegID*scores$score[match(frequencies$word, scores$word)]
  return(frequencies)
}

#' @import data.table
computeSentimentByRegID <- function(frequencies, scores) {
  frequencies <- frequencies[, c("regID", "SentimentScores")]
  regID <-  NULL
  agg <- frequencies[, lapply(.SD,sum, na.rm = TRUE), by = list(regID)]
  agg$SentimentScores <- as.numeric(agg$SentimentScores)
  return(agg[, c("regID", "SentimentScores")])
}

