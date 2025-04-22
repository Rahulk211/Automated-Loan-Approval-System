import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loanapp/applyLoanScreen.dart';
import 'package:loanapp/modules/ActivityTile.dart';
import 'package:loanapp/modules/DashboardCards.dart';
import 'package:loanapp/modules/ActionButton.dart';

class Dashboardscreenog extends StatefulWidget {
  const Dashboardscreenog({super.key});

  @override
  State<Dashboardscreenog> createState() => DashboardscreenogState();
}

class DashboardscreenogState extends State<Dashboardscreenog> {
  String? userName;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchFirstName();
  }

  Future<void> fetchFirstName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userdoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .get();

        setState(() {
          userName = userdoc['firstName'];
          isLoading = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(" Error fetching name: $e");
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Dashboardcards(
                        icon: Icons.insert_drive_file,
                        title: 'Total',
                        value: 'null',
                        color: Colors.blue),
                    Dashboardcards(
                        icon: Icons.check_circle,
                        title: 'Approved',
                        value: 'null',
                        color: Colors.green)
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Dashboardcards(
                        icon: Icons.cancel_presentation_rounded,
                        title: 'Rejected',
                        value: 'null',
                        color: Colors.red),
                    Dashboardcards(
                        icon: Icons.hourglass_top,
                        title: 'Pending',
                        value: 'null',
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>  ApplyForLoanScreen()));
                        }),
                    ActionButton(
                        icon: Icons.list_alt,
                        title: 'My Application',
                        color: Colors.blueAccent,
                        onTap: () {}),
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
                const Activitytile(
                    color: Colors.green,
                    title: 'Medical Loan',
                    subtitle: 'loan for mediacal purpose',
                    icon: Icons.check_box_sharp)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
