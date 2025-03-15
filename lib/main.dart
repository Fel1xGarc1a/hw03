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
                      return FlipCard(
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

// Add this new class for the flip animation
class FlipCard extends StatefulWidget {
  final CardItem card;
  final VoidCallback onTap;

  const FlipCard({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isFlipped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.14;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: widget.card.isMatched
                    ? Colors.green.shade100
                    : angle < 1.57 
                        ? Colors.blue
                        : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Center(
                child: angle < 1.57
                    ? null
                    : Transform(
                        transform: Matrix4.identity()..rotateY(3.14),
                        alignment: Alignment.center,
                        child: Text(
                          widget.card.value.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
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
