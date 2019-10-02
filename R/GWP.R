#' VIX Index
#' 
#' @docType data
#' 
#' @description A dataset containing the monthly level of the VIX Index.
#'
#' @format A data frame with 345 rows and 2 variables:
#' \describe{
#'   \item{regID}{Date in format yyyy-mm}
#'   \item{y}{The VIX level}
#' }
#' 
#' @usage data("vix")
#' 
#' @source \url{https://fred.stlouisfed.org/series/VIXCLS}
"vix"

#' EPU Index
#' 
#' @docType data
#' 
#' @description A dataset containing the monthly level of the US Economic Policy Uncertainty (EPU) Index.
#'
#' @format A data frame with 403 rows and 2 variables:
#' \describe{
#'   \item{regID}{Date in format yyyy-mm}
#'   \item{y}{The EPU level}
#' }
#' @usage data("epu")
#' @source \url{https://www.policyuncertainty.com/us_monthly.html}
"epu"

#' Texts (not) relevant to the U.S. economy
#'
#' @docType data
#'
#' @description
#' A collection of texts annotated by humans in terms of relevance to the U.S. economy or not. The texts come from two major
#' journals in the U.S. (The Wall Street Journal and The Washington Post) and cover 4145 documents between 1995 and 2014. It
#' contains following information:

#' @format A data frame with 4145 rows and 3 variables:
#' \describe{
#' \item{docID}{Unique document ID}
#'   \item{regID}{Date in format yyyy-mm}
#'   \item{texts}{Texts in \code{character} format.}
#' }
#' 
#' @usage data("corpus")
#'
#' @source \href{https://www.figure-eight.com/data-for-everyone/}{Economic News Article Tone and Relevance}. Retrieved
#' November 1, 2017.
"corpus"