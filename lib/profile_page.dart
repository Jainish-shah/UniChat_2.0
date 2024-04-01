import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfilePage extends StatelessWidget {
  final GoogleSignInAccount? googleUser;

  ProfilePage({this.googleUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: Center(
        child: googleUser != null ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(googleUser?.photoUrl ?? 'https://via.placeholder.com/150'),
              radius: 50,
            ),
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text('Name: ${googleUser?.displayName ?? 'Not Available'}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: Text('Email: ${googleUser?.email ?? 'Not Available'}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.link),
                      title: Text('Discord ID: ${fetchDiscordId()}'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ) : const Text("No user is currently signed in."),
      ),
    );
  }

  String fetchDiscordId() {
    // Your logic to fetch the Discord ID
    return '123456789'; // Placeholder
  }
}
