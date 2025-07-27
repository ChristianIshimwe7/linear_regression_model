from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import joblib
import pandas as pd
import numpy as np
import os

# Initialize FastAPI app
app = FastAPI(
    title="Risk Score Prediction API",
    description="API for predicting birth defect risk score using RandomForestRegressor",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust to specific origins in production
    allow_credentials=True,
    allow_methods=["POST"],
    allow_headers=["*"],
)

# Define feature names
features = [
    'Maternal_age', 'Gestational_age_weeks', 'afp_level_ng_ml', 'Maternal_bmi',
    'Hemoglobin_g_dl', 'Prenatal_care_visits', 'Multiple_pregnancy',
    'Gestational_diabetes', 'Pregnancy_hypertension', 'Previous_history_defects'
]

# Loading function for model and scaler
def load_model_and_scaler(model_path='best_model.pkl', scaler_path='scaler.pkl'):
    try:
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Model file not found at {model_path}")
        if not os.path.exists(scaler_path):
            raise FileNotFoundError(f"Scaler file not found at {scaler_path}")
        model = joblib.load(model_path)
        scaler = joblib.load(scaler_path)
        return model, scaler
    except Exception as e:
        raise Exception(f"Failed to load model or scaler: {str(e)}")

# Load model and scaler at startup
try:
    best_model, scaler = load_model_and_scaler()
except Exception as e:
    raise Exception(f"Startup error: {str(e)}")

# Pydantic model for input validation
class PredictionInput(BaseModel):
    Maternal_age: int = Field(..., ge=15, le=50, description="Maternal age in years (15-50)")
    Gestational_age_weeks: int = Field(..., ge=20, le=42, description="Gestational age in weeks (20-42)")
    afp_level_ng_ml: float = Field(..., ge=0, le=200, description="Alpha-fetoprotein level in ng/ml (0-200)")
    Maternal_bmi: float = Field(..., ge=15, le=50, description="Maternal BMI (15-50)")
    Hemoglobin_g_dl: float = Field(..., ge=8, le=18, description="Hemoglobin level in g/dl (8-18)")
    Prenatal_care_visits: int = Field(..., ge=0, le=20, description="Number of prenatal care visits (0-20)")
    Multiple_pregnancy: int = Field(..., ge=0, le=1, description="Multiple pregnancy (0 = No, 1 = Yes)")
    Gestational_diabetes: int = Field(..., ge=0, le=1, description="Gestational diabetes (0 = No, 1 = Yes)")
    Pregnancy_hypertension: int = Field(..., ge=0, le=1, description="Pregnancy hypertension (0 = No, 1 = Yes)")
    Previous_history_defects: int = Field(..., ge=0, le=1, description="Previous history of defects (0 = No, 1 = Yes)")

# Prediction function
def predict_risk_score(input_data, feature_names=features):
    try:
        input_df = pd.DataFrame([input_data], columns=feature_names)
        if input_df.isna().any().any():
            raise ValueError("Input contains NaN values")
        scaled_input = scaler.transform(input_df)
        return best_model.predict(scaled_input)[0]
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Prediction error: {str(e)}")

# POST endpoint
@app.post("/predict", response_model=dict)
async def predict(data: PredictionInput):
    input_data = [
        data.Maternal_age, data.Gestational_age_weeks, data.afp_level_ng_ml,
        data.Maternal_bmi, data.Hemoglobin_g_dl, data.Prenatal_care_visits,
        data.Multiple_pregnancy, data.Gestational_diabetes,
        data.Pregnancy_hypertension, data.Previous_history_defects
    ]
    prediction = predict_risk_score(input_data)
    return {"prediction": float(prediction)}

# Health check endpoint
@app.get("/")
async def root():
    return {"message": "Risk Score Prediction API is running. Access /docs for Swagger UI."}