// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Forgotpasswordscreen extends StatefulWidget {
  const Forgotpasswordscreen({super.key});

  @override
  State<Forgotpasswordscreen> createState() => _ForgotpasswordscreenState();
}

class _ForgotpasswordscreenState extends State<Forgotpasswordscreen> {
  // ignore: non_constant_identifier_names
  final TextEditingController EmailControllor = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> sendResetMail() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: EmailControllor.text.trim());

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Password reset link")));
    } catch (e) {
      print("Error: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        centerTitle: true,
        title: const Text("Reset PassWord!!!"),
      ),
      backgroundColor: Colors.blue[100],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 350,
            decoration: BoxDecoration(
              color: Colors.white, // white card
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Enter register email id to get a reset link! ",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: EmailControllor,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter Email ID",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        // check if the email has the correct format
                        else if (!value.contains("@")) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            sendResetMail();
                          }
                        },
                        child: const Text("Send Reset Link"))
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
