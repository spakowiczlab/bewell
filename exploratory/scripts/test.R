
library(tidyverse)
library(reshape2)
library(rstatix)

king <- read.csv("../../data/derived/RelAbun/RelAbun_king.csv", row.names = 1)
phyl <- read.csv("../../data/derived/RelAbun/RelAbun_phyl.csv",row.names = 1)
class <- read.csv("../../data/derived/RelAbun/RelAbun_class.csv",row.names = 1)
ord <- read.csv("../../data/derived/RelAbun/RelAbun_ord.csv", row.names = 1)
fam <- read.csv("../../data/derived/RelAbun/RelAbun_fam.csv", row.names = 1)
gen <- read.csv("../../data/derived/RelAbun/RelAbun_gen.csv", row.names = 1)
spec <- read.csv("../../data/derived/RelAbun/RelAbun_spec.csv", row.names = 1)

run_wilcox <- function(level, str1, str2){
  microbes <- colnames(level)
  tableOfResults<-data.frame(var=microbes)
  tableOfResults$p_wilcox <- NA
  rownames(tableOfResults) <- microbes
  
  tempR <- filter(level, grepl(str1, rownames(level)))
  tempT <- filter(level, grepl(str2, rownames(level)))
  
  for(mic in colnames(level)){
    x <- tempR[, mic]
    y <- tempT[, mic]
    
    thiscommand <- paste("thiswilcox <- wilcox.test(x, y, paired = TRUE)")
    eval(parse(text = thiscommand))
    tableOfResults[mic, "p_wilcox"] <- thiswilcox$p.value
    
    # thiscommand <- paste("thiswilcox <- wilcox_effsize(x ~ y, paired = TRUE)")
    # eval(parse(text = thiscommand))
    # tableOfResults[mic, "effect-size"] <- thiswilcox$effsize
  }
  tableOfResults <- tableOfResults %>% select(p_wilcox)
  return(tableOfResults)
}



spec_dif <- run_wilcox(spec, "rB", "tB")
gen_dif <- run_wilcox(gen, "rB", "tB")
fam_dif <- run_wilcox(fam, "rB", "tB")
ord_dif <- run_wilcox(ord, "rB", "tB")
class_dif <- run_wilcox(class, "rB", "tB")
phyl_dif <- run_wilcox(phyl, "rB", "tB")
king_dif <- run_wilcox(king, "rB", "tB")

#combine and filter to p-value < 0.05
BRBresults <- rbind(king_dif, phyl_dif, class_dif, ord_dif, fam_dif, gen_dif, spec_dif) 
# %>% filter(p_wilcox < 0.05)


level = spec
str1 = "rB"
str2 = "tB"
  
microbes <- colnames(level)
tableOfResults<-data.frame(var=microbes)
tableOfResults$effect_size <- NA
rownames(tableOfResults) <- microbes

tempR <- filter(level, grepl(str1, rownames(level)))
tempT <- filter(level, grepl(str2, rownames(level)))

for(mic in colnames(level)){
  x <- tempR[, mic]
  y <- tempT[, mic]
  
  x.df <- as.data.frame(x) %>%
    rename("rB" = x)
  y.df <- as.data.frame(y) %>%
    rename("tB" = y)

  temp <- cbind(x.df, y.df)
  temp$id <- rownames(temp)
  
  temp <- temp %>%
    gather(key = "group", value = "relAbun", rB, tB)
  
  # thiscommand <- paste("thiswilcox <- temp %>% wilcox_effsize(relAbun ~ group, paired = TRUE)")
  # eval(parse(text = thiscommand))
  # tableOfResults[mic, "effect_size"] <- thiswilcox$effsize
  
  thiscommand <- paste("thiswilcox <- wilcox.test(x, y, paired = TRUE)")
  eval(parse(text = thiscommand))
  tableOfResults[mic, "p_wilcox"] <- thiswilcox$p.value
}
