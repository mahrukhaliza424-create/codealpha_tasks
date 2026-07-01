import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../models/flashcard.dart';
import '../theme/app_theme.dart';

class CardFactoryScreen extends StatefulWidget {
  final int? deckId;
  final Flashcard? existingCard;
  const CardFactoryScreen({super.key, this.deckId, this.existingCard});

  @override
  State<CardFactoryScreen> createState() => _CardFactoryScreenState();
}

class _CardFactoryScreenState extends State<CardFactoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _field1Controller = TextEditingController();
  final _field2Controller = TextEditingController();
  final _tagsController = TextEditingController();

  bool get _isDeck => widget.deckId == null && widget.existingCard == null;

  @override
  void initState() {
    super.initState();
    if (widget.existingCard != null) {
      _field1Controller.text = widget.existingCard!.question;
      _field2Controller.text = widget.existingCard!.answer;
    }
  }

  @override
  void dispose() {
    _field1Controller.dispose();
    _field2Controller.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (_isDeck) {
        context.read<FlashcardProvider>().addDeck(
          _field1Controller.text,
          _tagsController.text,
          0xFF10B981, // Defaulting to Green, could add color picker later
        );
        _showSuccess("Deck created successfully!");
      } else if (widget.existingCard != null) {
        context.read<FlashcardProvider>().updateCardContent(
          widget.existingCard!,
          _field1Controller.text,
          _field2Controller.text,
        );
        _showSuccess("Card updated successfully!");
      } else {
        context.read<FlashcardProvider>().addCard(
          widget.deckId!,
          _field1Controller.text,
          _field2Controller.text,
        );
        _showSuccess("Card safely saved to Deck!");
      }
      Navigator.pop(context);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isDeck ? "Create New Deck" : (widget.existingCard != null ? "Edit Card" : "Create New Card");
    final label1 = _isDeck ? "Deck Title" : "Question";
    final label2 = _isDeck ? "Description (Optional)" : "Answer";

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.midnightPurple,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(_field1Controller, label1, true),
              const SizedBox(height: 16),
              _buildTextField(_field2Controller, label2, !_isDeck),
              if (_isDeck) const SizedBox(height: 16),
              if (_isDeck) _buildTextField(_tagsController, "#Tags (e.g., #Math #Fun)", false),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _save,
                child: const Text("Save to Database", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool isRequired) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return "$label is required.";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
