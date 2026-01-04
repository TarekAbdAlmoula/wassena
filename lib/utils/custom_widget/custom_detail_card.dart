import 'package:flutter/material.dart';

class CustomDetailCard extends StatelessWidget {
  final String title;
  final String description;
  const CustomDetailCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 191, 190, 190),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: TextStyle(fontSize: 18, color: Colors.white)),
          Divider(color: Colors.white),
          Text(
            description,
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
