import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DiscordWidget extends StatefulWidget {
  // final String prop;
  //
  // DiscordWidget({Key? key, required this.prop}) : super(key: key);

  final String channelId;

  // Constructor requires a channelId
  DiscordWidget({Key? key, required this.channelId}) : super(key: key);


  @override
  _DiscordWidgetState createState() => _DiscordWidgetState();
}

class _DiscordWidgetState extends State<DiscordWidget> {
  late String channelId;

  @override
  Widget build(BuildContext context) {
    // String widgetBotUrl = "https://e.widgetbot.io/channels/${widget.prop}";
    // String widgetBotUrl = 'https://e.widgetbot.io/channels/${channelId}';

    return Scaffold(
      appBar: AppBar(title: Text('Discord Channel')),
      body: widget.channelId.isNotEmpty
          ? WebView(
        // initialUrl: widgetBotUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          // Perform initial setup on the webview here
        },
        onProgress: (int progress) {
          print("WebView is loading (progress : $progress%)");
        },
      )
          : Center(
        child: Text(
          'No Projects Found',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}