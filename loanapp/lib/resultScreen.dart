// ignore_for_file: file_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loanapp/dashboardscreenog.dart';
import 'package:loanapp/modules/ViewLoanDocument.dart';

class Resultscreen extends StatelessWidget {
  final String applicationId;
  const Resultscreen({super.key, required this.applicationId});

  Future<Map<String, dynamic>> fetchApplicationData() async {
    final doc = await FirebaseFirestore.instance
        .collection('loan_applications')
        .doc(applicationId)
        .get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    } else {
      throw Exception('Application not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueAccent[100],
        title: const Text('Application Result'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
          future: fetchApplicationData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final data = snapshot.data!;
            final status = data['loan_status'];
            final intent = data['loan_intent'];
            final amount = data['loan_amount'];
            final timestamp = data['date_applied'] as Timestamp;
            final formateddate =
                DateFormat('dd-MM-yyyy').format(timestamp.toDate());
            //final docUrl = data['loan_document'];

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                height: 350,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(10),
                  color: status == 'Approved'
                      ? Colors.green[100]
                      : Colors.red[100],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Application Id: - $applicationId",
                        style: const TextStyle(fontSize: 18)),
                    Text('Loan Intent: - $intent',
                        style: const TextStyle(fontSize: 18)),
                    Text('Loan Amount: - $amount',
                        style: const TextStyle(fontSize: 18)),
                    Text('Application Date: $formateddate',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Text('Status: - $status',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              status == 'Approved' ? Colors.green : Colors.red,
                        )),
                    const SizedBox(height: 20),
                    if (status == 'Approved')
                      ElevatedButton(
                        onPressed: () async {
                          final docSnap = await FirebaseFirestore.instance
                              .collection('loan_applications')
                              .doc(applicationId)
                              .get();

                          final loandoc = docSnap.data()?['loan_contract_text'];

                          if (loandoc != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Viewloandocument(
                                        LoanDocument: loandoc)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Loan document not found yet. Please try again later.')),
                            );
                          }
                        },
                        child: const Text('View Loan Document'),
                      ),
                    
                    ElevatedButton.icon(onPressed: () {
                        Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Dashboardscreenog()),
      (route) => false,
                        ); // Takes you back to Dashboard
                      },
                      icon: const Icon(Icons.dashboard),
                      label: const Text("Back to Dashboard"),
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
