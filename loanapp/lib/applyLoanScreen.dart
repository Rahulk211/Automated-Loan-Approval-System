// ignore_for_file: file_names, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:loanapp/resultScreen.dart';

class Applyloanscreen extends StatefulWidget {
  const Applyloanscreen({super.key});

  @override
  State<Applyloanscreen> createState() => _ApplyloanscreenState();
}

class _ApplyloanscreenState extends State<Applyloanscreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _repaymentDurationController =
      TextEditingController();

  final TextEditingController _age = TextEditingController();
  final TextEditingController _income = TextEditingController();
  final TextEditingController _exp = TextEditingController();
  final TextEditingController _loanAmount = TextEditingController();
  final TextEditingController _creditScore = TextEditingController();
  final TextEditingController _creditHisLen = TextEditingController();
  //final TextEditingController _loanIntent = TextEditingController();

  String loanIntent = 'PERSONAL';
  String gender = 'male';
  String education = 'Bachelor';
  String homeOwnership = 'RENT';
  String creditHistory = 'No';

  bool isLoading = false;

  Future<void> submitApplication() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    setState(() => isLoading = true);
    final int age = int.tryParse(_age.text) ?? 0;
    final int experience = int.tryParse(_exp.text) ?? 0;
    final int creditScore = int.tryParse(_creditScore.text) ?? 0;
    final double income = double.tryParse(_income.text) ??
        0.0; // Add this if income is from a controller
    final double loanAmt =
        double.tryParse(_loanAmount.text) ?? 0.0; // Same for loanAmt
    final int creditHistLen = int.tryParse(_creditHisLen.text) ?? 0;

    Map<String, dynamic> requestedData = {
      "person_age": age,
      "person_gender": gender,
      "person_education": education,
      "person_income": income,
      "person_emp_exp": experience,
      "person_home_ownership": homeOwnership,
      "loan_amnt": loanAmt,
      "loan_intent": loanIntent,
      "loan_int_rate": 12.0,
      "loan_percent_income": income != 0 ? (loanAmt / (income * 12)) : 0,
      "cb_person_cred_hist_length": creditHistLen,
      "credit_score": creditScore,
      "previous_loan_defaults_on_file": creditHistory,
    };

    final response = await http.post(
      Uri.parse(
          'https://automated-loan-approval-system-twdr.onrender.com/predict_loan'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestedData),
    );
    //print(json.encode(requestedData));

    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');
    //final resultStatus = response.statusCode == 200 ? 'Approved' : 'Rejected';
    final resultStatus;
    if (response.statusCode == 200) {
      final predictions = jsonDecode(response.body);
      final tfPrediction = predictions['tensorflow_prediction'];
      final xgbPrediction = predictions['xgboost_prediction'];
      final rfPrediction = predictions['randomforest_prediction'];

      final approvalvote = [tfPrediction, xgbPrediction, rfPrediction]
          .where((p) => p == 1)
          .length;

      resultStatus = approvalvote > 2 ? 'Approved' : 'Rejected';
    } else {
      resultStatus = 'Rejected';
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;

    final docRef =
        await FirebaseFirestore.instance.collection('loan_applications').add({
      'uid': userId,
      'loan_intent': requestedData['loan_intent'],
      'loan_amount': requestedData['loan_amnt'],
      'date_applied': DateTime.now(),
      'loan_status': resultStatus,
      //'loan_pdf_url': pdfUrl,
    });
    setState(() => isLoading = false);
    final applicationid = docRef.id;
    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => Resultscreen(applicationId: applicationid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.blueAccent[100],
          title: const Text('Apply for a Loan'),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                            key: formKey,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.8,
                              child: ListView(
                                children: [
                                  const Text('Basic Details',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                          labelText: 'Full Name')),
                                  TextFormField(
                                      controller: _dobController,
                                      decoration: const InputDecoration(
                                          labelText: 'Date of Birth')),
                                  TextFormField(
                                      controller: _age,
                                      decoration: const InputDecoration(
                                          labelText: 'Age')),
                                  TextFormField(
                                      controller: _idController,
                                      decoration: const InputDecoration(
                                          labelText:
                                              ' Aadhar card Number/ Pan Card number')),
                                  TextFormField(
                                      controller: _contactController,
                                      decoration: const InputDecoration(
                                          labelText: 'Contact Number')),
                                  const Divider(),
                                  const Text('Loan & Financial Details',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextFormField(
                                      controller: _organizationController,
                                      decoration: const InputDecoration(
                                          labelText: 'Name of your employer')),
                                  TextFormField(
                                      controller: _income,
                                      decoration: const InputDecoration(
                                          labelText: 'Monthly Income')),
                                  TextFormField(
                                      controller: _exp,
                                      decoration: const InputDecoration(
                                          labelText: 'Employment Experience')),
                                  TextFormField(
                                      controller: _loanAmount,
                                      decoration: const InputDecoration(
                                          labelText: 'Loan Amount')),
                                  TextFormField(
                                      controller: _creditScore,
                                      decoration: const InputDecoration(
                                          labelText: 'Credit Score')),
                                  TextFormField(
                                      controller: _creditHisLen,
                                      decoration: const InputDecoration(
                                          labelText:
                                              'Credit History Length (in Years(1,2,3 ...))')),
                                  // TextFormField(
                                  //     controller: _loanIntent,
                                  //     decoration: const InputDecoration(
                                  //         labelText:
                                  //             'Loan Intent (e.g., PERSONAL)')),
                                  DropdownButtonFormField(
                                    value: loanIntent,
                                    decoration: const InputDecoration(
                                        labelText: 'Intent of loan'),
                                    items: [
                                      'PERSONAL',
                                      'EDUCATION',
                                      'MEDICAL',
                                      'VENTURE',
                                      'HOMEIMPROVEMENT',
                                      'DEBTCONSOLIDATION'
                                    ]
                                        .map((val) => DropdownMenuItem(
                                            value: val, child: Text(val)))
                                        .toList(),
                                    onChanged: (String? val) =>
                                        setState(() => loanIntent = val!),
                                  ),
                                  TextFormField(
                                      controller: _repaymentDurationController,
                                      decoration: const InputDecoration(
                                          labelText: 'Duration of Loan')),
                                  DropdownButtonFormField(
                                    value: gender,
                                    decoration: const InputDecoration(
                                        labelText: 'Gender'),
                                    items: ['male', 'female']
                                        .map((val) => DropdownMenuItem(
                                            value: val, child: Text(val)))
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => gender = val!),
                                  ),
                                  DropdownButtonFormField(
                                    value: education,
                                    decoration: const InputDecoration(
                                        labelText: 'Education'),
                                    items: [
                                      'High School',
                                      'Bachelor',
                                      'Master',
                                      'PhD'
                                    ]
                                        .map((val) => DropdownMenuItem(
                                            value: val, child: Text(val)))
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => education = val!),
                                  ),
                                  DropdownButtonFormField(
                                    value: homeOwnership,
                                    decoration: const InputDecoration(
                                        labelText: 'Home Ownership'),
                                    items: ['RENT', 'OWN', 'MORTGAGE']
                                        .map((val) => DropdownMenuItem(
                                            value: val, child: Text(val)))
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => homeOwnership = val!),
                                  ),
                                  DropdownButtonFormField(
                                    value: creditHistory,
                                    decoration: const InputDecoration(
                                        labelText: 'Previous Defaults'),
                                    items: ['Yes', 'No']
                                        .map((val) => DropdownMenuItem(
                                            value: val, child: Text(val)))
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => creditHistory = val!),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: submitApplication,
                                    child: const Text('Submit Application'),
                                  ),
                                ],
                              ),
                            )),
                      ))));
  }
}
