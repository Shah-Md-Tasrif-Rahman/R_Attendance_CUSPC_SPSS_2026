# Libraries ----

library(readr)
library(dplyr)
library(tidyr)
library(tidyverse)
library(stringr)
library(scales)
library(writexl)
library(openxlsx)

# Custom functions are needed here ----

convert_minutes <- function(x) {
  hours <- ifelse(str_detect(x, "hr"), as.numeric(str_extract(x, "\\d+(?= hr)")), 0)
  
  minutes <- ifelse(str_detect(x, "min"), as.numeric(str_extract(x, "\\d+(?= min)")), 0)
  
  seconds <- ifelse(str_detect(x, "s"), as.numeric(str_extract(x, "\\d+(?=s)")), 0)
  
  hours * 60 + minutes + seconds / 60
}

# Now we can begin data extraction

# Now I'm feeling I should make more functions ----

# File extracting function

read_attendance <- function(file_path) {
  read_csv(file_path,
           col_select = c("Participant Name", "Attended Duration")) %>%
    filter(if_any(everything(), complete.cases))
}

# File formatting function

add_attendance_date <- function(data, date_input) {
  data %>%
    mutate(
      Duration_Minutes = convert_minutes(`Attended Duration`),
      Date = as.Date(date_input),
      Date_Name = weekdays(Date)
    )
}

# Now we can truly move on ----

# Base directory path
dir_path <- r"(C:\Users\Tasrif\Desktop\R_Project about class attendance\csv)"

# d1: 14-Jul-2026
d1 <- read_attendance(file.path(dir_path, "Attendance Report - [MEETING LINK] (14-Jul-2026).csv"))
d1 <- add_attendance_date(d1, "2026-7-14")

# d2: 17-Jul-2026
d2 <- read_attendance(file.path(dir_path, "Attendance Report - [MEETING LINK] (17-Jul-2026).csv"))
d2 <- add_attendance_date(d2, "2026-7-17")

# d3: 21-Jul-2026
d3 <- read_attendance(file.path(dir_path, "Attendance Report - [MEETING LINK] (21-Jul-2026).csv"))
d3 <- add_attendance_date(d3, "2026-7-21")

# d4: 24-Jul-2026
d4 <- read_attendance(file.path(dir_path, "Attendance Report - [MEETING LINK] (24-Jul-2026).csv"))
d4 <- add_attendance_date(d4, "2026-7-24")

# d5: 28-Jul-2026
d5 <- read_attendance(file.path(dir_path, "Attendance Report - [MEETING LINK] (28-Jul-2026).csv"))
d5 <- add_attendance_date(d5, "2026-7-28")

# d6: 04-Aug-2026
d6 <- read_attendance(file.path(dir_path, "Attendance Report - [MEETING LINK] (4-Aug-2026).csv"))
d6 <- add_attendance_date(d6, "2026-8-4")

# d8: 11-Aug-2026
d8 <- read_attendance(file.path(dir_path, "Attendance Report - [MEETING LINK] (11-Aug-2026).csv"))
d8 <- add_attendance_date(d8, "2026-8-11")

# d9: 14-Aug-2026
d9 <- read_attendance(file.path(dir_path, "Attendance Report - [MEETING LINK] (14-Aug-2026).csv"))
d9 <- add_attendance_date(d9, "2026-8-14")

# d10: 18-Aug-2026
d10 <- read_attendance(file.path(dir_path, "Attendance Report - [MEETING LINK] (18-Aug-2026).csv"))
d10 <- add_attendance_date(d10, "2026-8-18")

# d12: 25-Aug-2026
d12 <- read_attendance(file.path(dir_path, "Attendance Report - [MEETING LINK] (25-Aug-2026).csv"))
d12 <- add_attendance_date(d12, "2026-8-25")

# Master dataset ----

master_dataset <- bind_rows(d1, d2, d3, d4, d5, d6, d8, d9, d10, d12)

# Checking some stuff ----

summary(master_dataset$Duration_Minutes)
master_dataset %>% count(Date, Date_Name)
master_dataset %>%
  count(`Participant Name`, Date) %>%
  filter(n > 1)

# Dataset changes: ----
# One participant had a duplicate value in 14-7-2026, deleted that from CSV
# Another participant had used different gmail in 25-8-2026, fixed that by modifying the CSV

# Creating specific dataframes ----

# For individual participants

individual_participant_attendance <- master_dataset %>%
  select('Participant Name', Date, Duration_Minutes) %>%
  pivot_wider(names_from = Date, values_from = Duration_Minutes)

# Leaderboard ----

individual_participant_statistics <- individual_participant_attendance  %>%
  mutate(
    Total_Class_Time = rowSums(across(where(is.numeric)), na.rm = TRUE),
    Average_Class_Time = rowMeans(across(where(is.numeric) &
                                           !Total_Class_Time), na.rm = TRUE),
    Attendance_Count = rowSums(!is.na(
      pick(-Total_Class_Time, -Average_Class_Time, -"Participant Name")
    ))
  ) %>%
  relocate(Total_Class_Time, .after = 1) %>%
  relocate(Average_Class_Time, .after = 2) %>%
  relocate(Attendance_Count, .after = 3) %>%
  arrange(desc(Total_Class_Time))

write.xlsx(
  individual_participant_statistics,
  "E:/Statistical Softwares/R/RStudio/Projects/R_Attendance_CUSPC_SPSS_2026/Pseudonymization_process/Leaderboard.xlsx",
  overwrite = TRUE
)

write.xlsx(
  master_dataset,
  "E:/Statistical Softwares/R/RStudio/Projects/R_Attendance_CUSPC_SPSS_2026/Pseudonymization_process/Master_dataset.xlsx",
  overwrite = TRUE
)

# Pseudonymization time ----

# We'll generate keys using Leaderboard.xlsx to pseudonymize the master_dataset

real_names_leaderboard <- read.xlsx(
  "E:/Statistical Softwares/R/RStudio/Projects/R_Attendance_CUSPC_SPSS_2026/Pseudonymization_process/Leaderboard.xlsx"
)
names(real_names_leaderboard) <- gsub("\\.", " ", names(real_names_leaderboard))

pseudo_leaderboard <- real_names_leaderboard |>
  mutate(Pseudonym_key = sprintf("Participant_%03d", row_number())) |>
  select("Participant Name", Pseudonym_key, everything())

write.xlsx(
  pseudo_leaderboard,
  "E:/Statistical Softwares/R/RStudio/Projects/R_Attendance_CUSPC_SPSS_2026/Pseudonymization_process/Pseudo_Leaderboard.xlsx",
  overwrite = TRUE
)

pseudo_leaderboard_output <- subset(pseudo_leaderboard, select = -c(`Participant Name`))
names(pseudo_leaderboard_output)[1] <- "Participant Pseudonym"
write.xlsx(
  pseudo_leaderboard_output,
  "E:/Statistical Softwares/R/RStudio/Projects/R_Attendance_CUSPC_SPSS_2026/Pseudonymization_process/Public_datasets/Pseudo_Leaderboard_Output.xlsx",
  overwrite = TRUE
)

pseudo_master_dataset <- master_dataset |>
  left_join(pseudo_leaderboard |>
              select("Participant Name", Pseudonym_key),
            by = "Participant Name") |>
  select(-"Participant Name") |>
  relocate(Pseudonym_key)

check_unmatched <- pseudo_master_dataset |>
  filter(is.na(Pseudonym_key))
if (nrow(check_unmatched) > 0) {
  warning(paste(nrow(check_unmatched), "Rows have no matching pseudonym."))
}

names(pseudo_master_dataset)[1] <- "Participant Pseudonym"

write.xlsx(
  pseudo_master_dataset,
  "E:/Statistical Softwares/R/RStudio/Projects/R_Attendance_CUSPC_SPSS_2026/Pseudonymization_process/Public_datasets/Pseudo_Master_dataset.xlsx",
  overwrite = TRUE
)

# For daily participants ----

daily_summary <- pseudo_master_dataset %>%
  group_by(Date, Date_Name) %>%
  summarise(
    Participants = n_distinct(`Participant Pseudonym`),
    Mean_Minutes = mean(Duration_Minutes, na.rm = TRUE),
    Median_Minutes = median(Duration_Minutes, na.rm = TRUE),
    Standard_Deviation = sd(Duration_Minutes, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(Class = row_number()) %>%
  relocate(Class) %>%
  relocate(Participants, .after = Class)

write.xlsx(
  daily_summary,
  "E:/Statistical Softwares/R/RStudio/Projects/R_Attendance_CUSPC_SPSS_2026/Pseudonymization_process/Public_datasets/Daily attendance summary.xlsx",
  overwrite = TRUE
)

# Weekday summary ----

weekday_summary <- daily_summary %>%
  group_by(Date_Name) %>%
  summarise(
    Mean_Participants = mean(Participants),
    Mean_Minutes = mean(Mean_Minutes),
    Median_Minutes = median(Median_Minutes),
    .groups = "drop"
  )

write.xlsx(
  weekday_summary,
  "E:/Statistical Softwares/R/RStudio/Projects/R_Attendance_CUSPC_SPSS_2026/Pseudonymization_process/Public_datasets/Weekdays_separated.xlsx",
  overwrite = TRUE
)

# Tuesday vs Friday: participant-level paired dataset ----

weekday_paired <- pseudo_master_dataset %>%
  group_by(`Participant Pseudonym`, Date_Name) %>%
  summarise(Mean_Minutes = mean(Duration_Minutes, na.rm = TRUE),
            .groups = "drop") %>%
  pivot_wider(names_from = Date_Name,
              values_from = Mean_Minutes,
              names_glue = "{Date_Name}_Mean_Minutes") %>%
  filter(!is.na(Tuesday_Mean_Minutes), !is.na(Friday_Mean_Minutes))

write.xlsx(
  weekday_paired,
  "E:/Statistical Softwares/R/RStudio/Projects/R_Attendance_CUSPC_SPSS_2026/Pseudonymization_process/Public_datasets/Tuesday_vs_Friday_Paired.xlsx",
  overwrite = TRUE
)

# Making a final pseudonymized master dataset with all context ----

read_attendance_modified <- function(file_path) {
  read_csv(file_path, col_select = -c("Meeting code", "SNo")) %>%
    filter(if_any(everything(), complete.cases))
}

# Fetching all the csv files ----

# Base directory path
dir_path <- r"(C:\Users\Tasrif\Desktop\R_Project about class attendance\csv)"

# d1: 14-Jul-2026
d1 <- read_attendance_modified(file.path(dir_path, "Attendance Report - [MEETING LINK] (14-Jul-2026).csv"))
d1 <- add_attendance_date(d1, "2026-7-14")

# d2: 17-Jul-2026
d2 <- read_attendance_modified(file.path(dir_path, "Attendance Report - [MEETING LINK] (17-Jul-2026).csv"))
d2 <- add_attendance_date(d2, "2026-7-17")

# d3: 21-Jul-2026
d3 <- read_attendance_modified(file.path(dir_path, "Attendance Report - [MEETING LINK] (21-Jul-2026).csv"))
d3 <- add_attendance_date(d3, "2026-7-21")

# d4: 24-Jul-2026
d4 <- read_attendance_modified(file.path(dir_path, "Attendance Report - [MEETING LINK] (24-Jul-2026).csv"))
d4 <- add_attendance_date(d4, "2026-7-24")

# d5: 28-Jul-2026
d5 <- read_attendance_modified(file.path(dir_path, "Attendance Report - [MEETING LINK] (28-Jul-2026).csv"))
d5 <- add_attendance_date(d5, "2026-7-28")

# d6: 04-Aug-2026
d6 <- read_attendance_modified(file.path(dir_path, "Attendance Report - [MEETING LINK] (4-Aug-2026).csv"))
d6 <- add_attendance_date(d6, "2026-8-4")

# d8: 11-Aug-2026
d8 <- read_attendance_modified(file.path(dir_path, "Attendance Report - [MEETING LINK] (11-Aug-2026).csv"))
d8 <- add_attendance_date(d8, "2026-8-11")

# d9: 14-Aug-2026
d9 <- read_attendance_modified(file.path(dir_path, "Attendance Report - [MEETING LINK] (14-Aug-2026).csv"))
d9 <- add_attendance_date(d9, "2026-8-14")

# d10: 18-Aug-2026
d10 <- read_attendance_modified(file.path(dir_path, "Attendance Report - [MEETING LINK] (18-Aug-2026).csv"))
d10 <- add_attendance_date(d10, "2026-8-18")

# d12: 25-Aug-2026
d12 <- read_attendance_modified(file.path(dir_path, "Attendance Report - [MEETING LINK] (25-Aug-2026).csv"))
d12 <- add_attendance_date(d12, "2026-8-25")

# Pseudonymized Master dataset with full context ----

master_dataset_full_context <- bind_rows(d1, d2, d3, d4, d5, d6, d8, d9, d10, d12)

pseudonymized_master_dataset_full_context <- master_dataset_full_context |>
  left_join(pseudo_leaderboard |>
              select("Participant Name", Pseudonym_key),
            by = "Participant Name") |>
  select(-"Participant Name") |>
  relocate(Pseudonym_key)

check_unmatched <- pseudonymized_master_dataset_full_context |>
  filter(is.na(Pseudonym_key))
if (nrow(check_unmatched) > 0) {
  warning(paste(nrow(check_unmatched), "Rows have no matching pseudonym."))
}

names(pseudonymized_master_dataset_full_context)[1] <- "Participant Pseudonym"

write.xlsx(
  pseudonymized_master_dataset_full_context,
  "E:/Statistical Softwares/R/RStudio/Projects/R_Attendance_CUSPC_SPSS_2026/Pseudonymization_process/Public_datasets/pseudonymized_master_dataset_full_context.xlsx",
  overwrite = TRUE
)