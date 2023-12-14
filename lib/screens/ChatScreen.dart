import 'package:flutter/material.dart';
import 'package:miniprojectflutter/model/Api.dart';
import 'package:miniprojectflutter/model/Message.dart';
import 'package:miniprojectflutter/screens/SignInScreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.participantId}) : super(key: key);

  final String participantId;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      String? senderId = Auth.userId;
      String receiverId = widget.participantId;

      // First request
      Map<String, dynamic> chatData =
          await Api.getChatBySenderReceiverId(senderId!, receiverId);

      if (chatData.isEmpty) {
        chatData = await Api.getChatBySenderReceiverId(receiverId, senderId);
      }

      List<Message> newMessages = [];

      List<dynamic> apiMessages = chatData['messages'] ?? [];

      for (dynamic messageData in apiMessages) {
        bool isSender = messageData['isSender'] ?? false;

        newMessages.add(Message(
          senderId: isSender ? senderId : receiverId,
          receiverId: isSender ? receiverId : senderId,
          content: messageData['content'],
          timestamp: DateTime.parse(messageData['time']),
          isSender: isSender,
        ));
      }

      // Sort messages based on timestamp
      newMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      setState(() {
        messages = newMessages;
      });
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Screen'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isSender = message.isSender;
                final bool isCurrentUser = message.senderId == Auth.userId;

                return Row(
                  mainAxisAlignment: isCurrentUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? const Color.fromARGB(255, 249, 249, 249)
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        message.content,
                        style: TextStyle(
                          color: isCurrentUser
                              ? const Color.fromARGB(255, 0, 0, 0)
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              controller: _messageController,
              decoration: const InputDecoration(
                labelStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 115, 20, 132),
              backgroundColor:
                  Colors.white, // Set the button text color to green
            ),
            onPressed: () {
              _sendMessage();
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      try {
        String? senderId = Auth.userId;
        String receiverId = widget.participantId;

        await Api.sendMessage(senderId!, receiverId, messageText);

        Message newMessage = Message(
          senderId: senderId,
          receiverId: receiverId,
          content: messageText,
          timestamp: DateTime.now(),
          isSender: true,
        );

        setState(() {
          messages.insert(0, newMessage);
        });

        // Clear the text field
        _messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
