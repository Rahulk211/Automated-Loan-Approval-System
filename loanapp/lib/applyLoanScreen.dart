// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ApplyForLoanScreen extends StatefulWidget {
  @override
  _ApplyForLoanScreenState createState() => _ApplyForLoanScreenState();
}

class _ApplyForLoanScreenState extends State<ApplyForLoanScreen> {
  int _currentStep = 0;
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());
  Map<String, dynamic> formData = {};
  Map<String, File?> documents = {
    'photo': null,
    'id_card': null,
    'bank_statement': null,
    'pay_slip': null,
  };

  Future<void> _pickDocument(String key) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        documents[key] = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance.collection('loan_applications').doc(userId);

    Map<String, String> uploadedUrls = {};
    for (String key in documents.keys) {
      if (documents[key] != null) {
        final ref = FirebaseStorage.instance.ref('documents/$userId/$key.jpg');
        await ref.putFile(documents[key]!);
        final url = await ref.getDownloadURL();
        uploadedUrls[key] = url;
      }
    }

    await docRef.set({
      ...formData,
      'userId': userId,
      'applicationStatus': 'Pending',
      'documents': uploadedUrls,
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  List<Step> getSteps() => [
    // Step 1: Personal Details
    Step(
      title: const Text("Personal"),
      content: Form(
        key: _formKeys[0],
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Full Name'),
              onSaved: (val) => formData['name'] = val,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Date of Birth'),
              onSaved: (val) => formData['dob'] = val,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'ID Card Number'),
              onSaved: (val) => formData['id_card_number'] = val,
            ),
            ElevatedButton(
              onPressed: () => _pickDocument('id_card'),
              child: const Text('Upload ID Card'),
            )
          ],
        ),
      ),
      isActive: _currentStep == 0,
    ),

    // Step 2: Employment Details
    Step(
      title: const Text("Employment"),
      content: Form(
        key: _formKeys[1],
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Occupation'),
              onSaved: (val) => formData['occupation'] = val,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Employer Name'),
              onSaved: (val) => formData['employer'] = val,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Employment Duration'),
              onSaved: (val) => formData['employment_duration'] = val,
            ),
            ElevatedButton(
              onPressed: () => _pickDocument('pay_slip'),
              child: const Text('Upload Pay Slip'),
            )
          ],
        ),
      ),
      isActive: _currentStep == 1,
    ),

    // Step 3: Financial Details
    Step(
      title: const Text("Financial"),
      content: Form(
        key: _formKeys[2],
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Annual Income'),
              onSaved: (val) => formData['income'] = val,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Expenses'),
              onSaved: (val) => formData['expenses'] = val,
            ),
            ElevatedButton(
              onPressed: () => _pickDocument('bank_statement'),
              child: const Text('Upload Bank Statement'),
            )
          ],
        ),
      ),
      isActive: _currentStep == 2,
    ),

    // Step 4: Loan Details
    Step(
      title: const Text("Loan"),
      content: Form(
        key: _formKeys[3],
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Loan Amount'),
              onSaved: (val) => formData['loan_amount'] = val,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Loan Purpose'),
              onSaved: (val) => formData['loan_purpose'] = val,
            ),
            ElevatedButton(
              onPressed: () => _pickDocument('photo'),
              child: const Text('Upload Photo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                _formKeys[_currentStep].currentState?.save();
                await _uploadData();
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ApplicationSummaryScreen(data: formData),
                ));
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
      isActive: _currentStep == 3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Apply for Loan")),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        steps: getSteps(),
        onStepContinue: () {
          if (_formKeys[_currentStep].currentState!.validate()) {
            _formKeys[_currentStep].currentState!.save();
            if (_currentStep < 3) {
              setState(() => _currentStep += 1);
            }
          }
        },
        onStepCancel: () => setState(() {
          if (_currentStep > 0) _currentStep -= 1;
        }),
      ),
    );
  }
}

class ApplicationSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  ApplicationSummaryScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Application Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: data.entries.map((entry) => ListTile(
            title: Text(entry.key),
            subtitle: Text(entry.value.toString()),
          )).toList() + [
            const ListTile(
              title: Text('Status'),
              subtitle: Text('Pending'),
            )
          ],
        ),
      ),
    );
  }
}
