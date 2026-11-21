import 'package:mongo_dart/mongo_dart.dart';

class MongoDBService {
  late Db db;
  // Never ship database credentials in the app. Pass with --dart-define=MONGODB_URI=... for local tools only.
  final String uri = const String.fromEnvironment('MONGODB_URI');

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
