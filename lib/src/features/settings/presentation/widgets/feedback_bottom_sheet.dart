import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investr/l10n/app_localizations.dart';

import '../../../../shared/widgets/investr_button.dart';
import '../../../../shared/widgets/investr_snackbar.dart';
import '../../data/feedback_repository.dart';
import '../../domain/feedback_model.dart';

class FeedbackBottomSheet extends StatefulWidget {
  final String? title;

  const FeedbackBottomSheet({super.key, this.title});

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> {
  final _contentController = TextEditingController();
  final _emailController = TextEditingController();
  final _repository = FeedbackRepository();
  bool _isSubmitting = false;
  String? _errorMessage;

  void _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      final feedback = FeedbackModel(
        content: content,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        timestamp: DateTime.now(),
      );

      await _repository.submitFeedback(feedback);

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        InvestrSnackBar.show(context, l10n.feedbackThanks);
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Error sending feedback: $e');
        setState(() {
          _errorMessage = l10n.feedbackError;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                widget.title ?? l10n.feedbackTitle,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.feedbackOptionalEmail,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                isDense: true,
                filled: true,
                //fillColor: Theme.of(context).cardTheme.color,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: l10n.feedbackHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                //fillColor: Theme.of(context).cardTheme.color,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            InvestrButton(
              text: l10n.submitFeedback,
              onPressed: _isSubmitting ? null : _submit,
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
