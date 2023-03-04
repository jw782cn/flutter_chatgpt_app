import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'models.dart';
import 'conversation_provider.dart';
import 'secret.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final http.Client _client = http.Client();
  final String _model = "gpt-3.5-turbo";

  final Sender systemSender = Sender(
      name: 'System', avatarAssetPath: 'resources/avatars/ChatGPT_logo.png');
  final Sender userSender =
      Sender(name: 'User', avatarAssetPath: 'resources/avatars/person.png');

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<Message?> _sendMessage(List<Map<String, String>> messages) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $openaiApiKey',
    };

    // send all current conversation to OpenAI
    final body = {
      'model': _model,
      'messages': messages,
    };
    final response =
        await _client.post(url, headers: headers, body: json.encode(body));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final completions = data['choices'] as List<dynamic>;
      if (completions.isNotEmpty) {
        final completion = completions[0];
        final content = completion['message']['content'] as String;
        // delete all the prefix '\n' in content
        final contentWithoutPrefix = content.replaceFirst(RegExp(r'^\n+'), '');
        return Message(
            senderId: systemSender.id, content: contentWithoutPrefix);
      }
    } else {
      // print('Error: ${response.statusCode} ${response.body}');
      return Message(
          senderId: systemSender.id,
          content: 'Error: ${response.statusCode} ${response.body}');
    }
    return null;
  }

  //scroll to last message
  void _scrollToLastMessage() {
    final double height = _scrollController.position.maxScrollExtent;
    final double lastMessageHeight =
        _scrollController.position.viewportDimension;
    _scrollController.animateTo(
      height,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void _sendMessageAndAddToChat() async {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      _textController.clear();
      final userMessage = Message(senderId: userSender.id, content: text);
      setState(() {
        // add to current conversation
        Provider.of<ConversationProvider>(context, listen: false)
            .addMessage(userMessage);
      });

      // scroll to last message
      _scrollToLastMessage();

      final assistantMessage = await _sendMessage(
          Provider.of<ConversationProvider>(context, listen: false)
              .currentConversationMessages);
      if (assistantMessage != null) {
        setState(() {
          Provider.of<ConversationProvider>(context, listen: false)
              .addMessage(assistantMessage);
        });
      }
      
      // scroll to last message
      _scrollToLastMessage();
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Consumer<ConversationProvider>(
              builder: (context, conversationProvider, child) {
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: conversationProvider.currentConversationLength,
                  itemBuilder: (BuildContext context, int index) {
                    Message message = conversationProvider
                        .currentConversation.messages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.senderId != userSender.id)
                            CircleAvatar(
                              backgroundImage:
                                  AssetImage(systemSender.avatarAssetPath),
                              radius: 16.0,
                            )
                          else
                            const SizedBox(width: 24.0),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Align(
                              alignment: message.senderId == userSender.id
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color: message.senderId == userSender.id
                                      ?  Color(0xff55bb8e)
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  message.content,
                                  style: TextStyle(
                                    color: message.senderId == userSender.id
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          if (message.senderId == userSender.id)
                            CircleAvatar(
                              backgroundImage:
                                  AssetImage(userSender.avatarAssetPath),
                              radius: 16.0,
                            )
                          else
                            const SizedBox(width: 24.0),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // input box
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(32.0),
            ),
            margin:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Type your message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessageAndAddToChat,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}