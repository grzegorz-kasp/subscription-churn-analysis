import pandas as pd
import numpy as np
from faker import Faker
import random

fake = Faker()

NUM_USERS = 1000

def generate_data():
    users = []
    for i in range(1, NUM_USERS + 1):
        reg_date = fake.date_between(start_date='-2y', end_date='-1y')
        
        # Dane demograficzne
        age = np.random.choice([
            np.random.randint(18, 30), 
            np.random.randint(30, 50), 
            np.random.randint(50, 75)
        ], p=[0.5, 0.35, 0.15])
        country = np.random.choice(['Poland', 'USA', 'Germany', 'UK', 'France'], p=[0.4, 0.2, 0.2, 0.1, 0.1])
        gender = np.random.choice(['Male', 'Female', 'Other'], p=[0.48, 0.48, 0.04])

        # Create behavior profiles (dependent on user type)
        # 30% are "power users" (daily use, multiple devices), 70% are "casuals" (standard users, less frequent use), the older the user, the less likely they are to be a power user
        if age < 30:
            is_power_user = np.random.choice([True, False], p=[0.6, 0.4])
        elif age < 50:
            is_power_user = np.random.choice([True, False], p=[0.2, 0.8])
        else:
            is_power_user = np.random.choice([True, False], p=[0.05, 0.95])
        # random.choice allows for easy definition of user types with specific probabilities
        
        watch_time = np.random.normal(500, 100) if is_power_user else np.random.normal(50, 30) # Use normal distribution to introduce natural variability in data
        failed_payments = np.random.choice([0, 1, 2], p=[0.8, 0.15, 0.05]) # Use discrete distribution to simulate payment failure probabilities
        days_inactive = np.random.randint(0, 30) if is_power_user else np.random.randint(0, 90)

        # Calculate Churn Score (correlations)
        churn_risk = 0.1 
        if failed_payments > 0: churn_risk += 0.5
        if watch_time < 30: churn_risk += 0.4
        if days_inactive > 20: churn_risk += 0.3
        
        if age < 25: churn_risk += 0.1

        # Simulate human uncertainty - some users stay even with high risk scores
        is_churned = np.random.rand() < min(churn_risk, 0.95)
        
        # Create user record
        users.append({
            'user_id': i,
            'registration_date': reg_date,
            'age': int(age),
            'country': country,
            'gender': gender,
            'avg_watch_time': max(0, int(watch_time)),
            'payments_failed': failed_payments,
            'days_inactive': days_inactive,
            'churned': int(is_churned)
        })

    return pd.DataFrame(users)

# Generate data and export to CSV file
df = generate_data()
df.to_csv('churn_data_base.csv', index=False)

print("Wygenerowano dane z korelacjami.")
print(f"Liczba churned: {df['churned'].sum()} ({(df['churned'].mean()*100):.1f}%)")