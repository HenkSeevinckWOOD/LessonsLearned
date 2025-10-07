import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../LocalStorage/localstorage.dart';

class ClientProvider with ChangeNotifier {
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> get clients => _clients;

  Future<void> fetchClients() async {
    final url = Uri.parse('https://dailydiary.woodplc.com/DesignAssuranceUserLoginAPI/clients/AllClients?eid=${LocalStorageService.getUserID()!}&userKey=${LocalStorageService.getUserKey()!}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _clients = List<Map<String, dynamic>>.from(json.decode(response.body) as List);

        notifyListeners();
      } else {
        throw Exception('Failed to load clients');
      }
    } catch (e) {
      rethrow;
    }
  }
}