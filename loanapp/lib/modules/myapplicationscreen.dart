// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class Myapplicationscreen extends StatelessWidget {
//   const Myapplicationscreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     print('$userId');

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.blue[100],
//         title: const Text('My Applications'),
//       ),
//       body: StreamBuilder(
//           stream: FirebaseFirestore.instance
//               .collection('loan_application')
//               .where('uid', isEqualTo: userId)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             }

//             final docs = snapshot.data!.docs;

//             if (docs.isEmpty) {
//               return const Center(child: Text('No applications found.'));
//             }

//             return ListView.builder(
//                 itemCount: docs.length,
//                 itemBuilder: (context, index) {
//                   final doc = docs[index];
//                   return ListTile(
//                     title: Text(doc['loan_intent']),
//                     subtitle: Text("Status: ${doc['loan_status']}"),
//                     trailing: Text(
//                         doc['date_applied'].toDate().toString().split(' ')[0]),
//                   );
//                 });
//           }),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Myapplicationscreen extends StatelessWidget {
  const Myapplicationscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue[100],
        title: const Text('My Applications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('loan_application')
            .where('uid', isEqualTo: userId)
            .orderBy('date_applied', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No applications found."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final loanIntent = doc['loan_intent'] ?? 'N/A';
              final status = doc['loan_status'] ?? 'Unknown';
              final timestamp = doc['date_applied'] as Timestamp?;
              final formattedDate = timestamp != null
                  ? "${timestamp.toDate().day}-${timestamp.toDate().month}-${timestamp.toDate().year}"
                  : "No Date";

              return ListTile(
                title: Text(loanIntent),
                subtitle: Text("Status: $status"),
                trailing: Text(formattedDate),
              );
            },
          );
        },
      ),
    );
  }
}
