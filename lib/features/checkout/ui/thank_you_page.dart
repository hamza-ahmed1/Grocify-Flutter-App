import 'package:flutter/material.dart';
import 'dart:async';

class ThankYouPage extends StatefulWidget {
  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple animation
            SizedBox(
              height: 120,
              width: 120,
              child: CircularProgressIndicator(strokeWidth: 6),
            ),
            SizedBox(height: 20),
            Text(
              "Thank you for your order!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Parcel will be delivered in 1 to 2 working days",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
