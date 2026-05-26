import os
import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv

load_dotenv()

def get_data_from_db():
    print("Connecting to PostgreSQL database...")
    
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    host = os.getenv("DB_HOST")
    port = os.getenv("DB_PORT")
    name = os.getenv("DB_NAME")
    
    DATABASE_URL = f"postgresql://{user}:{password}@{host}:{port}/{name}"
    
    engine = create_engine(DATABASE_URL)
    query = "SELECT * FROM v_ml_features;"
    df = pd.read_sql_query(query, con=engine)
    
    print(f"Successfully loaded {len(df)} rows from v_ml_features view.")
    return df

def preprocess_features(df):
    print("Starting feature engineering...")
    ml_df = df.drop(columns=['user_id'])
    ml_df = pd.get_dummies(ml_df, columns=['country', 'gender'], drop_first=True, dtype=int)
    
    print("Feature engineering complete. Available columns:")
    print(ml_df.columns.tolist())
    
    return ml_df

if __name__ == "__main__":
    raw_data = get_data_from_db()
    processed_data = preprocess_features(raw_data)
    print("\nSample processed data:")
    print(processed_data.head(3))