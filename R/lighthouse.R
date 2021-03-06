#' Lighthouse Function
#'
#' This function allows you to retrive Lighthouse Data.
#' Lighthouse will analyze the Page you specific in the request. Lighthouse will open a new Chrome Window and run various tests.
#' The output you will get consists of 5 numeric values: Progressive Web App, Performance, Accessibility, Best Practices, SEO. Each a number between 0 (very bad) and 100 (perfect).
#' Additional to this you will get a HTML-file in your Workspace containing all results of the Lighthouse test. So you can have a deeper look in various parts.
#' @page The Page you want to get analyzed by Lighthouse
#' @view Logical. Do you want to open the HTML-File after the run? Default is FALSE.
#' lighthouse()



lighthouse <- function(page, view = FALSE) {
  #Check the Page input if the URL is correct and includes scheme
  if (isTRUE(grepl("http", page))) {

  } else {
    warning("Scheme (http/https) in the URL is missing")
  }
  #Check for the correct Lighthouse-Versions
  ver <- system("lighthouse --version", intern = TRUE)
  if (ver[1] < 2.7) {
    warning("Please Update your Lighthouse Version to 2.7 or higher")
  }
  if (!is.logical(view)) {
    stop("The view should be a logical input")
  }
  #TODO: Add more Error Monitoring

  #Call the lighthouse module

  sys_call <-
    paste0("lighthouse ", page , " --chrome-flags='--headless'", if (view == TRUE) {
      " --view"
    })
  s <- system(sys_call, intern = TRUE)

  #Find the file where we can see the ouptut

  output <- s[grep("GMT Printer domhtml output written to", s)]
  output <-
    gsub(".* GMT Printer domhtml output written to ", "", output)
  doc <- stringr::str_split(output, "\\\\")
  doc <- doc[[1]][nrow(as.data.frame(unlist(doc)))]

  #Load the file with the Lighthouse Output

  rawHTML <- paste(readLines(doc), collapse = "\n")

  #Get the Scores out of the HTML-File
  scores <-
    t(as.data.frame(
      stringr::str_extract_all(
        rawHTML,
        '.(accessibility|best-practices|pwa|performance|seo).,.score.\\:[0-9]{1,3}\\.?[0-9]{0,2}'
      )
    ))
  scores <-
    as.data.frame(
      gsub(
        '"(accessibility|best-practices|pwa|performance|seo)","score":',
        '',
        scores
      )
    )
  scores$Page <- as.data.frame(page)
  scores$fullReport <- as.data.frame(output)
  colnames(scores) <-
    c(
      "Progressive_Web_App",
      "Performance",
      "Accessibility",
      "Best_Practices",
      "SEO",
      "Page",
      "fullReport"
    )
  rownames(scores) <- "1"
  return(scores)
}
