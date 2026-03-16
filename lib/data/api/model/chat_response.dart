class ChatResponse {
  final List<Choice> choices;

  ChatResponse({required this.choices});

  factory ChatResponse.fromJson(Map<String, dynamic> json) => ChatResponse(
    choices: (json['choices'] as List).map((c) => Choice.fromJson(c)).toList(),
  );
}

class Choice {
  final Message message;

  Choice({required this.message});

  factory Choice.fromJson(Map<String, dynamic> json) => Choice(
    message: Message.fromJson(json['message']),
  );
}

class Message {
  final String role;
  final String content;

  Message({required this.role, required this.content});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    role: json['role'],
    content: json['content'],
  );

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
  };
}
