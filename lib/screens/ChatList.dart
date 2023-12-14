import 'package:flutter/material.dart';
import 'package:miniprojectflutter/screens/ChatScreen.dart';
import 'package:miniprojectflutter/model/Api.dart';
import 'package:miniprojectflutter/model/ChatItem.dart';
import 'package:miniprojectflutter/screens/SignInScreen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<ChatItem> chatItems = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      // Fetch all users
      List<Map<String, dynamic>> users = await Api.getAllUsers();

      // Transform API data into ChatItem objects
      List<ChatItem> newChatItems = users.map((user) {
        return ChatItem.fromJson(user);
      }).toList();

      // Update the state with the new chat items
      setState(() {
        chatItems = newChatItems;
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Chat List'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                // Handle logout here
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignInScreen(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return ['Logout'].map((String choice) {
                return const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: chatItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color.fromARGB(255, 252, 252, 252),
              child: Text(chatItems[index].participantName[0]),
            ),
            title: Text(chatItems[index].participantName),
            textColor: Colors.white,
            subtitle: Text(chatItems[index].lastMessage),
            onTap: () {
              // Navigate to ChatScreen with the participant ID
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    participantId: chatItems[index].participantId,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
