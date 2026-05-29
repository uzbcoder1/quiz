import 'package:postgres/postgres.dart';

class DatabaseHelper {
  // Replace these with your actual PostgreSQL credentials
  final String host = 'localhost';
  final int port = 5432;
  final String databaseName = 'quiz_db';
  final String username = 'postgres';
  final String password = 'your_password';

  Connection? _connection;

  Future<void> connect() async {
    _connection = await Connection.open(
      Endpoint(
        host: host,
        port: port,
        database: databaseName,
        username: username,
        password: password,
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.disable, // Change this for production
      ),
    );
    print('Connected to PostgreSQL database');
  }

  Future<void> close() async {
    await _connection?.close();
  }

  // Example: Get a user's details
  Future<Map<String, dynamic>?> getUserDetails(int userId) async {
    if (_connection == null) await connect();
    
    final result = await _connection!.execute(
      Sql.named('SELECT id, name, level, coins, diamonds FROM users WHERE id = @id'),
      parameters: {'id': userId},
    );

    if (result.isEmpty) return null;
    
    final row = result.first;
    return {
      'id': row[0],
      'name': row[1],
      'level': row[2],
      'coins': row[3],
      'diamonds': row[4],
    };
  }

  // Example: Get all categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    if (_connection == null) await connect();
    
    final result = await _connection!.execute('SELECT id, name, total_questions FROM categories');
    
    List<Map<String, dynamic>> categories = [];
    for (final row in result) {
      categories.add({
        'id': row[0],
        'name': row[1],
        'total_questions': row[2],
      });
    }
    return categories;
  }

  // Example: Get a question by category
  Future<Map<String, dynamic>?> getQuestion(int categoryId) async {
    if (_connection == null) await connect();
    
    // In a real app, you'd want to pick a random question or keep track of asked questions
    final result = await _connection!.execute(
      Sql.named('SELECT id, question_text, option_a, option_b, option_c, option_d, correct_option FROM questions WHERE category_id = @categoryId LIMIT 1'),
      parameters: {'categoryId': categoryId},
    );

    if (result.isEmpty) return null;
    
    final row = result.first;
    return {
      'id': row[0],
      'question_text': row[1],
      'option_a': row[2],
      'option_b': row[3],
      'option_c': row[4],
      'option_d': row[5],
      'correct_option': row[6],
    };
  }
}
