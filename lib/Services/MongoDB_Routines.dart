import 'package:mongo_dart/mongo_dart.dart';

class MongoDBService {
  late Db db;
  final String uri = 'mongodb+srv://unichat_admin:j5DyBXwyCEIEk8Df@studentdata.twgkxcq.mongodb.net/?retryWrites=true&w=majority&appName=StudentData';

  MongoDBService() {
    db = Db(uri);
  }

  Future<bool> connectToMongoDB() async {
    try {
      await db.open();
      print('Connected to MongoDB');
      return true;
    } catch (e) {
      print('Error connecting to MongoDB: $e');
      return false;
    }
  }

  // Remember to close the connection when it's no longer needed
  Future<void> disconnectFromMongoDB() async {
    await db.close();
  }
}
