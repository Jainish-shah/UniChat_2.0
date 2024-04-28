// import 'package:flutter/material.dart';
// import 'package:googledrivehandler/googleDriveHandler.dart';
// import 'dart:io';
//
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:googleapis/drive/v3.dart' as drive;
// import 'package:google_sign_in/google_sign_in.dart' as signIn;
// import 'package:googleapis_auth/auth_io.dart';
//
//
// class GoogleDrive extends StatefulWidget {
//   @override
//   _GoogleDriveState createState() => _GoogleDriveState();
// }
//
// class _GoogleDriveState extends State<GoogleDrive> {
//   @override
//   void initState() {
//     super.initState();
//     GoogleDriveHandler().setAPIKey(apiKey: '122508957186-t4seg8roisqdoqurtbt1ihg2d2iuvot4.apps.googleusercontent.com');
//   }
//
//   void previewFile(String webViewLink) {
//     Navigator.of(context).push(
//       MaterialPageRoute(builder: (_) {
//         return Scaffold(
//           appBar: AppBar(
//             title: Text('Preview File'),
//           ),
//           body: WebView(
//             initialUrl: webViewLink,
//             javascriptMode: JavascriptMode.unrestricted,
//           ),
//         );
//       }),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Drive Files'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             File? file = await GoogleDriveHandler().getFileFromGoogleDrive(context: context);
//             if (file != null) {
//               // Handle the file, e.g., display it or process it
//             }
//           },
//           child: Text('Get Files from Google Drive'),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class GoogleDrive extends StatefulWidget {
//   @override
//   _GoogleDriveState createState() => _GoogleDriveState();
// }
//
// class _GoogleDriveState extends State<GoogleDrive> {
//   WebViewController? _webViewController;
//   String _apiKey = 'AIzaSyA7AoViE54mW_dSKwRfI1hQs1dUV1POfoc';
//   String _clientId = '122508957186-852r6b0939i3tpjqlquc8b3v6r5bj96f.apps.googleusercontent.com';
//   // URL to your web page that implements the Google Picker API
//     String _pickerUrl = 'https://drive.google.com/drive/u/0/home';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Drive Files'),
//       ),
//       body: WebView(
//         initialUrl: _pickerUrl,
//         javascriptMode: JavascriptMode.unrestricted,
//         onWebViewCreated: (controller) {
//           _webViewController = controller;
//         },
//         onPageFinished: (url) {
//           // Inject API key and client ID into the web page
//           _webViewController?.evaluateJavascript(
//             "initPicker('$_apiKey', '$_clientId');",
//           );
//         },
//         javascriptChannels: {
//           JavascriptChannel(
//             name: 'UniChat',
//             onMessageReceived: (JavascriptMessage message) {
//               // Handle the received message, e.g., the selected file's URL
//               print('Selected file\'s URL: ${message.message}');
//             },
//           ),
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'main_home_page.dart';

class GoogleDrive extends StatefulWidget {
  final String studentId;
  GoogleDrive({Key?  key,required this.studentId}) : super (key: key);

  @override
  _GoogleDriveState createState() => _GoogleDriveState();
}

class _GoogleDriveState extends State<GoogleDrive> {
  WebViewController? _webViewController;
  String _apiKey = 'AIzaSyA7AoViE54mW_dSKwRfI1hQs1dUV1POfoc';
  String _clientId = '122508957186-852r6b0939i3tpjqlquc8b3v6r5bj96f.apps.googleusercontent.com';
  // URL to your web page that implements the Google Picker API
  String _pickerUrl = 'https://drive.google.com/drive/u/0/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Drive Files'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Pop the current route off the stack
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => MainHomePage(studentId: widget.studentId,), // Navigate to success page
            ));
          },
        ),
      ),
      body: WebView(
        initialUrl: _pickerUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onPageFinished: (url) {
          // Inject API key and client ID into the web page
          _webViewController?.evaluateJavascript(
            "initPicker('$_apiKey', '$_clientId');",
          );
        },
        javascriptChannels: {
          JavascriptChannel(
            name: 'UniChat',
            onMessageReceived: (JavascriptMessage message) {
              // Handle the received message, e.g., the selected file's URL
              print('Selected file\'s URL: ${message.message}');
            },
          ),
        },
      ),
    );
  }
}
