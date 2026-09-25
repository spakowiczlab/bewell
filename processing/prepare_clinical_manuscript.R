# Build data/derived/clinical_manuscript.rds.
#
# This is the only script that reads T:/Labs/Spakowicz/bewell.
# Private inputs, used when that folder is available:
#   BEWELL demographics.csv
#   09-10-21_demographics.csv
#   BeWell-studyid_consentdate.xlsx
#   Be Well Study Schedule.xlsx
#   bewell_studyschedule-v1 mb stats graphs.xlsx
#   study-dates.RDS   (calendar dates; converted to days before saving)
#
# The saved object is a list:
#   subjects       one row per subject (demographics, IPAQ, diet scores, cohort flags)
#   visits         Subject ID, event, date
#   samples        timepoint key, one row per completer
#   samples_long   timepoint key, one row per sample
#   diet           diet scores, including Username and userid
#
# Body mass index is not in these files, so it is not in the object.

repo_root <- if (file.exists("data/derived") || file.exists("processing")) {
  if (file.exists("data/derived")) "." else ".."
} else {
  stop("Run this script from the repository root or from processing/.")
}

private_dir <- "T:/Labs/Spakowicz/bewell"
out_path <- file.path(repo_root, "data", "derived", "clinical_manuscript.rds")

subject_number <- function(x) {
  as.integer(sub("^HONC60-0*", "", as.character(x)))
}

read_private <- function(filename) {
  path <- file.path(private_dir, filename)
  if (!file.exists(path)) {
    return(NULL)
  }
  message("Reading ", path)
  if (grepl("\\.xlsx$", filename, ignore.case = TRUE)) {
    return(readxl::read_excel(path))
  }
  read.csv(path, check.names = FALSE, fileEncoding = "UTF-8-BOM")
}

existing <- if (file.exists(out_path)) readRDS(out_path) else NULL
subjects <- if (is.data.frame(existing)) {
  existing
} else if (is.list(existing) && !is.null(existing$subjects)) {
  existing$subjects
} else {
  NULL
}

demo <- read_private("BEWELL demographics.csv")
ipaq <- read_private("09-10-21_demographics.csv")
if (!is.null(demo) && !is.null(ipaq)) {
  demo_keep <- c("Subject ID", "Gender", "Smoking status", "Age", "Race/ethnicity")
  ipaq_keep <- c(
    "subject_number", "IPAQscore",
    "METwalking", "METmoderate", "METvig", "METmins"
  )
  demo <- demo[, demo_keep, drop = FALSE]
  ipaq <- ipaq[, ipaq_keep, drop = FALSE]
  demo$subject_number <- subject_number(demo[["Subject ID"]])
  ipaq$subject_number <- as.integer(ipaq$subject_number)
  rebuilt <- merge(demo, ipaq, by = "subject_number", all = TRUE)
  if (!is.null(subjects)) {
    keep_flags <- intersect(
      c("consented", "completed_all_visits", "resedip", "resedih", "HEI2015"),
      names(subjects)
    )
    if (length(keep_flags)) {
      rebuilt <- merge(
        rebuilt,
        subjects[, c("subject_number", keep_flags), drop = FALSE],
        by = "subject_number",
        all.x = TRUE
      )
    }
  }
  subjects <- rebuilt
}
if (is.null(subjects)) {
  stop("No subject table is available. Mount T:/Labs/Spakowicz/bewell and rerun.")
}

schedule_path <- file.path(private_dir, "bewell_studyschedule-v1 mb stats graphs.xlsx")
schedule <- if (file.exists(schedule_path)) {
  message("Reading ", schedule_path)
  readxl::read_excel(schedule_path, sheet = 2)
} else {
  NULL
}
if (!is.null(schedule) && "Completed V4" %in% names(schedule)) {
  completed <- data.frame(
    subject_number = subject_number(schedule[[1]]),
    completed_all_visits = !is.na(schedule[["Completed V4"]]) &
      tolower(as.character(schedule[["Completed V4"]])) == "x",
    stringsAsFactors = FALSE
  )
  completed <- completed[!is.na(completed$subject_number), ]
  completed <- completed[!duplicated(completed$subject_number), ]
  subjects$completed_all_visits <- NULL
  subjects <- merge(subjects, completed, by = "subject_number", all.x = TRUE)
  subjects$completed_all_visits[is.na(subjects$completed_all_visits)] <- FALSE
}

consent_path <- file.path(private_dir, "BeWell-studyid_consentdate.xlsx")
if (file.exists(consent_path)) {
  message("Reading ", consent_path)
  consent <- readxl::read_excel(consent_path)
  consented_ids <- subject_number(consent[["Study ID"]])
  consented_ids <- consented_ids[!is.na(consented_ids)]
  subjects$consented <- subjects$subject_number %in% consented_ids
  missing_consent <- consented_ids[!consented_ids %in% subjects$subject_number]
  if (length(missing_consent)) {
    extra <- subjects[0, ]
    extra[seq_along(missing_consent), ] <- NA
    extra$subject_number <- missing_consent
    extra$consented <- TRUE
    extra$completed_all_visits <- FALSE
    subjects <- rbind(subjects, extra)
  }
}

diet_path <- file.path(repo_root, "data", "derived", "bewelldietscore.07122022.csv")
diet <- read.csv(diet_path, fileEncoding = "UTF-8-BOM", check.names = FALSE)
diet_scores <- data.frame(
  subject_number = subject_number(diet$Username),
  resedip = as.numeric(diet$resedip),
  resedih = as.numeric(diet$resedih),
  HEI2015 = as.numeric(diet$HEI2015),
  stringsAsFactors = FALSE
)
diet_scores <- diet_scores[!is.na(diet_scores$subject_number), ]
subjects$resedip <- NULL
subjects$resedih <- NULL
subjects$HEI2015 <- NULL
subjects <- merge(subjects, diet_scores, by = "subject_number", all.x = TRUE)

visit_path <- file.path(private_dir, "Be Well Study Schedule.xlsx")
if (file.exists(visit_path)) {
  message("Reading ", visit_path)
  visits_wide <- readxl::read_excel(visit_path, skip = 1, trim_ws = TRUE)
  visit_cols <- intersect(
    c(
      "Subject ID", "Consented date", "Visit 1", "Redoing V1",
      "Visit 2", "Visit 3", "Redoing V3", "Visit 4"
    ),
    names(visits_wide)
  )
  visits <- visits_wide[, visit_cols, drop = FALSE]
  visits <- tidyr::pivot_longer(
    visits,
    cols = -`Subject ID`,
    names_to = "event",
    values_to = "date"
  )
} else {
  study_dates_path <- file.path(private_dir, "study-dates.RDS")
  if (!file.exists(study_dates_path)) {
    study_dates_path <- file.path(repo_root, "data", "derived", "study-dates.RDS")
  }
  if (file.exists(study_dates_path)) {
    message("Reading ", study_dates_path)
    visits <- readRDS(study_dates_path)
    if (!"Subject ID" %in% names(visits) && "id" %in% names(visits)) {
      names(visits)[names(visits) == "id"] <- "Subject ID"
    }
  } else if (is.list(existing) && !is.null(existing$visits)) {
    visits <- existing$visits
  } else {
    stop("Visit dates were not found on T:/Labs/Spakowicz/bewell.")
  }
}

samples <- read.csv(file.path(repo_root, "data", "derived", "timepoint_key.csv"))
samples_long <- read.csv(file.path(repo_root, "data", "derived", "timepoint_key_long.csv"))

# Store days from consent, or from Visit 1 when consent is missing.
# Calendar dates are not written to the RDS. Rows that are already in
# days (no date column) are kept as they are.
if ("date" %in% names(visits)) {
  visits$date <- as.Date(visits$date)
  anchor <- visits[visits$event == "Consented date", c("Subject ID", "date")]
  names(anchor)[2] <- "anchor"
  anchor$day_zero <- "consent"
  visit1 <- visits[visits$event == "Visit 1", c("Subject ID", "date")]
  names(visit1)[2] <- "visit1"
  anchor <- merge(anchor, visit1, by = "Subject ID", all = TRUE)
  use_visit1 <- is.na(anchor$anchor) & !is.na(anchor$visit1)
  anchor$anchor[use_visit1] <- anchor$visit1[use_visit1]
  anchor$day_zero[use_visit1] <- "visit_1"
  anchor$visit1 <- NULL
  anchor <- anchor[!is.na(anchor$anchor) & !duplicated(anchor[["Subject ID"]]), ]
  visits <- merge(visits, anchor, by = "Subject ID", all.x = TRUE)
  visits$day <- as.integer(visits$date - visits$anchor)
  visits$date <- NULL
  visits$anchor <- NULL
}

clinical <- list(
  subjects = subjects,
  visits = visits,
  samples = samples,
  samples_long = samples_long,
  diet = diet
)

saveRDS(clinical, out_path)
message(
  "Wrote ", out_path,
  ": ", nrow(subjects), " subjects, ",
  nrow(visits), " visit rows, ",
  nrow(samples_long), " samples."
)
