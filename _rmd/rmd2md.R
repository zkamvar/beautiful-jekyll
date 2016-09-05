library('knitr')
#' This R script will process a R mardown files in the current working directory
#' to a markdown file to be placed in the '_posts' directory and figures to be
#' placed in the 'figures' directory.
#'
#' @param file A base filename without an extension (assumed to be '.Rmd').
#' @param path_site Path to the local root storing the site files.
#' @return nothing.
#' @author I modified the code provided by Derek Ogle who heavily modified the
#'   code provided by Andy South (http://andysouth.github.io/blog-setup/) who
#'   modified the code of Jason Bryer
#' @example rmd2md("2015-09-05-Age-Comparison-Results-for-Individual-Fish")
#'
rmd2md <- function(file, path_site = "~/Documents/zkamvar.github.io") {
  ## Get knitr
	## Read in the rmd file
	content <- readLines(file.path(path_site, "_rmd", paste0(file, ".Rmd")))
	## Create output file name
	outFile <- file.path(path_site, "_posts", paste0(file, ".md"))
	## Set the rendering engine
	knitr::render_jekyll(highlight = "pygments")
	## Set the output format to markdown
	knitr::opts_knit$set(out.format = 'markdown')
	## Set the directory for the figures
	# this did not work with new gitHub
	#opts_knit$set(base.url = "../",base.dir=path_site)
	knitr::opts_knit$set(base.url = "http://zkamvar.github.io/")
	knitr::opts_chunk$set(fig.path = paste0("figures/", file, "/"))
	## Actually knit the RMD file
	knitr::knit(text = content, output = outFile)
	invisible()
}
