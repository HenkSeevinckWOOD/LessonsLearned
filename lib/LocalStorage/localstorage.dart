// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

class LocalStorageService {
  static const String _userKey = 'userKey';
  static const String _userID = 'userID';
  static const String _userName = 'userName';

  // Save userKey to local storage
  static void saveUserKey(String userKey) {
    html.window.localStorage[_userKey] = userKey;
  }

  // Retrieve userKey from local storage
  static String? getUserKey() {
    return html.window.localStorage[_userKey];
  }

  // Remove userKey from local storage
  static void removeUserKey() {
    html.window.localStorage.remove(_userKey);
  }

  // Save userID to local storage
    static void saveUserID(String userID) {
    html.window.localStorage[_userID ] = userID;
  }

  // Retrieve userID from local storage
  static String? getUserID() {
    return html.window.localStorage[_userID];
  }

  // Remove userID from local storage
  static void removeUserID() {
    html.window.localStorage.remove(_userID);
  }

    // Save userName to local storage
    static void saveUserName(String userName) {
    html.window.localStorage[_userName] = userName;
  }

  // Retrieve userName from local storage
  static String? getUserName() {
    return html.window.localStorage[_userName];
  }

  // Remove userName from local storage
  static void removeUserName() {
    html.window.localStorage.remove(_userName);
  }
}