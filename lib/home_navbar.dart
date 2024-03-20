import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Assuming chatGPTLogo is an SVG

class CustomNavBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _CustomNavBarState createState() => _CustomNavBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomNavBarState extends State<CustomNavBar> {
  final TextEditingController _searchController = TextEditingController();
  String userImage = "path/to/your/image.png"; // Update with your image path
  bool _isChatGPTBoxOpen = false;

  void _toggleChatGPTBox() {
    setState(() {
      _isChatGPTBoxOpen = !_isChatGPTBoxOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      title: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search or type a command",
          prefixIcon: Icon(Icons.search, color: Colors.white),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
        ),
        style: TextStyle(color: Colors.white),
      ),
      actions: <Widget>[
        IconButton(
          icon: SvgPicture.asset("assets/ChatGPT_icon.svg"), // SVG image
          onPressed: _toggleChatGPTBox,
        ),
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            // Handle notifications
          },
        ),
        IconButton(
          icon: CircleAvatar(
            backgroundImage: NetworkImage(userImage),
          ),
          onPressed: () {
            // Handle user profile
          },
        ),
        PopupMenuButton<int>(
          itemBuilder: (context) => [
            PopupMenuItem<int>(value: 0, child: Text('Profile')),
            PopupMenuItem<int>(value: 1, child: Text('Settings')),
            PopupMenuItem<int>(value: 2, child: Text('Logout')),
          ],
          onSelected: (item) => { /* Handle menu item selection */ },
        ),
      ],
    );
  }
}
