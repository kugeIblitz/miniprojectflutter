import 'package:miniprojectflutter/screens/SignInScreen.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  bool isSender;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isSender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isSender: json['senderId'] == Auth.userId,
    );
  }
}
