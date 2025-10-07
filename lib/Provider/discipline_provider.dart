import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../LocalStorage/localstorage.dart';

class DisciplineProvider with ChangeNotifier {
  List<Map<String, dynamic>> _disciplines = [];
  List<Map<String, dynamic>> get disciplines => _disciplines;

  List<Map<String, dynamic>> _homeDisciplines = [];
  List<Map<String, dynamic>> get homeDisciplines => _homeDisciplines;

  List<Map<String, dynamic>> _siteDisciplines = [];
  List<Map<String, dynamic>> get siteDisciplines => _siteDisciplines;

//--------------------------------------------------------------------------------------
//Get Disciplines

  Future<void> fetchDisciplines() async {
    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/disciplines/GetDisciplines?eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Parse all disciplines from the response
        _disciplines = List<Map<String, dynamic>>.from(json.decode(response.body));

        // Split into home and site disciplines
        _homeDisciplines = _disciplines
            .where((disc) => int.tryParse(disc['costCode'])! >= 8000 && int.tryParse(disc['costCode'])! <= 9000)
            .map((disp) => {...disp, 'type': 'home'})
            .toList();
        _siteDisciplines = _disciplines
            .where((disc) => int.tryParse(disc['costCode'])! >= 6000 && int.tryParse(disc['costCode'])! <= 7000)
            .map((disp) => {...disp, 'type': 'site'})
            .toList();

        // Merge home and site back into _disciplines with type
        _disciplines = [
          ..._homeDisciplines,
          ..._siteDisciplines,
        ];

        notifyListeners();
      } else {
        throw Exception('Failed to load disciplines');
      }
    } catch (e) {
      rethrow;
    }
  }

//--------------------------------------------------------------------------------------
//Get Project Disciplines

  List<Map<String, dynamic>> _projectDisciplines = [];
  List<Map<String, dynamic>> get projectDisciplines => _projectDisciplines;

  List<Map<String, dynamic>>? _editableProjectDisciplines; // This is a deep copy for the UI to modify
  List<Map<String, dynamic>>? get editableProjectDisciplines => _editableProjectDisciplines;

  Future<void> fetchProjectDisciplines(int projectID) async {
    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/proposals/disciplines/GetDisciplinesByProjectID?projectID=$projectID&eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as List;
        _projectDisciplines = data.map<Map<String, dynamic>>((projDisc) {
          final Map<String, dynamic> projDiscMap = Map<String, dynamic>.from(projDisc as Map);
          
          // Find the matching discipline from the main disciplines list to enrich the data.
          final disciplineDetails = _disciplines.firstWhere(
            (disc) => disc['disciplineID'] == projDiscMap['disciplineID'],
            orElse: () => <String, dynamic>{}, // Return an empty map if no match is found to prevent errors.
          );
          // Combine the data from both sources.
          return {
            ...projDiscMap,
            'type': disciplineDetails['type'],
            'costCode': disciplineDetails['costCode'],
            'disciplineDescription': disciplineDetails['disciplineDescription'] ?? 'Unknown Discipline',
          };
        }).toList();

        // Create editable copies for the UI to modify.
        _editableProjectDisciplines = List<Map<String, dynamic>>.from(_projectDisciplines);

        notifyListeners();
      } else {
        throw Exception('Failed to load WBS items');
      }
    } catch (e) {
      rethrow;
    }
  }

//--------------------------------------------------------------------------------------
//Manage Disciplines
Future<void> manageDisciplines(List<Map<String, dynamic>> disciplines) async {
  // Iterate over a copy of the list to avoid concurrent modification errors.
  for (var discipline in List.from(disciplines)) {
    if (discipline['isDirty'] == true && discipline['projectDisciplineID'] == null) {
      addDiscipline(discipline);
    }
  }
}

//--------------------------------------------------------------------------------------
//Add Discipline
  Future<void> addDiscipline(Map<String, dynamic> newDiscipline) async {
    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/proposals/disciplines/CreateNewDiscipline?eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}');

    try {
      final response = await http.post(
        url,
        body: json.encode(newDiscipline),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'}
      );
      if (response.statusCode == 201) {
        // The API returns the newly created object, including its new ID.
        final createdDiscipline = json.decode(response.body) as Map<String, dynamic>;

         // Add the new "clean" record to the main project disciplines list.
        _projectDisciplines.add(createdDiscipline);

        // Find the original "dirty" record in the editable list and replace it with the clean one.
        final index = _editableProjectDisciplines?.indexWhere((discipline) => discipline['disciplineID'] == newDiscipline['disciplineID'] && discipline['projectDisciplineID'] == null) ?? -1;
        if (index != -1) {
            _editableProjectDisciplines?[index] = {
            ...createdDiscipline,
            'type': newDiscipline['type'], // preserve the type for UI
            };
        }

        notifyListeners();
      } else {
        throw Exception('Failed to create discipline');
      }
    } catch (e) {
      rethrow;
    }
  }

//--------------------------------------------------------------------------------------
//Delete Discipline
  Future<void> deleteDiscipline(Map<String, dynamic> deletedDiscipline) async {
    var projectDisciplineID = deletedDiscipline['projectDisciplineID'];
    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/proposals/disciplines/DeleteDiscipline?projectDisciplineID=$projectDisciplineID&eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}');

    try {
      final response = await http.delete(
        url,
        body: json.encode(deletedDiscipline),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'}
      );
      if (response.statusCode == 204) {
        // On success, remove the discipline from the local list.
        _disciplines.removeWhere((item) => item['projectDisciplineID'] == deletedDiscipline['projectDisciplineID']);
        notifyListeners();
      } else {
        throw Exception('Failed to delete discipline');
      }
    } catch (e) {
      rethrow;
    }
  }

//--------------------------------------------------------------------------------------
// Reset selected Project Discipline
  void resetSelectedProjectDiscipline() {
    _selectedProjectDiscipline = {};
    notifyListeners();
  }

//--------------------------------------------------------------------------------------
// Select Project Discipline
  Map<String, dynamic> _selectedProjectDiscipline = {};
  Map<String, dynamic> get selectedProjectDiscipline => _selectedProjectDiscipline;

  void selectProjectDiscipline(Map<String, dynamic> discipline) {
    _selectedProjectDiscipline = discipline;
    notifyListeners();
  }

//--------------------------------------------------------------------------------------
// Select Organization Discipline
  Map<String, dynamic> _selectedOrganizationDiscipline = {};
  Map<String, dynamic> get selectedOrganizationDiscipline => _selectedOrganizationDiscipline;

  void selectOrganizationDiscipline(Map<String, dynamic> discipline) {
    _selectedOrganizationDiscipline = discipline;
    notifyListeners();
  }

//--------------------------------------------------------------------------------------
// Reset selected Organization Discipline
  void resetSelectedOrganizationDiscipline() {
    _selectedOrganizationDiscipline = {};
    notifyListeners();
  }
}