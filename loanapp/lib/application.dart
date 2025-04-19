import 'package:flutter/material.dart';

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  final TextEditingController loanAmountController = TextEditingController();
  final TextEditingController incomeController = TextEditingController();
  final TextEditingController creditScoreController = TextEditingController();

  String loanType = "Personal Loan";
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Loan Application"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loan Type Dropdown
            const Text("Select Loan Type"),
            DropdownButton<String>(
              value: loanType,
              isExpanded: true,
              items: [
                "Personal Loan",
                "Home Loan",
                "Education Loan",
                "Medical Loan"
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  loanType = newValue!;
                });
              },
            ),

            const SizedBox(height: 10),

            // Loan Amount Field
            const Text("Loan Amount"),
            TextField(
              controller: loanAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter Loan Amount",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // Income Field
            const Text("Income"),
            TextField(
              controller: incomeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter Your Monthly Income",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // Credit Score Field
            const Text("Credit Score"),
            TextField(
              controller: creditScoreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter Credit Score",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  String loanAmount = loanAmountController.text;
                  String income = incomeController.text;
                  String creditScore = creditScoreController.text;

                  // Print values to console (for testing)
                  // ignore: avoid_print
                  print("Loan Type: $loanType");
                  // ignore: avoid_print
                  print("Loan Amount: $loanAmount");
                  // ignore: avoid_print
                  print("Income: $income");
                  // ignore: avoid_print
                  print("Credit Score: $creditScore");

                  // You can connect this to your Flask API here
                },
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  
  }
}