import 'dart:convert';
import 'package:postgres/postgres.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class User {
  String id;
  String name;
  String email;
  String? imagePath;
  String? phone;
  int level;
  int coins;
  int diamonds;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.imagePath,
    this.phone,
    this.level = 1,
    this.coins = 0,
    this.diamonds = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image_path': imagePath,
      'phone': phone,
      'level': level,
      'coins': coins,
      'diamonds': diamonds,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      imagePath: map['image_path'],
      phone: map['phone'],
      level: map['level'] ?? 1,
      coins: map['coins'] ?? 0,
      diamonds: map['diamonds'] ?? 0,
    );
  }
}

class Question {
  final int id;
  final int categoryId;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;

  Question({
    required this.id,
    required this.categoryId,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'question_text': questionText,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_option': correctOption,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      categoryId: map['category_id'],
      questionText: map['question_text'],
      optionA: map['option_a'],
      optionB: map['option_b'],
      optionC: map['option_c'],
      optionD: map['option_d'],
      correctOption: map['correct_option'],
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  Connection? _connection;
  User? currentUser;

  Future<Connection> get connection async {
    if (_connection != null) return _connection!;

    _connection = await Connection.open(
      Endpoint(
        host: dotenv.get('DB_HOST'),
        port: int.parse(dotenv.get('DB_PORT')),
        database: dotenv.get('DB_NAME'),
        username: dotenv.get('DB_USER'),
        password: dotenv.get('DB_PASSWORD'),
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );

    await _createTables();
    return _connection!;
  }

  Future<void> initDB() async {
    try {
      await connection;
      // Load current user locally to keep session
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        currentUser = User.fromMap(json.decode(userJson));
      }
    } catch (e) {
      print("DB Init Error: $e");
    }
  }

  Future<void> _createTables() async {
    final conn = await connection;
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT UNIQUE,
        image_path TEXT,
        phone TEXT,
        level INTEGER DEFAULT 1,
        coins INTEGER DEFAULT 0,
        diamonds INTEGER DEFAULT 0
      )
    ''');
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS questions (
        id SERIAL PRIMARY KEY,
        category_id INTEGER,
        question_text TEXT,
        option_a TEXT,
        option_b TEXT,
        option_c TEXT,
        option_d TEXT,
        correct_option CHAR(1)
      )
    ''');
  }

  Future<bool> login(String email, String password) async {
    final conn = await connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM users WHERE email = @email'),
      parameters: {'email': email},
    );

    if (result.isNotEmpty) {
      final row = result.first.toColumnMap();
      currentUser = User.fromMap(row);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', json.encode(currentUser!.toMap()));
      return true;
    }
    return false;
  }

  Future<bool> signup(String name, String email, String password) async {
    try {
      final conn = await connection;
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await conn.execute(
        Sql.named('INSERT INTO users (id, name, email) VALUES (@id, @name, @email)'),
        parameters: {'id': id, 'name': name, 'email': email},
      );

      return await login(email, password);
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }

  Future<void> updateUser(User user) async {
    final conn = await connection;
    await conn.execute(
      Sql.named('''
        UPDATE users SET
        name = @name, image_path = @img, phone = @phone,
        level = @lvl, coins = @coins, diamonds = @dia
        WHERE email = @email
      '''),
      parameters: {
        'name': user.name,
        'img': user.imagePath,
        'phone': user.phone,
        'lvl': user.level,
        'coins': user.coins,
        'dia': user.diamonds,
        'email': user.email,
      },
    );
    currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', json.encode(user.toMap()));
  }

  List<Category> getCategories() {
    return [
      Category(id: 1, name: 'Sport', totalQuestions: 10, iconName: 'sports_soccer'),
      Category(id: 2, name: 'Ilm-fan', totalQuestions: 10, iconName: 'science'),
      Category(id: 3, name: 'Tarix', totalQuestions: 10, iconName: 'account_balance'),
      Category(id: 4, name: 'Kinolar', totalQuestions: 10, iconName: 'movie'),
      Category(id: 5, name: 'Musiqa', totalQuestions: 10, iconName: 'music_note'),
      Category(id: 6, name: 'Umumiy', totalQuestions: 10, iconName: 'help'),
    ];
  }

  Future<List<Question>> getAllQuestions() async {
    final conn = await connection;
    final result = await conn.execute('SELECT * FROM questions ORDER BY id DESC');
    return result.map((row) => Question.fromMap(row.toColumnMap())).toList();
  }

  Future<List<Question>> getQuestionsForCategory(int categoryId) async {
    final conn = await connection;
    final result = await conn.execute(
      Sql.named('SELECT * FROM questions WHERE category_id = @catId'),
      parameters: {'catId': categoryId},
    );
    return result.map((row) => Question.fromMap(row.toColumnMap())).toList();
  }

  Future<void> addQuestion(Question q) async {
    final conn = await connection;
    await conn.execute(
      Sql.named('''
        INSERT INTO questions (category_id, question_text, option_a, option_b, option_c, option_d, correct_option)
        VALUES (@cat, @txt, @a, @b, @c, @d, @cor)
      '''),
      parameters: {
        'cat': q.categoryId,
        'txt': q.questionText,
        'a': q.optionA,
        'b': q.optionB,
        'c': q.optionC,
        'd': q.optionD,
        'cor': q.correctOption,
      },
    );
  }

  Future<void> deleteQuestion(int id) async {
    final conn = await connection;
    await conn.execute(
      Sql.named('DELETE FROM questions WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  Future<List<User>> getAllUsers() async {
    final conn = await connection;
    final result = await conn.execute('SELECT * FROM users ORDER BY level DESC');
    return result.map((row) => User.fromMap(row.toColumnMap())).toList();
  }
}

class Category {
  final int id;
  final String name;
  final int totalQuestions;
  final String iconName;

  Category({
    required this.id,
    required this.name,
    required this.totalQuestions,
    required this.iconName,
  });
}
