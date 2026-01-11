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
        color: const Color.fromRGBO(228, 227, 227, 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: TextStyle(fontSize: 18, color: Color(0xff094067))),
          Divider(color: Colors.white),
          Text(
            description,
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
