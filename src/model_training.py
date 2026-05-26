import os
import pickle
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from features_setup import get_data_from_db, preprocess_features

def prepare_train_test_sets(df):
    
    X = df.drop(columns=['churned'])
    y = df['churned']
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    print(f"Training set size: {X_train.shape[0]} rows")
    print(f"Testing set size: {X_test.shape[0]} rows")
    
    return X_train, X_test, y_train, y_test

def train_model(X_train, y_train):

    print("Training Random Forest Classifier...") 
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    
    print("Model training complete successfully!")
    return model

def save_model(model, filename="models/churn_model.pkl"):

    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with open(filename, 'wb') as file:
        pickle.dump(model, file)
        
    print(f"Model successfully serialized and saved to {filename}")

if __name__ == "__main__":
    
    raw_data = get_data_from_db()
    processed_data = preprocess_features(raw_data)
    X_train, X_test, y_train, y_test = prepare_train_test_sets(processed_data)
    trained_model = train_model(X_train, y_train)
    save_model(trained_model)