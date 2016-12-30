---
title: 'Recreating Figure 3'
layout: 'post'
tags: ['R', 'poppr', 'multilocus genotype', 'ggplot2']
---



Motivation
==========

In February of 2016, I got an email asking if I could provide the code to
recreate [figure three][fig3] from my [article in Phytopathology][sod] on the
outbreak of *Phytophthora ramorum* in Curry County OR from 2001 to 2014
(paywalled, but [you can find a copy here][sod-free]).

While I have the [code used for the analysis on github][analysis], it's a lot of
stuff to sort through, considering that it was my first foray in attempting a
reproducible analysis, so for this post, I'm going to recreate it using current
tools.

I created figure three originally in two parts with ggplot2 and then manually
aligned the two figures in inkscape. Since then, the package cowplot has come
around and made this process easier. I have my old code up here:
[mlg_distribution.Rmd][mlgdist], and since the packages have changed since then,
I'm redoing the code here.

Analysis
========

## Loading Packages/Data


{% highlight r %}
library("poppr")    # Note, v.2.2.0 or greater is needed for the %>% operator
library("ggplot2")  # Plotting
library("cowplot")  # Grouping the plots
{% endhighlight %}

The data from the paper has been stored in *poppr* as "Pram", but it includes 
nursery data. I'm removing it here.


{% highlight r %}
data("Pram")
mll(Pram) <- "original"
Pram
{% endhighlight %}



{% highlight text %}
## 
## This is a genclone object
## -------------------------
## Genotype information:
## 
##     98 original multilocus genotypes 
##    729 diploid individuals
##      5 codominant loci
## 
## Population information:
## 
##      3 strata - SOURCE, YEAR, STATE
##      9 populations defined - 
## Nursery_CA, Nursery_OR, JHallCr_OR, ..., Winchuck_OR, ChetcoMain_OR, PistolRSF_OR
{% endhighlight %}



{% highlight r %}
ramdat <- Pram %>%
  setPop(~SOURCE) %>%               # Set population strata to SOURCE (forest/nursery)
  popsub(blacklist = "Nursery") %>% # remove the nursery derived samples
  setPop(~YEAR)                     # Set the strata to YEAR of epidemic

# A color palette (unnecessary)
ncolors <- max(mll(ramdat))
myPal   <- setNames(funky(ncolors), paste0("MLG.", seq(ncolors)))
{% endhighlight %}

Creating the Barplot
--------------------

The barplot is a barplot of the MLG counts ordered from most abundant to least
abundant.


{% highlight r %}
# This obtains a table of sorted MLG counts for adjusting the axes.
mlg_order <- table(mll(ramdat)) %>% 
  sort() %>% 
  data.frame(MLG = paste0("MLG.", names(.)), Count = unclass(.))

# Creating the bar plot
bars <- ggplot(mlg_order, aes(x = MLG, y = Count, fill = MLG)) + 
  geom_bar(stat = "identity") +
  theme_classic() +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 180)) +
  scale_fill_manual(values = myPal) +
  geom_text(aes(label = Count), size = 2.5, hjust = 0, fontface = "bold") +
  theme(axis.text.y = element_blank()) + 
  theme(axis.ticks.y = element_blank()) +
  theme(legend.position = "none") +
  theme(text = element_text(family = "Helvetica")) +
  theme(axis.title.y = element_blank()) +
  # From the documentation for theme: top, right, bottom, left
  theme(plot.margin = unit(c(1, 1, 1, 0), "lines")) + 
  scale_x_discrete(limits = mlg_order$MLG) +
  coord_flip()

bars
{% endhighlight %}

<img src="http://zkamvar.github.io/figures/2016-02-10-recreating-fig-3/barplot-1.png" title="plot of chunk barplot" alt="plot of chunk barplot" width="50%" style="display: block; margin: auto;" />

Creating the Subway plot
------------------------

This plot displays the MLGs occurring across years. It's a nice graphical way of
displaying the results of `mlg.crosspop()` when the populations are years.


{% highlight r %}
mlg_range <- mlg.crosspop(ramdat, mlgsub = unique(mll(ramdat)), 
                          df = TRUE, quiet = TRUE)
names(mlg_range)[2] <- "Year"

# Creating the subway plot
ranges <- ggplot(mlg_range, aes(x = Year, y = MLG, group = MLG, color = MLG)) + 
  geom_line(size = 1, linetype = 1) + 
  geom_point(size = 5, pch = 21, fill = "white") +
  geom_text(aes(label = Count), color = "black", size = 2.5) + 
  scale_color_manual(values = myPal) + 
  ylab("Multilocus Genotype") +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  theme(text = element_text(family = "Helvetica")) +
  theme(legend.position = "none") +
  theme(axis.line = element_line(colour = "black")) +
  # From the documentation for theme: top, right, bottom, left
  theme(plot.margin = unit(c(1, 0, 1, 1), "lines")) +
  scale_y_discrete(limits = mlg_order$MLG)

ranges
{% endhighlight %}

<img src="http://zkamvar.github.io/figures/2016-02-10-recreating-fig-3/subwayplot-1.png" title="plot of chunk subwayplot" alt="plot of chunk subwayplot" width="50%" style="display: block; margin: auto;" />

> **A word on margins**
> 
> Cowplot is nice for placing the ggplot objects next to each other in one
> frame, but it likes to give them room to spread out. To get the plots as close
> together as possible, I'm cutting out the left and right margins of the
> barplot and subway plot, respectively. This is done with the `plot.margin`
> argument to `theme()` which organizes the widths as **top**, **right**,
> **bottom**, **left**.


Aligning with cowplot
---------------------

Cowplot's `plot_grid()` will fit these two plots together. Originally, I had to 
export these plots and align them by hand in inkscape, but now, they can be 
plotted together and aligned in one swoop. There's some fiddling to be done with
the margins, but it might be easier to export it as an svg, and then slide one
over to the other in 2 minutes in inkscape.



{% highlight r %}
cowplot::plot_grid(ranges, bars, align = "h", rel_widths = c(2.5, 1))
{% endhighlight %}

<img src="http://zkamvar.github.io/figures/2016-02-10-recreating-fig-3/cowplot-1.png" title="plot of chunk cowplot" alt="plot of chunk cowplot" width="50%" style="display: block; margin: auto;" />

Conclusion
==========

This plot was done when I was originally toying with the idea of keeping my
analysis open. Of course, I know more things now than I did then, but I do enjoy
the fact that I can go back a year later and recreate the exact plot from start
to finish.

Session Information
===================


{% highlight r %}
options(width = 100)
devtools::session_info()
{% endhighlight %}



{% highlight text %}
## Session info ---------------------------------------------------------------------------------------
{% endhighlight %}



{% highlight text %}
##  setting  value                       
##  version  R version 3.3.2 (2016-10-31)
##  system   x86_64, darwin13.4.0        
##  ui       RStudio (1.0.44)            
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  tz       America/Los_Angeles         
##  date     2016-12-29
{% endhighlight %}



{% highlight text %}
## Packages -------------------------------------------------------------------------------------------
{% endhighlight %}



{% highlight text %}
##  package      * version     date       source                                  
##  ade4         * 1.7-5       2016-12-13 CRAN (R 3.3.2)                          
##  adegenet     * 2.0.2       2016-12-28 Github (thibautjombart/adegenet@78d2045)
##  ape            4.0         2016-12-01 CRAN (R 3.3.2)                          
##  assertthat     0.1         2013-12-06 CRAN (R 3.2.0)                          
##  backports      1.0.4       2016-10-24 cran (@1.0.4)                           
##  boot           1.3-18      2016-02-23 CRAN (R 3.2.3)                          
##  cluster        2.0.4       2016-04-18 CRAN (R 3.3.0)                          
##  coda           0.18-1      2015-10-16 CRAN (R 3.2.0)                          
##  colorspace     1.2-6       2015-03-11 CRAN (R 3.2.0)                          
##  cowplot      * 0.7.0       2016-10-28 CRAN (R 3.3.0)                          
##  cranlogs     * 2.1.1       2016-06-06 Github (metacran/cranlogs@77182ee)      
##  curl           2.3         2016-11-24 CRAN (R 3.3.2)                          
##  DBI            0.4-1       2016-05-08 CRAN (R 3.3.0)                          
##  deldir         0.1-12      2016-03-06 CRAN (R 3.2.4)                          
##  devtools       1.12.0      2016-06-24 CRAN (R 3.3.0)                          
##  digest         0.6.10      2016-08-02 CRAN (R 3.3.0)                          
##  dplyr        * 0.5.0       2016-06-24 CRAN (R 3.3.0)                          
##  evaluate       0.10        2016-10-11 cran (@0.10)                            
##  fastmatch      1.0-4       2012-01-21 CRAN (R 3.2.0)                          
##  gdata          2.17.0      2015-07-04 CRAN (R 3.2.0)                          
##  ggplot2      * 2.2.0       2016-11-11 CRAN (R 3.3.2)                          
##  ggthemes     * 3.2.0       2016-07-11 CRAN (R 3.3.0)                          
##  gmodels        2.16.2      2015-07-22 CRAN (R 3.2.0)                          
##  gtable         0.2.0       2016-02-26 CRAN (R 3.2.3)                          
##  gtools         3.5.0       2015-05-29 CRAN (R 3.2.0)                          
##  highr          0.6         2016-05-09 CRAN (R 3.3.0)                          
##  htmltools      0.3.5       2016-03-21 CRAN (R 3.2.4)                          
##  httpuv         1.3.3       2015-08-04 CRAN (R 3.2.0)                          
##  httr           1.2.1       2016-07-03 cran (@1.2.1)                           
##  igraph         1.0.1       2015-06-26 CRAN (R 3.2.0)                          
##  jsonlite       1.1         2016-09-14 cran (@1.1)                             
##  knitr        * 1.15.6      2016-12-25 Github (yihui/knitr@849f2d0)            
##  labeling       0.3         2014-08-23 CRAN (R 3.2.0)                          
##  lattice        0.20-33     2015-07-14 CRAN (R 3.2.0)                          
##  lazyeval       0.2.0.9000  2016-07-01 Github (hadley/lazyeval@c155c3d)        
##  LearnBayes     2.15        2014-05-29 CRAN (R 3.2.0)                          
##  lubridate    * 1.5.6       2016-04-06 CRAN (R 3.2.4)                          
##  magrittr       1.5         2014-11-22 CRAN (R 3.2.0)                          
##  MASS           7.3-45      2015-11-10 CRAN (R 3.2.2)                          
##  Matrix         1.2-6       2016-05-02 CRAN (R 3.3.0)                          
##  memoise        1.0.0       2016-01-29 CRAN (R 3.2.3)                          
##  mgcv           1.8-13      2016-07-21 CRAN (R 3.3.0)                          
##  mime           0.5         2016-07-07 cran (@0.5)                             
##  munsell        0.4.3       2016-02-13 CRAN (R 3.2.3)                          
##  nlme           3.1-128     2016-05-10 CRAN (R 3.3.0)                          
##  pegas          0.9         2016-04-16 CRAN (R 3.2.5)                          
##  permute        0.9-4       2016-09-09 cran (@0.9-4)                           
##  phangorn       2.1.1       2016-12-04 cran (@2.1.1)                           
##  plyr           1.8.4       2016-06-08 CRAN (R 3.3.0)                          
##  poppr        * 2.3.0.99-16 2016-12-26 local                                   
##  quadprog       1.5-5       2013-04-17 CRAN (R 3.2.0)                          
##  R6             2.2.0       2016-10-05 cran (@2.2.0)                           
##  RColorBrewer   1.1-2       2014-12-07 CRAN (R 3.2.0)                          
##  Rcpp           0.12.8      2016-11-17 cran (@0.12.8)                          
##  reshape2       1.4.2       2016-10-22 cran (@1.4.2)                           
##  rmarkdown      1.3         2016-12-25 Github (rstudio/rmarkdown@3276760)      
##  rprojroot      1.1         2016-10-29 cran (@1.1)                             
##  rsconnect      0.5         2016-10-17 cran (@0.5)                             
##  scales         0.4.1       2016-11-09 CRAN (R 3.3.2)                          
##  seqinr         3.3-3       2016-10-13 cran (@3.3-3)                           
##  shiny          0.14.2.9001 2016-12-28 Github (rstudio/shiny@1962369)          
##  sp             1.2-3       2016-04-14 CRAN (R 3.3.0)                          
##  spdep          0.6-8       2016-09-21 CRAN (R 3.3.0)                          
##  stringi        1.1.1       2016-05-27 CRAN (R 3.3.0)                          
##  stringr        1.1.0       2016-08-19 cran (@1.1.0)                           
##  tibble         1.2         2016-08-26 cran (@1.2)                             
##  vegan          2.4-1       2016-09-07 cran (@2.4-1)                           
##  withr          1.0.2       2016-06-20 cran (@1.0.2)                           
##  xtable         1.8-2       2016-02-05 CRAN (R 3.2.3)                          
##  yaml           2.1.14      2016-11-12 cran (@2.1.14)
{% endhighlight %}
[fig3]: https://www.researchgate.net/publication/278039693_Spatial_and_Temporal_Analysis_of_Populations_of_the_Sudden_Oak_Death_Pathogen_in_Oregon_Forests/figures
[sod]: http://apsjournals.apsnet.org/doi/10.1094/PHYTO-12-14-0350-FI
[sod-free]: https://www.researchgate.net/publication/278039693_Spatial_and_Temporal_Analysis_of_Populations_of_the_Sudden_Oak_Death_Pathogen_in_Oregon_Forests
[analysis]: https://github.com/zkamvar/Sudden_Oak_Death_in_Oregon_Forests#readme
[mlgdist]: https://github.com/zkamvar/Sudden_Oak_Death_in_Oregon_Forests/blob/master/mlg_distribution.Rmd
