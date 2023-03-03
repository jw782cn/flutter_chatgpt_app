import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'conversation_provider.dart';
import 'models.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  Provider.of<ConversationProvider>(context, listen: false)
                      .addEmptyConversation('');
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Text(
                    'New Chat',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<ConversationProvider>(
                builder: (context, conversationProvider, child) {
                  return ListView.builder(
                    itemCount: conversationProvider.conversations.length,
                    itemBuilder: (BuildContext context, int index) {
                      Conversation conversation =
                          conversationProvider.conversations[index];
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          color: Colors.red,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          color: Colors.orange,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            Provider.of<ConversationProvider>(context,
                                    listen: false)
                                .removeConversation(index);
                          } else {
                            // TODO: handle edit conversation
                          }
                        },
                        child: GestureDetector(
                          onTap: () {
                            conversationProvider.currentConversationIndex =
                                index;
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: conversationProvider
                                          .currentConversationIndex ==
                                      index
                                  ? Colors.grey[200]
                                  : Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  conversation.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.more_vert),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

