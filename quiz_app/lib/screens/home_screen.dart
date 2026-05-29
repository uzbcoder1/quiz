import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'question_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onShopTap;

  const HomeScreen({super.key, this.onProfileTap, this.onShopTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    final user = db.currentUser;
    final categories = db.getCategories();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: widget.onProfileTap,
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.purple,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hey, ${user?.name ?? "Alex"}! 👋',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Level ${user?.level ?? 1}',
                              style: TextStyle(color: Colors.purple[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: widget.onShopTap,
                        child: _buildCurrencyBadge(Icons.monetization_on, '${user?.coins ?? 0}', Colors.orange),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: widget.onShopTap,
                        child: _buildCurrencyBadge(Icons.diamond, '${user?.diamonds ?? 0}', Colors.purple),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // Daily Challenge Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8A2BE2), Color(0xFFDA70D6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily Challenge', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Answer 10 questions', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: 1.0, // Let's say 10/10 done
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation(Colors.yellowAccent),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('10/10', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Categories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Quiz Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AllCategoriesScreen(categories: categories)));
                    },
                    child: const Text('See All >', style: TextStyle(color: Colors.grey)),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return GestureDetector(
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => QuestionScreen(category: cat)));
                      },
                      child: _buildCategoryCard(cat.name, '${cat.totalQuestions} Questions', _getIconFor(cat.iconName), _getColorFor(cat.iconName)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconFor(String iconName) {
    switch (iconName) {
      case 'sports_soccer': return Icons.sports_soccer;
      case 'science': return Icons.science;
      case 'account_balance': return Icons.account_balance;
      case 'movie': return Icons.movie;
      case 'music_note': return Icons.music_note;
      case 'help': return Icons.help;
      default: return Icons.category;
    }
  }

  Color _getColorFor(String iconName) {
     switch (iconName) {
      case 'sports_soccer': return Colors.green;
      case 'science': return Colors.purple;
      case 'account_balance': return Colors.orange;
      case 'movie': return Colors.black;
      case 'music_note': return Colors.red;
      case 'help': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Widget _buildCurrencyBadge(IconData icon, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          const Icon(Icons.add_circle, color: Colors.deepPurple, size: 16),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, IconData icon, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}

class AllCategoriesScreen extends StatelessWidget {
  final List<dynamic> categories;
  const AllCategoriesScreen({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Categories', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final cat = categories[index];
            return GestureDetector(
              onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => QuestionScreen(category: cat)));
              },
              child: _CategoryCard(
                title: cat.name,
                subtitle: '${cat.totalQuestions} Questions',
                icon: _getIconFor(cat.iconName),
                iconColor: _getColorFor(cat.iconName),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getIconFor(String iconName) {
    switch (iconName) {
      case 'sports_soccer': return Icons.sports_soccer;
      case 'science': return Icons.science;
      case 'account_balance': return Icons.account_balance;
      case 'movie': return Icons.movie;
      case 'music_note': return Icons.music_note;
      case 'help': return Icons.help;
      default: return Icons.category;
    }
  }

  Color _getColorFor(String iconName) {
     switch (iconName) {
      case 'sports_soccer': return Colors.green;
      case 'science': return Colors.purple;
      case 'account_balance': return Colors.orange;
      case 'movie': return Colors.black;
      case 'music_note': return Colors.red;
      case 'help': return Colors.blue;
      default: return Colors.grey;
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _CategoryCard({required this.title, required this.subtitle, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}
