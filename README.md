# Subscription Churn Analysis Project

An end-to-end data science project focused on predicting user churn for a subscription-based streaming service (Netflix/Spotify style).

## Project Objective
The goal is to identify users at risk of churning in the upcoming month by analyzing behavioral patterns, payment history, and engagement metrics using **SQL** for feature engineering and **Machine Learning** for prediction.

---

## Roadmap
- [X] **Phase 1:** Synthetic Data Generation (Python)
- [ ] **Phase 2:** Database Schema & Feature Engineering (PostgreSQL)
- [ ] **Phase 3:** Exploratory Data Analysis (SQL)
- [ ] **Phase 4:** Churn Prediction Model (Python / Scikit-learn)
- [ ] **Phase 5:** Business Insights & Documentation

---

## Phase 1: User Churn Simulation

This part of the project generates synthetic user data to analyze and model **churn rates**. The script simulates user behavior by creating correlations between activity levels, payment issues, and the likelihood of cancellation.

### User profiles
* **Power users (30%):** High engagement, daily usage, and long watch times.
* **Casual users (70%):** Standard users with lower frequency of use and shorter sessions.

### Churn logic & correlations
The script uses a probability-based model ($P$) where specific triggers increase the churn risk:
* **Base risk:** $0.1$
* **Failed payments:** $+0.5$ risk boost.
* **Low Watch time (< 30 min):** $+0.4$ risk boost.
* **Inactivity (> 20 days):** $+0.3$ risk boost.

*Note: The simulation includes a "human uncertainty" factor, capping the maximum churn probability at 95% to ensure some high-risk users remain subscribed.*

---

## Getting started

### 1. Prerequisites
Ensure you have the following libraries installed:
```bash
pip install pandas numpy faker
```

### 2. Run the generator
Execute the script to create dataset
```bash
python generate_data.py
```

### 3. Output
The script will generate a file named churn_data_base.csv in the root directory and print a summary to the console:
Status:         **Data generated with correlations.**
Summary: e.g.,  **Number of churned users 372 (37.2%)** 

## Data Features

**user_id**     	    Unique identifier for each user.
**registration_date**	Date the user joined the platform.
**avg_watch_time**	    Average daily watch time in minutes.
**payments_failed** 	Number of failed payment attempts (0-2).
**days_inactive**       Number of days since the last login.
**churned**	            Target variable (1 = Churned, 0 = Active).

*Note: This project is currently in progress. Next phase: Database Schema & SQL Analysis.*