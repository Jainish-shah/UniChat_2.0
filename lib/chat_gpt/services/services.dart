import 'package:flutter/material.dart';
import 'package:unichat_poojan_project/chat_gpt/widgets/drop_down.dart';

import '../constants/constant.dart';
import '../widgets/text_widget.dart';

class Services {
  static Future<void> showModalSheet({required BuildContext context}) async {
    await showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        backgroundColor: scaffoldBackgroundColor,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children:  [
                Container(
                  child: TextWidget(
                    label: "Chosen Model",
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20,),
                Container(child: ModelsDrowDownWidget()),
              ],
            ),
          );
        });
  }
}