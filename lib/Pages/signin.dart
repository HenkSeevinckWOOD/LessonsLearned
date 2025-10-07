import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woodproposals/Pages/home.dart';
import 'package:woodproposals/Pages/signup.dart';
import 'package:woodproposals/Provider/formstate_management.dart';
import 'package:woodproposals/Provider/user_login_provider.dart';
import 'package:woodproposals/Utilities/globalvariables.dart';
import 'package:woodproposals/Widgets/widgets.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class EmailValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
}

class _SigninState extends State<Signin> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> signInDetails = {};
  late bool _loading;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: "");
    _passwordController = TextEditingController(text: "");
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get Provider Variables
    final localAppTheme = ResponsiveTheme(context).theme;
    final userLoginProvider = Provider.of<UserLoginProvider>(context, listen: false);
    final formStatusProvider = Provider.of<FormStatusProvider>(context, listen: false);
  
    return Scaffold(
      body: Column(
        children: [
          pageHeader(
            context: context,
            topText: '',
            bottomText: '',
            ),
          const Expanded(child: SizedBox()),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  width: 700,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            header1(
                              header: 'SIGN-IN',
                              context: context,
                              color: localAppTheme['anchorColors']['primaryColor'],
                            ),
                            header3(
                              header: 'with your WOOD PLC email to use the application:',
                              context: context,
                              color: localAppTheme['anchorColors']['primaryColor'],
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: 700,
                              child: formInputField(
                                label: 'EMAIL',
                                errorMessage: 'Please enter a valid Email',
                                controller: _emailController,
                                isMultiline: false,
                                isPassword: false,
                                prefixIcon: Icons.person,
                                suffixIcon: null,
                                showLabel: true,
                                context: context,
                                initialValue: null,
                                enabled: true,
                                validator: EmailValidator.validate,
                                onChanged: (value){
                                  signInDetails['email'] = value;
                                  },
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: 700,
                              child: formInputField(
                                label: 'FOUR DIGIT PIN',
                                errorMessage: '',
                                controller: _passwordController,
                                isMultiline: false,
                                isPassword: true,
                                prefixIcon: Icons.password_rounded,
                                suffixIcon: null,
                                showLabel: true,
                                context: context,
                                initialValue: null,
                                enabled: true,
                                onChanged: (value){
                                  signInDetails['password'] = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter you 4 digit PIN';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: 700,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      formStatusProvider.signUpFormStatus = 'reset';
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Signup()));
                                    },
                                    child: header3(
                                      header: 'Forgot PIN?',
                                      context: context,
                                      color: localAppTheme['anchorColors']['primaryColor'],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: 700,
                              height: 50,
                              child: elevatedButton(
                                label: 'SIGN-IN',
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {_loading = true;});
                                    try {
                                      await userLoginProvider.fetchUserKey(signInDetails);
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
                                      setState(() {_loading = false;});
                                    } catch (e) {
                                      snackbar(
                                        context: context,
                                        header: e.toString(),
                                      );
                                    }
                                    setState(() {_loading = false;});
                                  }
                                },
                                backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                                labelColor: localAppTheme['anchorColors']['secondaryColor'],
                                leadingIcon: null,
                                trailingIcon: null,
                                context: context,
                              ),
                            ),
                            SizedBox(
                              width: 700,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      formStatusProvider.signUpFormStatus = 'signup';
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Signup()));
                                    },
                                    child: header3(
                                      header: 'I dont have an account?',
                                      context: context,
                                      color: localAppTheme['anchorColors']['primaryColor'],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          const Expanded(child: SizedBox()),
          pageFooter(context: context, userRole: null),
        ],
      ),
    );
  }
}