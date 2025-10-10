import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:woodproposals/LocalStorage/localstorage.dart';
import 'package:woodproposals/Provider/formstate_management.dart';
import 'package:woodproposals/Provider/project_provider.dart';

class LessonsLearnedProvider with ChangeNotifier {
  // Cancellation support
  bool _isCancelled = false;
  
  void cancelOperations() {
    _isCancelled = true;
  }
  
  void resetCancellation() {
    _isCancelled = false;
  }
  //--------------------------------------------------------------
  // Fetch all Lessons Learned
  List<Map<String, dynamic>> _lessonsLearned = [];
  List<Map<String, dynamic>> get lessonsLearned => _lessonsLearned;

  List<Map<String, dynamic>> _editableLessonsLearned = [];
  List<Map<String, dynamic>> get editableLessonsLearned => _editableLessonsLearned;

  Future<void> fetchLessonsLearned({bool notify = true}) async {

    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/lessonslearned/Lessons/GetAllLessonsLearned?eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        _lessonsLearned = List<Map<String, dynamic>>.from(data).toList();
        _editableLessonsLearned = List<Map<String, dynamic>>.from(_lessonsLearned);
        if (notify) {
          notifyListeners();
        }
      }
    } catch (e) {
      rethrow;
      }
    }
   
//--------------------------------------------------------------------------------------
// Add Lessons Learned
  Future<void> addLessonsLearned(Map<String, dynamic> newLessonsLearned, Projectprovider projectProvider, AppInfo applicationInfo, {bool notify = true, BuildContext? context}) async {
    // Create a mutable copy of the payload to modify it before sending.
    final Map<String, dynamic> payload = Map.from(newLessonsLearned);

    payload['dateRaised'] = (payload['dateRaised'] as String).split('T')[0];

    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/lessonslearned/Lessons/CreateNewLesson?eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}');

    try {
      final response = await http.post(
        url,
        body: json.encode(payload),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'}
      );
      
      // Check if widget is still mounted after async operation (if context is provided)
      if (context != null && !context.mounted) {
        debugPrint('Widget unmounted during lesson creation, aborting');
        return;
      }
      
      if (response.statusCode == 201) {
        // The API returns the newly created object, including its new ID.
        final createdLessonsLearned = json.decode(response.body) as Map<String, dynamic>;

         // Add the new "clean" record to the main project disciplines list.
        _lessonsLearned.add(createdLessonsLearned);
        _editableLessonsLearned.add(createdLessonsLearned);
        await _uploadLessonsLearnedToVectorStore(createdLessonsLearned, projectProvider, applicationInfo, 'new');
        
        // FIX: Uncomment and fix the notifyListeners call
        if (notify) {
          notifyListeners();
        }
      } else {
        //print(response.body);
        throw Exception('Failed to create the lesson learned');
      }
    } catch (e) {
      print(e);
      rethrow;
      }
    }

//--------------------------------------------------------------------------------------
// Add Bulk Lessons Learned from Excel Upload with Progress Callback
  Future<void> addBulkLessonsLearnedWithProgress(
    List<Map<String, dynamic>> lessons, 
    Projectprovider projectProvider, 
    AppInfo applicationInfo, 
    BuildContext context,
    {Function(int current, int total)? onProgress}
  ) async {
    // Reset cancellation state at the start
    resetCancellation();
    
    int successCount = 0;
    
    for (int i = 0; i < lessons.length; i++) {
      final lesson = lessons[i];
      
      // Update progress
      if (onProgress != null) {
        onProgress(i + 1, lessons.length);
      }
      
      // Check for cancellation or unmounted widget
      if (_isCancelled) {
        debugPrint('Operation cancelled during bulk upload, stopping at lesson ${i + 1}');
        throw Exception('Upload cancelled by user');
      }
      
      if (!context.mounted) {
        debugPrint('Widget unmounted during bulk upload, stopping at lesson ${i + 1}');
        throw Exception('Upload interrupted - widget was closed');
      }
      
      try {
        final newLesson = {
          ...lesson,
          'projectID': projectProvider.selectedProject?['fld_ID'],
          'dateRaised': DateTime.now().toIso8601String(),
        };
        await addLessonsLearned(newLesson, projectProvider, applicationInfo, notify: false, context: context);
        successCount++;
        debugPrint('Successfully uploaded lesson ${i + 1} of ${lessons.length}');
      } catch (e) {
        debugPrint('Failed to upload lesson ${i + 1}: $e');
        // Continue with next lesson instead of stopping the entire process
        continue;
      }
    }
    
    // Final check before notifying listeners
    if (!_isCancelled && context.mounted) {
      notifyListeners();
      debugPrint('Bulk upload completed: $successCount of ${lessons.length} lessons uploaded successfully');
    }
  }

//--------------------------------------------------------------------------------------
// Add Bulk Lessons Learned from Excel Upload
  Future<void> addBulkLessonsLearned(List<Map<String, dynamic>> lessons, Projectprovider projectProvider, AppInfo applicationInfo, BuildContext context) async {
    return addBulkLessonsLearnedWithProgress(lessons, projectProvider, applicationInfo, context);
  }
  
//--------------------------------------------------------------------------------------
// Edit Lessons Learned
  Future<void> editLessonsLearned(
  Map<String, dynamic> updatedLessonsLearned, 
  Projectprovider projectProvider, 
  AppInfo applicationInfo, 
  {bool notify = true, bool uploadToVectorStore = true}  // Add this parameter
) async {

  final int lessonID = updatedLessonsLearned['lessonID'];
  final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/lessonslearned/Lessons/UpdateLesson?eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}');

  // Create a copy to avoid modifying the original map passed to the function.
  final Map<String, dynamic> payload = Map.from(updatedLessonsLearned);

  // 1. Add the missing 'lesson' field. We can use the title for this.
  payload['lesson'] = payload['lessonTitle'];

  // 2. Correctly format the 'dateRaised' field to "YYYY-MM-DD".
  if (payload['dateRaised'] is String) {
    payload['dateRaised'] = (payload['dateRaised'] as String).split('T')[0];
  }

  try {
    final response = await http.put(
      url,
      body: json.encode(payload),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'}
    );

    // A 204 "No Content" response is a success for an update operation.
    if (response.statusCode == 204) {
      // The API call was successful. Update the local state with the data we sent.
      final index = _lessonsLearned.indexWhere((lesson) => lesson['lessonID'] == lessonID);
      if (index != -1) {
        _lessonsLearned[index] = updatedLessonsLearned; // Use the original updated map for UI consistency
      }

      final editableIndex = _editableLessonsLearned.indexWhere((lesson) => lesson['lessonID'] == lessonID);
      if (editableIndex != -1) {
        _editableLessonsLearned[editableIndex] = updatedLessonsLearned;
      }

      // FIX: Only upload to vector store if explicitly requested (prevents recursion)
      if (uploadToVectorStore) {
        await _uploadLessonsLearnedToVectorStore(updatedLessonsLearned, projectProvider, applicationInfo, 'update');
      }
      
      if (notify) {
        notifyListeners();
      }
    } else {
      throw Exception('Failed to update the lesson learned');
    }
  } catch (e) {
    rethrow;
    }
    }

//--------------------------------------------------------------------------------------
// Delete Lessons Learned
  Future<void> deleteLessonsLearned(Map<String, dynamic> deletedLessonsLearned, Projectprovider projectProvider, AppInfo applicationInfo, {bool notify = true}) async {

    final int lessonID = deletedLessonsLearned['lessonID'];
    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/lessonslearned/Lessons/DeleteLesson?eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}&lessonID=$lessonID');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 204) {
        // Successfully deleted on the server, now remove from local state.
        _lessonsLearned.removeWhere((lesson) => lesson['lessonID'] == lessonID);
        _editableLessonsLearned.removeWhere((lesson) => lesson['lessonID'] == lessonID);
        await _uploadLessonsLearnedToVectorStore(deletedLessonsLearned, projectProvider, applicationInfo, 'delete');
        if (notify) {
          notifyListeners();
        }
      } else {
        throw Exception('Failed to delete the lesson learned');
      }
    } catch (e) {
      rethrow;
      }
    }

//--------------------------------------------------------------------------------------
// Upload Lessons Learned to Vector Store  
Future<void> _uploadLessonsLearnedToVectorStore(Map<String, dynamic> lessonData, Projectprovider projectProvider, AppInfo applicationInfo, String lessonstatus) async {
  final String projectNo = projectProvider.selectedProject?['fld_ProjectNo'] ?? '';
  final String projectName = projectProvider.selectedProject?['fld_ProjectDescription'] ?? '';
  final int applicationID = applicationInfo.appInfo['applicationID'] ?? 0;
  final int lessonID = lessonData['lessonID'];
  final String lessonText = _formatLessonForVectorStore(lessonData, projectNo);
  final String status = lessonstatus;

  final url = Uri.parse('https://aiserver.global.amec.com/webhook/8156096b-2f55-4ac7-909e-b2b1c74fc366'); //Production
  
  try {
    // Log the lesson text being sent for debugging
    debugPrint('Sending lesson to vector store:');
    debugPrint('LessonID: $lessonID');
    debugPrint('Status: $status');
    debugPrint('Lesson Text Length: ${lessonText.length}');
    debugPrint('Lesson Text Preview: ${lessonText.substring(0, lessonText.length > 200 ? 200 : lessonText.length)}...');
    
    // FIX: Use regular JSON POST instead of MultipartRequest
    final Map<String, dynamic> requestBody = {
      'projectNo': projectNo,
      'applicationID': applicationID,
      'lesson': lessonText,
      'lessonID': lessonID,
      'status': status,
      'projectName': projectName,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',  // Explicit JSON content type
        'Accept': 'application/json',
      },
      body: json.encode(requestBody),
    );

    debugPrint('Vector store response: ${response.statusCode}');
    debugPrint('Vector store response body: ${response.body}');

    if (response.statusCode == 200) {
      // Success! n8n received the webhook.
      debugPrint('Vector store webhook accepted for lessonID: $lessonID');
      
      // Note: We mark as synced when webhook is accepted, not when processing completes
      // This is because n8n doesn't provide real-time feedback on processing success
      Map<String, dynamic> updatedLessonData = Map.from(lessonData);
      updatedLessonData['syncedWithVectorStore'] = true;
      
      // FIX: Prevent recursion by setting uploadToVectorStore to false
      await editLessonsLearned(updatedLessonData, projectProvider, applicationInfo, notify: false, uploadToVectorStore: false);
      
      debugPrint('Successfully updated sync status to true for lessonID: $lessonID');
      
    } else {
      debugPrint('Vector store webhook rejected. Status: ${response.statusCode}, Body: ${response.body}');
      
      // Update sync status to false for rejected uploads
      Map<String, dynamic> updatedLessonData = Map.from(lessonData);
      updatedLessonData['syncedWithVectorStore'] = false;
      
      // FIX: Prevent recursion by setting uploadToVectorStore to false
      await editLessonsLearned(updatedLessonData, projectProvider, applicationInfo, notify: false, uploadToVectorStore: false);
      
      debugPrint('Updated sync status to false for lessonID: $lessonID due to webhook rejection');
    }
  } catch (e) {
    debugPrint('Error sending document to vector store: $e');
    
    // Update sync status to false for failed uploads
    try {
      Map<String, dynamic> updatedLessonData = Map.from(lessonData);
      updatedLessonData['syncedWithVectorStore'] = false;
      
      // FIX: Prevent recursion by setting uploadToVectorStore to false
      await editLessonsLearned(updatedLessonData, projectProvider, applicationInfo, notify: false, uploadToVectorStore: false);
      
      debugPrint('Updated sync status to false for lessonID: $lessonID due to exception');
    } catch (updateError) {
      debugPrint('Failed to update sync status after vector store error: $updateError');
    }
    
    // Don't rethrow for vector store errors - they shouldn't block the main operation
  }
}

  //--------------------------------------------------------------------------------------
  // Format Lesson for Vector Store
  String _formatLessonForVectorStore(Map<String, dynamic> lesson, String projectNo) {
    final title = lesson['lessonTitle']?.toString().trim() ?? '';
    final event = _cleanText(lesson['event']?.toString() ?? '');
    final outcome = _cleanText(lesson['outcome']?.toString() ?? '');
    final learning = _cleanText(lesson['whatIsTheLearning']?.toString() ?? '');
    final costSavings = lesson['costSavings']?.toString().trim() ?? '';
    final type = lesson['type']; // 1 for positive, 2 for negative

    String costSavingsStatement = (costSavings.isNotEmpty && costSavings != "\$0")
        ? " This resulted in cost savings of $costSavings."
        : "";

    if (type == 1) { // Best Practice
      return "PROJECT: $projectNo | TITLE: $title | TYPE: Best Practice | "
             "EVENT: $event | "
             "OUTCOME: $outcome$costSavingsStatement | "
             "LEARNING: $learning";
    } else { // Lesson Learned from a challenge
      return "PROJECT: $projectNo | TITLE: $title | TYPE: Challenge Lesson | "
             "EVENT: $event | "
             "OUTCOME: $outcome | "
             "LEARNING: $learning";
    }
  }

  //--------------------------------------------------------------------------------------
  // Helper method to clean text for vector store
  String _cleanText(String text) {
    return text
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ')  // Replace multiple whitespace with single space
      .replaceAll(RegExp(r'\n+'), '. ') // Replace newlines with periods and space
      .replaceAll(RegExp(r'\.+'), '.') // Replace multiple periods with single period
      .replaceAll(RegExp(r'\s*\.\s*'), '. ') // Normalize period spacing
      .trim();
  }
}