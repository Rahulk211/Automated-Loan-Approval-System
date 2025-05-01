// ignore_for_file: non_constant_identifier_names, file_names

import 'package:flutter/material.dart';

class Viewloandocument extends StatelessWidget {
  final String LoanDocument;
  const Viewloandocument({super.key, required this.LoanDocument});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue[50],
        title: const Text('Loan Agreement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Text(LoanDocument, style: const TextStyle(fontSize: 16)
        ),
      ),
    );
  }
}
