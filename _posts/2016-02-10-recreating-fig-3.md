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
around and made this process easier. I have my old code up here: https://github.
com/zkamvar/Sudden_Oak_Death_in_Oregon_Forests/blob/master/mlg_distribution.Rmd,
and since the packages have changed since then, I'm redoing the code here.

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
##      3 strata - SOURCE YEAR STATE
##      9 populations defined - Nursery_CA Nursery_OR JHallCr_OR ... 
## Winchuck_OR ChetcoMain_OR PistolRSF_OR
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
  scale_y_continuous(expand = c(0, 0), limits = c(0, 175)) +
  scale_fill_manual(values = myPal) +
  geom_text(aes(label = Count), size = 2.5, hjust = 0, fontface = "bold") +
  theme(axis.text.y = element_blank()) + 
  theme(axis.ticks.y = element_blank()) +
  theme(legend.position = "none") +
  theme(text = element_text(family = "Helvetica")) +
  theme(axis.title.y = element_blank()) +
  theme(plot.margin = unit(c(1, 1, 0, 1), "lines")) + 
  scale_x_discrete(limits = mlg_order$MLG) +
  coord_flip()

bars
{% endhighlight %}

![plot of chunk barplot](http://zkamvar.github.io/figures/2016-02-10-recreating-fig-3/barplot-1.png)

Creating the Subway plot
------------------------

This plot displays the MLGs occurring across years. It's a nice graphical way of
displaying the results of `mlg.crosspop()` when the populations are years.


{% highlight r %}
mlg_range <- mlg.crosspop(ramdat, mlgsub = unique(mll(ramdat)), 
                          df = TRUE, quiet = TRUE)
names(mlg_range)[2] <- "Year"

# Creating the subway plot
(ranges <- ggplot(mlg_range, aes(x = Year, y = MLG, group = MLG, color = MLG)) + 
  geom_line(size = 1, linetype = 1) + 
  geom_point(size = 5, pch = 21, fill = "white") +
  geom_text(aes(label = Count), color = "black", size = 2.5) + 
  scale_color_manual(values = myPal) + 
  ylab("Multilocus Genotype") +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        text = element_text(family = "Helvetica"),
        legend.position = "none",
        axis.line = element_line(colour = "black"),
        plot.margin = unit(c(1, 0, 1, 1), "lines")) +
  scale_y_discrete(limits = mlg_order$MLG))
{% endhighlight %}

![plot of chunk subwayplot](http://zkamvar.github.io/figures/2016-02-10-recreating-fig-3/subwayplot-1.png)


Aligning with cowplot
---------------------

Cowplot's `plot_grid()` will fit these two plots together. Originally, I had to 
export these plots and align them by hand in inkscape, but now, they can be 
plotted together and aligned in one swoop. There's some fiddling to be done with
the margins, but it might be easier to export it as an svg, and then slide one
over to the other in 2 minutes in inkscape.



{% highlight r %}
plot_grid(ranges, bars, align = "h", rel_widths = c(2.5, 1))
{% endhighlight %}

![plot of chunk cowplot](http://zkamvar.github.io/figures/2016-02-10-recreating-fig-3/cowplot-1.png)

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
##  version  R version 3.3.1 (2016-06-21)
##  system   x86_64, darwin13.4.0        
##  ui       RStudio (0.99.1292)         
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  tz       America/Los_Angeles         
##  date     2016-09-04
{% endhighlight %}



{% highlight text %}
## Packages -------------------------------------------------------------------------------------------
{% endhighlight %}



{% highlight text %}
##  package    * version     date       source                                  
##  ade4       * 1.7-4       2016-03-01 CRAN (R 3.2.3)                          
##  adegenet   * 2.0.2       2016-09-02 Github (thibautjombart/adegenet@a349841)
##  ape          3.5         2016-05-24 CRAN (R 3.3.0)                          
##  assertthat   0.1         2013-12-06 CRAN (R 3.2.0)                          
##  boot         1.3-18      2016-02-23 CRAN (R 3.2.3)                          
##  cluster      2.0.4       2016-04-18 CRAN (R 3.3.0)                          
##  coda         0.18-1      2015-10-16 CRAN (R 3.2.0)                          
##  colorspace   1.2-6       2015-03-11 CRAN (R 3.2.0)                          
##  cowplot    * 0.6.2       2016-04-20 CRAN (R 3.2.5)                          
##  DBI          0.4-1       2016-05-08 CRAN (R 3.3.0)                          
##  deldir       0.1-12      2016-03-06 CRAN (R 3.2.4)                          
##  devtools     1.12.0      2016-06-24 CRAN (R 3.3.0)                          
##  digest       0.6.10      2016-08-02 CRAN (R 3.3.0)                          
##  dplyr        0.5.0       2016-06-24 CRAN (R 3.3.0)                          
##  evaluate     0.9         2016-04-29 CRAN (R 3.2.5)                          
##  fastmatch    1.0-4       2012-01-21 CRAN (R 3.2.0)                          
##  formatR      1.4         2016-05-09 CRAN (R 3.3.0)                          
##  gdata        2.17.0      2015-07-04 CRAN (R 3.2.0)                          
##  ggplot2    * 2.1.0       2016-03-01 CRAN (R 3.3.0)                          
##  gmodels      2.16.2      2015-07-22 CRAN (R 3.2.0)                          
##  gtable       0.2.0       2016-02-26 CRAN (R 3.2.3)                          
##  gtools       3.5.0       2015-05-29 CRAN (R 3.2.0)                          
##  htmltools    0.3.5       2016-03-21 CRAN (R 3.2.4)                          
##  httpuv       1.3.3       2015-08-04 CRAN (R 3.2.0)                          
##  igraph       1.0.1       2015-06-26 CRAN (R 3.2.0)                          
##  knitr      * 1.14        2016-08-13 cran (@1.14)                            
##  labeling     0.3         2014-08-23 CRAN (R 3.2.0)                          
##  lattice      0.20-33     2015-07-14 CRAN (R 3.2.0)                          
##  LearnBayes   2.15        2014-05-29 CRAN (R 3.2.0)                          
##  magrittr     1.5         2014-11-22 CRAN (R 3.2.0)                          
##  MASS         7.3-45      2015-11-10 CRAN (R 3.2.2)                          
##  Matrix       1.2-6       2016-05-02 CRAN (R 3.3.0)                          
##  memoise      1.0.0       2016-01-29 CRAN (R 3.2.3)                          
##  mgcv         1.8-13      2016-07-21 CRAN (R 3.3.0)                          
##  mime         0.5         2016-07-07 cran (@0.5)                             
##  munsell      0.4.3       2016-02-13 CRAN (R 3.2.3)                          
##  nlme         3.1-128     2016-05-10 CRAN (R 3.3.0)                          
##  nnls         1.4         2012-03-19 CRAN (R 3.2.0)                          
##  pegas        0.9         2016-04-16 CRAN (R 3.2.5)                          
##  permute      0.9-0       2016-01-24 CRAN (R 3.2.3)                          
##  phangorn     2.0.4       2016-06-21 CRAN (R 3.3.0)                          
##  plyr         1.8.4       2016-06-08 CRAN (R 3.3.0)                          
##  poppr      * 2.2.1       2016-08-29 CRAN (R 3.3.1)                          
##  quadprog     1.5-5       2013-04-17 CRAN (R 3.2.0)                          
##  R6           2.1.3       2016-08-19 cran (@2.1.3)                           
##  Rcpp         0.12.6      2016-07-19 CRAN (R 3.3.0)                          
##  reshape2     1.4.1       2014-12-06 CRAN (R 3.2.0)                          
##  rstudioapi   0.6         2016-06-27 cran (@0.6)                             
##  scales       0.4.0       2016-02-26 CRAN (R 3.2.3)                          
##  seqinr       3.3-0       2016-07-19 CRAN (R 3.3.0)                          
##  shiny        0.13.2.9005 2016-09-02 Github (rstudio/shiny@1ff52c5)          
##  sp           1.2-3       2016-04-14 CRAN (R 3.3.0)                          
##  spdep        0.6-6       2016-07-30 CRAN (R 3.3.0)                          
##  stringi      1.1.1       2016-05-27 CRAN (R 3.3.0)                          
##  stringr      1.0.0       2015-04-30 CRAN (R 3.2.0)                          
##  tibble       1.2         2016-08-26 cran (@1.2)                             
##  vegan        2.4-0       2016-06-15 CRAN (R 3.3.0)                          
##  withr        1.0.2       2016-06-20 cran (@1.0.2)                           
##  xtable       1.8-2       2016-02-05 CRAN (R 3.2.3)
{% endhighlight %}
[fig3]: https://www.researchgate.net/publication/278039693_Spatial_and_Temporal_Analysis_of_Populations_of_the_Sudden_Oak_Death_Pathogen_in_Oregon_Forests/figures
[sod]: http://apsjournals.apsnet.org/doi/10.1094/PHYTO-12-14-0350-FI
[sod-free]: https://www.researchgate.net/publication/278039693_Spatial_and_Temporal_Analysis_of_Populations_of_the_Sudden_Oak_Death_Pathogen_in_Oregon_Forests
[analysis]: https://github.com/zkamvar/Sudden_Oak_Death_in_Oregon_Forests#readme