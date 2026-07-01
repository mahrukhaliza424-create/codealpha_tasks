import 'package:flutter/foundation.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../services/database_service.dart';

class FlashcardProvider with ChangeNotifier {
  List<Deck> _decks = [];
  List<Flashcard> _currentCards = [];
  bool _isLoading = false;

  List<Deck> get decks => _decks;
  List<Flashcard> get currentCards => _currentCards;
  bool get isLoading => _isLoading;
  int? _currentUserId;

  void loadDecksForUser(int userId) {
    _currentUserId = userId;
    loadDecks();
  }

  Future<void> loadDecks() async {
    if (_currentUserId == null) return;
    _isLoading = true;
    notifyListeners();

    _decks = await DatabaseService.instance.readAllDecks(_currentUserId!);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addDeck(String title, String tags, int colorCode) async {
    if (_currentUserId == null) return;
    final newDeck = Deck(title: title, tags: tags, colorCode: colorCode);
    await DatabaseService.instance.createDeck(newDeck, _currentUserId!);
    await loadDecks();
  }

  Future<void> deleteDeck(int id) async {
    await DatabaseService.instance.deleteDeck(id);
    await loadDecks();
  }

  Future<void> loadCardsForDeck(int deckId) async {
    _isLoading = true;
    notifyListeners();

    _currentCards = await DatabaseService.instance.readCardsForDeck(deckId);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCard(int deckId, String question, String answer) async {
    final newCard = Flashcard(deckId: deckId, question: question, answer: answer);
    await DatabaseService.instance.createFlashcard(newCard);
    await loadCardsForDeck(deckId);
  }

  Future<void> updateCardContent(Flashcard card, String newQuestion, String newAnswer) async {
    final updatedCard = Flashcard(
      id: card.id,
      deckId: card.deckId,
      question: newQuestion,
      answer: newAnswer,
      isMastered: card.isMastered,
    );
    await DatabaseService.instance.updateFlashcard(updatedCard);
    await loadCardsForDeck(card.deckId);
  }

  Future<void> updateCardMastery(Flashcard card, bool isMastered) async {
    final updatedCard = Flashcard(
      id: card.id,
      deckId: card.deckId,
      question: card.question,
      answer: card.answer,
      isMastered: isMastered,
    );
    await DatabaseService.instance.updateFlashcard(updatedCard);
    await loadCardsForDeck(card.deckId);
  }

  Future<void> deleteCard(int id, int deckId) async {
    await DatabaseService.instance.deleteFlashcard(id);
    await loadCardsForDeck(deckId);
  }
}
