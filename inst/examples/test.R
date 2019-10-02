# Load example data
data("corpus",  package = "GWP")

# Setup the lexicons
sentimentWord <- sentometrics::list_lexicons$LM_en$x
shifterWord <- sentometrics::list_valence_shifters$en[, c("x", "y")]

# Generate the frequency data
frequencies <- computeFrequencies(corpus, sentimentWord, shifterWord, clusterSize = 5)

########################################

# Load example data
data("corpus",  package = "GWP")
data("vix",  package = "GWP")
# Setup the lexicons
sentimentWord <- sentometrics::list_lexicons$LM_en$x
shifterWord <- sentometrics::list_valence_shifters$en[, c("x", "y")]

# Generate the frequency data
frequencies <- computeFrequencies(corpus, sentimentWord, shifterWord, clusterSize = 5)

# Calibrate the lexicon
res = fitGWP(frequencies = frequencies, responseData = vix)

#########################################

# Load example data
data("corpus",  package = "GWP")
data("vix",  package = "GWP")
# Setup the lexicons
sentimentWord <- sentometrics::list_lexicons$LM_en$x
shifterWord <- sentometrics::list_valence_shifters$en[, c("x", "y")]

# Generate the frequency data
frequencies <- computeFrequencies(corpus[1:991, ], sentimentWord, shifterWord, clusterSize = 5)

# Calibrate the lexicon
res <- fitGWP(frequencies = frequencies, responseData = vix)

newFrequencies <- computeFrequencies(corpus[-1:-991, ], sentimentWord, shifterWord, clusterSize = 5)
pred <- predictGWP(newFrequencies, res)
 