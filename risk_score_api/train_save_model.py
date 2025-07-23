import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error
import joblib
import os

# Load dataset
df = pd.read_csv('Alpha-Fetoprotein and Birth Defect Risk Prediction with African Population Demographics (AAFP-BDR Dataset).csv')

# Define features
features = [
    'Maternal_age', 'Gestational_age_weeks', 'afp_level_ng_ml', 'Maternal_bmi',
    'Hemoglobin_g_dl', 'Prenatal_care_visits', 'Multiple_pregnancy',
    'Gestational_diabetes', 'Pregnancy_hypertension', 'Previous_history_defects'
]

# Handle categorical columns
for col in ['Multiple_pregnancy', 'Gestational_diabetes', 'Pregnancy_hypertension', 'Previous_history_defects']:
    df[col] = df[col].fillna('No').str.lower().map({'no': 0, 'yes': 1}).fillna(0)

# Select features and target
X = df[features].copy()
y = df['Risk_score'].copy()

# Impute missing values
numeric_cols = ['Maternal_age', 'Gestational_age_weeks', 'afp_level_ng_ml', 'Maternal_bmi', 'Hemoglobin_g_dl', 'Prenatal_care_visits']
X.loc[:, numeric_cols] = X[numeric_cols].fillna(X[numeric_cols].median())
y = y.fillna(y.median())

# Scale features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Split data
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2, random_state=42)

# Train Random Forest
rf_model = RandomForestRegressor(random_state=42)
rf_model.fit(X_train, y_train)
rf_train_pred = rf_model.predict(X_train)
rf_test_pred = rf_model.predict(X_test)
print(f'Random Forest - Train MSE: {mean_squared_error(y_train, rf_train_pred):.2f}')
print(f'Random Forest - Test MSE: {mean_squared_error(y_test, rf_test_pred):.2f}')

# Save model and scaler
joblib.dump(rf_model, 'best_model.pkl')
joblib.dump(scaler, 'scaler.pkl')
print("\nSaved best_model.pkl and scaler.pkl")

# Verify saved files
print("\nChecking saved files:")
print("best_model.pkl exists:", os.path.exists('best_model.pkl'))
print("scaler.pkl exists:", os.path.exists('scaler.pkl'))