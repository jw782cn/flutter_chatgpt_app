import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'models.dart';
import 'conversation_provider.dart';

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


  Future<void> _loadMessages(String filePath) async {
    String data = await rootBundle.loadString(filePath);
    List<dynamic> messagesJson = jsonDecode(data);
    List<Message> messages = messagesJson.map((json) {
      String role = json['role'];
      String content = json['content'];
      String senderId = role == 'user' ? userSender.id : systemSender.id;
      return Message(content: content, senderId: senderId);
    }).toList();
    setState(() {
      // add to current conversation
      final newConversation = Conversation(messages: messages, title: filePath);
      Provider.of<ConversationProvider>(context, listen: false)
          .addConversation(newConversation);
    });
  }

  Future<Message?> _sendMessage() async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    // Read API key from local text file
    final apiKeyFile = File('openai_api_key.txt');
    final apiKey = await apiKeyFile.readAsString();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    // send all current conversation to OpenAI
    final body = {
      'model': _model,
      'messages': Provider.of<ConversationProvider>(context, listen: false)
          .currentConversationMessages,
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
        return Message(senderId: systemSender.id, content: contentWithoutPrefix);
      }
    } else {
      // print('Error: ${response.statusCode} ${response.body}');
      return Message(
          senderId: systemSender.id,
          content: 'Error: ${response.statusCode} ${response.body}');
    }
    return null;
  }

  void _clearCurrentConversation() {
    setState(() {
      Provider.of<ConversationProvider>(context, listen: false)
          .clearCurrentConversation();
    });
  }

  void _sendMessageAndAddToChat() async {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      _textController.clear();
      final userMessage = Message(senderId: userSender.id, content: text);
      setState(() {
        // add to current conversation
        Provider.of<ConversationProvider>(context, listen: false).addMessage(userMessage);
      });
      final assistantMessage = await _sendMessage();
      if (assistantMessage != null) {
        setState(() {
          Provider.of<ConversationProvider>(context, listen: false).addMessage(assistantMessage);
        });
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
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
              child: 
              Consumer<ConversationProvider>(
            builder: (context, conversationProvider, child) {
              return
              ListView.builder(
            controller: _scrollController,
            itemCount: conversationProvider.currentConversationLength,
            itemBuilder: (BuildContext context, int index) {
              Message message = conversationProvider.currentConversation
                  .messages[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                                ? Colors.blue[100]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Text(message.content),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    if (message.senderId == userSender.id)
                      CircleAvatar(
                        backgroundImage: AssetImage(userSender.avatarAssetPath),
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
