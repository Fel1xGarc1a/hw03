import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<CardItem> cards;
  
  @override
  void initState() {
    super.initState();
    initializeCards();
  }

  void initializeCards() {
    const numberOfPairs = 8;
    cards = [];
    
    for (var i = 0; i < numberOfPairs; i++) {
      cards.add(CardItem(id: i, value: i));
      cards.add(CardItem(id: i + numberOfPairs, value: i));
    }
    
    cards.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Matching Game'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            return GameCard(
              card: cards[index],
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}

class CardItem {
  final int id;
  final int value;
  bool isFlipped;
  bool isMatched;

  CardItem({
    required this.id,
    required this.value,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class GameCard extends StatelessWidget {
  final CardItem card;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: card.isFlipped ? Colors.white : Colors.blue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: card.isFlipped
              ? Text(
                  card.value.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
