import os
import pickle
import pandas as pd
from sklearn.metrics import classification_report, confusion_matrix
from features_setup import get_data_from_db, preprocess_features
from model_training import prepare_train_test_sets

def load_saved_model(filename="models/churn_model.pkl"):
    print(f"Loading trained model from {filename}...")
    with open(filename, 'rb') as file:
        model = pickle.load(file)
    return model

def generate_report(model, X_test, y_test, report_path="reports/evaluation_report.txt"):
    os.makedirs(os.path.dirname(report_path), exist_ok=True)
    
    y_pred = model.predict(X_test)
    cm = confusion_matrix(y_test, y_pred)
    cr = classification_report(y_test, y_pred)
    
    importances = model.feature_importances_
    feat_importances = pd.Series(importances, index=X_test.columns)
    sorted_features = feat_importances.sort_values(ascending=False)
    
    report_lines = []
    report_lines.append("==================================================")
    report_lines.append("         CUSTOMER CHURN EVALUATION REPORT         ")
    report_lines.append("==================================================")
    report_lines.append("\n--- CONFUSION MATRIX ---")
    report_lines.append(f"True Negatives (Poprawnie wskazani lojalni): {cm[0][0]}")
    report_lines.append(f"False Positives (Błędnie wskazani jako odejścia): {cm[0][1]}")
    report_lines.append(f"False Negatives (Przeoczone odejścia): {cm[1][0]}")
    report_lines.append(f"True Positives (Poprawnie wskazane odejścia): {cm[1][1]}")
    
    report_lines.append("\n--- CLASSIFICATION METRICS ---")
    report_lines.append(cr)
    
    report_lines.append("--- FEATURE IMPORTANCE (BUSINESS INSIGHTS) ---")
    for rank, (feature, importance) in enumerate(sorted_features.items(), 1):
        report_lines.append(f"{rank}. {feature:<25} -> {importance*100:>6.2f}% weight")
    report_lines.append("==================================================")
    
    final_report = "\n".join(report_lines)
    print(final_report)
    
    with open(report_path, "w", encoding="utf-8") as f:
        f.write(final_report)
        
    print(f"\n[SUCCESS] Evaluation report successfully saved to: {report_path}")

if __name__ == "__main__":
    raw_data = get_data_from_db()
    processed_data = preprocess_features(raw_data)
    _, X_test, _, y_test = prepare_train_test_sets(processed_data)
    model = load_saved_model()
    generate_report(model, X_test, y_test)