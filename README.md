# Subscription Churn Analysis Project

An end-to-end data science project focused on predicting user churn for a subscription-based streaming service (Netflix/Spotify style).

## Project Objective
The goal is to identify users at risk of churning in the upcoming month by analyzing behavioral patterns, payment history, and engagement metrics using **SQL** for feature engineering and **Machine Learning** for prediction.

---

## Roadmap
- [X] **Phase 1:** Synthetic Data Generation (Python)
- [X] **Phase 2:** Database Schema & Feature Engineering (PostgreSQL)
- [X] **Phase 3:** Exploratory Data Analysis (SQL)
- [X] **Phase 4:** Churn Prediction Model (Python / Scikit-learn)
- [X] **Phase 5:** Business Insights & Documentation

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

## Phase 2 & 3: Database Schema & SQL Exploration

The generated data was migrated into a local PostgreSQL instance. To model the business environment properly, the flat file structure was normalized into three distinct tables linked via foreign keys: `users`, `user_activity`, and `subscription`.

### Analytical View
To separate the database schema from the Python application, an optimized database view was created. This view aggregates structural tables and maps boolean target logic directly into a clean format for machine learning:

CREATE OR REPLACE VIEW v_ml_features AS
SELECT 
    u.id AS user_id,
    u.age,
    u.country,
    u.gender,
    a.avg_watch_time,
    a.days_inactive,
    s.payments_failed,
    CASE WHEN s.churned = TRUE THEN 1 ELSE 0 END AS churned
FROM users u
JOIN user_activity a ON u.id = a.user_id
JOIN subscription s ON u.id = s.user_id;

---

## Phase 4 & 5: Churn Prediction Model & Performance

The pipeline connects to PostgreSQL securely via SQLAlchemy using local environment variables (.env). It performs One-Hot Encoding via Pandas on categorical attributes and splits data into an 80/20 train/test partition.

A **Random Forest Classifier** (n_estimators=100) was trained to predict the binary target variable.

### Evaluation Metrics
The model achieved an overall accuracy of **72%** on unseen validation records:

==================================================<br>
         CUSTOMER CHURN EVALUATION REPORT    <br>     
==================================================<br>
--- CONFUSION MATRIX ---
True Negatives (Poprawnie wskazani lojalni): 83<br>
False Positives (Błędnie wskazani jako odejścia): 33<br>
False Negatives (Przeoczone odejścia): 23<br>
True Positives (Poprawnie wskazane odejścia): 61<br>

--- CLASSIFICATION METRICS ---
* Precision (Class 1): 0.65
* Recall (Class 1): 0.73
* F1-Score (Class 1): 0.69
* Overall Accuracy: 0.72 (200 rows)

* **Business Impact (Recall = 73%):** The model correctly captures 73% of the users who will actually churn, enabling the marketing team to target nearly 3/4 of endangered accounts proactively.

### Feature Importance Weights
The internal metrics of the Random Forest isolated the exact behavioral triggers behind account drops:
1. avg_watch_time            ->  30.13% weight
2. days_inactive             ->  27.80% weight
3. age                       ->  19.72% weight
4. payments_failed           ->  11.20% weight

*Insight: Operational payment issues (payments_failed) hold a massive 11.20% structural weight, proving technical friction is a leading driver of user attrition.*

---

## Getting started

### 1. Prerequisites
Ensure you have the following libraries installed:
```bash
pip install pandas numpy faker sqlalchemy psycopg2-binary scikit-learn python-dotenv
```
### 2. Configuration
Create a local .env file in the root folder to handle database credentials securely:
DB_USER=your_user
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=your_database
### 3. Run the evaluation
Execute the evaluation script to test the model:
```bash
python src/model_evaluation.py
```