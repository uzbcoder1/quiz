import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for leaderboard
    final List<Map<String, dynamic>> top3 = [
      {'name': 'Sarah', 'score': 4500, 'rank': 2, 'color': Colors.grey},
      {'name': 'Alex', 'score': 5200, 'rank': 1, 'color': Colors.orange},
      {'name': 'Mike', 'score': 4100, 'rank': 3, 'color': Colors.brown},
    ];

    final List<Map<String, dynamic>> remaining = List.generate(
      27,
      (index) => {'name': 'Player ${index + 4}', 'score': 4000 - (index * 100), 'rank': index + 4},
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Top 3 section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            height: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildTop3Avatar(top3[0], 40), // 2nd place
                _buildTop3Avatar(top3[1], 60), // 1st place (center, bigger)
                _buildTop3Avatar(top3[2], 40), // 3rd place
              ],
            ),
          ),
          const Divider(),
          // Ranks 4-30
          Expanded(
            child: ListView.builder(
              itemCount: remaining.length,
              itemBuilder: (context, index) {
                final user = remaining[index];
                final tile = ListTile(
                  leading: Text('#${user['rank']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text('${user['score']} pts', style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                );
                
                if (user['rank'] == 10) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      tile,
                      const Divider(thickness: 4, color: Colors.black26),
                    ],
                  );
                }
                
                return tile;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTop3Avatar(Map<String, dynamic> user, double radius) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (user['rank'] == 1) const Icon(Icons.star, color: Colors.orange, size: 40),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CircleAvatar(
              radius: radius,
              backgroundColor: user['color'],
              child: Icon(Icons.person, size: radius, color: Colors.white),
            ),
            Positioned(
              bottom: -10,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: Text('${user['rank']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            )
          ],
        ),
        const SizedBox(height: 15),
        Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text('${user['score']}', style: const TextStyle(color: Colors.purple)),
      ],
    );
  }
}
