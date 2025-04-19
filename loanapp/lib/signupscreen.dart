import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loanapp/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  // ignore: non_constant_identifier_names
  final DoBController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      // await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );

      final uid = userCredential.user!.uid;
      //store users data in database
      await FirebaseFirestore.instance.collection('User').doc(uid).set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'DoB': DoBController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'password': passwordController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      showMessage("Account created successfully!");
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const login()),
      );
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? "Something went wrong");
    }catch (e) {
    showMessage("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        centerTitle: true,
        title: const Text("Sign up"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                buildTextField("First Name", firstNameController),
                buildTextField("Last Name", lastNameController),
                buildTextField("Date-of-Birth", DoBController),
                buildTextField("Email", emailController, isEmail: true),
                buildTextField("Phone Number", phoneController, isPhone: true),
                buildTextField("Password", passwordController,
                    isPassword: true),
                buildTextField("Confirm Password", confirmPasswordController,
                    isPassword: true, validator: (value) {
                  if (value != passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                }),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerUser,
                    child: Text(isLoading ? "Registering..." : "Register"),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Already have an account? Login"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    bool isEmail = false,
    bool isPhone = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              children: const [
                TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: isPhone
                ? TextInputType.phone
                : (isEmail ? TextInputType.emailAddress : TextInputType.text),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Required",
            ),
            validator: validator ??
                (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "$label is required";
                  }
                  return null;
                },
          ),
        ],
      ),
    );
  }
}
