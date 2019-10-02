testthat::context("test pred")

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
  newfrequencies <- computeFrequencies(corpus[1001:1100,], sentimentWord, shifterWord,clusterSize = 5)
  pred = predictGWP(newfrequencies,model = res)
  test_value = c(1.612)
  test_run = round(pred[1,2],3)
  testthat::expect_true(test_value == test_run)
})
