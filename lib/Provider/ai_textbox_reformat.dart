import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:woodproposals/Widgets/widgets.dart';

/// URL for the n8n workflow that provides AI suggestions.
final String _aiSuggestionUrl = 'https://aiserver.global.amec.com/webhook/3e3a032f-6fc8-4cd4-88ff-63453c6366c0';

class AITextboxReformat with ChangeNotifier {

  List<int> applicableLessonsLearnedIDs = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Posts a prompt to the n8n workflow to get a chat response.
  ///
  /// Returns the suggested text as a [String], or `null` if an error occurs.
  Future<String?> getChatResponse({
    required String prompt,
    required String chatSessionID,
    required BuildContext context,
  }) async {
    _setLoading(true);
    // Clear previous applicable IDs at the start of a new request.
    applicableLessonsLearnedIDs.clear();

    try {
      final response = await http.post(
        Uri.parse(_aiSuggestionUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({'prompt': prompt, 'chatSessionID': chatSessionID}),
      );

      if (response.statusCode == 200) {
        try {
          final dynamic decodedData = json.decode(response.body);
          dynamic actualData = decodedData;

          // The AI sometimes wraps the JSON list in an 'output' string.
          // We need to handle this by decoding the inner string.
          if (decodedData is Map<String, dynamic> && decodedData.containsKey('output')) {
            final outputValue = decodedData['output'];
            if (outputValue is String) {
              actualData = json.decode(outputValue);
            }
          }

          // Handle the new format: `[{"output": "...", "applicableLessonsLearned": [...]}]`
          if (actualData is List && actualData.isNotEmpty) {
            final firstItem = actualData.first;
            if (firstItem is Map<String, dynamic>) {
              final output = firstItem['output'] as String?;
              final lessons = firstItem['applicableLessonsLearned'] as List?;

              if (lessons != null) {
                // Parse lesson IDs from string to int, ignoring any that fail.
                applicableLessonsLearnedIDs = lessons
                    .map((id) => int.tryParse(id.toString()))
                    .whereType<int>()
                    .toList();
              }
              return output;
            }
          }

          // If the new format is not found, show an error.
          debugPrint('Could not find suggestion in response: ${response.body}');
          snackbar(context: context, header: 'AI suggestion format is unexpected.');
        } catch (e) {
          debugPrint('Error parsing AI suggestion response: $e\nResponse body: ${response.body}');
          snackbar(context: context, header: 'Received an unexpected response from the AI service.');
        }
      } else {
        debugPrint('AI suggestion failed with status ${response.statusCode}: ${response.body}');
        snackbar(context: context, header: 'AI suggestion service returned an error.');
      }
    } catch (e, stackTrace) {
      // Log the actual error to the console for easier debugging.
      debugPrint('An error occurred while getting AI suggestion: $e');
      debugPrint('Stack trace: $stackTrace');
      snackbar(context: context, header: 'An error occurred while getting AI suggestion. Check the console for details.');
    } finally {
      _setLoading(false);
    }
    return null;
  }
}