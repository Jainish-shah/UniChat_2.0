import 'package:flutter/material.dart';

import 'main.dart';

class RegistrationSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.green,
              radius: 50,
              child: Icon(
                Icons.check,
                size: 80,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Request Submitted\nSuccessfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()), // Make sure MyHomePage exists
                    (Route<dynamic> route) => false, // Removes all routes below the new route
              ),
              child: Text('GO BACK'),
              style: ElevatedButton.styleFrom(
                // primary: Colors.white,
                // onPrimary: Colors.deepPurple,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
