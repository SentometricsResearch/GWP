testthat::context("Test Normalized Frequencies")

# Load example data
data(corpus,  package = "GWP")

#' # Setup the lexicons
sentimentWord = sentometrics::list_lexicons$LM_en$x
shifterWord = sentometrics::list_valence_shifters$en[,c("x","y")]

testthat::test_that("frequencies", {
  
  frequencies <- computeFrequencies(corpus[1:100,], sentimentWord, shifterWord,clusterSize = 5)
  
  test_value = c(0.00457,0.00887)
  test_run = c(round(frequencies$NormalizedFrequency[1],5),round(frequencies$NormalizedFrequency[752],5))  
  testthat::expect_true(all(test_value == test_run))
  
})
  