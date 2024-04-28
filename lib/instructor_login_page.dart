import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'chat_gpt/constants/api_consts.dart';

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
        initialUrl: '$LOCALHOST/teacher/login',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('$LOCALHOST')) {
            return NavigationDecision.navigate;
          }
          return NavigationDecision.prevent; // Prevent navigation to unexpected URLs
        },
      ),
    );
  }
}