// ignore_for_file: file_names

import 'package:flutter/material.dart';

class Activitytile extends StatelessWidget {
  final Color color;
  final String title;
  final IconData icon;

  const Activitytile(
      {super.key,
      required this.color,
      required this.title,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: color.withAlpha(51),
            child: Icon(icon, color: color),
          ),
          title: Text(title,
              style: const TextStyle(fontSize: 16, color: Colors.black)),
        ));
  }
}
