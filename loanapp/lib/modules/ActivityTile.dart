// ignore_for_file: file_names

import 'package:flutter/material.dart';

class Activitytile extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final IconData icon;

  const Activitytile(
      {super.key,
      required this.color,
      required this.title,
      required this.subtitle,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          title: Text(title,
              style: const TextStyle(fontSize: 16, color: Colors.black)),
          subtitle: Text(subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ));
  }
}
