import 'package:flutter/material.dart';
import 'package:taste_hub/controller/gemini_ai_controller.dart';
import 'package:taste_hub/controller/services/ai_dialog_text_formatting_service.dart';
import 'package:taste_hub/model/Message.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final GeminiAiController _geminiAiController =
      GeminiAiController(); // Instance of GeminiAiController
  final TextEditingController _controller =
      TextEditingController(); // Controller for the user input text field
  final ScrollController _scrollController =
      ScrollController(); // Controller for scrolling the chat messages
  final List<Message> _messages = [
    // List to hold chat messages
    Message(
      text:
          'Welcome to Tasteful AI, I will be your assistant. Ask whatever you want!',
      isUser: false,
    ),
  ];
  bool _isLoading = false; // Flag to track loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            automaticallyImplyLeading: false, // Disable back button in app bar
            centerTitle: false,
            backgroundColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome), // Icon for the app bar title
                    SizedBox(width: 10),
                    Text(
                      'Tasteful AI', // Title text in the app bar
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () async {
                    await _geminiAiController.showClearChatDialog(context,
                        _messages); // Show dialog to clear chat history
                    setState(() {
                      _isLoading = false; // Update loading state
                    });
                  },
                  icon: const Icon(
                      Icons.cleaning_services), // Icon button to clear chat
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Dismiss keyboard on tap outside text field
        },
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index]; // Current message
                  return ListTile(
                    title: Align(
                      alignment: message.isUser
                          ? Alignment
                              .centerRight // Align user messages to right
                          : Alignment.centerLeft, // Align AI messages to left
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: message.isUser
                              ? const Color.fromARGB(255, 255, 255,
                                  255) // User message background color
                              : const Color.fromARGB(255, 255, 148,
                                  148), // AI message background color
                          borderRadius: message.isUser
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                )
                              : const BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: processText(message
                                .text), // Format text based on message type
                            style: TextStyle(
                                color: message.isUser
                                    ? Colors.black // User message text color
                                    : Colors.white), // AI message text color
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // User input
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText:
                              'Write your message', // Hint text for input field
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(22),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true; // Set loading state
                                });
                                await _geminiAiController.callGeminiModel(
                                    _messages,
                                    _controller,
                                    context,
                                    _scrollController); // Call AI model for response
                                setState(() {
                                  _controller.clear(); // Clear input field
                                  _isLoading = false; // Reset loading state
                                });
                              },
                              icon: const Icon(
                                Icons.send_rounded,
                                color: Colors.red, // Send button color
                              ),
                            )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
