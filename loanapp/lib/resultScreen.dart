// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                height: 300,
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
                    // if (status == 'Approved')
                    //   ElevatedButton(
                    //     onPressed: () {
                    //       // Open PDF from docUrl
                    //     },
                    //     child: const Text('View Loan Document'),
                    //   ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
