// ignore_for_file: file_names

import 'package:flutter/material.dart';

class Dashboardcards extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const Dashboardcards(
      {super.key,
      required this.icon,
      required this.title,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      height: 110,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(
            height: 10,
          ),
          Text(
            title,
            style: const TextStyle(
                fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: 20, color: color, fontWeight: FontWeight.bold),
          )
        ],
      ),
    ));
  }
}
