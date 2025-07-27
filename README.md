Risk Score Prediction App

1.Mission and Problem
This project predicts birth defect risks using maternal health data, improving healthcare access in African communities. 
A Flutter app and FastAPI backend deliver accurate risk scores. The API is tested via Swagger UI for reliability. It supports medical professionals with data-driven insights.

2. Youtube Link: https://youtu.be/v1rupAczPH0
   
3. API Endpoint
The API is hosted at : https://christian-ishimwe-mml-summative.onrender.com  .
Test the `/predict` POST endpoint using Swagger UI at https://christian-ishimwe-mml-summative.onrender.com/docs  .

5. Example input: json
{
  "Maternal_age": 20,
  "Gestational_age_weeks": 32,
  "afp_level_ng_ml": 20.0,
  "Maternal_bmi": 20.0,
  "Hemoglobin_g_dl": 13.0,
  "Prenatal_care_visits": 12,
  "Multiple_pregnancy": 0,
  "Gestational_diabetes": 0,
  "Pregnancy_hypertension": 0,
  "Previous_history_defects": 0
}
