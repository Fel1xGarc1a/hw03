import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: const MyApp(),
    ),
  );
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

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Matching Game'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Matches: ${gameProvider.matchedPairs}',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: gameProvider.cards.length,
                    itemBuilder: (context, index) {
                      return GameCard(
                        card: gameProvider.cards[index],
                        onTap: () => gameProvider.flipCard(index),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
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
          color: card.isMatched 
              ? Colors.green.shade100
              : card.isFlipped 
                  ? Colors.white 
                  : Colors.blue,
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

// Simple state management class
class GameProvider extends ChangeNotifier {
  List<CardItem> cards = [];
  bool canFlipCard = true;
  CardItem? firstCard;
  int matchedPairs = 0;

  GameProvider() {
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
    notifyListeners();
  }

  void flipCard(int index) {
    if (!canFlipCard || cards[index].isFlipped || cards[index].isMatched) return;

    cards[index].isFlipped = true;
    
    if (firstCard == null) {
      firstCard = cards[index];
    } else {
      checkMatch(cards[index]);
    }
    
    notifyListeners();
  }

  void checkMatch(CardItem secondCard) {
    canFlipCard = false;

    if (firstCard!.value == secondCard.value) {
      firstCard!.isMatched = true;
      secondCard.isMatched = true;
      matchedPairs++;
      resetTurn();
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        firstCard!.isFlipped = false;
        secondCard.isFlipped = false;
        resetTurn();
      });
    }
  }

  void resetTurn() {
    firstCard = null;
    canFlipCard = true;
    notifyListeners();
  }
}
