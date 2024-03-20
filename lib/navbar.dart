import 'package:flutter/material.dart';

class MyNavBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('My Application'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            // Implement search functionality
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            // Implement notifications functionality
          },
        ),
        IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () {
            // Implement user profile functionality
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
