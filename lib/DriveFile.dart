class DriveFile {
  final String id;
  final String name;

  DriveFile({required this.id, required this.name});

  factory DriveFile.fromJson(Map<String, dynamic> json) {
    return DriveFile(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
