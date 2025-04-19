from flask import Flask, request, jsonify
import tensorflow as tf
import joblib 
import pandas as pd

#Load the trained modeland preprocessing tools
model = tf.keras.models.load_model("finsure.h5")
xgb = joblib.load("xgb_model.pkl")
Rf = joblib.load("rfclassifier.pkl")
scaler = joblib.load("scaler.pkl")
le = joblib.load("label_encoders.pkl")

app = Flask(__name__)

# Define loan interest rates
loan_interest_rates = {
    'PERSONAL': 9.5,
    'EDUCATION': 8.0,
    'MEDICAL': 10.0,
    'VENTURE': 14.0,
    'HOMEIMPROVEMENT': 9.5,
    'DEBTCONSOLIDATION': 15.0
}

@app.route("/predict", methods = ["POST"])
def predict_loan():
    # Get the loan application data from the request
    data = request.get_json

    # Add loan interest rate
    data['loan_int_rate'] = loan_interest_rates.get(data['loan_intent'], 12.0)

    # Convert data to DataFrame
    df_input = pd.DataFrame([data])

    # Encode categorical variables
    for col in le:
        if col in df_input:
            df_input[col] = le[col].transform(df_input[col])
    
    # Scale input data
    df_input_scaled = scaler.transform(df_input)

    nn_prediction = (model.predict(df_input_scaled) > 0.5).astype("int32")
    xgb_prediction = xgb.predict(df_input_scaled)
    Rf_prediction = Rf.predict(df_input_scaled)

    # Determine final decision (majority voting or priority-based logic)
    final_prediction = "Approved" if (nn_prediction[0][0] == 1 and xgb_prediction[0] == 1) or (nn_prediction[0][0] == 1 and Rf_prediction == 1) or (Rf_prediction[0][0] == 1 and xgb_prediction[0][0] == 1) or (nn_prediction[0][0] == 1 and xgb_prediction[0][0] == 1 and Rf_prediction[0][0]==1) else "Rejected"

    if final_prediction == "Approved":
        return jsonify({"status": "Approved", "message": "Loan Approved!"})
    
    else:
        rejection_reasons = []
        if data['credit_score'] < 325:
            rejection_reasons.append('Low credit score')
        if data['loan_percent_income'] > 0.3:
            rejection_reasons.append('High loan-to-income ratio')
        if data['person_emp_exp'] < 2:
            rejection_reasons.append('Insufficient employment experience')
        if data['previous_loan_defaults_on_file'] == 'Yes':
            rejection_reasons.append('Previous loan defaults')
        
        return jsonify({"status": "Rejected", "reasons": rejection_reasons})
    
    if __name__ == "__main__":
        app.run(debug=True, port=5000)

