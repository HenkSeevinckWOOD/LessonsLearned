import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../LocalStorage/localstorage.dart';

class Projectprovider with ChangeNotifier {
  //--------------------------------------------------------------
  // Fetch all Projects
  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> get projects => _projects;

  Future fetchProjects({bool notify = true}) async {

    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/api/Project/ProjectStatistics/AllProjects?eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as List;
        _projects = List<Map<String, dynamic>>.from(data);
        if (notify) {
          notifyListeners();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  //--------------------------------------------------------------------------
  //Update Project
  Future<void> updateProject(Map<String, dynamic> projectData) async {
    var projectID = projectData['fld_ID'];

    // Helper function to convert DateTime objects to ISO8601 strings for JSON.
    Object? toEncodable(Object? object) {
      if (object is DateTime) {
        // Format the DateTime to "YYYY-MM-DD" string as expected by the API.
        return object.toIso8601String().split('T')[0];
      }
      return object;
    }

    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/api/Project/ProjectID?projectID=$projectID&eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}');
    try {
      final response = await http.put(
        url,
        body: json.encode(projectData, toEncodable: toEncodable),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'}
      );
      if (response.statusCode == 204) {
        // On success, update all local copies of the project data to ensure consistency.
        _selectedProject = Map<String, dynamic>.from(projectData);
        _editableProject = Map<String, dynamic>.from(projectData);
        // Also update the project in the main list.
        final index = _projects.indexWhere((p) => p['fld_ID'] == projectID);
        if (index != -1) {
          _projects[index] = _selectedProject!;
        }
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  //--------------------------------------------------------------------------
  //Selected Project
  Map<String, dynamic>? _selectedProject; // This holds the original, unmodified project data
  Map<String, dynamic>? get selectedProject => _selectedProject;

  Map<String, dynamic>? _editableProject; // This is a deep copy for the UI to modify
  Map<String, dynamic>? get editableProject => _editableProject;

  void setCurrentProject(Map<String, dynamic>? project) {
    if (project == null) {
      _selectedProject = null;
      _editableProject = null;
    } else {
      // Create a deep copy for editing.
      final Map<String, dynamic> projectCopy = Map<String, dynamic>.from(project);

      // Parse date strings into DateTime objects.
      // This ensures the rest of the app works with consistent data types.
      if (projectCopy['projectStartDate'] is String) {
        projectCopy['projectStartDate'] = DateTime.tryParse(projectCopy['projectStartDate']);
      }
      if (projectCopy['projectEndDate'] is String) {
        projectCopy['projectEndDate'] = DateTime.tryParse(projectCopy['projectEndDate']);
      }
      _selectedProject = projectCopy;
      _editableProject = Map<String, dynamic>.from(projectCopy); // Make another copy for editing
    }
    notifyListeners();
  }

  /// Resets the editable project to its original state, discarding any changes.
  void resetEditableProject() {
    if (_selectedProject != null) {
      _editableProject = Map<String, dynamic>.from(_selectedProject!);
    } else {
      _editableProject = null;
    }
    notifyListeners();
  }
}
