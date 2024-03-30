import 'package:flutter/material.dart';
import 'package:googledrivehandler/googleDriveHandler.dart';
import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:googleapis_auth/auth_io.dart';


class GoogleDrive extends StatefulWidget {
  @override
  _GoogleDriveState createState() => _GoogleDriveState();
}

class _GoogleDriveState extends State<GoogleDrive> {
  @override
  void initState() {
    super.initState();
    GoogleDriveHandler().setAPIKey(apiKey: '190196846143-10082f8l8hbnu2knq1ptm5628og0iies.apps.googleusercontent.com');
  }

  void previewFile(String webViewLink) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Preview File'),
          ),
          body: WebView(
            initialUrl: webViewLink,
            javascriptMode: JavascriptMode.unrestricted,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Drive Files'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            File? file = await GoogleDriveHandler().getFileFromGoogleDrive(context: context);
            if (file != null) {
              // Handle the file, e.g., display it or process it
            }
          },
          child: Text('Get Files from Google Drive'),
        ),
      ),
    );
  }
}

// // -------------------------
// // class GoogleDrive extends StatefulWidget {
// //   @override
// //   _GoogleDriveState createState() => _GoogleDriveState();
// // }
// //
// // class _GoogleDriveState extends State<GoogleDrive> {
// //   @override
// //   void initState() {
// //     super.initState();
// //     GoogleDriveHandler().setAPIKey(apiKey: '190196846143-10082f8l8hbnu2knq1ptm5628og0iies.apps.googleusercontent.com');
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Google Drive Files'),
// //       ),
// //       body: FutureBuilder<List<dynamic>?>(
// //         future: fetchGoogleDriveFiles(),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return Center(child: CircularProgressIndicator());
// //           } else if (snapshot.hasError) {
// //             return Center(child: Text('Error: ${snapshot.error}'));
// //           } else if (snapshot.hasData) {
// //             final files = snapshot.data!;
// //             return ListView.builder(
// //               itemCount: files.length,
// //               itemBuilder: (context, index) {
// //                 final file = files[index];
// //                 return ListTile(
// //                   title: Text(
// //                     file['name'],
// //                     style: TextStyle(color: Colors.black), // Set font color to black
// //                   ),
// //                   onTap: () async {
// //                     // Handle file tap, e.g., download or preview
// //                   },
// //                 );
// //               },
// //             );
// //           } else {
// //             return Center(child: Text('No files found', style: TextStyle(color: Colors.black)));
// //           }
// //         },
// //       ),
// //     );
// //   }
// //
// //   Future<List<dynamic>?> fetchGoogleDriveFiles() async {
// //     // Your implementation to fetch files from Google Drive
// //     // This is a placeholder for your actual implementation
// //
// //     body: Center(
// //         child: ElevatedButton(
// //           onPressed: () async {
// //             File? file = await GoogleDriveHandler().getFileFromGoogleDrive(context: context);
// //             if (file != null) {
// //               // Handle the file, e.g., display it or process it
// //             }
// //           },
// //           child: Text('Get Files from Google Drive'),
// //         ),
// //       );
// //   }
// // }


// import 'package:flutter/material.dart';
// import 'package:googledrivehandler/googledrivehandler.dart';
// import 'dart:io';
// import 'home_navbar.dart'; // Make sure to import your CustomNavBar
// import 'sidebar.dart'; // Make sure to import your CustomSidebar
//
// class GoogleDrive extends StatefulWidget {
//   const GoogleDrive({Key? key}) : super(key: key);
//
//   @override
//   _GoogleDriveState createState() => _GoogleDriveState();
// }
//
// class _GoogleDriveState extends State<GoogleDrive> {
//   late GoogleDriveHandler _googleDriveHandler;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize your GoogleDriveHandler here
//     _googleDriveHandler = GoogleDriveHandler();
//     _googleDriveHandler.setAPIKey(apiKey: '190196846143-10082f8l8hbnu2knq1ptm5628og0iies.apps.googleusercontent.com');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomNavBar(), // Use your custom navigation bar here
//       drawer: CustomSidebar(updateBody: (HomePageBody ) {  },), // Use your custom sidebar here
//       body: Center(
//         child: FutureBuilder<List<File>?>(
//           future: _googleDriveHandler.getFiles(), // Assuming you have a method to fetch files
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return CircularProgressIndicator();
//             } else if (snapshot.hasError) {
//               return Text("Error: ${snapshot.error}");
//             } else if (snapshot.hasData) {
//               List<File>? files = snapshot.data;
//               return ListView.builder(
//                 itemCount: files?.length ?? 0,
//                 itemBuilder: (context, index) {
//                   File file = files![index];
//                   // Display file details here
//                   return ListTile(
//                     title: Text(file.name), // Display the file name
//                     // Add more details as needed
//                   );
//                 },
//               );
//             } else {
//               return Text("No files found");
//             }
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Implement the logic for the back button here
//           Navigator.pop(context); // This will take the user back to the previous screen
//         },
//         child: Icon(Icons.arrow_back), // Use an appropriate icon for the back button
//       ),
//     );
//   }
// }

//
// import 'package:flutter/material.dart';
// import 'package:googledrivehandler/googleDriveHandler.dart';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
//
// class GoogleDrive extends StatefulWidget {
//   @override
//   _GoogleDriveState createState() => _GoogleDriveState();
// }
//
// class _GoogleDriveState extends State<GoogleDrive> {
//   Uint8List? _pdfData;
//
//   @override
//   void initState() {
//     super.initState();
//     GoogleDriveHandler().setAPIKey(apiKey: '190196846143-10082f8l8hbnu2knq1ptm5628og0iies.apps.googleusercontent.com');
//   }
//
//   Future<void> _previewDocument(String fileId) async {
//     // Assuming getFileContentFromGoogleDrive returns Uint8List
//     _pdfData = await GoogleDriveHandler().getFileContentFromGoogleDrive(fileId: fileId);
//     setState(() {}); // Update the UI
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
//             // Example file ID, replace with actual logic to select a file
//             String fileId = 'your_file_id_here';
//             await _previewDocument(fileId);
//           },
//           child: Text('Get Files from Google Drive'),
//         ),
//       ),
//       floatingActionButton: _pdfData != null
//           ? FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => PDFViewerScaffold(
//                 appBar: AppBar(
//                   title: Text("Document Preview"),
//                 ),
//                 path: _pdfData,
//               ),
//             ),
//           );
//         },
//         child: Icon(Icons.preview),
//       )
//           : null,
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:googleapis/drive/v3.dart' as drive;
// import 'package:googleapis_auth/auth_io.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:googledrivehandler/googleDriveHandler.dart';
//
// class GoogleDrive extends StatefulWidget {
//   final String accessToken;
//
//   GoogleDrive({Key? key, required this.accessToken}) : super(key: key);
//
//   @override
//   _GoogleDriveState createState() => _GoogleDriveState();
// }
//
// class _GoogleDriveState extends State<GoogleDrive> {
//   late final drive.DriveApi _driveApi;
//   List<drive.File> _files = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeDriveApi();
//     _listDriveFiles();
//   }
//
//   // void _initializeDriveApi() {
//   //   final authClient = authenticatedClient(
//   //     // Use your http.Client and your credentials
//   //   );
//   //   _driveApi = drive.DriveApi(authClient);
//   // }
//
//   void _initializeDriveApi() {
//     super.initState();
//     // Initialize your GoogleDriveHandler here
//     _googleDriveHandler = GoogleDriveHandler();
//     _googleDriveHandler.setAPIKey(apiKey: '190196846143-10082f8l8hbnu2knq1ptm5628og0iies.apps.googleusercontent.com');
//   }
//
//   Future<void> _listDriveFiles() async {
//     final result = await _driveApi.files.list(spaces: 'drive');
//     setState(() {
//       _files = result.files!;
//     });
//   }
//
//   void _previewFile(drive.File file) {
//     // Google Drive API provides a webViewLink that you can use to preview files in a browser.
//     if (file.webViewLink != null) {
//       _launchURL(file.webViewLink!);
//     }
//   }
//
//   Future<void> _launchURL(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Drive Files'),
//       ),
//       body: ListView.builder(
//         itemCount: _files.length,
//         itemBuilder: (context, index) {
//           final file = _files[index];
//           return ListTile(
//             title: Text(file.name ?? 'Unknown'),
//             subtitle: Text(file.mimeType ?? 'Unknown MIME type'),
//             onTap: () => _previewFile(file),
//           );
//         },
//       ),
//     );
//   }
// }

//
// class GoogleDrive extends StatefulWidget {
//   @override
//   _GoogleDriveState createState() => _GoogleDriveState();
// }
//
// class _GoogleDriveState extends State<GoogleDrive> {
//   late Future<List<drive.File>> _filesFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _filesFuture = _fetchFiles();
//   }
//
//   Future<List<drive.File>> _fetchFiles() async {
//     final googleSignIn = signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
//     final signIn.GoogleSignInAccount? account = await googleSignIn.signInSilently();
//     final authHeaders = await account?.authHeaders;
//     final authenticatedClient = authenticatedClientFromHeaders(authHeaders!);
//     var api = drive.DriveApi(authenticatedClient);
//
//     final fileList = await api.files.list(spaces: 'drive', $fields: 'files(id, name, webViewLink)');
//     return fileList.files!;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Google Drive Files')),
//       body: FutureBuilder<List<drive.File>>(
//         future: _filesFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             if (snapshot.hasError) {
//               return Center(child: Text("Error fetching files"));
//             }
//
//             if (snapshot.hasData) {
//               return ListView.builder(
//                 itemCount: snapshot.data!.length,
//                 itemBuilder: (context, index) {
//                   final file = snapshot.data![index];
//                   return ListTile(
//                     title: Text(file.name!),
//                     onTap: () => _previewFile(file.webViewLink!),
//                   );
//                 },
//               );
//             }
//           }
//           return Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }
//
//   void _previewFile(String url) {
//     Navigator.push(context, MaterialPageRoute(builder: (_) => PreviewPage(url: url)));
//   }
// }
//
// class PreviewPage extends StatelessWidget {
//   final String url;
//
//   const PreviewPage({Key? key, required this.url}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Preview')),
//       body: WebView(
//         initialUrl: url,
//         javascriptMode: JavascriptMode.unrestricted,
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:googledrivehandler/googleDriveHandler.dart';
// import 'dart:io';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:googleapis/drive/v3.dart' as drive;
// import 'package:google_sign_in/google_sign_in.dart' as signIn;
// import 'package:googleapis_auth/auth_io.dart';
//
// class GoogleDrive extends StatefulWidget {
//   @override
//   _GoogleDriveState createState() => _GoogleDriveState();
// }
//
// class _GoogleDriveState extends State<GoogleDrive> {
//   String? _fileUrl;
//
//   @override
//   void initState() {
//     super.initState();
//     GoogleDriveHandler().setAPIKey(apiKey: '190196846143-10082f8l8hbnu2knq1ptm5628og0iies.apps.googleusercontent.com');
//   }
//
//   Future<void> _previewDocument(String fileId) async {
//     // Assuming getFilePreviewUrlFromGoogleDrive returns a URL for previewing the file
//     _fileUrl = await GoogleDriveHandler().getFilePreviewUrlFromGoogleDrive(fileId: fileId);
//     setState(() {}); // Update the UI
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
//             // Example file ID, replace with actual logic to select a file
//             String fileId = 'your_file_id_here';
//             await _previewDocument(fileId);
//           },
//           child: Text('Get Files from Google Drive'),
//         ),
//       ),
//       floatingActionButton: _fileUrl != null
//           ? FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => Scaffold(
//                 appBar: AppBar(
//                   title: Text("Document Preview"),
//                 ),
//                 body: WebView(
//                   initialUrl: _fileUrl,
//                   javascriptMode: JavascriptMode.unrestricted,
//                 ),
//               ),
//             ),
//           );
//         },
//         child: Icon(Icons.preview),
//       )
//           : null,
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:googledrivehandler/googleDriveHandler.dart';
// import 'dart:io';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:googleapis/drive/v3.dart' as drive;
// import 'package:google_sign_in/google_sign_in.dart' as signIn;
// import 'package:googleapis_auth/auth_io.dart';
//
// class GoogleDrive extends StatefulWidget {
//   @override
//   _GoogleDriveState createState() => _GoogleDriveState();
// }
//
// class _GoogleDriveState extends State<GoogleDrive> {
//   List<drive.File>? _files;
//   String? _fileUrl;
//
//   @override
//   void initState() {
//     super.initState();
//     GoogleDriveHandler().setAPIKey(apiKey: '190196846143-10082f8l8hbnu2knq1ptm5628og0iies.apps.googleusercontent.com');
//     _listFiles();
//   }
//
//   Future<void> _listFiles() async {
//     _files = await GoogleDriveHandler().listFilesFromGoogleDrive();
//     setState(() {}); // Update the UI
//   }
//
//   Future<void> _previewDocument(String fileId) async {
//     _fileUrl = await GoogleDriveHandler().getFilePreviewUrlFromGoogleDrive(fileId: fileId);
//     setState(() {}); // Update the UI
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Drive Files'),
//       ),
//       body: _files == null
//           ? Center(child: CircularProgressIndicator()) // Show loading indicator if files are not fetched yet
//           : ListView.builder(
//         itemCount: _files!.length,
//         itemBuilder: (context, index) {
//           final file = _files![index];
//           return ListTile(
//             title: Text(file.name ?? ''),
//             onTap: () => _previewDocument(file.id ?? ''),
//           );
//         },
//       ),
//       floatingActionButton: _fileUrl != null
//           ? FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => Scaffold(
//                 appBar: AppBar(
//                   title: Text("Document Preview"),
//                 ),
//                 body: WebView(
//                   initialUrl: _fileUrl,
//                   javascriptMode: JavascriptMode.unrestricted,
//                 ),
//               ),
//             ),
//           );
//         },
//         child: Icon(Icons.preview),
//       )
//           : null,
//     );
//   }
// }
