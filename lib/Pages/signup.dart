import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woodproposals/Pages/signin.dart';
import 'package:woodproposals/Provider/formstate_management.dart';
import 'package:woodproposals/Provider/user_login_provider.dart';
import 'package:woodproposals/Utilities/globalvariables.dart';
import 'package:woodproposals/Widgets/widgets.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class EmailValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email.';
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email.';
    }
    return null;
  }
}

class PasswordValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a 4 digit PIN.';
    }
    String pattern = r'^\d{4}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'PIN must be exactly 4 digits and contain only numbers.';
    }
    return null;
  }
}

class ConfirmPasswordValidator {
  static String? validate(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please re-enter your 4 digit PIN.';
    }
    if (value != originalPassword) {
      return 'PINs do not match.';
    }
    return null;
  }
}

class _SignupState extends State<Signup> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confimPasswordController;
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> signUpDetails = {};
  late bool _loading;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: "");
    _passwordController = TextEditingController(text: "");
    _confimPasswordController = TextEditingController(text: "");
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confimPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final createUserLoginDetailsProvider = Provider.of<CreateUserLoginDetailsProvider>(context, listen: false);
    final updateUserLoginInformationProvider = Provider.of<UpdateUserLoginInformationProvider>(context, listen: false);
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            header1(
                              header: formStatusProvider.signUpFormStatus == 'signup' ? 'SIGN-UP' : 'RESET PIN',
                              context: context,
                              color: localAppTheme['anchorColors']['primaryColor'],
                            ),
                            header3(
                              header: formStatusProvider.signUpFormStatus == 'signup' ? 'with you WOOD email to use the application:' : 'insert you WOOD email and new PIN:',
                              context: context,
                              color: localAppTheme['anchorColors']['primaryColor'],
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              //height: 200,
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
                                  signUpDetails['email'] = value;
                                  },
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              //height: 200,
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
                                validator: PasswordValidator.validate,
                                onChanged: (value){
                                  signUpDetails['password'] = value;
                                },
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              //height: 200,
                              width: 700,
                              child: formInputField(
                                label: 'CONFIRM FOUR DIGIT PIN',
                                errorMessage: '',
                                controller: _confimPasswordController,
                                isMultiline: false,
                                isPassword: true,
                                prefixIcon: Icons.password_rounded,
                                suffixIcon: null,
                                showLabel: true,
                                context: context,
                                initialValue: null,
                                enabled: true,
                                validator: (value) => ConfirmPasswordValidator.validate(value, _passwordController.text),
                                onChanged: null,
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: 700,
                              height: 50,
                              child: elevatedButton(
                                label: formStatusProvider.signUpFormStatus == 'signup' ? 'SIGN-UP' : 'RESET PIN',
                                onPressed: () async {
                                  setState(() {_loading = true;});
                                  if (_formKey.currentState!.validate()) {
                                    try{   
                                        if (formStatusProvider.signUpFormStatus == 'signup') {
                                        //Create Account go here
                                        await createUserLoginDetailsProvider.createUserLogin(signUpDetails);
                                        snackbar(
                                        context: context,
                                        header: 'Registered, please sign-in to use the application.',
                                        );
                                        await Future.delayed(const Duration(seconds: 1));
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Signin()));
                                        setState(() {_loading = false;});
                                        } else {
                                        //Reset Password go here
                                        await updateUserLoginInformationProvider.changeUserPassword(signUpDetails);
                                        snackbar(
                                        context: context,
                                        header: 'Password updated, please sign-in to use the application.',
                                        );
                                        await Future.delayed(const Duration(seconds: 1));
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Signin()));
                                        setState(() {_loading = false;});
                                        } 
                                    } catch (e){
                                      snackbar(
                                        context: context,
                                        header: e.toString(),
                                      );
                                    }
                                  }
                                  setState(() {_loading = false;});
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
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Signin()));
                                    },
                                    child: header3(
                                      header: 'I already have an account?',
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