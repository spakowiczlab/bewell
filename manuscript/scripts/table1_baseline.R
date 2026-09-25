# Table 1. Baseline demographic and clinical characteristics.
# Two overlapping cohorts, matching the manuscript table:
#   participants who completed all visits, and everyone who consented.
# Body mass index is not in this repository and is omitted.

repo_root <- if (file.exists("../../data/derived/clinical_manuscript.rds")) {
  "../.."
} else if (file.exists("data/derived/clinical_manuscript.rds")) {
  "."
} else {
  stop("Run from manuscript/scripts or the repository root.")
}

clinical <- readRDS(file.path(repo_root, "data/derived/clinical_manuscript.rds"))$subjects

clinical$Gender <- factor(
  tools::toTitleCase(tolower(trimws(clinical$Gender))),
  levels = c("Female", "Male")
)
clinical$`Smoking status` <- factor(
  tools::toTitleCase(tolower(trimws(clinical$`Smoking status`))),
  levels = c("Former", "Current")
)

race <- tolower(trimws(clinical$`Race/ethnicity`))
race[race == ""] <- NA_character_
clinical$Race <- NA_character_
clinical$Race[race %in% c("white", "caucasian", "white caucasian")] <- "White"
clinical$Race[race %in% c("african american", "black", "african")] <- "African American"
clinical$Race[!is.na(race) & is.na(clinical$Race)] <- "Other/Unk"
clinical$Race <- factor(
  clinical$Race,
  levels = c("White", "African American", "Other/Unk")
)

clinical$`Age group` <- cut(
  clinical$Age,
  breaks = c(55, 67, 80),
  right = FALSE,
  labels = c("55-66 years", "67-79 years")
)

clinical$IPAQ <- dplyr::recode(
  clinical$IPAQscore,
  "HEPA active" = "Active",
  "Minimally active" = "Minimally active",
  "Inactive" = "Inactive"
)
clinical$IPAQ <- factor(
  clinical$IPAQ,
  levels = c("Active", "Minimally active", "Inactive")
)

hei <- clinical$HEI2015
clinical$`HEI-2015` <- NA_character_
clinical$`HEI-2015`[hei < 50] <- "Poor (<50)"
clinical$`HEI-2015`[hei >= 51 & hei <= 79] <- "Fair (51-79)"
clinical$`HEI-2015`[hei > 80] <- "Good (>80)"
clinical$`HEI-2015` <- factor(
  clinical$`HEI-2015`,
  levels = c("Good (>80)", "Fair (51-79)", "Poor (<50)")
)

vars <- c(
  "Gender", "Race", "Age group", "Age", "Smoking status",
  "HEI-2015", "IPAQ", "resedip", "resedih"
)
cat_vars <- c("Gender", "Race", "Age group", "Smoking status", "HEI-2015", "IPAQ")

one_cohort <- function(data, label) {
  tab <- tableone::CreateTableOne(
    vars = vars,
    data = data,
    factorVars = cat_vars
  )
  printed <- print(
    tab,
    showAllLevels = TRUE,
    quote = FALSE,
    noSpaces = TRUE,
    printToggle = FALSE
  )
  out <- data.frame(
    Variable = rownames(printed),
    Level = printed[, "level"],
    value = printed[, "Overall"],
    stringsAsFactors = FALSE
  )
  names(out)[3] <- label
  out
}

completers <- clinical[clinical$completed_all_visits, ]
consented <- clinical[clinical$consented, ]

left <- one_cohort(
  completers,
  paste0("Completed all visits (N=", nrow(completers), ")")
)
right <- one_cohort(
  consented,
  paste0("All consented (N=", nrow(consented), ")")
)

table1 <- cbind(
  left[, c("Variable", "Level", names(left)[3])],
  right[, 3, drop = FALSE]
)

out_dir <- file.path(repo_root, "manuscript", "tables")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
out_path <- file.path(out_dir, "table1_baseline.csv")
write.csv(table1, out_path, row.names = FALSE)
message("Wrote ", out_path)
print(table1, row.names = FALSE)
