//import 'dart:ui_web';
import 'package:docx_template/docx_template.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:unichat_poojan_project/chat_gpt/constants/api_consts.dart';
import 'package:unichat_poojan_project/chat_gpt/models/get_chat_gpt_messages_list.dart';
import 'package:unichat_poojan_project/chat_gpt/models/post_chat_model.dart';
import 'package:unichat_poojan_project/chat_gpt/widgets/chat_widget.dart';
import 'package:unichat_poojan_project/chat_gpt/widgets/text_widget.dart';
import 'package:unichat_poojan_project/discord.dart';
import '../../main_home_page.dart';
import '../constants/constant.dart';
import '../models/chat_model.dart';
import '../provider/models_provider.dart';
import '../services/api_service.dart';
import '../services/assets_manager.dart';
import '../services/services.dart';

class _ChatScreenState extends State<ChatScreen> {
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    final modelsProvider = Provider.of<ModelsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        // leading: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Image.asset(AssetsManager.openaiLogo),
        // ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => DiscordWidget(studentId: widget.studentId,id: widget.id,discordServerId: widget.discordServerId,), // Navigate to success page
            ));
          },
        ),
        title: const Text("ChatGPT"),
        actions: [
          IconButton(
            onPressed: () async {
              await Services.showModalSheet(context: context).then((value) {
                print("VALUE :: "+modelsProvider.currentModel);
                if(modelsProvider.currentModel == "gpt-4-vision-preview") {
                  _showImageSelectionDialog(modelsProvider);
                }
              });
            },
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: downloadChatHistoryAsDoc,
          ),
          // IconButton(
          //   icon: Icon(Icons.download),
          //   onPressed: () {
          //     downloadChatHistory();
          //   },
          // ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                  controller: _listScrollController,
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    var messagesToSend = [
                      {'role': chatList[index].chatIndex, 'content': chatList[index].msg},
                    ];
                    //storeChatMessage(widget.id, "universityatalbanyDB", messagesToSend);
                    if(chatList[index].isURL == 0){
                      return ChatWidget(
                        msg: chatList[index].msg,
                        chatIndex: chatList[index].chatIndex,
                        isURL: chatList[index].isURL,
                      );
                    }else{
                      return ChatWidget(
                        msg: chatList[index].msg,
                        chatIndex: chatList[index].chatIndex,
                        isURL: chatList[index].isURL,
                      );
                    }

                  }),
            ),

            if (_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            ],
            SizedBox(
              height: 15,
            ),
            Material(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: focusNode,
                        style: const TextStyle(color: Colors.white),
                        controller: textEditingController,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (value) async {
                          await sendMessageFCT(
                            modelsProvider: modelsProvider,
                          );
                        },
                        decoration: const InputDecoration.collapsed(
                            hintText: "How can I help you?",
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    IconButton(
                        onPressed: () async {
                          await sendMessageFCT(
                            modelsProvider: modelsProvider,
                          );
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        )),
                    Visibility(
                      visible: modelsProvider.currentModel.contains("gpt-4-vision-preview") ? true : false,
                      child: IconButton(
                          onPressed: () async {
                            _showImageSelectionDialog(modelsProvider);
                          },
                          icon: const Icon(
                            Icons.upload_sharp,
                            color: Colors.white,
                          )),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showAddTextDialog(String path, ModelsProvider modelsProvider) async {
    setState(() {
      imageTextController.text = "";
    });
    await showDialog<String>(
      context: context,
      builder: (context) => _SystemPadding(child: AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                autofocus: true,
                controller: imageTextController,
                maxLines: 4,
                minLines: 4,
                decoration: const InputDecoration(
                    labelText: 'Enter text', hintText: ''),
              ),
            )
          ],
        ),
        actions: <Widget>[
          /*ElevatedButton(
            child: Text('Camera'),
            onPressed: () {
              Navigator.pop(context);
              _uploadImageFromCamera(modelsProvider);
            },
          ),*/
          ElevatedButton(
            child: Text('Submit & Upload'),
            onPressed: () async {
              if(imageTextController.text.isEmpty) {
                EasyLoading.showError("Please enter text");
              } else {
                Navigator.pop(context);
                String response = await sendImageToGPT4Vision(image: File(path), modelsProvider: modelsProvider, text: imageTextController.text);
                print("RESPONSE :: "+response);

                chatList.add(ChatModel(msg: response, chatIndex: 1, isURL: 0));
                setState(() {
                  scrollListToEnd();
                  _isTyping = false;
                });
              }
            },
          ),
        ],
      ),),
    );
  }
}