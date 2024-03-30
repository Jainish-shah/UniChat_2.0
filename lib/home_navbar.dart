import 'package:flutter/material.dart';

class CustomNavBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _CustomNavBarState createState() => _CustomNavBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // Make sure this height fits your needs
}

class _CustomNavBarState extends State<CustomNavBar> {
  bool _isSearchExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      title: _isSearchExpanded
          ? TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: "Search or type a command",
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
        ),
        style: TextStyle(color: Colors.white),
        onSubmitted: (value) {
          setState(() {
            _isSearchExpanded = false; // Optionally collapse after search
          });
          // Handle the search operation
        },
      )
          : Text(""),
      leading: _isSearchExpanded
          ? BackButton(
        onPressed: () {
          setState(() {
            _isSearchExpanded = false;
          });
        },
      )
          : null,
      actions: <Widget>[
        if (!_isSearchExpanded)
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearchExpanded = true;
              });
            },
          ),
        if (!_isSearchExpanded)
          IconButton(
            icon: Image.asset("assets/ChatGPT_icon.png"), // Assuming it's an SVG. Change it to Image.asset if it's a PNG or JPEG.
            onPressed: () {
              // Toggle ChatGPT box
            },
          ),
        if (!_isSearchExpanded)
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
        if (!_isSearchExpanded)
          IconButton(
            icon: CircleAvatar(
              backgroundImage: NetworkImage("path/to/userImage.png"), // Update with your image path or use AssetImage for local images
            ),
            onPressed: () {
              // Handle user profile action
            },
          ),
        if (!_isSearchExpanded)
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem<int>(value: 0, child: Text('Profile')),
              PopupMenuItem<int>(value: 1, child: Text('Settings')),
              PopupMenuItem<int>(value: 2, child: Text('Logout')),
            ],
            onSelected: (item) {
              // Handle selected item
            },
          ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// class CustomNavBar extends StatefulWidget implements PreferredSizeWidget {
//   @override
//   _CustomNavBarState createState() => _CustomNavBarState();
//
//   @override
//   Size get preferredSize => Size.fromHeight(kToolbarHeight); // Make sure this height fits your needs
// }
//
// class _CustomNavBarState extends State<CustomNavBar> {
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   bool _isSearchExpanded = false;
//
//   Future<void> _handleSignOut() async {
//     await FirebaseAuth.instance.signOut();
//     await _googleSignIn.signOut();
//     // After sign out, navigate to the home page or login screen
//     Navigator.of(context).pushReplacementNamed('/login'); // Assuming '/login' route leads to the login screen.
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // ... Rest of your AppBar widget code ...
//
//     return AppBar(
//       // ... Your AppBar properties ...
//       actions: <Widget>[
//         // ... Other action widgets ...
//         PopupMenuButton<int>(
//           itemBuilder: (context) => [
//             PopupMenuItem<int>(value: 0, child: Text('Profile')),
//             PopupMenuItem<int>(value: 1, child: Text('Settings')),
//             PopupMenuItem<int>(value: 2, child: Text('Logout')),
//           ],
//           onSelected: (item) {
//             switch (item) {
//               case 2:
//                 _handleSignOut();
//                 break;
//             // Handle other menu items if necessary
//             }
//           },
//         ),
//       ],
//     );
//   }
// }
