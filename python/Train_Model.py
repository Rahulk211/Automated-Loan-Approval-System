import pandas as pd
import numpy as np
import tensorflow as tf
from tensorflow import keras
from sklearn.model_selection import StratifiedKFold, train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
from imblearn.combine import SMOTETomek
from xgboost import XGBClassifier
import  joblib
import pickle
from sklearn.metrics import confusion_matrix, precision_score, recall_score

#Loading data into the model
dataframe  = pd.read_csv("E:\Loan_Approval_System\python\loan_data.csv")

dataframe = dataframe.drop_duplicates()
dataframe['loan_status'].value_counts(normalize=True)
# Fill missing values
for col in dataframe.select_dtypes(include=['number']).columns:
    dataframe[col] = dataframe[col].fillna(dataframe[col].median())
for col in dataframe.select_dtypes(include=['object']).columns:
    dataframe[col] = dataframe[col].fillna(dataframe[col].mode()[0])

# Define loan interest rate based on loan intent
loan_interest_rates = {
    'PERSONAL': 12.5,
    'EDUCATION': 8.0,
    'MEDICAL': 10.0,
    'VENTURE': 14.0,
    'HOMEIMPROVEMENT': 9.5,
    'DEBTCONSOLIDATION': 11.0
}

def set_loan_interest(row) :
    return loan_interest_rates.get(row['loan_intent'],12) # get default rate to 12

dataframe['loan_int_rate'] = dataframe.apply(set_loan_interest, axis = 1)
#print(dataframe['loan_int_rate'])

#Function to encode categorical data
def encode_category(dataframe, columns):
    label_encoders = {}
    for value in columns:
        le = LabelEncoder()
        dataframe[value] = le.fit_transform(dataframe[value])
        label_encoders[value] = le
    return dataframe,label_encoders

# Encode Categorical data
columns = ['person_gender', 'person_education', 'person_home_ownership', 'loan_intent', 'previous_loan_defaults_on_file']
dataframe,label_encoders = encode_category(dataframe,columns)

# Feature Engineering
dataframe['loan_to_income_ratio'] = dataframe['loan_amnt'] / dataframe['person_income']
dataframe['employment_income_ratio'] = dataframe['person_emp_exp'] / dataframe['person_income']

# # Drop redundant features
# dataframe = dataframe.drop(columns=['loan_amnt', 'person_income', 'person_emp_exp'])

#Split dataset
X = dataframe.drop(columns=['loan_status'])
y = dataframe['loan_status']

#Handling class imblance using Adasyn
smote_Tomek = SMOTETomek(random_state=42)
X, y = smote_Tomek.fit_resample(X, y)

X_train, x_test, Y_train, y_test = train_test_split(X, y, test_size= 0.2)

# Scale numerical features
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
x_test = scaler.transform(x_test)

#Tensorflow
model = keras.Sequential([
    keras.layers.Dense(128, activation='relu',kernel_regularizer=keras.regularizers.l2(0.0001), input_shape=(X_train.shape[1],)),
    keras.layers.BatchNormalization(),
    keras.layers.Dropout(0.2),
    
    keras.layers.Dense(64, activation='relu', kernel_regularizer=keras.regularizers.l2(0.0001)),
    keras.layers.BatchNormalization(),
    keras.layers.Dropout(0.2),

    keras.layers.Dense(32, activation='relu', kernel_regularizer=keras.regularizers.l2(0.0001)),
    keras.layers.BatchNormalization(),
    
    keras.layers.Dense(1, activation='sigmoid')
])

#Compile Model
lr_schedule = keras.optimizers.schedules.ExponentialDecay(
    initial_learning_rate = 0.01, decay_steps = 10000, decay_rate = 0.9
)
optimizer = keras.optimizers.Adam(learning_rate=lr_schedule)
model.compile(optimizer=optimizer, loss='binary_crossentropy', metrics=['accuracy'])

#Early stopping to prevent over fitting
early_stopping = keras.callbacks.EarlyStopping(monitor='val_loss', patience=5, restore_best_weights = True)

#training the model
model.fit(X_train,Y_train, epochs = 50, batch_size = 64, validation_data = (x_test,y_test),callbacks=[early_stopping])

#Predictions
y_predict = (model.predict(x_test)>0.4).astype("int32")

#Evaluation
accuracy = accuracy_score(y_test,y_predict)
print('Accuracy: {accuracy:.2f}')
print(classification_report(y_test,y_predict))

# Compare with XGBoost
xgb = XGBClassifier(n_estimators=200, learning_rate=0.05, max_depth=6, subsample=0.8, colsample_bytree = 0.8)
skf = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
for train_idx,val_idx in skf.split(X_train, Y_train):
    xgb.fit(X_train[train_idx, :], Y_train.iloc[train_idx])
print(f'XGBoost Accuracy: {xgb.score(x_test, y_test):.2f}')

Rf = RandomForestClassifier()
Rf.fit(X_train, Y_train)
print(f'Random Forest Accuracy: {Rf.score(x_test, y_test):.2f}')

# Saving models 
model.save("finsure.h5")

joblib.dump(xgb, "xgb_model.pkl")
joblib.dump(scaler, "scaler.pkl")  # Save StandardScaler
joblib.dump(label_encoders, "label_encoders.pkl")  # Save LabelEncoders
joblib.dump(Rf, "rfclassifier.pkl")

pickle.dump(xgb, open('xgbclassifiers.sav', 'wb' ))
pickle.dump(scaler, open('scalers.sav','wb'))


print(confusion_matrix(y_test, y_predict))
print(f"Precision: {precision_score(y_test, y_predict)}")
print(f"Recall: {recall_score(y_test, y_predict)}")


# ✅ Example prediction usage
# def predict_loan_approval(data):
#     model = tf.keras.models.load_model("finsure.h5")
#     scaler = joblib.load("scaler.pkl")
#     label_encoders = joblib.load("label_encoders.pkl")

#     data['loan_int_rate'] = loan_interest_rates.get(data['loan_intent'], 12.0)
#     df_input = pd.DataFrame([data])

#     for col in label_encoders:
#         df_input[col] = label_encoders[col].transform(df_input[col])

#     df_input['loan_to_income_ratio'] = df_input['loan_amnt'] / df_input['person_income']
#     df_input['employment_income_ratio'] = df_input['person_emp_exp'] / df_input['person_income']

#     df_input_scaled = scaler.transform(df_input)
#     print("Processed input to model:", df_input_scaled)
#     prediction = (model.predict(df_input_scaled) > 0.5).astype("int32")

#     if prediction[0][0] == 1:
#         return 'Approved: Everything is fine!'
#     else:
#         rejection_reasons = []
#         if data['credit_score'] < 600:
#             rejection_reasons.append('Low credit score')
#         if data['loan_percent_income'] > 0.4:
#             rejection_reasons.append('High loan-to-income ratio')
#         if data['person_emp_exp'] < 2:
#             rejection_reasons.append('Insufficient employment experience')
#         if data['loan_int_rate'] > 15:
#             rejection_reasons.append('High loan interest rate')
#         if data['previous_loan_defaults_on_file'] == 'Yes':
#             rejection_reasons.append('Previous loan defaults')
#         if not rejection_reasons:
#             rejection_reasons.append('Other financial factors')
#         return f'Rejected: {", ".join(rejection_reasons)}'

# # ✅ Sample input to test
# sample_data = {
#   "person_age": 28,
#   "person_gender": "female",
#   "person_education": "Master",
#   "person_income": 90000.0,
#   "person_emp_exp": 3,
#   "person_home_ownership": "RENT",
#   "loan_amnt": 20000.0,
#   "loan_intent": "MEDICAL",
#   "loan_int_rate": 10.0,
#   "loan_percent_income": 0.22,
#   "cb_person_cred_hist_length": 6,
#   "credit_score": 480,
#   "previous_loan_defaults_on_file": "No"
# }

# print(predict_loan_approval(sample_data))
