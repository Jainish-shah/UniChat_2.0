import 'package:flutter/material.dart';

class DiscordWidget extends StatelessWidget {
  final String discordServerId;
  final List<dynamic> projects; // Assuming projects is a list of dynamic objects

  DiscordWidget({Key? key, required this.discordServerId, required this.projects}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: discordServerId == "noProjectsFound"
          ? Center(
        child: Text(
          'No Projects Found',
          style: TextStyle(color: Colors.white, fontFamily: 'Kode Mono'),
        ),
      )
          : discordServerId == "noProjectSelected"
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Select a project to view its discord server',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontFamily: 'Kode Mono', fontWeight: FontWeight.bold),
          ),
          Divider(color: Colors.blue, thickness: 2), // Customize this
          // Display projects list if available
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                var project = projects[index];
                return Card(
                  color: Colors.grey, // Customize this
                  child: InkWell(
                    onTap: () {
                      // Handle project selection
                    },
                    child: Center(
                      child: Text(
                        project['projectName'], // Adjust based on your project object
                        style: TextStyle(color: Colors.white, fontFamily: 'Kode Mono'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      )
          : Container(
        // An iframe equivalent in Flutter could be a WebView for embedding an external webpage
        // Flutter doesn't support iframe directly but you can use webview_flutter package to embed web content
        child: Center(child: Text('Discord screen placeholder')),
      ),
    );
  }
}
