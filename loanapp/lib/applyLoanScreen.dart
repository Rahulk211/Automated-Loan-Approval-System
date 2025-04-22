// ignore_for_file: file_names

import 'package:flutter/material.dart';

class Applyloanscreen extends StatefulWidget {
  const Applyloanscreen({super.key});

  @override
  State<Applyloanscreen> createState() => _ApplyloanscreenState();
}

class _ApplyloanscreenState extends State<Applyloanscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Application form"),
        backgroundColor: Colors.blue,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Form(child: Text("welcome"))
        )),
    );
  }
}
