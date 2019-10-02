#' @title Normalized Frequencies.
#' @description Generate the Normalized Frequency table from textual data input.
#' @param corpus corpus with column \code{docID}, \code{regID}, and \code{texts}. 
#' docID indicate a unique ID for the document. regID is used for aggregation of document for the regression. It must match with the specific regID of the response variable in  \code{\link{fitGWP}}.
#' texts are the textual data.
#' @param sentimentWord Vector of words used for computing the sentiment.
#' @param shifterWord Matrix with element \code{x} and \code{y}. x is a vector of valence shifting words while y is the modifier values.
#' @param clusterSize Scalar indicating the window in which valance shifting words have an influence.
#' @return A list with the following elements:
#'         \itemize{
#'         \item docID: unique document ID.
#'         \item regID: regression ID.
#'         \item loc: location of the sentiment word within the texts.
#'         \item word: sentiment word. 
#'         \item shift: shigt coefficient modifying the sentiment word.
#'         \item NormalizedFrequency: frequency of word normalized by number of token in each text
#'         \item NormalizedFrequencyPerRegID: Normalzied Frequency normalized by the number of documents per each regression ID.
#'         }
#' @examples 
#' # Load example data
#' data("corpus",  package = "GWP")
#' 
#' # Setup the lexicons
#' sentimentWord <- sentometrics::list_lexicons$LM_en$x
#' shifterWord <- sentometrics::list_valence_shifters$en[, c("x", "y")]
#' 
#' # Generate the frequency data
#' frequencies <- computeFrequencies(corpus, sentimentWord, shifterWord, clusterSize = 5)
#' @import data.table tokenizers
#' @export
computeFrequencies <- function(corpus, sentimentWord, shifterWord, clusterSize = 1){
  
  #Compute number of Tokens per documents
  nDocPerRegID <- table(corpus$regID)
  token <- tokenizers::tokenize_words(corpus$texts)
  
  # Long table with tokens
  frequencies <- list()
  for(i in 1:length(token)){
    nToken <- length(token[[i]])
    frequencies[[i]] <-  data.frame(docID = corpus$docID[i], 
                                     regID =  corpus$regID[i],
                                     loc = 1:nToken, 
                                     word = token[[i]], 
                                     nToken = nToken,
                                     stringsAsFactors = FALSE)
  }
  frequencies <- data.table::rbindlist(frequencies)
  
  #Adding number of documents per regression ID for normalization
  frequencies$nDocPerRegID <- nDocPerRegID[match(frequencies$regID,names(nDocPerRegID))]
  
  #Matching texts words with sentiment words
  mWord <- match(frequencies$word, sentimentWord)
  frequencies$mWordList <- as.numeric(!is.na(mWord))
  
  #Matching texts words with valence shifting words
  mVal <- match(frequencies$word, shifterWord$x)
  mshift  <- shifterWord[mVal,]
  mshift[which(is.na(mshift[, 2])), 2] <- 1
  
  frequencies$shift <- mshift[, 2]
  
  # Expanding the effect of valence shifting words to cluster of size clusterSize
  id <- which(frequencies$shift != 1)
  
  expandDf <- cbind(id,frequencies[id, ])
  expand <- list()
  for(i in 1:length(id)){
    if((expandDf$loc[i] - clusterSize) > 0){
      low_expand <- (id[i] - clusterSize):id[i]
    } else {
      low_expand <- (id[i] - expandDf$loc[i] + 1):id[i]
    }
    
    if((expandDf$loc[i] + clusterSize) > expandDf$nToken[i]){
      max_expand <- id[i]:(id[i] + expandDf$nToken[i] - expandDf$loc[i])
    } else {
      max_expand <- id[i]:(id[i] + clusterSize)
    }
    expand[[i]] <- data.frame(id = unique(c(low_expand, max_expand)), shift = expandDf$shift[i])
  }
  expand <- data.table::rbindlist(expand)
  expand <- expand[, lapply(.SD,sum), by = list(id)]
  frequencies$shift[expand$id] <- expand$shift
  
  frequencies <- frequencies[frequencies$mWordList != 0, ]
  
  # Normalized frequency per Documents
  frequencies$NormalizedFrequency <- frequencies$mWordList*frequencies$shift/frequencies$nToken
  
  #Normalized frequency per RegID (it Normalized the frequency per documents)
  frequencies$NormalizedFrequencyPerRegID <- frequencies$NormalizedFrequency/frequencies$nDocPerRegID
  
  frequencies <- frequencies[, c("docID", "regID", "loc", "word", "shift", "NormalizedFrequency", "NormalizedFrequencyPerRegID")]
  nMissing <- length(setdiff(sentimentWord,unique(frequencies$word)))
  
  if(nMissing > 0){
    warning(paste0("Be aware that ", nMissing, " or ", round(nMissing/length(sentimentWord), 2), " percent of the sentiment word list are not observable in the corpus."))
  }
  
  return(frequencies)
}

