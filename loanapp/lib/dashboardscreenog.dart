import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loanapp/applyLoanScreen.dart';
import 'package:loanapp/modules/ActivityTile.dart';
import 'package:loanapp/modules/DashboardCards.dart';
import 'package:loanapp/modules/ActionButton.dart';
import 'package:loanapp/resultScreen.dart';
// import 'package:loanapp/modules/myapplicationscreen.dart';

class Dashboardscreenog extends StatefulWidget {
  const Dashboardscreenog({super.key});

  @override
  State<Dashboardscreenog> createState() => DashboardscreenogState();
}

class DashboardscreenogState extends State<Dashboardscreenog> {
  String? userName;
  bool isLoading = true;
  int total = 0;
  int approved = 0;
  int rejected = 0;
  int pending = 0;
  List<Map<String, dynamic>> recentApp = [];

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .get();

      final applicationsQuery = await FirebaseFirestore.instance
          .collection('loan_applications')
          .where('uid', isEqualTo: user.uid)
          .orderBy('date_applied', descending: true)
          .get();
      List<Map<String, dynamic>> recent = [];
      int a = 0, r = 0, p = 0;

      // DocumentSnapshot userdoc = await FirebaseFirestore.instance
      //     .collection('User')
      //     .doc(user.uid)
      //     .get();

      for (var doc in applicationsQuery.docs) {
        String status = doc['loan_status'];
        if (status == 'Approved') {
          a++;
        } else if (status == 'Rejected') {
          r++;
        } else {
          p++;
        }

        if (recent.length < 3) {
          recent.add({
            'title': doc['loan_intent'],
            'status': status,
            'application_id': doc.id
          });
        }
      }

      setState(() {
        userName = userDoc['firstName'];
        total = applicationsQuery.docs.length;
        approved = a;
        rejected = r;
        pending = p;
        recentApp = recent;
        isLoading = false;
      });
      // setState(() {
      //   userName = userdoc['firstName'];
      //   isLoading = false;
      // });
    } catch (e) {
      // ignore: avoid_print
      print(" Error fetching dashboard data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Dashboard"),
        backgroundColor: Colors.blue[100],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, $userName!",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Dashboardcards(
                        icon: Icons.insert_drive_file,
                        title: 'Total',
                        value: '$total',
                        color: Colors.blue),
                    Dashboardcards(
                        icon: Icons.check_circle,
                        title: 'Approved',
                        value: '$approved',
                        color: Colors.green)
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Dashboardcards(
                        icon: Icons.cancel_presentation_rounded,
                        title: 'Rejected',
                        value: '$rejected',
                        color: Colors.red),
                    Dashboardcards(
                        icon: Icons.hourglass_top,
                        title: 'Pending',
                        value: '$pending',
                        color: Colors.orange)
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  "Quick Actions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                        icon: Icons.add_box,
                        title: 'Apply loan',
                        color: Colors.blueAccent,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const Applyloanscreen()));
                        }),
                    // ActionButton(
                    //     icon: Icons.list_alt,
                    //     title: 'My Application',
                    //     color: Colors.blueAccent,
                    //     onTap: () {
                    //       Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) =>
                    //                   const Myapplicationscreen()));
                    //     }),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text("Recent Applications",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  children: recentApp.map((app) {
                    Color color = app['status'] == 'Approved'
                        ? Colors.green
                        : app['status'] == 'Rejected'
                            ? Colors.red
                            : Colors.orange;

                    IconData icon = app['status'] == 'Approved'
                        ? Icons.check_box
                        : app['status'] == 'Rejected'
                            ? Icons.cancel
                            : Icons.hourglass_top;

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Resultscreen(
                                  applicationId: app['application_id']),
                            ));
                      },
                      child: Activitytile(
                        color: color,
                        title: app['title'],
                        subtitle: app['status'],
                        icon: icon,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
