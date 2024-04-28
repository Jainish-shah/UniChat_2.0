/// role : "role"
/// content : "Test with GPT 11"

class PostChatModel {
  PostChatModel({
      String? role, 
      String? content,}){
    _role = role;
    _content = content;
}

  PostChatModel.fromJson(dynamic json) {
    _role = json['role'];
    _content = json['content'];
  }
  String? _role;
  String? _content;

  String? get role => _role;
  String? get content => _content;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['role'] = _role;
    map['content'] = _content;
    return map;
  }

}