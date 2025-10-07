import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woodproposals/LocalStorage/localstorage.dart';
import 'package:woodproposals/Pages/signin.dart';
import 'package:woodproposals/Provider/formstate_management.dart';
import 'package:woodproposals/Provider/user_information_provider.dart';
import 'package:woodproposals/Utilities/globalvariables.dart';
import 'package:woodproposals/Widgets/widgets.dart';

class ChatWindowSide extends StatefulWidget {
  const ChatWindowSide({super.key});

  @override
  State<ChatWindowSide> createState() => _ChatWindowSideState();
}

class _ChatWindowSideState extends State<ChatWindowSide> {
  @override
  Widget build(BuildContext context) {
    
    final localAppTheme = ResponsiveTheme(context).theme;
    final employeeInfoProvider = Provider.of<EmployeeInformationprovider>(context, listen: false);
    final formStatusProvider = Provider.of<FormStatusProvider>(context, listen: false);
    return Column(
      children: [
        const SizedBox(height: 15),
        header3(header: 'MENU:', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
        const SizedBox(height: 5),
        Divider(color: localAppTheme['anchorColors']['secondaryColor']),
        Visibility(
          visible: true, //TO DO: Implement visibility logic
          child: ListTile(
            leading: Icon(Icons.stacked_bar_chart, color: localAppTheme['anchorColors']['secondaryColor']),
            title: body(header: 'LESSONS LEARNED GRID:', color: localAppTheme['anchorColors']['secondaryColor'], context: context),
            onTap: () {
              formStatusProvider.setDisplayWidget('lessonslearnedgrid');
            },
          ),
        ),
        Expanded(child: SizedBox()),
        Divider(color: localAppTheme['anchorColors']['secondaryColor']),
        ListTile(
          leading: Icon(Icons.logout, color: localAppTheme['anchorColors']['secondaryColor']),
          title: Center(child: body(header: 'SIGN OUT:', color: localAppTheme['anchorColors']['secondaryColor'], context: context)),
          onTap: () {
            employeeInfoProvider.clearEmployeeInformation();
            //userLoginInformation.clearFetchedUserLoginInformation();
            LocalStorageService.removeUserID();
            LocalStorageService.removeUserKey();
            LocalStorageService.removeUserName();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Signin()));
          },
        ),
        SizedBox(height: 7)
      ],
    );
  }
}