import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class Api {
  static const baseUrl = 'http://10.0.2.2:8000';

  // User authentication
  static Future<bool> authenticateUser(String email, String password) async {
    final response = await http
        .get(Uri.parse('$baseUrl/users?email=$email&password=$password'));
    if (response.statusCode == 200) {
      final List<dynamic> users = json.decode(response.body);
      return users.isNotEmpty;
    } else {
      throw Exception('Failed to authenticate user');
    }
  }

  // Get all messages between two users
  static Future<List<Map<String, dynamic>>> getMessages(
      String senderId, String receiverId) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/contact?idSender=$senderId&idReceiver=$receiverId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load messages');
    }
  }

  //get All users
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      final List<dynamic> users = json.decode(response.body);
      return List<Map<String, dynamic>>.from(users);
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Get user ID by email
  static Future<String?> getIdByEmail(String email) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users?email=$email'));
      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        if (users.isNotEmpty) {
          return users[0]['id'].toString();
        }
      }
      return null; // User not found
    } catch (e) {
      print('Error getting user ID by email: $e');
      throw Exception('Failed to get user ID by email');
    }
  }

  static Future<Map<String, dynamic>> getChatBySenderReceiverId(
      String senderId, String receiverId) async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/contact?idSender=$senderId&idReceiver=$receiverId'));
      if (response.statusCode == 200) {
        List<dynamic> chatList = json.decode(response.body);

        print('Chat List: $chatList');

        if (chatList.isNotEmpty) {
          return Map<String, dynamic>.from(chatList[0]);
        } else {
          // Return an empty map if no chat is found
          return {};
        }
      } else {
        throw Exception('Failed to load chat');
      }
    } catch (e) {
      print('Error getting chat: $e');
      throw Exception('Failed to get chat');
    }
  }

  //Send message
  static Future<void> sendMessage(
      String senderId, String receiverId, String content) async {
    try {
      // Check if a contact already exists
      final existingContact = await getContact(senderId, receiverId);

      if (existingContact != null) {
        // Contact exists, update it with the new message
        await http.patch(
          Uri.parse('$baseUrl/contact/${existingContact['id']}'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'messages': [
              ...existingContact['messages'],
              {
                'id': senderId,
                'content': content,
                'time': DateTime.now().toUtc().toIso8601String(),
                'isSender': true,
              },
            ],
          }),
        );
      } else {
        // Contact doesn't exist, create a new one
        await http.post(
          Uri.parse('$baseUrl/contact'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'id': const Uuid().v4(),
            'idSender': senderId,
            'idReceiver': receiverId,
            'messages': [
              {
                'id': senderId,
                'content': content,
                'time': DateTime.now().toUtc().toIso8601String(),
                'isSender': true,
              },
            ],
          }),
        );
      }

      print('Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
    }
  }

// Helper function to get an existing contact
  static Future<Map<String, dynamic>?> getContact(
      String senderId, String receiverId) async {
    try {
      // Check for contact from sender to receiver
      final responseSenderToReceiver = await http.get(
        Uri.parse('$baseUrl/contact?idSender=$senderId&idReceiver=$receiverId'),
      );

      if (responseSenderToReceiver.statusCode == 200) {
        final List<dynamic> contactList =
            json.decode(responseSenderToReceiver.body);
        if (contactList.isNotEmpty) {
          return Map<String, dynamic>.from(contactList[0]);
        }
      }

      // Check for contact from receiver to sender
      final responseReceiverToSender = await http.get(
        Uri.parse('$baseUrl/contact?idSender=$receiverId&idReceiver=$senderId'),
      );

      if (responseReceiverToSender.statusCode == 200) {
        final List<dynamic> contactList =
            json.decode(responseReceiverToSender.body);
        if (contactList.isNotEmpty) {
          return Map<String, dynamic>.from(contactList[0]);
        }
      }
    } catch (e) {
      print('Error getting contact: $e');
    }

    return null;
  }

  //Get contact id by id sender
  static Future<String?> getContactIdByIdSender(String idSender) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/contact?idSender=$idSender'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> contacts = json.decode(response.body);
        if (contacts.isNotEmpty) {
          return contacts[0]['id'].toString();
        }
      }
    } catch (e) {
      print('Error getting contact ID by idSender: $e');
    }

    return null;
  }
}
