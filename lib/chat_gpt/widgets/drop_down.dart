import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unichat_poojan_project/chat_gpt/models/model_model.dart';
import 'package:unichat_poojan_project/chat_gpt/services/api_service.dart';
import 'package:unichat_poojan_project/chat_gpt/widgets/text_widget.dart';

import '../constants/constant.dart';
import '../provider/models_provider.dart';

class ModelsDrowDownWidget extends StatefulWidget {
  const ModelsDrowDownWidget({Key? key});

  @override
  State<ModelsDrowDownWidget> createState() => _ModelsDrowDownWidgetState();
}

class _ModelsDrowDownWidgetState extends State<ModelsDrowDownWidget> {
  String ?currentModel;

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context, listen: false);
    currentModel = modelsProvider.getCurrentModel;
    return FutureBuilder<List<ModelsModel>>(
      future: modelsProvider.getAllModels(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: TextWidget(label: snapshot.error.toString()),
          );
        }
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return SizedBox.shrink();
        }
        return DropdownButton(
          dropdownColor: scaffoldBackgroundColor,
          iconEnabledColor: Colors.white,
          items: List<DropdownMenuItem<String>>.generate(
              snapshot.data!.length,
                  (index) {
                String modelName = "";
                if(snapshot.data![index].id == "gpt-3.5-turbo") {
                  modelName = "Chat with Chat GPT";
                } else if(snapshot.data![index].id == "dall-e-3") {
                  modelName = "Image Generation";
                } else if(snapshot.data![index].id == "gpt-4-vision-preview") {
                  modelName = "Send the Image and Get the Reply";
                }
                return DropdownMenuItem(
                  value: snapshot.data![index].id,
                  child: TextWidget(
                    label: modelName,
                    fontSize: 15,
                  ),
                );
              }
          ),
          value: currentModel,
          onChanged: (value) {
            setState(() {
              currentModel = value.toString();
            });
            modelsProvider.setCurrentModel(value.toString(),);
          },
        );
      },
    );
  }
}
