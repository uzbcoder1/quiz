import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: Colors.purple[50],
                 borderRadius: BorderRadius.circular(15),
               ),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   const Text('Your Diamonds:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   Row(
                     children: const [
                       Icon(Icons.diamond, color: Colors.purple),
                       SizedBox(width: 5),
                       Text('120', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
                     ],
                   )
                 ],
               ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  const Text('Buy Diamonds', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildDiamondPack('100 Diamonds', '\$0.99', 100),
                  _buildDiamondPack('500 Diamonds', '\$3.99', 500),
                  _buildDiamondPack('1200 Diamonds', '\$8.99', 1200),
                  const SizedBox(height: 30),
                  const Text('Power-ups', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildShopItem('Extra Time (+10s)', 'Use in game', 50, Icons.timer),
                  _buildShopItem('50/50 Helper', 'Removes 2 wrong options', 100, Icons.exposure_minus_2),
                  _buildShopItem('Audience Help', 'Ask the audience', 150, Icons.people),
                  _buildShopItem('Skip Question', 'Skip a hard question', 200, Icons.next_plan),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildShopItem(String title, String subtitle, int price, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.orange),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
            icon: const Icon(Icons.diamond, size: 16),
            label: Text('$price'),
          )
        ],
      ),
    );
  }

  Widget _buildDiamondPack(String title, String price, int amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.diamond, color: Colors.purple),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: Text(price),
          )
        ],
      ),
    );
  }
}
