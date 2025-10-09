import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woodproposals/LocalStorage/localstorage.dart';
import 'package:woodproposals/Pages/home.dart';
import 'package:woodproposals/Pages/signin.dart';
import 'package:woodproposals/Provider/ai_textbox_reformat.dart';
import 'package:woodproposals/Provider/application_role_provider.dart';
import 'package:woodproposals/Provider/client_provider.dart';
import 'package:woodproposals/Provider/discipline_provider.dart';
import 'package:woodproposals/Provider/formstate_management.dart';
import 'package:woodproposals/Provider/lessons_learned_provider.dart';
import 'package:woodproposals/Provider/project_provider.dart';
import 'package:woodproposals/Provider/statuscode_provider.dart';
import 'package:woodproposals/Provider/user_information_provider.dart';
import 'package:woodproposals/Provider/user_login_provider.dart';
import 'package:woodproposals/Provider/user_roles_provider.dart';
import 'package:woodproposals/Utilities/globalvariables.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedUserKey = LocalStorageService.getUserKey();
  final savedUserID = LocalStorageService.getUserID();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppInfo>(create: (_) => AppInfo(appInfo)),
        ChangeNotifierProvider(create: (_) => CreateUserLoginDetailsProvider()),
        ChangeNotifierProvider(create: (_) => UpdateUserLoginInformationProvider()),
        ChangeNotifierProvider(create: (_) => UserLoginProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeInformationprovider()),
        ChangeNotifierProvider(create: (_) => AllEmployeeProvider()),
        ChangeNotifierProvider(create: (_) => FormStatusProvider()),
        ChangeNotifierProvider(create: (_) => CodeListsProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationRoleProvider()),
        ChangeNotifierProvider(create: (_) => UserRoleProvider()),
        ChangeNotifierProvider(create: (_) => AITextboxReformat()),
        ChangeNotifierProvider(create: (_) => Projectprovider()),
        ChangeNotifierProvider(create: (_) => DisciplineProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => LessonsLearnedProvider()),
      ],
      child: MyApp(savedUserKey: savedUserKey, savedUserID: savedUserID),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? savedUserKey;
  final String? savedUserID;
  const MyApp({super.key, required this.savedUserKey, required this.savedUserID});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: savedUserKey != null && savedUserID != null
      ? const Home()
      : const Signin()
    );
  }
}
