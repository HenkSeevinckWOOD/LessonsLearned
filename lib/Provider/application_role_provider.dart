import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../LocalStorage/localstorage.dart';

class ApplicationRoleProvider with ChangeNotifier {
  List<Map<String, dynamic>> _applicationRoles = [];
  List<Map<String, dynamic>> get applicationRoles => _applicationRoles;

  Future<void> fetchApplicationRoles(int applicationID) async {
    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/api/ApplicationRole/applicationID?applicationID=$applicationID&eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _applicationRoles = List<Map<String, dynamic>>.from(json.decode(response.body) as List);

        notifyListeners();
      } else {
        throw Exception('Failed to load employees');
      }
    } catch (e) {
      rethrow;
    }
  }
}