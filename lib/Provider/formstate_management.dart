import 'package:flutter/material.dart';
import 'package:woodproposals/Pages/SubFunctions/Landing/ChatWindow/chatwindowmain.dart';
import 'package:woodproposals/Pages/SubFunctions/Landing/ChatWindow/chatwindowside.dart';
import 'package:woodproposals/Pages/SubFunctions/Landing/LessonsLeardnedGrid/lessonslearnedgridmain.dart';
import 'package:woodproposals/Pages/SubFunctions/Landing/LessonsLeardnedGrid/lessonslearnedgridside.dart';


//Form Status Provider
class FormStatusProvider with ChangeNotifier {

  String pageToShow = 'landingPage';
  bool adminMode = false;
  Widget pageMainWidget = ChatWindowMain();
  Widget pageSideWidget = ChatWindowSide();
  String pageHeader = 'LANDING PAGE';
  int? selectedDeliverableGroup;
  String? chatSessionID;
  bool chatVisible = false;
  String? signUpFormStatus;
  List<Map<String, dynamic>> displayData = [
    {'pageTitle': 'landingPage', 'pageHeader':'LANDING PAGE','mainWidget': ChatWindowMain(),'sideWidget': ChatWindowSide(),'chatVisible': false},
    {'pageTitle': 'lessonslearnedgrid', 'pageHeader':'LESSONS LEARNED GRID','mainWidget': LessonsLearnedGridMain(),'sideWidget': LessonsLearnedGridSide(),'chatVisible': true},
  ];

  void setDisplayWidget(String pageToShow) {
    final initialPageData = displayData.firstWhere((page) => page['pageTitle'] == pageToShow);
    pageMainWidget = initialPageData['mainWidget'];
    pageSideWidget = initialPageData['sideWidget'];
    chatVisible = initialPageData['chatVisible'];
    pageHeader = initialPageData['pageHeader'];
    notifyListeners();
  }

  List<Map<String, dynamic>> llTypes = [
    {'typeID' : 1, 'type': 'Positive'}, 
    {'typeID' : 2, 'type': 'Negative'}
  ];

  void setAdminMode(bool status) {
    adminMode = status;
    notifyListeners();
  }

  /// Set the selected deliverable group to identify which widgets needs to be displayed for pages like Meetings & Reviews and Deliverables & Activities
  void setSelectedDeliverableGroup(int group) {
    selectedDeliverableGroup = group;
    notifyListeners();
  }

  void setPageToShow(String pageTitle) {
    pageToShow = pageTitle;
    notifyListeners();
  }

  void setChatSessionID(String sessionID) {
    chatSessionID = sessionID;
    notifyListeners();
  }
}

//Application Info
class AppInfo {
  final Map<String, dynamic> appInfo;
  AppInfo(this.appInfo);
}