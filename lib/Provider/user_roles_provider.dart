import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../LocalStorage/localstorage.dart';
import 'SubFunctions/userkeyexpired.dart';
import 'application_role_provider.dart';
import 'user_information_provider.dart';
import '../Widgets/widgets.dart';

class UserRoleProvider with ChangeNotifier {
  List<Map<String, dynamic>> _userRoles = [];
  List<Map<String, dynamic>> get userRoles => _userRoles;

//-----------------------------------------------------------------------------
// Get User Roles

  Future<void> fetchUserRoles(int applicationID, BuildContext context) async {
    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/api/UserProjectRole?eid=${LocalStorageService.getUserID()!}&applicationID=$applicationID&userKey=${LocalStorageService.getUserKey()!}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as List;
        _userRoles = List<Map<String, dynamic>>.from(data).map((role) {
          return role;
        }). toList();
        notifyListeners();
      } else if (response.statusCode == 401) {
          await userKeyExpired(context: context);
        } else {
          // Handle other errors
          String errorMsg = 'Failed to load employee roles';
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
//Get Proposal Team
  List<Map<String, dynamic>> _proposalTeam = [];
  List<Map<String, dynamic>> get proposalTeam => _proposalTeam;

  Future<void> fetchProposalTeam(
    int projectID, 
    int applicationID, 
    BuildContext context, 
    AllEmployeeProvider allEmployeeProvider, 
    ApplicationRoleProvider applicationRoleProvider,
    ) async {
    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/api/UserProjectRole/ProjectID?projectID=$projectID&eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as List;
        _proposalTeam = List<Map<String, dynamic>>.from(data)
            .where((role) =>
                role['applicationID'] == applicationID &&
                role['applicationRoleID'] != 1)
            .map((role) {
          final employee = allEmployeeProvider.allEmployees.firstWhere(
              (emp) => emp['eid'] == role['eid'],
              orElse: () => <String, dynamic>{});
          final roleDescription = applicationRoleProvider.applicationRoles.firstWhere(
              (member) => member['applicationRoleID'] == role['applicationRoleID'],
              orElse: () => <String, dynamic>{});
          return {...role, 'nameSurname': employee['nameSurname'] ?? 'Unknown User', 'roleDescription': roleDescription['roleDescription'] ?? 'Unknown Role'};
        }).toList();
        _createEditableCopy(); // Initialize the editable copy
        notifyListeners(); // This notifies listeners of changes to both _proposalTeam and _editableProposalTeam
      } else if (response.statusCode == 401) {
          await userKeyExpired(context: context);
        } else {
          // Handle other errors
          String errorMsg = 'Failed to load proposal Team';
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
// Manage Proposal Team Members
  Future<void> manageProposalTeamMembers(List<Map<String, dynamic>> members) async {
    // Iterate over a copy of the list to avoid concurrent modification errors.
    for (var member in List.from(members)) {
      if (member['isDirty'] == true && member['userRolesID'] == null) {
        addProposalTeamMember(member);
      }
    }
  }


//-----------------------------------------------------------------------------
// Add Proposal Team Member
  Future<void> addProposalTeamMember(Map<String, dynamic> newMember) async {
    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/api/UserProjectRole?eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}');
    try {
      final response = await http.post(
        url,
        body: json.encode(newMember),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'}
      );
      if (response.statusCode == 201) {
        // The API returns the newly created object, including its new ID.
      final createdMember = json.decode(response.body) as Map<String, dynamic>;

      // Add the new "clean" record to the main project disciplines list.
      _proposalTeam.add(createdMember);

      // Find the original "dirty" record in the editable list and replace it with the clean one.
      final index = _editableProposalTeam.indexWhere((d) => d['userRolesID'] == newMember['userRolesID'] && d['userRolesID'] == null);
      if (index != -1) {
        _editableProposalTeam[index] = createdMember;
      }

        notifyListeners();
      } else {
        throw Exception('Failed to add proposal team member');
      }
    } catch (e) {
      rethrow;
    }
  }

//-----------------------------------------------------------------------------
// Remove Proposal Team Member
  Future<void> removeProposalTeamMember(Map<String, dynamic> memberToRemove) async {
    var userRolesID = memberToRemove['userRolesID'];
    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/api/UserProjectRole/UserRoleID?userRoleID=$userRolesID&eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}');

    try {
      final response = await http.delete(
        url,
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'}
      );
      if (response.statusCode == 204) {
        // On success, remove the member from the local list.
        _proposalTeam.removeWhere((item) => item['userRolesID'] == userRolesID);
        _editableProposalTeam = List<Map<String, dynamic>>.from(_proposalTeam);
        notifyListeners();
      } else {
        throw Exception('Failed to remove proposal team member');
      }
    } catch (e) {
      rethrow;
    }
  }

//-----------------------------------------------------------------------------
// Make Editable Copy

  List<Map<String, dynamic>> _editableProposalTeam = [];
  List<Map<String, dynamic>> get editableProposalTeam => _editableProposalTeam;

  void _createEditableCopy() {
    // This creates a deep copy. It makes a new List, and for each element (which is a Map),
    // it creates a new Map from the original. This is safe because the map values are primitives.
    _editableProposalTeam = _proposalTeam.map((member) => Map<String, dynamic>.from(member)).toList();
  }

//-----------------------------------------------------------------------------
// Reset Editable Copy

  /// Resets the editable proposal team list to match the original `_proposalTeam`.
  /// Call this method when you want to discard any user-made changes to the list.
  void resetEditableProposalTeam() {
    _createEditableCopy();
    notifyListeners();
  }

//-----------------------------------------------------------------------------
// Select Role

  Map<String, dynamic>? _selectedRole;
  Map<String, dynamic>? get selectedRole => _selectedRole;
  
  void selectedRoleByID(Map<String, dynamic> role) {
    _selectedRole = role;
    notifyListeners();
  }
}