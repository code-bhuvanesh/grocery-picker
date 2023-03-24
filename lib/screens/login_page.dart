import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_picker/screens/buyer_screens/buyer_main_page.dart';
import 'package:grocery_picker/screens/splash_screen.dart';
import 'package:grocery_picker/widgets/custom_button.dart';

import '../widgets/login_input_field.dart';
import '../widgets/toggle_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static const routeName = "/loginPage";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var isLoginstate = true;

  var btnText = " Login ";

  final emailTextController = TextEditingController();
  final usernameTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  late StreamSubscription<User?> _listener;

  void onToggle(String state) {
    setState(() {
      btnText = state;
      if (state == "Signup") {
        isLoginstate = false;
      } else {
        isLoginstate = true;
      }
    });
  }

  Future<void> firebaseLogin() async {
    if (emailTextController.text.isNotEmpty &&
        passwordTextController.text.isNotEmpty) {
      try {
        loginProgress = true;
        var userCredentials = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailTextController.text,
                password: passwordTextController.text);
        var user = userCredentials.user;
        debugPrint(user?.uid);
        _listener =
            FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user == null) {
            debugPrint('User is currently signed out!');
            loginProgress = false;
          } else {
            debugPrint('User is signed in!');
            Navigator.popAndPushNamed(context, SplashScreen.routeName);
          }
        });
      } on FirebaseAuthException catch (e) {
        loginProgress = false;
        debugPrint(e.code);
        var error = "";
        if (e.code == 'invalid-email') {
          error = 'email entered not found!';
        } else if (e.code == 'wrong-password') {
          error = 'entered password is wrong!';
        }
        Fluttertoast.showToast(
            msg: error,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Color.fromARGB(255, 54, 54, 54),
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      } catch (e) {
        loginProgress = false;
        debugPrint(e.toString());
      }
    }
  }

  Future<void> firebaseSignup() async {
    if (emailTextController.text.isNotEmpty &&
        passwordTextController.text.isNotEmpty &&
        usernameTextController.text.isNotEmpty) {
      try {
        loginProgress = true;
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text,
        );
        _listener =
            FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user == null) {
            debugPrint('User is currently signed out!');
          } else {
            debugPrint('User is signed in!');
            user.updateDisplayName(usernameTextController.text);
            Navigator.popAndPushNamed(context, SplashScreen.routeName);
          }
        });
      } on FirebaseAuthException catch (e) {
        loginProgress = false;
        debugPrint("error : ... ${e.code}");
        var error = "";
        if (e.code == 'weak-password') {
          error = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          error = 'The account already exists for that email.';
        }
        if (error.isNotEmpty) {
          Fluttertoast.showToast(
              msg: error,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Color.fromARGB(255, 54, 54, 54),
              timeInSecForIosWeb: 1,
              fontSize: 16.0);
        }
      } catch (e) {
        loginProgress = false;
        debugPrint(e.toString());
      }
    }
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  var loginProgress = false;

  @override
  Widget build(BuildContext context) {
    var topPadding = AppBar().preferredSize.height + 50;
    return Scaffold(
      body: Stack(children: [
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // const Text(
                //   "Grocery\n        Picker",
                //   style: TextStyle(
                //       color: Colors.green,
                //       fontSize: 46,
                //       fontWeight: FontWeight.bold,
                //       fontFamily: "autumn_in_november"),
                // ),
                Image.asset("assets/images/splashScreen_background1.png"),
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        ToggleButton(onToggle: onToggle),
                        if (!isLoginstate)
                          AnimatedScale(
                              duration: Duration(seconds: 1),
                              scale: !isLoginstate ? 1 : 0,
                              child: CustomInputField(
                                hintText: 'username',
                                controller: usernameTextController,
                              )),
                        CustomInputField(
                          hintText: 'email',
                          controller: emailTextController,
                        ),
                        CustomInputField(
                          hintText: 'password',
                          controller: passwordTextController,
                          isPassword: true,
                        ),
                        CustomButton(
                          btnText: btnText,
                          onClick:
                              isLoginstate ? firebaseLogin : firebaseSignup,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        if (loginProgress)
          Container(
            child: Center(child: CircularProgressIndicator()),
          )
      ]),
    );
  }
}
