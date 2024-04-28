class Project {
  final String id;
  final String projectName;
  List<User> members;

  Project({required this.id, required this.projectName, required this.members});

  factory Project.fromJson(Map<String, dynamic> json) {
    List<User> members = (json['members'] as List).map((i) => User.fromJson(i)).toList();
    return Project(
      id: json['_id'],
      projectName: json['projectName'],
      members: members,
    );
  }
}

class User {
  final String userId;
  final String name;

  User({required this.userId, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['_id'],
      name: json['name'],
    );
  }
}

class Message {
  String message;
  String sender;
  DateTime sentTime;

  Message({required this.message, required this.sender, required this.sentTime});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json['messageData'],
      sender: json['sender'],
      sentTime: DateTime.parse(json['sentTime']),
    );
  }
}
