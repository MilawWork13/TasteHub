import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:taste_hub/components/toast.dart';
import 'package:taste_hub/model/Message.dart';

class GeminiAiController {
  callGeminiModel(List messages, TextEditingController controller,
      BuildContext context, ScrollController scrollController) async {
    try {
      if (controller.text.isNotEmpty) {
        messages.add(Message(text: controller.text, isUser: true));

        final prompt = controller.text.trim();

        final model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: dotenv.env['GOOGLE_API_KEY']!,
        );

        final content = [Content.text(prompt)];
        final response = await model.generateContent(content);

        messages.add(Message(text: response.text!, isUser: false));

        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (e.toString().contains('safety')) {
        controller.clear();
        // ignore: use_build_context_synchronously
        showErrorToast(context,
            message: 'Your message was blocked due to offensive content');
      }
    }
  }

  showClearChatDialog(BuildContext context, List<Message> messages) async {
    // Wait for the user's response from the dialog
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Chat'),
          content: const Text('Are you sure you want to clear the chat?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false to indicate "No"
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true to indicate "Yes"
              },
            ),
          ],
        );
      },
    );

    // Check the result of the dialog
    if (result == true) {
      // Clear the messages if the user clicked "Yes"
      messages.clear();
    }
  }
}
