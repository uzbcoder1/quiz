import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
      'imagePath': imagePath,
      'phone': phone,
      'level': level,
      'coins': coins,
      'diamonds': diamonds,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      imagePath: map['imagePath'],
      phone: map['phone'],
      level: map['level'],
      coins: map['coins'],
      diamonds: map['diamonds'],
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
      'categoryId': categoryId,
      'questionText': questionText,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctOption': correctOption,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      categoryId: map['categoryId'],
      questionText: map['questionText'],
      optionA: map['optionA'],
      optionB: map['optionB'],
      optionC: map['optionC'],
      optionD: map['optionD'],
      correctOption: map['correctOption'],
    );
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

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  SharedPreferences? _prefs;
  User? currentUser;
  List<Question> _allQuestions = [];

  Future<void> initDB() async {
    _prefs = await SharedPreferences.getInstance();

    // Load current user if logged in
    final userJson = _prefs?.getString('current_user');
    if (userJson != null) {
      currentUser = User.fromMap(json.decode(userJson));
    }

    // Load questions from storage or use defaults
    final questionsJson = _prefs?.getString('questions');
    if (questionsJson != null) {
      Iterable l = json.decode(questionsJson);
      _allQuestions = List<Question>.from(l.map((model) => Question.fromMap(model)));
    } else {
      _allQuestions = _defaultQuestions;
      await _saveQuestions();
    }
  }

  Future<void> _saveQuestions() async {
    final String encodedData = json.encode(_allQuestions.map((q) => q.toMap()).toList());
    await _prefs?.setString('questions', encodedData);
  }

  Future<bool> login(String email, String password) async {
    // In a real DB, verify password. Here we simulate.
    final usersJson = _prefs?.getString('users') ?? '{}';
    Map<String, dynamic> users = json.decode(usersJson);
    
    if (users.containsKey(email)) {
      // Simulate successful login
      currentUser = User.fromMap(users[email]);
      await _prefs?.setString('current_user', json.encode(currentUser!.toMap()));
      return true;
    }
    return false;
  }

  Future<bool> signup(String name, String email, String password) async {
    final usersJson = _prefs?.getString('users') ?? '{}';
    Map<String, dynamic> users = json.decode(usersJson);

    if (users.containsKey(email)) {
      return false; // User exists
    }

    final newUser = User(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, email: email);
    users[email] = newUser.toMap();
    await _prefs?.setString('users', json.encode(users));
    
    currentUser = newUser;
    await _prefs?.setString('current_user', json.encode(currentUser!.toMap()));
    return true;
  }

  Future<void> logout() async {
    currentUser = null;
    await _prefs?.remove('current_user');
  }

  Future<void> updateUser(User user) async {
    if (currentUser?.email != null) {
      currentUser = user;
      await _prefs?.setString('current_user', json.encode(currentUser!.toMap()));
      
      final usersJson = _prefs?.getString('users') ?? '{}';
      Map<String, dynamic> users = json.decode(usersJson);
      users[user.email] = user.toMap();
      await _prefs?.setString('users', json.encode(users));
    }
  }

  // MOCK DATA for Categories
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

  final List<Question> _defaultQuestions = [
    // Sport (ID: 1)
    Question(id: 1, categoryId: 1, questionText: 'Qaysi sport turi millionlar oyini deb ataladi?', optionA: 'Basketbol', optionB: 'Tennis', optionC: 'Futbol', optionD: 'Golf', correctOption: 'C'),
    Question(id: 2, categoryId: 1, questionText: 'Futbol jamoasida nechta oyinchi boladi?', optionA: '9', optionB: '10', optionC: '11', optionD: '12', correctOption: 'C'),
    Question(id: 3, categoryId: 1, questionText: 'Jahon chempionatida eng kop qaysi davlat golib bolgan?', optionA: 'Germaniya', optionB: 'Italiya', optionC: 'Argentina', optionD: 'Braziliya', correctOption: 'D'),

    // Ilm-fan (ID: 2)
    Question(id: 11, categoryId: 2, questionText: 'Qizil sayyora qaysi?', optionA: 'Yer', optionB: 'Mars', optionC: 'Yupiter', optionD: 'Saturn', correctOption: 'B'),
    Question(id: 12, categoryId: 2, questionText: 'Oltinning kimyoviy belgisi qanday?', optionA: 'Au', optionB: 'Ag', optionC: 'Fe', optionD: 'O', correctOption: 'A'),
    Question(id: 13, categoryId: 2, questionText: 'Suv necha gradusda qaynaydi?', optionA: '50', optionB: '100', optionC: '150', optionD: '200', correctOption: 'B'),

    // Tarix (ID: 3)
    Question(id: 21, categoryId: 3, questionText: 'Amerikani kim kashf qilgan?', optionA: 'Leif Erikson', optionB: 'Xristofor Kolumb', optionC: 'Marko Polo', optionD: 'Jeyms Kuk', correctOption: 'B'),
    Question(id: 22, categoryId: 3, questionText: 'Ikkinchi jahon urushi qachon tugagan?', optionA: '1945', optionB: '1939', optionC: '1918', optionD: '1965', correctOption: 'A'),
    Question(id: 23, categoryId: 3, questionText: 'Amir Temur qachon tugilgan?', optionA: '1336', optionB: '1405', optionC: '1441', optionD: '1370', correctOption: 'A'),

    // Kinolar (ID: 4)
    Question(id: 31, categoryId: 4, questionText: 'Titanik kinosida Jek rolini kim oynagan?', optionA: 'Bred Pitt', optionB: 'Jonni Depp', optionC: 'Leonardo Di Kaprio', optionD: 'Tom Kruz', correctOption: 'C'),
    Question(id: 32, categoryId: 4, questionText: '"Sherik" kinosida Mufasaning ukasi kim?', optionA: 'Skar', optionB: 'Zazu', optionC: 'Simba', optionD: 'Rafiki', correctOption: 'A'),
    Question(id: 33, categoryId: 4, questionText: 'Matritsa kinosida Neo qanday rangli dori ichadi?', optionA: 'Qizil', optionB: 'Kok', optionC: 'Yashil', optionD: 'Sariq', correctOption: 'A'),

    // Musiqa (ID: 5)
    Question(id: 41, categoryId: 5, questionText: 'Pop qiroli kim?', optionA: 'Elvis Presli', optionB: 'Maykl Jekson', optionC: 'Prins', optionD: 'Stivi Uonder', correctOption: 'B'),
    Question(id: 42, categoryId: 5, questionText: 'Gitara odatda nechta torga ega?', optionA: '4', optionB: '5', optionC: '6', optionD: '7', correctOption: 'C'),
    Question(id: 43, categoryId: 5, questionText: 'Qaysi asbob oq va qora tugmalarga ega?', optionA: 'Gitara', optionB: 'Pianino', optionC: 'Nogora', optionD: 'Skaypka', correctOption: 'B'),

    // Umumiy (ID: 6)
    Question(id: 51, categoryId: 6, questionText: 'Yerdagi eng katta okean qaysi?', optionA: 'Atlantika', optionB: 'Hind', optionC: 'Shimoliy Muz', optionD: 'Tinch', correctOption: 'D'),
    Question(id: 52, categoryId: 6, questionText: 'Dunyodagi eng baland tog?', optionA: 'K2', optionB: 'Everest', optionC: 'Kilimanjaro', optionD: 'Monblan', correctOption: 'B'),
    Question(id: 53, categoryId: 6, questionText: 'Dunyodagi eng uzun daryo qaysi?', optionA: 'Amazonka', optionB: 'Nil', optionC: 'Yantszi', optionD: 'Missisipi', correctOption: 'B'),
  ];

  // MOCK DATA for Questions
  List<Question> getQuestionsForCategory(int categoryId) {
    return _allQuestions.where((q) => q.categoryId == categoryId).toList();
  }

  // --- ADMIN METHODS --- //
  
  List<Question> getAllQuestions() {
    return _allQuestions.toList();
  }

  Future<void> addQuestion(Question q) async {
    _allQuestions.add(q);
    await _saveQuestions();
  }

  Future<void> deleteQuestion(int id) async {
    _allQuestions.removeWhere((q) => q.id == id);
    await _saveQuestions();
  }

  List<User> getAllUsers() {
    final usersJson = _prefs?.getString('users');
    if (usersJson == null) return [];
    
    Map<String, dynamic> usersMap = json.decode(usersJson);
    return usersMap.values.map((u) => User.fromMap(u)).toList();
  }
}
