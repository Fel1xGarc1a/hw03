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
      title: 'HW03 - Card Matching Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameProvider extends ChangeNotifier {
  List<CardItem> cards = [];
  bool canFlipCard = true;
  CardItem? firstCard;
  int matchedPairs = 0;
  bool isGameComplete = false;

  GameProvider() {
    initializeCards();
  }

  void initializeCards() {
    const numberOfPairs = 8;
    cards = [];
    matchedPairs = 0;
    isGameComplete = false;
    
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
      
      if (matchedPairs == cards.length ~/ 2) {
        isGameComplete = true;
      }
      
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

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game'),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Column(
            children: [
              if (gameProvider.isGameComplete)
                const Center(
                  child: Text(
                    'You Won!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          'https://deckofcardsapi.com/static/img/back.png',
          fit: BoxFit.cover,
        ),
      ),
    );
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
            child: angle < 1.57
                ? _buildCardBack()
                : Container(
                    decoration: BoxDecoration(
                      color: widget.card.isMatched
                          ? Colors.green.shade100
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Center(
                      child: Transform(
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
