import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DiscordWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://yourdomain.com/path/to/discord-widget',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}
