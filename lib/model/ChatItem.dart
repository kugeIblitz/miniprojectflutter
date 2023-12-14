class ChatItem {
  final String participantId; // Add participantId field
  final String participantName;
  final String lastMessage;

  ChatItem({
    required this.participantId,
    required this.participantName,
    required this.lastMessage,
  });

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      participantId: json['id'] ?? '', // Assuming participant ID is the user ID
      participantName: json['fullName'] ?? 'Unknown',
      lastMessage: json['lastMessage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participantId': participantId,
      'participantName': participantName,
      'lastMessage': lastMessage,
    };
  }
}
