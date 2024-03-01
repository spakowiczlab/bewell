library(tidyverse)

fq.files <- list.files("/fs/ess/PAS1695/projects/bewell/data/fastqs/fastqs", full.names = T, pattern = "fastq")

fq.df <- as.data.frame(cbind(fq.files, sampnames = NA))%>%
  mutate(sampnames = gsub(".*(FF.*)\\.fast.*", "\\1", fq.files))


samples <- unique(fq.df$sampnames)

for(s in samples){
  fileOut<- paste0("/fs/ess/PAS1695/projects/bewell/scripts/batch/humann3_", s, ".pbs")
  
  writeLines(c(paste0("#PBS -N humann3_", s),
               "#PBS -A PAS1695",
               "#PBS -l walltime=10:00:00",
               "#PBS -l nodes=1:ppn=28",
               "#PBS -j oe",
               "",
               "cd /fs/ess/PAS1695/projects/bewell/data/fastqs/fastqs",
               "module load python/3.7-2019.10",
               "source activate humann3.2023.12",
               paste0("humann -i ", s, ".fastq.gz"," -o ", "../../humann3/", s, " --threads 28 --input-format fastq.gz",
                      " --nucleotide-database /fs/ess/PAS1695/db/chocophlan/chocophlan --protein-database /fs/ess/PAS1695/db/chocophlan/uniref"),
               ""),
             fileOut)
}


# res.dir <- "/fs/scratch/PAS1695/projects/iobio/humann3/"
# res.files <- list.files(res.dir)
# 
# mettab.ls <- lapply(samples, function(x) read.table(paste0("/fs/scratch/PAS1695/projects/iobio/humann3/",
#                                                            x, "/",x, "_humann_temp/", x, "_metaphlan_bugs_list.tsv"),
#                                                     header = F, sep = "\t", stringsAsFactors = F) %>%
#                       mutate(V2 = as.character(V2)))
# names(mettab.ls) <- samples
# metab.df <- bind_rows(lapply(samples, function(x) mettab.ls[[x]] %>% mutate(sample = x)))
# 
# 
# 
# metab.df.form <- metab.df %>%
#   rename("Taxonomy" = "V1",
#          "TaxNum" = "V2",
#          "RelAbun" = "V3",
#          "Alternative.Tax" = "V4")
# write.csv(metab.df.form, "/fs/ess/PAS1695/projects/iobio/2023-12-07_mpa-aggregate.csv", row.names = F)
# write.csv(metab.df.form, "../data/2023-12-07_mpa-aggregate.csv", row.names = F)

humann.ls <- lapply(samples, function(x) read.table(paste0("/fs/ess/PAS1695/projects/bewell/data/humann3/",
                                                           x, "/",x, "_pathabundance.tsv"),
                                                    header = F, sep = "\t", stringsAsFactors = F) %>%
                      mutate(sample = x))

humann3.df <- humann.ls %>%
  bind_rows() %>%
  rename("Pathway" = "V1",
         "PathAbun" = "V2")
write.csv(humann3.df, "/fs/ess/PAS1695/projects/bewell/data/2024-02-01_humann3-aggregate.csv", row.names = F)
write.csv(humann3.df, "../data/2024-02-01_humann3-aggregate.csv", row.names = F)
