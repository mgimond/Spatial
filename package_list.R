get.pckg.info <- function(fname){
library(purrr)
library(stringr)

x <- readChar(fname, file.info(fname)$size)

pck_names <- str_match_all(x, "library\\(\\s*(.*?)\\s*\\)") [[1]][,2]
sapply(pck_names, 
       FUN = function(x) as.character(packageVersion(x)))


pck_names <- pck_names[!pck_names %in% c( "kableExtra", "knitr", "dplyr", 
                                          "gridExtra", "reshape2","Matrix",
                                          "leaflet", "latticeExtra", "lattice",
                                          "rpart", "nlme")]

pck.ver <- 
  t(data.frame( Package = pck_names,
                Version = sapply(pck_names, 
                                 FUN = function(x) as.character(packageVersion(x))),
                row.names = NULL))

pck.ver <- cbind(c("R", substring(R.version$version.string, 11, 16) ), pck.ver )

rownames(pck.ver) <- NULL

row.style <- "font-size: 12px !important; 
              margin:5px; 
              border-radius: 8px;
              border: 2px solid white;
              padding-top: 1px;
              padding-bottom: 1px;
              padding-left: 4px;
              padding-right: 4px;"


library(dplyr)
kableExtra::kbl( pck.ver, escape = FALSE, table.attr = "class=\"package_ver_table\" ") %>%
  kableExtra::row_spec(row = 1,   align = "center",
                       extra_css = row.style,
                       color = "black", background = "#ffc178") %>% 
  kableExtra::row_spec(row = 2,  align = "center",
                       extra_css = row.style,
                       color = "white", background = "#AAAAAA") 
}