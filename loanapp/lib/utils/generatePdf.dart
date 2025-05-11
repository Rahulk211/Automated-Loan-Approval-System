// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

Future<String> GenerateAgreement({
  required String applicationId,
  required String name,
  required String dob,
  required String id,
  required String contact,
  required String fulladdress,
  required String organization,
  required String gender,
  required String education,
  required String homeOwnership,
  required String creditHistory,
  required String Bank,
  required String borrowerbank,
  required String repaymentmethod,
  required String borroweraccountholdername,
  required String borroweraccountnumber,
  required String borrowerifsccode,
  required double income,
  required int experience,
  required int creditScore,
  required int creditHistLen,
  required double loanAmount,
  required double monthlyEmi,
  required double loaninst,
  required String loanIntent,
  required String paymentmethod,
  required int repaymentDuration,
}) async {
  final aiPrompt = '''
    Generate a professional loan contract agreement based on the following borrower details:
  Borrower Information:
  - Full Name: $name
  - Date of Birth: $dob
  - ID (Aadhaar/PAN): $id
  - Contact Number: $contact
  - Address: $fulladdress
  - Gender: $gender
  - Education: $education
  - Home Ownership: $homeOwnership
  - Credit History Defaults: $creditHistory

  Employment & Financial Details:
  - Employer/Organization: $organization
  - Monthly Income: ₹$income
  - Employment Experience: $experience years
  - Credit Score: $creditScore
  - Credit History Length: $creditHistLen years
  - Borrower Bank: $borrowerbank
  - Borrower Account Holder Name: $borroweraccountholdername
  - Borrower Account Number: $borroweraccountnumber
  - Borrower Ifsc code: $borrowerifsccode

  Loan Details:
  - Loan Amount: ₹$loanAmount
  - Loan Purpose: $loanIntent
  - Repayment Duration: $repaymentDuration months
  - Interest Rate: $loaninst% 
  - Lenders Bank : $Bank
  - Payment Method : $paymentmethod
  - Repayment Method: $repaymentmethod
  Generate a professional contract agreement including repayment terms, 
    borrower's obligations, and other standard clauses. Write it in a formal tone.
  ''';

  try {
    final aiResponse = await http.post(
      Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyBQFynWHwfa1v_eg_-PEx7eoBIsMJGBOTA'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'contents': [
          {
            'parts': [
              {'text': aiPrompt}
            ]
          }
        ]
      }),
    );

    final aiData = json.decode(aiResponse.body);
    final content = aiData['candidates'][0]['content']['parts'][0]['text'];

    await FirebaseFirestore.instance
        .collection('loan_applications')
        .doc(applicationId)
        .update({'loan_contract_text': content});

    return content;
  } catch (e) {
    print('Error generating or saving agreement: $e');
    return 'Error generating contract. Please try again later.';
  }
}
