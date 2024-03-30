// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// // Assuming you have a ThemeProvider similar to the context in your React app.
//
// class DiscordWidget extends StatelessWidget {
//   final List<dynamic> props; // Assuming props is a dynamic list as in your React code
//
//   DiscordWidget({Key? key, required this.props}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context); // Or using a custom ThemeProvider if you have one
//
//     if (props.isNotEmpty && props[0] == "noProjectsFound") {
//       return Center(
//         child: Text(
//           'No Projects Found',
//           style: TextStyle(
//             color: Colors.white, // Adjust based on your theme
//             fontFamily: 'Kode Mono',
//           ),
//         ),
//       );
//     } else if (props.isNotEmpty && props[0] == "noProjectSelected") {
//       return Column(
//         children: [
//           SlideTransition(
//             position: Tween<Offset>(
//               begin: Offset(0, -1),
//               end: Offset.zero,
//             ).animate(AnimationController(
//               vsync: NavigatorState(),
//               duration: const Duration(seconds: 1),
//             )),
//             child: Text(
//               'Select a project to view its discord server',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: theme.primaryColor, // Adjust your theme colors accordingly
//                 fontFamily: 'Kode Mono',
//               ),
//             ),
//           ),
//           Divider(color: theme.dividerColor), // Adjust your theme accordingly
//           // Assuming props[1] contains a list of projects
//           Expanded(
//             child: GridView.builder(
//               itemCount: props[1].length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3, // Or based on your layout preference
//               ),
//               itemBuilder: (context, index) {
//                 var project = props[1][index];
//                 return GestureDetector(
//                   onTap: () async {
//                     SharedPreferences prefs = await SharedPreferences.getInstance();
//                     await prefs.setString('discordServerId', project['discordServerId']);
//                   },
//                   child: Card(
//                     color: theme.cardColor, // Adjust your theme colors accordingly
//                     child: Center(
//                       child: Text(
//                         project['projectName'],
//                         style: TextStyle(fontFamily: 'Kode Mono'),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       );
//     } else {
//       // For displaying the iframe - Note: iframes in Flutter especially on mobile might not work as expected.
//       // You might need to use a WebView widget from the webview_flutter package.
//       return Container(
//         // Placeholder for WebView or another widget that can display the Discord widget
//       );
//     }
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class DiscordWidget extends StatefulWidget {
//   @override
//   _DiscordWidgetState createState() => _DiscordWidgetState();
// }
//
// class _DiscordWidgetState extends State<DiscordWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('WidgetBot'),
//       ),
//       body: WebView(
//         initialUrl: 'https://e.widgetbot.io/channels/${props[0]}', // Replace with your WidgetBot URL
//         javascriptMode: JavascriptMode.unrestricted, // Enable JavaScript execution
//         onWebViewCreated: (WebViewController webViewController) {
//           // You can store the controller to interact with the WebView, if needed.
//         },
//         onProgress: (int progress) {
//           print("WebView is loading (progress : $progress%)");
//         },
//         javascriptChannels: <JavascriptChannel>{
//           // You can add JavaScript channels here if you need to communicate with the WebView.
//         },
//         navigationDelegate: (NavigationRequest request) {
//           // Handle navigation actions, such as opening a new page.
//           return NavigationDecision.navigate;
//         },
//         onPageStarted: (String url) {
//           print('Page started loading: $url');
//         },
//         onPageFinished: (String url) {
//           print('Page finished loading: $url');
//         },
//         gestureNavigationEnabled: true, // Enable or disable gesture navigation.
//       ),
//     );
//   }
// }

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
    String widgetBotUrl = 'https://e.widgetbot.io/';


    return Scaffold(
      appBar: AppBar(title: Text('Discord Channel')),
      body: widget.channelId.isNotEmpty
          ? WebView(
        initialUrl: widgetBotUrl,
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