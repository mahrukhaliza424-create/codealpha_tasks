import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';
import '../theme/app_theme.dart';
import '../services/gemini_service.dart';
import 'card_factory_screen.dart';

class StudyScreen extends StatefulWidget {
  final Deck deck;
  const StudyScreen({super.key, required this.deck});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showFront = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlashcardProvider>().loadCardsForDeck(widget.deck.id!);
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_showFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      _showFront = !_showFront;
    });
  }

  void _handleSwipe(bool isMastered, Flashcard card) {
    context.read<FlashcardProvider>().updateCardMastery(card, isMastered);
    setState(() {
      _currentIndex++;
      _showFront = true;
      _flipController.reset();
    });
  }

  void _showAIExplanation(String answer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.midnightPurple,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.glassDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    "AI Explanation",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<String>(
                future: GeminiService.explainConcept(answer),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
                  }
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent));
                  }
                  return Text(
                    snapshot.data ?? "",
                    style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashcardProvider>(
      builder: (context, provider, child) {
        final cards = provider.currentCards;
        final hasCards = cards.isNotEmpty && _currentIndex < cards.length;
        final currentCard = hasCards ? cards[_currentIndex] : null;

        return Scaffold(
          backgroundColor: AppTheme.midnightPurple,
          appBar: AppBar(
            title: Text(widget.deck.title, style: const TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              if (currentCard != null) ...[
                IconButton(
                  icon: const Icon(Icons.edit, color: AppTheme.primaryBlue),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => CardFactoryScreen(deckId: widget.deck.id, existingCard: currentCard),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _confirmDeleteCard(context, currentCard),
                ),
              ],
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => CardFactoryScreen(deckId: widget.deck.id),
                  );
                },
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
              : _buildBody(provider, cards),
        );
      },
    );
  }

  void _confirmDeleteCard(BuildContext context, Flashcard card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.midnightPurple,
        title: const Text("Delete Card", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to delete this flashcard?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<FlashcardProvider>().deleteCard(card.id!, widget.deck.id!);
              if (_currentIndex > 0) {
                setState(() => _currentIndex--); // Adjust index if deleting last card
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(FlashcardProvider provider, List<Flashcard> cards) {
    if (cards.isEmpty) {
            return const Center(
              child: Text("No cards in this deck yet.", style: TextStyle(color: Colors.white70)),
            );
          }

          if (_currentIndex >= cards.length) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 80, color: AppTheme.primaryGreen),
                  const SizedBox(height: 16),
                  const Text("You've reviewed all cards!", style: TextStyle(color: Colors.white, fontSize: 24)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0;
                        _showFront = true;
                        _flipController.reset();
                      });
                    },
                    child: const Text("Restart Deck", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          final currentCard = cards[_currentIndex];

          return Center(
            child: Dismissible(
              key: ValueKey(currentCard.id),
              onDismissed: (direction) {
                if (direction == DismissDirection.endToStart) {
                  // Swiped Left (Forgot)
                  _handleSwipe(false, currentCard);
                } else {
                  // Swiped Right (Mastered)
                  _handleSwipe(true, currentCard);
                }
              },
              background: _buildSwipeBackground(isLeft: false),
              secondaryBackground: _buildSwipeBackground(isLeft: true),
              child: GestureDetector(
                onTap: _toggleFlip,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final value = _flipAnimation.value;
                    final isUnder = value > 0.5;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(value * pi),
                      child: isUnder ? _buildCardBack(currentCard) : _buildCardFront(currentCard),
                    );
                  },
                ),
              ),
            ),
          );
  }

  Widget _buildSwipeBackground({required bool isLeft}) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isLeft ? Colors.redAccent.withOpacity(0.8) : AppTheme.primaryGreen.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isLeft ? Icons.close : Icons.check, color: Colors.white, size: 48),
          Text(isLeft ? "Needs Review" : "Mastered", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCardFront(Flashcard card) {
    return Container(
      width: 320,
      height: 480,
      margin: const EdgeInsets.all(24),
      decoration: AppTheme.cardGradientBorder.copyWith(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "QUESTION",
              style: TextStyle(color: Colors.white.withOpacity(0.6), letterSpacing: 2),
            ),
            const SizedBox(height: 24),
            Text(
              card.question,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Text("Tap to flip", style: TextStyle(color: Colors.white.withOpacity(0.4))),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(Flashcard card) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: Container(
        width: 320,
        height: 480,
        margin: const EdgeInsets.all(24),
        decoration: AppTheme.cardGradientBorder.copyWith(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryGreen, Color(0xFF064E3B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ANSWER",
                    style: TextStyle(color: Colors.white.withOpacity(0.6), letterSpacing: 2),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    card.answer,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: FloatingActionButton.extended(
                heroTag: 'ai_explain_btn',
                onPressed: () => _showAIExplanation(card.answer),
                backgroundColor: Colors.white,
                icon: const Icon(Icons.auto_awesome, color: AppTheme.primaryBlue),
                label: const Text("Explain", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
              ).animate().shimmer(duration: 2000.ms),
            ),
          ],
        ),
      ),
    );
  }
}
