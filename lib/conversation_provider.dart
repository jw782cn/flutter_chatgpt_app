import 'package:flutter/material.dart';

import 'models.dart';

class ConversationProvider extends ChangeNotifier {
  List<Conversation> _conversations = [];
  int _currentConversationIndex = 0;

  List<Conversation> get conversations => _conversations;
  int get currentConversationIndex => _currentConversationIndex;
  int get ConversationCount => _conversations.length;
  int get currentConversationLength =>
      _conversations[_currentConversationIndex].messages.length;
  Conversation get currentConversation => _conversations[_currentConversationIndex];
  // get current conversation's messages format
  //'messages': [
      //   {'role': 'user', 'content': text},
      // ],
  List<Map<String, String>> get currentConversationMessages {
    List<Map<String, String>> messages = [{ 'role': "system", 'content': "You are ChatGPT, a large language model trained by OpenAI. Answer as concisely as possible."}];
    for (Message message in _conversations[_currentConversationIndex].messages) {
      messages.add({
        'role': message.senderId == 'User' ? 'user' : 'system',
        'content': message.content
      });
    }
    return messages;
  }


  // initialize provider conversation list
  ConversationProvider() {
    _conversations.add(Conversation(messages: [], title: 'new conversation'));
  }

  // change conversations
  set conversations(List<Conversation> value) {
    _conversations = value;
    notifyListeners();
  }
  
  // change current conversation
  set currentConversationIndex(int value) {
    _currentConversationIndex = value;
    notifyListeners();
  }

  // add to current conversation
  void addMessage(Message message) {
    _conversations[_currentConversationIndex].messages.add(message);
    notifyListeners();
  }
  
  // add a new empty conversation
  void addEmptyConversation() {
    _conversations.add(Conversation(messages: [], title: 'new conversation'));
    _currentConversationIndex = _conversations.length - 1;
    notifyListeners();
  }

  // add new conversation
  void addConversation(Conversation conversation) {
    _conversations.add(conversation);
    _currentConversationIndex = _conversations.length - 1;
    notifyListeners();
  }

  // clear all conversations
  void clearConversations() {
    _conversations.clear();
    addEmptyConversation();
    notifyListeners();
  }

  // clear current conversation
  void clearCurrentConversation() {
    _conversations[_currentConversationIndex].messages.clear();
    notifyListeners();
  }

}