# Automated-Loan-Approval-System
An intelligent, end-to-end loan approval platform using machine learning and OCR to streamline loan applications, verify documents, and predict loan eligibility — all through a seamless Flutter frontend with Firebase backend and a Flask ML API.

✨ Features
📄 Upload documents like Aadhaar, PAN, pay slips, bank statements
🔍 OCR-powered auto-extraction of user data
🤖 ML-based loan approval prediction
🔐 Secure authentication via Firebase
📊 Admin dashboard to monitor applications
⏱ Real-time validation and feedback
📥 Auto-filled application forms from documents
🧠 Multi-model setup (XGBoost, RandomForest, TensorFlow)

🧰 Tech Stack
🔹 Frontend
Flutter (cross-platform mobile app)

🔹 Backend
Firebase (authentication + database)
Flask (Python REST API for ML + OCR)
Python Libraries: pytesseract, OpenCV, Pandas, Scikit-learn, XGBoost, TensorFlow

🔹 Machine Learning
Supervised classification models
Feature Engineering
Hyperparameter tuning

🧱 Architecture
flowchart TD
  A[User uploads documents via Flutter App] --> B[OCR system extracts structured info]
  B --> C[User info and financial data sent to ML API]
  C --> D[ML Model predicts loan approval]
  D --> E[Results shown to user + stored in Firebase]

⚙️ How It Works
User signs up and logs in via the Flutter app
User uploads documents (e.g. Aadhaar, payslip)
OCR extracts relevant details like name, DOB, salary
Extracted and user-entered data is sent to Flask API
ML model predicts loan approval status (approved/rejected)
User sees result, and data is stored for future reference

💡 ML Model Info
Trained on synthetic & real-world loan datasets
Features include: income, employment length, credit history, loan amount, DTI, etc.

Models Used:
-> XGBoost (best accuracy)
-> Random Forest
-> Deep Neural Network (TensorFlow)

Evaluation Metrics:
Accuracy, Precision, Recall, F1 Score, Confusion Matrix

🔍 OCR Integration
Documents supported:
Aadhaar Card
PAN Card
Pay Slips
Bank Statements
Utility Bills / Rent Agreement

OCR Stack:
pytesseract + OpenCV for image processing
Regex-based post-processing for field detection

# Backend Setup
cd backend
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
python app.py  # runs Flask API

# Flutter Frontend
cd flutter_app
flutter pub get
flutter run

# Firebase setup:
# - Add your google-services.json (Android) or GoogleService-Info.plist (iOS)
🗺️ Roadmap
 Basic OCR + Data Extraction

 ML Model Deployment via Flask API

 Flutter UI with Firebase Auth

 Document classifier to auto-detect type (e.g. PAN vs Payslip)

 Admin dashboard for application monitoring

 UI/UX improvements

 Auto email notification system

🤝 Contributing
Contributions, ideas, and suggestions are welcome!


