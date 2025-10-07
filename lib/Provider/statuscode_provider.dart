import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../LocalStorage/localstorage.dart';
import 'SubFunctions/userkeyexpired.dart';
import '../Widgets/widgets.dart';

class CodeListsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _allCodeLists = [];
  List<Map<String, dynamic>> get allCodeLists => _allCodeLists;
  List<Map<String, dynamic>> _projectPhase = [];
  List<Map<String, dynamic>> get projectPhase => _projectPhase;
  List<Map<String, dynamic>> _contractingStrategy = [];
  List<Map<String, dynamic>> get contractingStrategy => _contractingStrategy;
  List<Map<String, dynamic>> _packageType = [];
  List<Map<String, dynamic>> get packageType => _packageType;
  List<Map<String, dynamic>> _proposalReturnables = [];
  List<Map<String, dynamic>> get proposalReturnables => _proposalReturnables;
  List<Map<String, dynamic>> _workDivisionTypes = [];
  List<Map<String, dynamic>> get workDivisionTypes => _workDivisionTypes;
  List<Map<String, dynamic>> _aimOfSubContract = [];
  List<Map<String, dynamic>> get aimOfSubContract => _aimOfSubContract;
  List<Map<String, dynamic>> _proposalOrProject = [];
  List<Map<String, dynamic>> get proposalOrProject => _proposalOrProject;
  List<Map<String, dynamic>> _engineeringReviews = [];
  List<Map<String, dynamic>> get engineeringReviews => _engineeringReviews;
  List<Map<String, dynamic>> _meetings = [];
  List<Map<String, dynamic>> get meetings => _meetings;
  List<Map<String, dynamic>> _roleLevels = [];
  List<Map<String, dynamic>> get roleLevels => _roleLevels;
  List<Map<String, dynamic>> _workShareOffices = [];
  List<Map<String, dynamic>> get workShareOffices => _workShareOffices;
  List<Map<String, dynamic>> _actionStatusCodes = [];
  List<Map<String, dynamic>> get actionStatusCodes => _actionStatusCodes;


  Future<void> allCodeListsCodes(int applicationID, BuildContext context) async {
    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/api/CodeListByApplicationID/applciationID?applicationID=$applicationID&eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as List;
        _allCodeLists = List<Map<String, dynamic>>.from(data);
        _projectPhase = _allCodeLists.where((codelist) => codelist['codeListID'] == 11).toList();
        _contractingStrategy = _allCodeLists.where((codelist) => codelist['codeListID'] == 15).toList();
        _packageType = _allCodeLists.where((codelist) => codelist['codeListID'] == 16).toList();
        _proposalReturnables = _allCodeLists.where((codelist) => codelist['codeListID'] == 17).toList();
        _workDivisionTypes = _allCodeLists.where((codelist) => codelist['codeListID'] == 18).toList();
        _aimOfSubContract = _allCodeLists.where((codelist) => codelist['codeListID'] == 19).toList();
        _proposalOrProject = _allCodeLists.where((codelist) => codelist['codeListID'] == 20).toList();
        _engineeringReviews = _allCodeLists.where((codelist) => codelist['codeListID'] == 21).toList();
        _meetings = _allCodeLists.where((codelist) => codelist['codeListID'] == 22).toList();
        _roleLevels = _allCodeLists.where((codelist) => codelist['codeListID'] == 23).toList();
        _workShareOffices = _allCodeLists.where((codelist) => codelist['codeListID'] == 24).toList();
        _actionStatusCodes = _allCodeLists.where((codelist) => codelist['codeListID'] == 8).toList();
        notifyListeners();
      } else if (response.statusCode == 401) {
        await userKeyExpired(context: context);
      } else {
        // Handle other errors
        String errorMsg = 'Failed to load enums';
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          errorMsg = errorData['message'] ?? errorMsg;
        } catch (_) {}
        snackbar(
          context: context,
          header: errorMsg,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

//-----------------------------------------------------------------------------
// Select a Project Phase
  Map<String, dynamic> _selectedProjectPhase = {};
  Map<String, dynamic> get selectedProjectPhase => _selectedProjectPhase;

  void selectProjectPhase(Map<String, dynamic> phase) {
    _selectedProjectPhase = phase;
    notifyListeners();
  }

  //-----------------------------------------------------------------------------
  // Clear selected Project Phase
  void clearSelectedProjectPhase() {
    _selectedProjectPhase = {};
    notifyListeners();
  }
}