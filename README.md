# Statistical Analysis of Online Course Attendance

[![Hits](https://hits.sh/github.com/Shah-Md-Tasrif-Rahman/R_Attendance_CUSPC_SPSS_2026.svg)](https://hits.sh/github.com/Shah-Md-Tasrif-Rahman/R_Attendance_CUSPC_SPSS_2026/)

## Overview

This repository contains statistical analyses of the attendance dataset of an SPSS course hosted by [Programming Club, Dept. of Statistics, CU](https://www.linkedin.com/company/programmingclub-stat-cu/), and conducted by [Md Ahsanul Islam (Himel)](https://www.linkedin.com/in/mdahsanulhimel/).

This project examines participant attendance patterns across multiple sessions and compares regression models for describing attendance trajectories in this course and potentially similar courses.

Main tools used for this project are: **R, renv, jamovi, and Quarto.**

*This repository also contains a pseudonymized version of the original dataset for replication and future uses.*

## Dataset & Data Privacy

### Original Data

The original data for this project was collected using an extension in Google Meet to generate detailed meeting reports in CSV format. The course had a total of 12 sessions, which were held from 14/7/2026 to 25/8/2026. Due to technical errors, attendance records for sessions 7 and 11 were missing, leaving 10 observed sessions out of 12.

Key variables in the original dataset were:
- Participant Name
- Time when attendance started
- Joining time
- Time when attendance stopped
- Attendance duration

### Data Preparation

The CSV files for the 10 sessions were extracted and combined, and then attendance duration was calculated as a new numeric variable. Date-related variables were also included. This produced a master dataset for subsequent processing. A leaderboard, daily attendance summary, weekday summary, and paired weekdays data was created.

### Privacy & Pseudonymization

The original dataset contained participants' real names, which would compromise their privacy if published. To make the dataset publicly available, the names were pseudonymized, and new datasets were created using those pseudonyms. The pseudonymized datasets were then used for furthur statistical analysis.

The repository is designed so the analytical/visualization portion does not require the original dataset with PII.

**Check out the [pseudonymized master_dataset](./Pseudonymization_process/Public_datasets/pseudonymized_master_dataset_full_context.xlsx)**

**Check out [all datasets](./Pseudonymization_process/Public_datasets/)**

## Research Questions

1. How is the attendance duration of participants distributed?

2. Is there a systematic difference in participants' attendance duration between Tuesdays and Fridays?

3. Which regression model explains the participant attendance pattern best?

## Methods

#### Exploratory Data Analysis

- Descriptive statistics
- Distribution shape characteristics
- Visualization

#### Comparison Between Weekdays

- Normality tests
- Wilcoxon signed-rank test
- Visualization

#### Regression Models

- Linear model
- Exponential decay model
- Asymptotic exponential decay model

#### Model Diagnostics and Comparison

- ANOVA
- Heteroscedasticity Tests
- Durbin-Watson test
- Residual analysis
- AIC
- BIC
- RMSE
- Model visualization

## 1st Research Question

Let's see some descriptive statistics for the attendance duration of participants in this course.

#### Descriptive Statistics

| Statistic | Value |
|:----------|------:|
| Participant-session observations (*N*) | 400 |
| Mean | 71.5 |
| SD | 33.1 |
| SE | 1.66 |
| Median | 82.3 |
| IQR | 45.6 |
| Minimum | 0.167 |
| Maximum | 128 |
| Skewness | -0.722 |
| SE of skewness | 0.122 |
| Kurtosis | -0.543 |
| SE of kurtosis | 0.243 |
| **Shapiro-Wilk *W*** | 0.916 |
| **Shapiro-Wilk *p*** | < .001 |

*Note*. SD = standard deviation, SE = standard error, IQR = interquartile range. All the values are as minutes of attendance.

The Shapiro–Wilk test provides `evidence against normality of the attendance-duration distribution`.

#### Q-Q plot
![Attendance_duration_QQ_plot](./Jamovi_files/Reports/Images/Attendance_duration_QQ_plot.png)

#### Attendance duration histogram
![Attendance_duration_distribution](./Graphs_and_tables/Images/Attendance_duration_distribution.png)

From these visualizations, we can see that the distribution of attendance duration of participants in this course is `negatively skewed and platykurtic`.

## 2nd Research Question

In this course, sessions were held at either Tuesday or Friday. Since this was an online course, participants were expected to stay longer in sessions at Friday (which counts as a weekend in this context). This course was mostly attended by university-level students. To test whether there's a difference between the average attendance duration of participants at Tuesday or Friday, a **paired-samples measure** was decided to be used.

First, we assess the distribution of the paired differences to decide which test we should use.

#### Normality Tests

| Test | Statistic | *p* |
|:------|:----------:|:--:|
| Shapiro-Wilk | 0.933 | .002 |
| Kolmogorov-Smirnov | 0.131 | .217 |
| Anderson-Darling | 1.29 | .002 |

The paired differences were assessed for normality. Given the observed distribution and the test assumptions, we'll use the **Wilcoxon signed-rank test**.

#### Descriptives

| Group | *N* | Mean | Median | SD | SE |
|:------|--:|-----:|-------:|---:|---:|
| Tuesday_Mean_Minutes | 62 | 68.8 | 71.2 | 23.1 | 2.93 |
| Friday_Mean_Minutes | 62 | 72.7 | 78.8 | 27.2 | 3.45 |

*Note*. SD = standard deviation, SE = standard error.

The Wilcoxon signed-rank test `did not provide sufficient evidence of a difference between Tuesday and Friday attendance durations`, *W* = 747, *p* = .108.

![Tuesday_vs_Friday](./Graphs_and_tables/Images/Tuesday_vs_Friday.png)

There appears to be a difference in attendance duration, but it's not statistically significant.

## 3rd Research Question

First, let's examine how attendance counts vary across sessions.

![Attendance_across_sessions](./Graphs_and_tables/Images/Attendance_across_sessions.png)

The observed trajectory suggests that linear and exponential decay models are reasonable candidate forms to investigate. Let's fit a linear regression model first.

#### Normality Tests

| Test | Statistic | *p* |
|:------|:--:|:--:|
| Shapiro-Wilk | 0.868 | .096 |
| Kolmogorov-Smirnov | 0.221 | .638 |
| Anderson-Darling | 0.622 | .075 |

*Note*. Not enough evidence to reject normality was found here.

#### Heteroscedasticity Tests

| Test | Statistic | *p* |
|:------|:--:|:--:|
| Breusch-Pagan | 0.771 | .380 |
| Goldfeld-Quandt | 0.913 | .529 |
| Harrison-McCabe | 0.685 | .809 |

*Note*. Not enough evidence to reject homoscedasticity was found here.

#### Model Fit Measures

| *R* | *R²* | Adjusted *R²* | AIC | BIC | RMSE | *F* | df1 | df2 | *p* |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| 0.884 | 0.781 | 0.753 | 76.0 | 76.9 | 8.03 | 28.5 | 1 | 8 | < .001 |

*Note*. Model estimated using sample size of n = 10.

#### Model Coefficients

| Predictor | Estimate | SE | *t* | *p* |
|:--:|:--:|:--:|:--:|:--:|
| Intercept | 61.09 | 4.866 | 12.55 | < .001 |
| t | -1.10 | 0.207 | -5.34 | < .001 |

*Note*. Model predicts participants over time (t). SE = standard error.

#### Durbin-Watson Test

| Autocorrelation | DW Statistic | *p* |
|:--:|:--:|:--:|
| 0.372 | 0.762 | .002 |

*Note*. There's statistically significant evidence of positive autocorrelation in the model residuals.

#### Regression Plot

![Linear_flexplot](./Jamovi_files/Reports/Images/Linear_flexplot.png)

#### Q-Q Plot
![Linear_model_QQ_plot](./Jamovi_files/Reports/Images/Linear_model_QQ_plot.png)

#### Residual vs. Fitted Plot
![Linear_model_residual_vs_fitted_plot](./Jamovi_files/Reports/Images/Linear_model_residual_vs_fitted_plot.png)

As we can see, the linear model shows evidence of positive residual autocorrelation and potential lack of fit in the diagnostic plots. We'll next examine a log-linear model to assess whether the transformation provides a more appropriate representation of the attendance trend.

#### Normality Tests

| Test | Statistic | *p* |
|:------|:--:|:--:|
| Shapiro-Wilk | 0.874 | .112 |
| Kolmogorov-Smirnov | 0.271 | .383 |
| Anderson-Darling | 0.644 | .065 |

*Note*. Not enough evidence to reject normality was found here.

#### Heteroscedasticity Tests

| Test | Statistic | *p* |
|:------|:--:|:--:|
| Breusch-Pagan | 0.835 | .361 |
| Goldfeld-Quandt | 6.06 | .087 |
| Harrison-McCabe | 0.462 | .419 |

*Note*. Not enough evidence to reject homoscedasticity was found here.

#### Model Fit Measures

| *R* | *R²* | Adjusted *R²* | AIC | BIC | RMSE | *F* | df1 | df2 | *p* |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| 0.923 | 0.852 | 0.833 | -3.14 | -2.23 | 0.153 | 46.0 | 1 | 8 | < .001 |

*Note*. Model estimated using sample size of n = 10.

#### Model Coefficients

| Predictor | Estimate | SE | *t* | *p* |
|:--:|:--:|:--:|:--:|:--:|
| Intercept | 4.1174 | 0.09289 | 44.32 | < .001 |
| *t* | -0.0268 | 0.00395 | -6.78 | < .001 |

*Note*. Model predicts participants over time (t). The variable "Participants" was transformed into ln_Participants for this model. SE = standard error.

#### Durbin-Watson Test

| Autocorrelation | DW Statistic | *p* |
|:--:|:--:|:--:|
| 0.149 | 1.16 | .070 |

*Note*. There's not enough evidence of autocorrelation in the model residuals.

#### Regression Plot

![Log_flexplot](./Jamovi_files/Reports/Images/Log_flexplot.png)

#### Q-Q Plot
![Log_model_QQ_plot](./Jamovi_files/Reports/Images/Log_model_QQ_plot.png)

#### Residual vs. Fitted Plot
![Log_model_residual_vs_fitted_plot](./Jamovi_files/Reports/Images/Log_model_residual_vs_fitted_plot.png)

The log-linear model shows less evidence of residual autocorrelation (Durbin–Watson *p* = .070), although the small sample size limits the test's power. The residual plots also indicate that potential lack of fit remains.

We therefore examine **exponential decay and asymptotic exponential decay models** as alternative specifications.

The preceding analyses were conducted in jamovi. We then use R's nonlinear least squares function, `nls()`, to fit the alternative models.

### Regression Model Fitting

Let's consider the following regression models:

```math
\begin{aligned}
\text{Linear model (Baseline model):}\quad
& y_i = z + tx_i + \varepsilon_i \\

\text{Exponential decay model:} \quad
& y_i = ae^{bx_i} + \varepsilon_i,\; b<0 \\

\text{Asymptotic exponential model:} \quad
& y_i = c + ae^{bx_i} + \varepsilon_i,\; b<0
\end{aligned}
```
Where,
```math
\begin{aligned}
y_i &= \text{Number of participants (Target variable)} \\
x_i &= \text{Days since first session (Explanatory variable)} \\
z &= \text{Intercept of the linear model} \\
t &= \text{Linear rate of change} \\
a &= \text{Amplitude of the exponential component} \\
b &= \text{Exponential decay rate} \\
c &= \text{Limiting predicted participant count as } x\to\infty \\
\varepsilon_i &= \text{Residual error}
\end{aligned}
```

***Note*. For the asymptotic model, the predicted response at x = 0 is c + a. The interpretation of this reference point depends on how x is coded.**

#### Model Parameters
| Parameter | Linear | Exponential Decay | Asymptotic Exponential |
|:----------:|:----------:|:----------:|:----------:|
| z | 61.091 | - | - |
| t | -1.104 | - | - |
| a | - | 68.282 | 52.695 |
| b | - | -0.034 | -0.097 |
| c | - | - | 23.199 |

*Note*. All coefficients are statistically significant with *p* < .001. Check the [Quarto output](https://htmlpreview.github.io/?https://github.com/Shah-Md-Tasrif-Rahman/R_Attendance_CUSPC_SPSS_2026/blob/main/Graphs_and_tables/Quarto/Graphs_and_tables_output.html) for more information.

#### Model Performance
| Metric | Linear | Exponential Decay | Asymptotic Exponential |
|:-------:|:-------:|:-------:|:-------:|
| Observations (n) | 10 | 10 | 10 |
| Residual df | 8 | 8 | 7 |
| R² | 0.781 | 0.896 | 0.978 |
| Adj. R² | 0.753 | - | - |
| AIC | 76.037 | 68.564 | 54.944 |
| BIC | 76.945 | 69.472 | 56.154 |
| RMSE | 8.028 | 5.525 | 2.530 |
| ΔAIC | - | 7.473 | 21.093 |
| ΔBIC | - | 7.473 | 20.791 |
| ΔRMSE | - | 2.503 | 5.498 |

*Note*. R² for the non-linear models was computed as 1 − RSS/TSS. AIC = Akaike Information Criterion, BIC = Bayesian Information Criterion, and RMSE = Root Mean Square Error. ΔAIC, ΔBIC, and ΔRMSE are calculated as the corresponding linear-model metric minus the alternative-model metric. Positive values favour the alternative model under these comparison conventions.

#### ANOVA

| Model | Residual df | Residual SS | Δdf | ΔSS | *F* | *p* |
|:------|:--:|:--:|:--:|:--:|:--:|:--:|
| Exponential Decay | 8 | 305.237 | - | - | - | - |
| Asymptotic Exponential | 7 | 64.013 | 1 | 241.22 | 26.379 | .001345 |

*Note*. The nested-model comparison favoured the asymptotic exponential model, *F*(1, 7) = 26.379, *p* = .001345. But given the small sample size, this evidence should be interpreted cautiously.

#### Model plotting
![All_models_fit](./Graphs_and_tables/Images/All_models_fit.png)

#### Residuals vs. Fitted Plots
![Residual_vs_fitted_linear_model](./Graphs_and_tables/Images/Residual_vs_fitted_linear_model.png)
![Residual_vs_fitted_exponential_model](./Graphs_and_tables/Images/Residual_vs_fitted_exponential_model.png)
![Residual_vs_fitted_asymptotic_model](./Graphs_and_tables/Images/Residual_vs_fitted_asymptotic_model.png)

Let's consider another set of regression models, but instead of using **days since first session**; let's use **session number**.

### Regression Model Fitting (Using Session Number)

Let's consider the following regression models:

```math
\begin{aligned}
\text{Linear model (Baseline model):}\quad
& y_i = z + t\alpha_i + \varepsilon_i \\

\text{Exponential decay model:} \quad
& y_i = ae^{b\alpha_i} + \varepsilon_i,\; b<0 \\

\text{Asymptotic exponential model:} \quad
& y_i = c + ae^{b\alpha_i} + \varepsilon_i,\; b<0
\end{aligned}
```
Where,
```math
\begin{aligned}
y_i &= \text{Number of participants (Target variable)} \\
\alpha_i &= \text{Session number (Explanatory variable)} \\
z &= \text{Intercept of the linear model} \\
t &= \text{Linear rate of change} \\
a &= \text{Amplitude of the exponential component} \\
b &= \text{Exponential decay rate} \\
c &= \text{Limiting predicted participant count as } \alpha\to\infty \\
\varepsilon_i &= \text{Residual error}
\end{aligned}
```

#### Model Parameters
| Parameter | Linear | Exponential Decay | Asymptotic Exponential |
|:----------:|:----------:|:----------:|:----------:|
| z | 66.200 | - | - |
| t | -4.367 | - | - |
| a | - | 80.323 | 75.984 |
| b | - | -0.135 | -0.325 |
| c | - | - | 21.602 |

*Note*. All coefficients are statistically significant with *p* < .001. Check the [Quarto output](https://htmlpreview.github.io/?https://github.com/Shah-Md-Tasrif-Rahman/R_Attendance_CUSPC_SPSS_2026/blob/main/Graphs_and_tables/Quarto/Graphs_and_tables_output.html) for more information.

#### Model Performance
| Metric | Linear | Exponential Decay | Asymptotic Exponential |
|:-------:|:-------:|:-------:|:-------:|
| Observations (n) | 10 | 10 | 10 |
| Residual df | 8 | 8 | 7 |
| R² | 0.779 | 0.906 | 0.972 |
| Adj. R² | 0.751 | - | - |
| AIC | 76.121 | 67.513 | 57.412 |
| BIC | 77.028 | 68.421 | 58.623 |
| RMSE | 8.061 | 5.242 | 2.862 |
| ΔAIC | - | 8.608 | 18.709 |
| ΔBIC | - | 8.607 | 18.405 |
| ΔRMSE | - | 2.819 | 5.199 |

*Note*. R² for the non-linear models was computed as 1 − RSS/TSS. AIC = Akaike Information Criterion, BIC = Bayesian Information Criterion, and RMSE = Root Mean Square Error. ΔAIC, ΔBIC, and ΔRMSE are calculated as the corresponding linear-model metric minus the alternative-model metric. Positive values favour the alternative model under these comparison conventions.

#### ANOVA

| Model | Residual df | Residual SS | Δdf | ΔSS | *F* | *p* |
|:------|:--:|:--:|:--:|:--:|:--:|:--:|
| Exponential Decay | 8 | 274.784 | - | - | - | - |
| Asymptotic Exponential | 7 | 81.935 | 1 | 192.85 | 16.476 | .004815 |

*Note*. The nested-model comparison favoured the asymptotic exponential model, *F*(1, 7) = 16.476, *p* = .004815. But given the small sample size, this evidence should be interpreted cautiously.

#### Model plotting
![All_models_snf_fit](./Graphs_and_tables/Images/All_models_snf_fit.png)

#### Residuals vs. Fitted Plots
![Residual_vs_fitted_linear_snf_model](./Graphs_and_tables/Images/Residual_vs_fitted_linear_snf_model.png)
![Residual_vs_fitted_exponential_snf_model](./Graphs_and_tables/Images/Residual_vs_fitted_exponential_snf_model.png)
![Residual_vs_fitted_asymptotic_snf_model](./Graphs_and_tables/Images/Residual_vs_fitted_asymptotic_snf_model.png)

Across both time specifications, **the asymptotic exponential models provided the best in-sample fit among the candidate models considered**.

It captured **a rapid initial decline followed by progressively smaller decreases, approaching a non-zero asymptote as the explanatory variable increases**. The asymptote represents **a theoretical persistent-attendance level**. This pattern is consistent with **a possible mechanism in which attendance declines toward a smaller long-run level, although the fitted curve alone cannot establish that mechanism**.

Since this dataset contains only 10 sessions and represents a single attendance sequence, this interpretation should be treated as a testable hypothesis rather than evidence of a universal attendance law.

**Two sets of models were fitted because attendance records for sessions 7 and 11 were missing, leaving 10 observed sessions out of 12. So the initial plan was to just use a set of regression model using days since first session as explanatory variable. But to be congruent with the literature about this topic, another set of regression model using session number as explanatory variable was needed. Calendar time preserves the actual elapsed intervals between observed sessions, whereas session number represents course progression. The choice of explanatory variable is dependent on data quality and the specific context of the dataset being worked on.**

## Literature Review

**Massive Open Online Courses (MOOCs)** gained widespread prominence in 2012, expanding access to online learning at scale. MOOCs are great for life-long learning and educational resource sharing. Compared with traditional education, MOOCs suffer more severe dropout problem. For most courses, less than 13% of students could follow **(Chen & Zhang, 2017, p. 1)**.

Although the SPSS course dataset analyzed in this project does not represent a MOOC, the course shares some structural similarities with MOOCs. The course had three assignments and a final project. Certificates were awarded separately based on participation and final project completion. Nonetheless, this dataset exhibited an attendance trajectory similar to those reported in studies of MOOCs.

**Dai et al. (2025)** utilized a collection of MOOCs offered through Coursera by the University of Pennsylvania from 2015 to 2025, which includes over 200 courses and has been used by over 5.7 million individual users. According to **Dai et al. (2025)**, "The findings suggest that stopout in MOOCs generally follows an exponential decay pattern across graded assessments, but the disproportionately high stopout rate at the first graded assessment indicates that early disengagement follows a different underlying mechanism" **(p. 4)**.

**Perna et al. (2014)** utilized data from the population of 16 first-generation MOOCs taught for the first time by University of Pennsylvania faculty in the 1st year of Penn-Coursera offerings. Courses were offered and completed between June 2012 and July 2013. For the 16 MOOCs in this study, there were 710,385 registrants and 541,576 starters. According to **Perna et al. (2014)**, "Despite these variations, and regardless of the course’s length, the patterns of decay were similar. Between the first and second modules, the decline in the share of registrants who accessed each subsequent lecture was steeper, as measured by both percentage point and percentage declines than between any two subsequent modules" **(p. 5)**.

**De Freitas et al. (2015)** utilized data from an astronomy MOOC developed by John Morgan and colleagues at Curtin University using the Open2Study (OUA) platform. According to **De Freitas et al. (2015)**, "These data have been modelled as a fixed fraction of students dropping out after each course segment (ie, an exponential decay), with a differing dropout rate for each module (a quarter of a course) and for each cohort. This model suggests a relatively rapid dropout rate of approximately 5% per unit at the start of the course, which quickly stabilises to an almost negligible rate by the final module. These patterns point towards students making a fairly rapid decision that the course is or is not for them" **(p. 10)**.

**Evans et al. (2016)** utilized a dataset of 44 Coursera MOOCs, comprising over 2.1 million student observations across more than 2,900 lectures. According to **Evans et al. (2016)**, "The pattern of lecture watching across courses is quite similar: high initial engagement that falls off rapidly and, in most instances, stabilizes at a low level. The rate of decline varies, but in all cases the greatest decline in participation occurs during the first ten lectures" **(p. 21)**.

**Taken together, these studies document patterns of declining participation and subsequent stabilization in MOOCs. In this project, the asymptotic exponential regression model provided a substantially better fit than the linear and ordinary exponential regression models, yielding an estimated non-zero asymptote that represents the model-implied limiting attendance level. Building on this result, the project proposes an *Asymptotic Participation Proportion*, a model-derived measure expressing the estimated long-term attendance level relative to a specified participant reference population. This proposed measure may offer a model-based summary of the attendance trajectory, complementing conventional measures of course completion and individual persistence. Its validity and practical usefulness remain to be evaluated empirically.**

## Proposed Asymptotic Participation Proportion (APP)

If a fitted asymptotic exponential regression model is given by,
```math
\begin{aligned}
\hat{y} = \hat{c} + \hat{a}e^{\hat{b}x},\; \hat{b}<0
\end{aligned}
```
Then we define the following model-derived, reference-relative measure:
```math
\begin{aligned}
\text{Asymptotic Participation Proportion (APP),}\quad p_{D} = \frac{\hat{c}}{D}
\end{aligned}
```
Where,
```math
\begin{aligned}
\hat{y} &= \text{Model-predicted participant count at }x \\
\hat{c} &= \text{Estimated limiting predicted participant count as } x\to\infty \\
D &= \text{A specified reference count of participants}
\end{aligned}
```
Here, *D* denotes one of the following participant reference quantities:
```math
D =
\left\{
\begin{aligned}
i &\quad \text{Attendance at the initial observed session} \\
N &\quad \text{Total number of registered participants} \\
M &\quad \text{Maximum observed attendance across sessions}
\end{aligned}
\right.
```

For the context of our dataset,
```math
\begin{aligned}
\text{Estimated limiting participant count for calendar-time asymptotic model,}\; \hat{c}_{calendar} &= 23.199 \\
\text{Estimated limiting participant count for session-number asymptotic model,}\; \hat{c}_{session} &= 21.602 \\
i &= M = 74 \\
N &= 111 \\
\therefore \text{APP for calendar-time asymptotic model considering initial and maximum attendance,}\; p_{i (calendar)} = p_{M (calendar)} &= \frac{23.199}{74} = 0.3135 \\
\therefore \text{APP for calendar-time asymptotic model considering total number of registered participants,}\; p_{N (calendar)} &= \frac{23.199}{111} = 0.209 \\
\therefore \text{APP for session-number asymptotic model considering initial and maximum attendance,}\; p_{i (session)} = p_{M (session)} &= \frac{21.602}{74} = 0.2919 \\
\therefore \text{APP for session-number asymptotic model considering total number of registered participants,}\; p_{N (session)} &= \frac{21.602}{111} = 0.1946 
\end{aligned}
```

Under the fitted models, the estimated asymptotic attendance levels were equivalent to 31.35% of initial/maximum observed attendance for the calendar-time model and 29.19% for the session-number model. Relative to the 111 registered participants, the estimated asymptotic attendance levels were 20.90% and 19.46%, respectively.

#### Potential Uses and Implications

1. Estimating the scale of sustained attendance

2. *p<sub>N</sub>* helps interpreting long-run attendance relative to registration

3. *p<sub>i</sub>* helps to compare long-run attendance relative to starting level

4. Comparing calendar-time and session-number models helps assess how sensitive the estimated reference-relative attendance level is to the choice of time scale

5. Build reference distributions across multiple comparable courses, once sufficient datasets are available

6. Compare estimated limiting attendance relative to registration across comparable course offerings

7. Explore whether different online, hybrid, or classroom formats exhibit different reference-relative attendance levels

8. Describe differences between cohorts with similar registration definitions and session structures

A particularly useful future application would be to compare many course offerings and investigate whether the proposed measure has a stable, interpretable relationship with other outcomes, such as completion or assignment submission. Those would be separate empirical research questions, not properties guaranteed by the formula.

**A further research question is whether attendance in in-person courses exhibits a similar asymptotic pattern. Investigating this across comparable courses would be a meaningful future research direction.**

This proposed measure may help course designers and instructors describe and compare estimated long-run attendance across comparable course offerings. Its practical usefulness would need to be evaluated through further research.

## Limitations

1. The attendance trajectory is based on only 10 observed sessions, limiting the robustness of model selection, the precision of parameter estimates, and inference about the long-run attendance level.

2. Attendance records for sessions 7 and 11 are missing because of technical errors. Consequently, the observed trajectory does not represent a complete record of attendance across all 12 course sessions.

3. The precision of Asymptotic Participation Proportion (APP) depends on the uncertainty associated with the estimated asymptote. A wide confidence interval for the estimated asymptote would imply substantial uncertainty in APP when the reference count is treated as fixed.

4. The dataset represents a single course, limiting the extent to which the observed attendance pattern and estimated APP values can be generalized to other courses, instructors, participant populations, or teaching formats.

5. The estimated asymptotic attendance level depends on both the explanatory variable scale and the fitted model specification. Calendar time represents elapsed time, whereas session number represents course progression. Consequently, the resulting asymptotes and APP values need not be identical.

6. The asymptotic exponential model provided the best in-sample fit among the candidate models considered, but its predictive performance on future sessions has not been established.

7. Recorded attendance duration and session attendance counts are operational measures of participation. They do not directly measure attention, engagement with course material, learning, or completion of course activities.

8. The Tuesday–Friday comparison is based on participants with usable paired observations. Its findings may not generalize to participants excluded from the paired analysis, and the comparison does not establish that the weekday itself caused any difference in attendance duration.

## Acknowledgements

Special thanks to **Md Ahsanul Islam (Himel)** for generously providing access to the original attendance dataset, and to **Sucheen Dewan** for thoughtful suggestions on the regression plots and table design. Their support and contributions played an important role in improving this project.

## Repository Structure

- `README.md` - Main landing page for the project

- `Graphs_and_tables/`- Contains all images, R, and Quarto files related to statistical analysis 

- `Jamovi_files/` - Contains all jamovi files and outputs with images

- `Pseudonymization_process/` - Contains all the datasets and R files related to pseudonymization

[View the jamovi HTML report](https://htmlpreview.github.io/?https://github.com/Shah-Md-Tasrif-Rahman/R_Attendance_CUSPC_SPSS_2026/blob/main/Jamovi_files/Reports/HTMLs/Combined_output.html)

[View the jamovi PDF report](./Jamovi_files/Reports/PDFs/Combined_output.pdf)

[View the Quarto HTML report](https://htmlpreview.github.io/?https://github.com/Shah-Md-Tasrif-Rahman/R_Attendance_CUSPC_SPSS_2026/blob/main/Graphs_and_tables/Quarto/Graphs_and_tables_output.html)

[View the Quarto PDF report](./Graphs_and_tables/Quarto/Graphs_and_tables_output.pdf)

## Reproducibility

The analysis was conducted using R, jamovi, and Quarto, with renv used for R package management. The scripts and project files are organized in the repository to facilitate inspection and reproducibility. To reproduce the analysis, restore the R environment using renv and run the relevant scripts and Quarto documents with modified file locations in scripts.

## References

- Chen, Y., & Zhang, M. (2017). MOOC student dropout: Pattern and prevention. Proceedings of the ACM Turing 50th Celebration Conference - China, 1–6. https://doi.org/10.1145/3063955.3063959

- Dai, Y., Vanacore, K., Baker, R., & Slater, S. (2025). Understanding MOOC Stopout Patterns: Course and Assessment-Level Insights. Proceedings of the Twelfth ACM Conference on Learning @ Scale, 300–304. https://doi.org/10.1145/3698205.3733944

- De Freitas, S. I., Morgan, J., & Gibson, D. (2015). Will MOOCS transform learning and teaching in higher education? Engagement and course retention in online learning provision. British Journal of Educational Technology, 46(3), 455–471. https://doi.org/10.1111/bjet.12268

- Evans, B. J., Baker, R. B., & Dee, T. S. (2016). Persistence Patterns in Massive Open Online Courses (MOOCs). The Journal of Higher Education, 87(2), 206–242. https://doi.org/10.1080/00221546.2016.11777400

- Perna, L. W., Ruby, A., Boruch, R. F., Wang, N., Scull, J., Ahmad, S., & Evans, C. (2014). Moving Through MOOCs: Understanding the Progression of Users in Massive Open Online Courses. Educational Researcher, 43(9), 421–432. https://doi.org/10.3102/0013189X14562423