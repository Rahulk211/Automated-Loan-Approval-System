from flask import Flask, request, jsonify
import numpy as np
import pickle
import joblib
import tensorflow as tf
import os

# ✅ Load models and preprocessing tools
xgb_model = pickle.load(open('xgbclassifiers.sav', 'rb'))
rf_model = joblib.load('rfclassifier.pkl')
scaler = joblib.load('scaler.pkl')
label_encoders = joblib.load('label_encoders.pkl')
tf_model = tf.keras.models.load_model('finsure.h5')

# ✅ Flask app initialization
app = Flask(__name__)

@app.route('/')
def home():
    return "Welcome to the Loan Approval API 🚀"

def preprocess_input(data):
    try:
        # Apply label encoding to categorical values
        for key in label_encoders:
            if key in data:
                le = label_encoders[key]
                data[key] = int(le.transform([data[key]])[0])
            else:
                data[key] = 0  # default if not present

        # Feature engineering
        # loan_to_income = float(data['loan_amnt']) / float(data['person_income'])
        # employment_income_ratio = float(data['person_emp_exp']) / float(data['person_income'])

        income = float(data.get('person_income', 1)) or 1
        loan_to_income = float(data.get('loan_amnt', 0)) / income
        employment_income_ratio = float(data.get('person_emp_exp', 0)) / income


        # Create input list
        input_features = [
            float(data.get('person_age', 0)),
            float(data.get('person_gender', 0)),          
            float(data.get('person_education', 0)), 
            float(data.get('person_income', 0)),
            float(data.get('person_emp_exp', 0)),
            float(data.get('person_home_ownership', 0)),
            float(data.get('loan_amnt', 0)),
            float(data.get('loan_intent', 0)),
            float(data.get('loan_int_rate', 0)),
            float(data.get('loan_percent_income', 0)),
            float(data.get('cb_person_cred_hist_length', 0)),
            float(data.get('credit_score', 0)),
            float(data.get('previous_loan_defaults_on_file',0)),
            loan_to_income,
            employment_income_ratio
        ]

        # Standardize input
        scaled_input = scaler.transform([input_features])
        return scaled_input
    except Exception as e:
        raise Exception(f"Preprocessing error: {str(e)}")

@app.route('/predict_loan', methods=['POST'])
def predict_loan():
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No input data received'}), 400
        
        credit_score = data.get('credit_score')  
        loan_percent_income = data.get('loan_percent_income')
        person_edu = data.get('person_education')
        loan_amt = data.get('loan_amnt')

        if(credit_score<350 or loan_percent_income > 0.4 or (person_edu not in ['Bachelor', 'PhD', 'Associate', 'Master'] and loan_amt > 400000)):
            return jsonify({'error': 'Loan application rejected'}), 400

        processed_input = preprocess_input(data)
        # print("Processed input to model:", processed_input)


        # TensorFlow prediction
        tf_pred = tf_model.predict(processed_input)
        tf_result = int((tf_pred > 0.6)[0][0])

        # XGBoost prediction
        xgb_result = int(xgb_model.predict(processed_input)[0])

        # RandomForest prediction
        rf_result = int(rf_model.predict(processed_input)[0])

        return jsonify({
            'tensorflow_prediction': tf_result,
            'xgboost_prediction': xgb_result,
            'randomforest_prediction': rf_result
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ✅ Run app
if __name__ == '__main__':
    port = int(os.environ.get('PORT', 10000))
    app.run(host='0.0.0.0', port=port)