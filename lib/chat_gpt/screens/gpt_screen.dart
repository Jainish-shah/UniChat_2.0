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


class ChatScreen extends StatefulWidget {
  final String studentId;
  final String id;
  final String discordServerId;
  ChatScreen({Key?  key,required this.studentId,required this.id,required this.discordServerId}) : super (key: key);
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class GetChatGptMessagesList {
  final String role;
  final String content;

  GetChatGptMessagesList({required this.role, required this.content});

  factory GetChatGptMessagesList.fromJson(Map<String, dynamic> json) {
    return GetChatGptMessagesList(
      role: json['role'],
      content: json['content'],
    );
  }
}


class _ChatScreenState extends State<ChatScreen> {


  bool _isTyping = false;
  String databasename = "universityatalbanyDB";

  late TextEditingController textEditingController;
  TextEditingController imageTextController = TextEditingController(text: "");
  late FocusNode focusNode;
  late ScrollController _listScrollController;
  late String messg;
  late String temp;

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();

    //sendMessageRequest(role: "user", sendMessageText: "Testing with Chat GPT Sync");

    WidgetsBinding.instance.addPostFrameCallback((_){
      getChatGptMessagesListAPI();
    });

    // List<GetChatGptMessagesList> listChatMessages = await getChatGptMessagesListAPI();
    // for(int i=0; i<listChatMessages.length; i++) {
    //   chatList.add(ChatModel(msg: listChatMessages[i].content!, chatIndex: listChatMessages[i].role == "user" ? 0 : 1, isURL: 0));
    //   setState(() {
    //     scrollListToEnd();
    //     // _isTyping = false;
    //   });
    // }


    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  List<ChatModel> chatList = [];

  bool isUrl(String text) {
    // This is a basic pattern and might not cover all valid URL cases.
    var pattern = r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$';
    var regExp = RegExp(pattern);

    return regExp.hasMatch(text);
  }

  bool isImageUrl(String url) {
    // A basic check for image file extensions in the URL
    return RegExp(r"\.(jpeg|jpg|gif|png)$", caseSensitive: false).hasMatch(url);
  }
  // --------------------working logic -------------
  // void downloadChatHistory() async {
  //   // Compile chat data into a text format
  //   String chatData = chatList.map((chat) => "${chat.chatIndex == 0 ? 'User' : 'Assistant'}: ${chat.msg}").join('\n');
  //
  //   // Get temporary directory
  //   final directory = await getTemporaryDirectory();
  //   final filePath = '${directory.path}/chat_history.txt';
  //
  //   // Write to a text file
  //   final File file = File(filePath);
  //   await file.writeAsString(chatData);
  //
  //   // Use flutter_file_dialog to offer saving the file
  //   final params = SaveFileDialogParams(sourceFilePath: filePath);
  //   final filePathOrCancel = await FlutterFileDialog.saveFile(params: params);
  //
  //   if (filePathOrCancel != null) {
  //     print("Save successful: $filePathOrCancel");
  //   } else {
  //     print("Save cancelled or failed.");
  //   }
  // }
  // --------------------working logic -------------

  void downloadChatHistoryAsDoc() async {
    // Compile chat data into a text format
    String chatData = chatList.map((chat) => "${chat.chatIndex == 0 ? 'User' : 'Assistant'}: ${chat.msg}").join('\n');

    // Get temporary directory
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/chat_history.doc';  // Changed from .txt to .doc

    // Write to a text file with a .doc extension
    // final File file = File(filePath);
    // await file.writeAsString(chatData);
    //
    // // Optional: Use a file dialog or another method to share the file
    // print("DOC file saved at $filePath");

    final params = SaveFileDialogParams(sourceFilePath: filePath);
    final filePathOrCancel = await FlutterFileDialog.saveFile(params: params);

    if (filePathOrCancel != null) {
      print("Save successful: $filePathOrCancel");
    } else {
      print("Save cancelled or failed.");
    }
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


  void _showImageSelectionDialog(ModelsProvider modelsProvider) {
    showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        //content: Text('Choose image source'),
        alignment: Alignment.center,
        title: Text("Choose image selection option", ),
        actions: [
          ElevatedButton(
            child: Text('Camera'),
            onPressed: () {
              Navigator.pop(context);
              _uploadImageFromCamera(modelsProvider);
            },
          ),
          ElevatedButton(
            child: Text('Gallery'),
            onPressed: () {
              Navigator.pop(context);
              _uploadImageFromGallery(modelsProvider);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImageFromCamera(ModelsProvider modelsProvider) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      final path = pickedImage.path;

      // String response = await sendImageToGPT4Vision(image: File(path), modelsProvider: modelsProvider);
      // print("RESPONSE :: "+response);
      //
      // chatList.add(ChatModel(msg: response, chatIndex: 1, isURL: 0));
      // setState(() {
      //   scrollListToEnd();
      //   _isTyping = false;
      // });

      _showAddTextDialog(path, modelsProvider);
    }
  }

  Future<void> _uploadImageFromGallery(ModelsProvider modelsProvider) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final path = pickedImage.path;

      // String response = await sendImageToGPT4Vision(image: File(path), modelsProvider: modelsProvider);
      // print("RESPONSE :: "+response);
      //
      // chatList.add(ChatModel(msg: response, chatIndex: 1, isURL: 0));
      // setState(() {
      //   scrollListToEnd();
      //   _isTyping = false;
      // });

      _showAddTextDialog(path, modelsProvider);
    }
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

  final Dio _dio = Dio();

  Future<String> encodeImage(File image) async {
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  Future<String> sendImageToGPT4Vision({
    required File image,
    required ModelsProvider modelsProvider,
    required String text,
    int maxTokens = 500,
    String model = "gpt-4-vision-preview",
  }) async {
    setState(() {
      _isTyping = true;
      chatList.add(ChatModel(msg: "Upload Image", chatIndex: 0, isURL: 0));

      //printChatList(chatList);

      messg = "Upload Image";

      textEditingController.clear();
      focusNode.unfocus();

    });
    final String base64Image = await encodeImage(image);

    try {
      final response = await _dio.post(
        "$BASE_URL/chat/completions",
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $API_Key',
            HttpHeaders.contentTypeHeader: "application/json",
          },
        ),
        data: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': 'You have to give concise and short answers'
              // 'content': 'You have to match the image with given text and give concise and short answers'
            },
            {
              'role': 'user',
              'content': [
                // {
                //   'type': 'text',
                //   'text':
                //       'GPT, your task is to identify plant health issues with precision. Analyze any image of a plant or leaf I provide, and detect all abnormal conditions, whether they are diseases, pests, deficiencies, or decay. Respond strictly with the name of the condition identified, and nothing else—no explanations, no additional text. If a condition is unrecognizable, reply with \'I don\'t know\'. If the image is not plant-related, say \'Please pick another image\'',
                // },
                {
                  'type': 'text',
                  'text': 'GPT, '+text
                  // 'text': 'Match the image with text and give the concise and short answers, Text is '+text,
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
                },
              ],
            },
          ],
          'max_tokens': maxTokens,
        }),
      );

      final jsonResponse = response.data;

      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']["message"]);
      }
      return jsonResponse["choices"][0]["message"]["content"];
    } catch (e) {
      setState(() {
        _isTyping = false;
      });
      throw Exception('Error: $e');
    } finally {

    }
  }

  void printChatList(List<ChatModel> chatList) {
    for (ChatModel chatModel in chatList) {
      print(chatModel.msg);
      print(isUrl(chatModel.msg));
      print("**********");
    }
  }

  void scrollListToEnd() {
    _listScrollController.animateTo(
      _listScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 100),
      curve: Curves.fastEaseInToSlowEaseOut,
    );
  }

  // Ensure this function definition is inside your class or an appropriate scope.
  Future<void> sendMessageFCT({required ModelsProvider modelsProvider}) async {
    try {
      setState(() {
        _isTyping = true;
        chatList.add(ChatModel(msg: textEditingController.text, chatIndex: 0, isURL: 0));

        // printChatList(chatList);

        messg = textEditingController.text;

        textEditingController.clear();
        focusNode.unfocus();

        sendMessageRequest(role: "user", sendMessageText: textEditingController.text);

      });
      // Assuming ApiService.sendMessage expects a String message and a model ID.
      chatList.addAll(await ApiService.sendMessage(
        message: messg,
        modelId: modelsProvider.currentModel,
      ));

      sendMessageRequest(role: "assistant", sendMessageText: messg);

      for (ChatModel chat in chatList) {
        print('-----------------------------------------------------------------------------');
        print('Message: ${chat.msg}');
        print('Chat Index: ${chat.chatIndex}');
        print('Is URL: ${chat.isURL}');
        print('------------------------------------------------------------------------------');
      }
      setState(() {
        // textEditingController.clear();
      });
    } catch (error) {
      log("error $error");
    } finally {
      setState(() {
        scrollListToEnd();
        _isTyping = false;
      });
    }
  }

  // Future<void> storeChatMessage(String projectId, String databaseName, List<Map<String, String>> messages) async {
  //   const String url = 'https://9023-2603-7080-b1f0-6390-fcf3-a348-dfe3-7430.ngrok-free.app/api/chatgpt/storechat';
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({
  //         'projectID': projectId,
  //         'databasename': databaseName,
  //         'messages': messages,
  //       }),
  //     );
  //
  //     if (response.statusCode != 200) {
  //       print("Failed to store messages: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Error storing messages: $e");
  //   }
  // }
  //// ==============================
  // Future<List<GetChatGptMessagesList>> getChatGptMessagesListAPI() async {
  //   var url = Uri.parse('$LOCALHOST/api/chatgpt/storechat?projectID=66107b05e3cf7763a806b6b4&databasename=universityatalbanyDB');
  //   //var url = Uri.parse("https://jsonplaceholder.typicode.com/albums/1/photos");
  //   final response = await http.get(url, headers: {"Content-Type": "application/json"});
  //   final result = jsonDecode(response.body);
  //   final List body = result['chatgptmessages'];
  //   print("Messages list Count :: "+body.length.toString());
  //   List<GetChatGptMessagesList> listChatMessages = body.map((e) => GetChatGptMessagesList.fromJson(e)).toList();
  //   for(int i=0; i<listChatMessages.length; i++) {
  //     chatList.add(ChatModel(msg: listChatMessages[i].content!, chatIndex: listChatMessages[i].role == "user" ? 0 : 1, isURL: 0));
  //     setState(() {
  //       // scrollListToEnd();
  //       // _isTyping = false;
  //     });
  //   }
  //   return body.map((e) => GetChatGptMessagesList.fromJson(e)).toList();
  // }
  //// ==============================

  Future<List<GetChatGptMessagesList>> getChatGptMessagesListAPI() async {
    var url = Uri.parse('$LOCALHOST/api/chatgpt/storechat?projectID=${widget.id}&databasename=universityatalbanyDB');
    final response = await http.get(url, headers: {"Content-Type": "application/json"});
    final result = jsonDecode(response.body);
    final List body = result['chatgptmessages'];
    print("Messages list Count :: "+body.length.toString());
    List<GetChatGptMessagesList> listChatMessages = body.map((e) => GetChatGptMessagesList.fromJson(e)).toList();
    for(int i=0; i<listChatMessages.length; i++) {
      chatList.add(ChatModel(msg: listChatMessages[i].content!, chatIndex: listChatMessages[i].role == "user" ? 0 : 1, isURL: 0));
      setState(() {
        scrollListToEnd();
        _isTyping = false;
      });
    }
    return listChatMessages;
  }


  Future<void> sendMessageRequest( {required String role,
    required String sendMessageText,
  }) async {
    if (sendMessageText.isNotEmpty) {
      final url = '$LOCALHOST/api/chatgpt/storechat'; // Replace with your actual server URL
      print('API request URL : $url');
      try {
        Map messages = {
          "role": role,
          "content": sendMessageText
        };

        List<PostChatModel> listPostChat = <PostChatModel>[];
        for(int i=0; i<chatList.length; i++) {
          PostChatModel postChatModel = PostChatModel(content: chatList[i].msg, role: chatList[i].chatIndex == 0 ? "user" : "assistant");
          listPostChat.add(postChatModel);
        }
        PostChatModel postChatModel = PostChatModel(content: sendMessageText, role: role);
        listPostChat.add(postChatModel);
        final response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode({
            'projectID': widget.id,
            'databasename': databasename,
            'messages': listPostChat/*[
              {
                "role": "user",
                "content": "Test with GPT 11"
              },
              {
                "role": "assistant",
                "content": "Test with GPT 22"
              },
              {
                "role": "user",
                "content": "Test with GPT 33"
              },
              {
                "role": "assistant",
                "content": "Test with GPT 44"
              },
              {
                "role": "user",
                "content": "Test with GPT 55"
              },
              {
                "role": "user",
                "content": "Test with GPT 66"
              },
              {
                "role": "assistant",
                "content": "Test with GPT 77"
              },
              {
                "role": "assistant",
                "content": "Test with GPT 88"
              }
            ]*/
          }),
        );

        String request = json.encode({
          'projectID': widget.id,
          'databasename': databasename,
          'messages': listPostChat
        });

        print("API Request :: "+request);

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          // Success response handling
          // Navigator.of(context).pushReplacement(MaterialPageRoute(
          //   builder: (context) => RegistrationSuccessPage(), // Navigate to success page
          // ));
          final result = jsonDecode(response.body);
          // EasyLoading.showSuccess(result['message']);
          // _controller.text = "";
          setState(() {

            scrollListToEnd();
          });
        } else {
          // Server error handling
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text('Registration Failed: ${response.body}'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        // Error handling
        print(e.toString());
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred: $e'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } else {
      // Validation failure handling
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter text to send message'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget? child;

  _SystemPadding({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.viewInsets,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}