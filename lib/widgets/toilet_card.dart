import 'package:flutter/material.dart';
import '../models/toilet.dart';
import 'package:flutter/material.dart';

class ToiletCard extends StatelessWidget {
  final Toilet toilet;

  ToiletCard({required this.toilet, required Null Function() onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.all(15),
        title: Text(toilet.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rating: ${toilet.rating}'),
            SizedBox(height: 5),
            Text('Accessibility: ${toilet.accessibility}'),
          ],
        ),
        trailing: Icon(Icons.arrow_forward, color: Colors.blue),
        onTap: () {
          // Navigate to the detail screen
        },
      ),
    );
  }
}
