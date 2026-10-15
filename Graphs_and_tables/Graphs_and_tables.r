# Libraries ----

library(readr)
library(dplyr)
library(readr)
library(tidyr)
library(tidyverse)
library(ggplot2)
library(stringr)
library(scales)
library(writexl)
library(openxlsx)
library(e1071)
library(ggpmisc)
library(gtsummary)
library(performance)
library(gt)
library(tibble)
library(tinytable)
library(flextable)
library(modelsummary)
library(webshot2)
library(parameters)

# Plotting ----

# Lemme just quickly load a few datasets before using them

weekday_summary <- read.xlsx(r"(E:\Statistical Softwares\R\RStudio\Projects\R_Attendance_CUSPC_SPSS_2026\Pseudonymization_process\Public_datasets\Weekdays_separated.xlsx)")
daily_summary <- read.xlsx(r"(E:\Statistical Softwares\R\RStudio\Projects\R_Attendance_CUSPC_SPSS_2026\Pseudonymization_process\Public_datasets\Daily attendance summary.xlsx)")
pseudo_master_dataset <- read.xlsx(r"(E:\Statistical Softwares\R\RStudio\Projects\R_Attendance_CUSPC_SPSS_2026\Pseudonymization_process\Public_datasets\Pseudo_Master_dataset.xlsx)")

# 1st plot: Relative percentages between weekdays ----

ggplot(
  weekday_summary,
  aes(x = Date_Name, y = Mean_Participants / max(Mean_Participants))
) +
  geom_col(fill = "steelblue") +
  geom_text(
    aes(label = percent(Mean_Participants / max(Mean_Participants), accuracy = 0.1)),
    vjust = -0.5
  ) +
  scale_y_continuous(labels = percent, limits = c(0, 1.1)) +
  labs(
    title = "Average Class Attendance Relative to Peak Day",
    x = "Weekday",
    y = "Percentage of Peak Attendance"
  )+
  theme(plot.title = element_text(hjust = 0.5))

# 2nd plot: Class attendance line plot ----

daily_summary$Session <- factor(
  c("S1\n14-Jul",
    "S2\n17-Jul",
    "S3\n21-Jul",
    "S4\n24-Jul",
    "S5\n28-Jul",
    "S6\n04-Aug",
    "S8\n11-Aug",
    "S9\n14-Aug",
    "S10\n18-Aug",
    "S12\n25-Aug"),
  levels = c("S1\n14-Jul",
             "S2\n17-Jul",
             "S3\n21-Jul",
             "S4\n24-Jul",
             "S5\n28-Jul",
             "S6\n04-Aug",
             "S8\n11-Aug",
             "S9\n14-Aug",
             "S10\n18-Aug",
             "S12\n25-Aug")
)

ggplot(daily_summary, aes(x = Session, y = Participants, group = 1)) +
  geom_line() +
  geom_point(size = 2.2) +
  geom_text(aes(label = Participants), vjust = -1) +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, by = 10),
    expand = c(0, 0)
  ) +
  labs(
    title = "Attendance Across Class Sessions",
    x = "Session (Date, 2026)",
    y = "Number of Participants"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5)
  )

# 3rd plot: Attendance histogram ----

histogram_data <- pseudo_master_dataset %>%
  mutate(
    Duration_Bin = cut(
      Duration_Minutes,
      breaks = seq(0, 130, by = 10),
      right = FALSE,
      include.lowest = TRUE
    )
  ) %>%
  count(Duration_Bin, .drop = FALSE) %>%
  mutate(
    Bin_Midpoint = seq(5, 125, by = 10)
  )

skew_histogram <- e1071::skewness(pseudo_master_dataset$Duration_Minutes, type = 2)
kurt_histogram <- e1071::kurtosis(pseudo_master_dataset$Duration_Minutes, type = 2)

equation_text <- paste0(
  "Skewness = ",
  round(skew_histogram, 3),
  "\nKurtosis = ",
  round(kurt_histogram, 3)
)

ggplot(pseudo_master_dataset, aes(x = Duration_Minutes)) +
  geom_histogram(
    breaks = seq(0, 130, by = 10),
    closed = "left",
    color = "white",
    linewidth = 0.5
  ) +
  scale_x_continuous(
    breaks = seq(0, 130, by = 10),
    limits = c(0, 130),
    minor_breaks = NULL
  ) +
  scale_y_continuous(
    breaks = seq(0, ceiling(max(histogram_data$n) / 10) * 10, by = 10),
    limits = c(0, ceiling(max(histogram_data$n) / 10) * 10),
    minor_breaks = NULL
  ) +
  annotate(
    "text",
    x = 2,
    y = ceiling(max(histogram_data$n) / 10) * 10 * 0.98,
    label = equation_text,
    hjust = 0,
    vjust = 1,
    size = 5
  ) +
  labs(
    title = "Distribution of Attendance Duration",
    x = "Attendance Duration (minutes)",
    y = "Number of Attendance Records"
  ) +
  theme(plot.title = element_text(hjust = 0.5))

# Fitting regression models ----

daily_summary$t <- as.numeric(
  daily_summary$Date - min(daily_summary$Date)
)

# Model A: Linear Regression ----

model_linear <- lm(
  Participants ~ t,
  data = daily_summary
)

# Create smooth linear fitted line

linear_curve <- data.frame(
  t = seq(
    min(daily_summary$t),
    max(daily_summary$t),
    length.out = 100
  )
)

linear_curve$Participants <- predict(
  model_linear,
  newdata = linear_curve
)

# Model B: Exponential Decay ----

model_exponential <- nls(
  Participants ~ a * exp(b * t),
  data = daily_summary,
  start = list(
    a = max(daily_summary$Participants),
    b = -0.05
  )
)

# Model C: Asymptotic Exponential ----

model_asymptotic <- nls(
  Participants ~ c + a * exp(b * t),
  data = daily_summary,
  start = list(
    c = 25,
    # c = 25; since this is the mean of the last four somewhat similar attendance values
    a = 49,
    # a is just N(0)=74=c+a
    b = -0.05
  )
)

# Comparison table ----

model_list <- list( "Linear" = model_linear, "Exponential Decay" = model_exponential, "Asymptotic Exponential" = model_asymptotic ) 

# Putting pseudo R square in the model

pseudo_r2 <- function(model, y){
  rss <- sum(residuals(model)^2)
  tss <- sum((y - mean(y))^2)
  1 - rss/tss
}

# Fit statistics
gof_custom <- tibble(
  term = c(
    "Observation Number",
    "R²",
    "Adj. R²",
    "AIC",
    "BIC",
    "RMSE"
  ),
  Linear = c(
    nobs(model_linear),
    summary(model_linear)$r.squared,
    summary(model_linear)$adj.r.squared,
    AIC(model_linear),
    BIC(model_linear),
    sqrt(mean(residuals(model_linear)^2))
  ),
  `Exponential Decay` = c(
    nobs(model_exponential),
    pseudo_r2(model_exponential, daily_summary$Participants),
    NA,
    AIC(model_exponential),
    BIC(model_exponential),
    sqrt(mean(residuals(model_exponential)^2))
  ),
  `Asymptotic Exponential` = c(
    nobs(model_asymptotic),
    pseudo_r2(model_asymptotic, daily_summary$Participants),
    NA,
    AIC(model_asymptotic),
    BIC(model_asymptotic),
    sqrt(mean(residuals(model_asymptotic)^2))
  )
)

comparison_table <- modelsummary(
  model_list,
  output = "flextable",
  statistic = NULL,
  gof_omit = ".*",
  add_rows = gof_custom
)

comparison_table <- colformat_double(
  comparison_table,
  digits = 3
)

save_as_image(
  comparison_table,
  path = r"(E:\Statistical Softwares\R\RStudio\Projects\R_Attendance_CUSPC_SPSS_2026\Graphs_and_tables\Images\model_comparison.png)"
)

# Parameters among models ----

model_parameters(model_linear)
model_parameters(model_exponential)
model_parameters(model_asymptotic)

# 4th plot: Linear fit ----

ggplot(
  daily_summary,
  aes(x = t, y = Participants)
) +
  
  # Actual attendance
  geom_line() +
  geom_point(size = 2.2) +
  
  # Linear fitted line
  geom_line(
    data = linear_curve,
    aes(x = t, y = Participants),
    linetype = "dotted",
    linewidth = 1,
    color = "steelblue3"
  ) +
  
  scale_x_continuous(
    limits = c(0, max(daily_summary$t)),
    breaks = pretty(daily_summary$t),
    expand = expansion(mult = c(0.0015, 0.02))
  ) +
  
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, by = 10),
    expand = c(0, 0)
  ) +
  
  labs(
    title = "Attendance Across Classes With Linear Model Fitted",
    x = "Days Since First Session (t)",
    y = "Number of Participants"
  ) +
  
  theme(
    plot.title = element_text(hjust = 0.5)
  )

# 5th plot: Exponential Decay fit ----

# Create smooth exponential fitted line
exp_curve <- data.frame(
  t = seq(
    min(daily_summary$t),
    max(daily_summary$t),
    length.out = 100
  )
)

# Predicted participants
exp_curve$Participants <- predict(
  model_exponential,
  newdata = exp_curve
)

ggplot(
  daily_summary,
  aes(x = t, y = Participants)
) +
  
  # Actual attendance
  geom_line() +
  geom_point(size = 2.2) +
  
  # Exponential fitted line
  geom_line(
    data = exp_curve,
    aes(x = t, y = Participants),
    linetype = "dotted",
    linewidth = 1,
    color = "forestgreen"
  ) +
  
  scale_x_continuous(
    limits = c(0, max(daily_summary$t)),
    breaks = pretty(daily_summary$t),
    expand = expansion(mult = c(0.0015, 0.02))
  ) +
  
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, by = 10),
    expand = c(0, 0)
  ) +
  
  labs(
    title = "Attendance Across Classes With Exponential Decay Model Fitted",
    x = "Days Since First Session (t)",
    y = "Number of Participants"
  ) +
  
  theme(
    plot.title = element_text(hjust = 0.5)
  )

# 6th plot: Asymptotic Exponential fit ----

# Create smooth asymptotic fitted line
asym_curve <- data.frame(
  t = seq(
    min(daily_summary$t),
    max(daily_summary$t),
    length.out = 100
  )
)

# Predicted participants
asym_curve$Participants <- predict(
  model_asymptotic,
  newdata = asym_curve
)

ggplot(
  daily_summary,
  aes(x = t, y = Participants)
) +
  
  # Actual attendance
  geom_line() +
  geom_point(size = 2.2) +
  
  # Asymptotic exponential fitted line
  geom_line(
    data = asym_curve,
    aes(x = t, y = Participants),
    linetype = "dotted",
    linewidth = 1,
    color = "firebrick3"
  ) +
  
  scale_x_continuous(
    limits = c(0, max(daily_summary$t)),
    breaks = pretty(daily_summary$t),
    expand = expansion(mult = c(0.0015, 0.02))
  ) +
  
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, by = 10),
    expand = c(0, 0)
  ) +
  
  labs(
    title = "Attendance Across Classes With Asymptotic Exponential Model Fitted",
    x = "Days Since First Session (t)",
    y = "Number of Participants"
  ) +
  
  theme(
    plot.title = element_text(hjust = 0.5)
  )

# 7th plot: Model comparison ----

ggplot(
  daily_summary,
  aes(x = t, y = Participants)
) +
  
  # Actual attendance
  geom_line(
    color = "grey27",
    linewidth = .8
  ) +
  
  geom_point(
    color = "black",
    size = 2.2
  ) +
  
  # Linear fit
  geom_line(
    data = linear_curve,
    aes(x = t, y = Participants,
        color = "Linear"),
    linewidth = 1.1
  ) +
  
  # Exponential fit
  geom_line(
    data = exp_curve,
    aes(x = t, y = Participants,
        color = "Exponential"),
    linewidth = 1.1
  ) +
  
  # Asymptotic exponential fit
  geom_line(
    data = asym_curve,
    aes(x = t, y = Participants,
        color = "Asymptotic Exponential"),
    linewidth = 1.1
  ) +
  
  scale_color_manual(
    name = "Model",
    values = c(
      "Linear" = "steelblue3",
      "Exponential" = "forestgreen",
      "Asymptotic Exponential" = "firebrick3"
    )
  ) +
  
  scale_x_continuous(
    limits = c(0, max(daily_summary$t)),
    breaks = pretty(daily_summary$t),
    expand = expansion(mult = c(0.0015, 0.02))
  ) +
  
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, by = 10),
    expand = c(0, 0)
  ) +
  
  labs(
    title = "Attendance Decline Over Time: Model Comparison",
    x = "Days Since First Session (t)",
    y = "Number of Participants"
  ) +
  
  theme(
    plot.title = element_text(hjust = 0.5),
    legend.position = "bottom"
  )

# Other plots and tests ----

plot(density(daily_summary$t))
plot(density(daily_summary$Participants))
qqnorm(daily_summary$Participants)
qqline(daily_summary$Participants)
shapiro.test(daily_summary$Participants)

# Model comparison 2: Electric Boogaloo ----

library(broom)
glance(model_linear)
glance(model_exponential)
glance(model_asymptotic)

# Plotting residuals vs fitted values

# Linear

res_vs_fit_linear <- data.frame(
  Fitted = fitted(model_linear),
  Residuals = residuals(model_linear)
)

ggplot(res_vs_fit_linear, aes(x = Fitted, y = Residuals)) +
  geom_point() +
  geom_hline(yintercept = 0, color = "steelblue3", linetype = "dashed") +
  labs(title = "Residuals vs Fitted in Linear Model", x = "Fitted Values", y = "Residuals") +
  theme(plot.title = element_text(hjust = 0.5))

# Exponential decay

res_vs_fit_exponential <- data.frame(
  Fitted = fitted(model_exponential),
  Residuals = residuals(model_exponential)
)

ggplot(res_vs_fit_exponential, aes(x = Fitted, y = Residuals)) +
  geom_point() +
  geom_hline(yintercept = 0, color = "forestgreen", linetype = "dashed") +
  labs(title = "Residuals vs Fitted in Exponential Decay Model", x = "Fitted Values", y = "Residuals") +
  theme(plot.title = element_text(hjust = 0.5))

# Asymptotic

res_vs_fit_asymptotic <- data.frame(
  Fitted = fitted(model_asymptotic),
  Residuals = residuals(model_asymptotic)
)

ggplot(res_vs_fit_asymptotic, aes(x = Fitted, y = Residuals)) +
  geom_point() +
  geom_hline(yintercept = 0, color = "firebrick3", linetype = "dashed") +
  labs(title = "Residuals vs Fitted in Asymptotic Model", x = "Fitted Values", y = "Residuals") +
  theme(plot.title = element_text(hjust = 0.5))

# Testing ANOVA between the exponential and asymptotic model ----

anova(model_exponential, model_asymptotic)