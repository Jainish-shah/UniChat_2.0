import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DiscordWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Discord Chat",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: WebView(
            initialUrl: 'https://yourdomain.com/path/to/discord-widget',
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
      ],
    );
  }
}
