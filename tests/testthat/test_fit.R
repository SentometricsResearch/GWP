testthat::context("Fitting")

# Load example data
data("corpus",  package = "GWP")
data("vix",  package = "GWP")
#' # Setup the lexicons
sentimentWord = sentometrics::list_lexicons$LM_en$x
shifterWord = sentometrics::list_valence_shifters$en[,c("x","y")]

testthat::test_that("frequencies", {
  set.seed(1234)
  frequencies <- computeFrequencies(corpus[1:1000,], sentimentWord, shifterWord,clusterSize = 5)
  res = fitGWP(frequencies = frequencies, responseData = vix)
  test_value = c(820.925, 0.014)
  test_run = round(res$scores[1,2:3],3)
  testthat::expect_true(all(test_value == test_run))
})
