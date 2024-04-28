import 'dart:io';
import 'dart:ui';

// import 'dart:ui_web';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:unichat_poojan_project/chat_gpt/constants/constant.dart';
import 'package:unichat_poojan_project/chat_gpt/services/assets_manager.dart';
import 'package:http/http.dart' as http;
import 'package:unichat_poojan_project/chat_gpt/widgets/text_widget.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({super.key, required this.msg, required this.chatIndex, required this.isURL});

  final String msg;
  final int chatIndex;
  final int isURL;

  get childIndex => null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: chatIndex == 0 ? scaffoldBackgroundColor : cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  chatIndex == 0 ? AssetsManager.userImage : AssetsManager.botImage,
                  height: 30,
                  width: 30,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: chatIndex == 0
                      ? Text(
                    msg,
                    style: const TextStyle(color: Colors.white), // Change font color to white for the user
                  )
                      : isURL==0 ? AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        msg.trim(),
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                    isRepeatingAnimation: false,
                    repeatForever: false,
                    displayFullTextOnTap: true,
                    totalRepeatCount: 1,
                  )
                      : Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Image.network(msg, height: 250), // Image
                      IconButton(
                        // Download Button
                        icon: Icon(Icons.download, color: Colors.white),
                        onPressed: () {
                          // Future.delayed(const Duration(seconds: 0), () async {
                          //   print("DOWNLOAD URL :: "+msg);
                          //   //storeImageInLocally(msg);
                          //   EasyLoading.show();
                          //   var response = await Dio().get(msg,
                          //       options: Options(responseType: ResponseType.bytes));
                          //   EasyLoading.dismiss();
                          //   EasyLoading.showSuccess("Image downloaded to gallery successfully!", duration: const Duration(seconds: 3));
                          //   await ImageGallerySaver.saveImage(
                          //       Uint8List.fromList(response.data),
                          //       quality: 100,
                          //       name: DateTime.now().toString()
                          //   );
                          // });
                          EasyLoading.show();
                          FileDownloader.downloadFile(
                              url: msg,
                              name: DateTime.now().toString(),//(optional)
                              onProgress: (String? fileName, double progress) {
                                print('FILE fileName HAS PROGRESS $progress');
                              },
                              onDownloadCompleted: (String path) {
                                print('FILE DOWNLOADED TO PATH: $path');
                                EasyLoading.dismiss();
                                EasyLoading.showSuccess("Image downloaded successfully to "+path, duration: const Duration(seconds: 3));
                              },
                              onDownloadError: (String error) {
                                print('DOWNLOAD ERROR: $error');
                                EasyLoading.dismiss();
                                EasyLoading.showSuccess(""+error, duration: const Duration(seconds: 3));
                              });
                        },
                      ),
                    ],
                  ),
                ),
                if (chatIndex != 0)
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                    ),
                    onPressed: () => _showCustomDialog(context),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }