import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../LocalStorage/localstorage.dart';

//HTTP GET
//-------------------------------------------------------------------------------------------------------------------
class UserLoginProvider with ChangeNotifier {
  Map<String, dynamic> _userKey = {};
  Map<String, dynamic> get userKey => _userKey;

  Future fetchUserKey(Map<String, dynamic> signInDetails) async {
    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/api/UserLogin/login');
     try {
      final response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(
          <String, dynamic>{
            'email': signInDetails['email'],
            'password': signInDetails['password'],
          },
        ),
      );
      //if (response.statusCode == 201 || response.statusCode == 200) {
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _userKey = data;
        LocalStorageService.saveUserID(data['eid'].toString());
        LocalStorageService.saveUserKey(data['userKey'].toString());
        notifyListeners();
      } else if (response.statusCode == 401) {
        final Map<String, dynamic> data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Unauthorized');
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
     } catch (e) {
       rethrow;
     }
  }
}

//HTTP POST
//-------------------------------------------------------------------------------------------------------------------
class CreateUserLoginDetailsProvider with ChangeNotifier {
  Map<String, dynamic> _userKey = {};
  Map<String, dynamic> get userKey => _userKey;

  Future createUserLogin(
    Map<String, dynamic> signUpDetails,
  ) async {
    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/api/UserLogin/register');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(
          <String, dynamic>{
            'email': signUpDetails['email'],
            'password': signUpDetails['password'],
          },
        ),
      );
      //if (response.statusCode == 201 || response.statusCode == 200) {
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _userKey = data;
        LocalStorageService.saveUserID(data['eid'].toString());
        LocalStorageService.saveUserKey(data['userKey'].toString());
        notifyListeners();
      } else if (response.statusCode == 401 || response.statusCode == 409) {
        final Map<String, dynamic> data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Registration Failed');
      } else {
        throw Exception('Failed to register: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

//HTTP PUT
//-------------------------------------------------------------------------------------------------------------------
class UpdateUserLoginInformationProvider with ChangeNotifier {
  Map<String, dynamic> _userKey = {};
  Map<String, dynamic> get userKey => _userKey;

  Future<void> changeUserPassword(
    Map<String, dynamic> userDetails,
  ) async {
    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/api/UserLogin/reset');
    try {
      final response = await http.put(
        url,
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(
          <String, dynamic>{
            'email': userDetails['email'],
            'password': userDetails['password'],
          },
        ),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _userKey = data;
        LocalStorageService.saveUserID(data['eid'].toString());
        LocalStorageService.saveUserKey(data['userKey'].toString());
        notifyListeners();
      } else if (response.statusCode == 404) {
        final Map<String, dynamic> data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Password change Failed');
      } else {
        throw Exception('Failed to change the password: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}