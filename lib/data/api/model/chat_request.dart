class Message {
  final String role;
  final String content;

  Message({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
  };
}

class ChatRequest {
  final String model;
  final List<Message> messages;

  ChatRequest({
    this.model = 'llama-3.3-70b-versatile',
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    'model': model,
    'messages': messages.map((m) => m.toJson()).toList(),
  };
}
