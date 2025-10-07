import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../LocalStorage/localstorage.dart';
import 'SubFunctions/userkeyexpired.dart';
import '../Widgets/widgets.dart';

//--------------------------------------------------------------------------
//Employee by Email
class EmployeeInformationprovider with ChangeNotifier {
  Map<String, dynamic> _employeeInformation = {};
  Map<String, dynamic> get employeeInformation => _employeeInformation;

  Future fetchEmployeeInformation(String email) async {
    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/api/Employee/Email?email=$email&eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        _employeeInformation = data;
        notifyListeners();
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  void clearEmployeeInformation() {
    _employeeInformation = {};
    notifyListeners();
  }
}

//--------------------------------------------------------------------------
//All Employees
class AllEmployeeProvider with ChangeNotifier {
    List<Map<String, dynamic>> _allEmployees = [];
    List<Map<String, dynamic>> get allEmployees => _allEmployees;

    Future<void> fetchAllEmployee(BuildContext context) async {
    final url = Uri.parse("https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/api/Employee?eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as List;
        _allEmployees = data.map((employee) {
          employee['nameSurname'] = '${employee['preferredName']} ${employee['surname']}';
          return Map<String, dynamic>.from(employee);
        }).toList();
        notifyListeners();
      } else if (response.statusCode == 401) {
          await userKeyExpired(context: context);
        } else {
          // Handle other errors
          String errorMsg = 'Failed to load employees';
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

    //--------------------------------------------------------------------------
    //Get Current Logged in user
    Map<String, dynamic> _currentUser = {};
    Map<String, dynamic> get currentUser => _currentUser;

    Future<void> getCurrentUser(int userID) async {
      _currentUser = _allEmployees.firstWhere((user) => user['eid'] == userID, orElse: () => {});
      _currentUser['roleDescription'] = 'NO ROLE';
      notifyListeners();
    }

    //--------------------------------------------------------------------------
    //Clear All Employee List
    void clearAllEmployeeProvider() {
      _allEmployees = [];
      notifyListeners();
    }

    //--------------------------------------------------------------------------
    //Get Selected Employee
    Map<String, dynamic> _selectedEmployee = {};
    Map<String, dynamic> get selectedEmployee => _selectedEmployee;

    void selectEmployee(Map<String, dynamic> employee) {
      _selectedEmployee = employee;
      notifyListeners();
    }
}
