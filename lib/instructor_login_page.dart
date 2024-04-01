import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InstructorLoginPage extends StatefulWidget {
  @override
  _InstructorLoginPageState createState() => _InstructorLoginPageState();
}

class _InstructorLoginPageState extends State<InstructorLoginPage> {
  WebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl: 'http://10.252.1.17:3000/te@cher',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('http://10.252.1.17:3000/te@cher')) {
            return NavigationDecision.navigate;
          }
          return NavigationDecision.prevent; // Prevent navigation to unexpected URLs
        },
      ),
    );
  }
}
