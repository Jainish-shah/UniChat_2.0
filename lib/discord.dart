import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

import 'chat_gpt/screens/gpt_screen.dart'; // Import this for Platform checking

class DiscordWidget extends StatefulWidget {
  final String studentId;
  final String discordServerId;
  final String id;

  DiscordWidget({Key? key, required this.discordServerId,required this.id,required this.studentId}) : super(key: key);

  @override
  _DiscordWidgetState createState() => _DiscordWidgetState();
}

class _DiscordWidgetState extends State<DiscordWidget> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize WebView for Android
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    String discordUrl =
        'https://discord.com/channels/${widget.discordServerId}/';
    print("Loading Discord URL: $discordUrl");

    return Scaffold(
      appBar: AppBar(
        title: Text("Discord Channel"),
        actions: <Widget>[
          IconButton(
            icon: Image.asset("assets/ChatGPT_icon.png"), // Assuming you have this asset
            onPressed: () {
              // Ensure you handle what happens when the icon is tapped
              debugPrint("ChatGPT icon tapped");
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => ChatScreen(id: widget.id,studentId: widget.studentId, discordServerId : widget.discordServerId), // Make sure this points to your chat screen
              ));
            },
          ),
        ],

      ),
      body: WebView(
        initialUrl: discordUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
        onPageStarted: (String url) {
          print('Page started loading: $url');
        },
        onPageFinished: (String url) {
          print('Page finished loading: $url');
        },
        onWebResourceError: (error) {
          print('Web resource error: $error');
        },
      ),
    );
  }
}
